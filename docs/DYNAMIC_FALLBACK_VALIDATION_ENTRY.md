# U5 - Dynamic Fallback Validation Entry

## 1. Sprint Question

`U3` already fixed the following on the remote Multipass K8s lab.

- child Jobs now read a parent result and receive explicit `nodeSelector` mutation
- that mutation reaches the real Job spec
- but the path is still the narrow form of `producer-pod-node -> required same-node`

This sprint asks one direct question.

- After explicit placement mutation, what exactly should dynamic fallback be validated as next?

This document does not broaden experimentation.
It fixes the next validation question from the real execution evidence and the current code path.

## 2. Actual Observations Behind This Entry

Basis 1. `U3` remote run result

- run: `dynplace-20260412-04`
- `a` Job `nodeSelector`: empty
- `b1`, `b2`, `b3`, `c` Job `nodeSelector`: all `{"kubernetes.io/hostname":"lab-worker-1"}`
- child Job annotations:
  - `poc.seoy.io/placement-source=producer-pod-node`
  - `poc.seoy.io/producer-node=lab-worker-1`

That means the current path does not merely “try same-node.”
It enforces same-node through a required selector.

Basis 2. current code path

The current `poc` mutator reads the parent pod node and mutates the child spec like this:

- `spec.Placement.NodeSelector["kubernetes.io/hostname"] = producerNode`

Then `spawner` translates that directly into the Job Pod spec `nodeSelector`.

So the current structure still does not have:

- preferred placement
- retry after same-node failure detection
- reinterpreting the child spec into a remote-ok path after same-node failure
- per-child fallback-state recording

## 3. Misreadings This Sprint Fixes

This entry first has to reject two wrong readings.

### A. Is fallback already present now?

No.

The current implementation reads the producer node before child submission
and immediately turns it into a required `nodeSelector`.
There is no “if this fails, move to another node” stage.

### B. If same-node is visible now, is fallback already close?

No.

Same-node success does not explain fallback semantics.
The fallback question closes only when the failure-transition condition is defined.

## 4. Minimum Fallback Question Fixed In This Sprint

The next direct validation question fixed here is:

- when same-node placement is injected into a child from a parent result, how should the runtime detect the point where that placement is impossible or no longer worth preserving, and how should it resubmit the child in a remote-capable form?

That question should be read in three parts.

1. trigger
- what state counts as same-node failure
- examples: unschedulable, node unavailable, locality mismatch, artifact missing

2. transition
- after that failure is detected, should the child be treated as a retry of the same Job
- or as a new submit cycle

3. target semantics
- does fallback mean “allow any node”
- or does it mean a separate placement resolution that reads recorded replicas / remote-ok policy

## 5. Scope Fixed In This Entry

This sprint directly covers only the following.

- separate the fallback question from the same-node success question
- fix that the current implementation only has the required-`nodeSelector` path
- define the next validation around trigger / transition / target semantics

This entry does not cover:

- actual fallback implementation
- retry/backoff policy
- scheduler/controller generalization
- replica-among-replica ordering

## 6. Minimum Questions The Next Validation Must Answer

The next direct validation must at least answer:

1. what observable signal means the same-node-required path has failed
2. whether that signal can be treated as a child-level fallback trigger
3. whether the fallback Job spec removes the required selector, downgrades it to preferred placement, or resolves a different remote target
4. whether the resulting behavior can be read as same-node-preferred / remote-fallback semantics

So the next validation is not “does same-node happen.”
It is “when same-node stops working, how does the runtime cross into the remote path.”

## 7. Judgments Fixed By This Sprint

This sprint fixes the following.

1. the current path now reaches dynamic placement, but still does not reach dynamic fallback
2. the current explicit `nodeSelector` is required locality, not preferred locality
3. therefore the next direct validation should open fallback trigger and fallback-resubmit semantics

## 8. Next Direct Follow-Up

`U6 - Same-Node Required vs Preferred Validation` is the right next step.

The project first needs to fix whether the current required selector should remain as-is
or be downgraded into preferred placement with a separate fallback mechanism.
Only after that can the real remote-fallback validation be designed cleanly.
