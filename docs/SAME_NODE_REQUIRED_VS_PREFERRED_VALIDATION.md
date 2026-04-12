# U6 - Same-Node Required vs Preferred Validation

## 1. Sprint Question

`U3` already showed that child Jobs now carry real `nodeSelector` mutation,
and `U5` fixed that the current path still implements only `same-node required`.

This sprint asks one direct question.

- Should the current explicit same-node placement be read as `required locality`, or is it already valid to read it as `preferred locality`?

This document does not broaden experimentation.
It fixes the validation criteria from the existing remote evidence and the current code path.

## 2. Actual Basis For This Judgment

Basis 1. remote `U3` run result

- child Jobs `b1`, `b2`, `b3`, and `c` carried real `nodeSelector={"kubernetes.io/hostname":"lab-worker-1"}`
- parent `a` did not
- child Job annotations preserved `placement-source=producer-pod-node`

So the child placement was not just “it happened to land on one node.”
It was the result of concrete selector mutation at submit time.

Basis 2. current code path

The current `poc` mutator does this:

- resolve the parent pod node
- set `spec.Placement.NodeSelector["kubernetes.io/hostname"] = producerNode`

The current `spawner` then translates that directly into the Job Pod spec `nodeSelector`.

The important point is:

- `nodeSelector` is not a hint
- it is a required constraint for scheduling
- the current path has no preferred-affinity or soft-locality branch

Basis 3. what the current path still does not have

The current structure still does not have:

- preferred node affinity
- a soft same-node-miss path that allows continuing on another node
- automatic downgrade after required-locality failure
- fallback resolution and retry policy

When the code path and the live run are read together,
there is still no basis for calling the current implementation `preferred`.

## 3. Why It Must Be Read As `Required` Right Now

The first judgment fixed in this sprint is:

- the current explicit same-node placement is `required locality`, not `preferred locality`

The reason is straightforward.

1. The real Job spec contains `nodeSelector`.
2. `nodeSelector` is not a soft rule that naturally spills over to another node when it cannot be satisfied.
3. The current runtime has no second submit path that relaxes that constraint.

So the current semantics should be read as:

- not “same-node if possible”
- but “the child should first be bound to the producer node”

## 4. Why It Must Not Be Prematurely Read As `Preferred`

This sprint also rejects one common misreading.

- Since the project direction is eventually same-node-preferred / remote-fallback, can the current implementation already be read as preferred?

No.

That reading would collapse three different things:

1. target semantics
- where the project wants to go

2. current implementation truth
- what the code actually does now

3. future fallback design
- the later downgrade / retry / remote-resolution path

What the documents have to fix right now is item 2.
Under item 2, the current implementation is still not `preferred`.

## 5. That Still Does Not Mean `Required` Is The Final Policy

The second judgment fixed here is:

- the current path must be read as `required locality`, but that does not automatically mean the final product policy should also be required same-node

These two statements are different.

- the current implementation uses a required same-node selector
- the product policy should permanently be required same-node

The first statement can be fixed now.
The second should still remain open.

That is because the project still has not validated:

- how much failure pressure a required selector creates in live operation
- whether preferred locality plus explicit fallback is the better fit
- which path better matches product-owned semantics under artifact miss / node unavailable conditions

## 6. Validation Criteria Fixed In This Sprint

The minimum criteria fixed here are:

### A. criteria for reading the path as `required`

The current path is `required locality` when all of these are true:

- a concrete `nodeSelector` is generated
- there is no alternate path that relaxes that selector
- there is no automatic remote continuation after failure

The current path satisfies all three.

### B. minimum criteria for reading a path as `preferred`

At least one of the following would need to exist before the path can be read as `preferred locality`:

- submit-time preferred affinity
- remote-capable resubmit after same-node miss
- explicit runtime downgrade of the same-node constraint
- child progress that remains semantically valid after same-node miss

The current path has none of these yet.

## 7. Judgments Fixed By This Sprint

This sprint fixes the following.

1. the current implementation truth is `same-node required`
2. that judgment is grounded in both the remote live result and the real `nodeSelector` path
3. this is still a current-validation reading, not a final policy commitment
4. therefore the next validation must separately check the downgrade conditions toward preferred locality and the fallback trigger

## 8. Next Direct Follow-Up

`U7 - Fallback Trigger Signal Validation` is the right next step.

The project now needs more than an abstract statement about lowering required to preferred.
It needs to fix whether an observable failure signal from the same-node-required path can be used as the fallback trigger.
