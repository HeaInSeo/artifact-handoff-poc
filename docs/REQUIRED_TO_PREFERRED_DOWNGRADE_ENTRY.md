# U8 - Required-To-Preferred Downgrade Entry

## 1. Sprint Question

`U7` fixed the primary fallback-trigger candidate for the current same-node-required path as:

- `PodScheduled=False, Unschedulable`

The next question is what that trigger should actually cause the runtime to do.

This sprint asks one direct question.

- Under what conditions should the current `same-node required` path be downgraded into `preferred locality` or a more remote-capable path?

This document adds no new implementation.
It fixes the downgrade entry from the current API-level placement truth and the `U7` trigger criteria.

## 2. Current Truth That Must Stay Fixed

The current implementation truth is:

1. the child `RunSpec` is mutated right before submit
2. `spec.Placement.NodeSelector["kubernetes.io/hostname"] = producerNode`
3. that value becomes a required `nodeSelector` in the Job Pod spec
4. the current runtime has no second submit path

So today the system only does this:

- inject required same-node
- stop there

There is still no downgrade path in the runtime itself.
That is why this sprint is not saying “downgrade already exists.”
It is only fixing when downgrade should be allowed.

## 3. Why Downgrade Is Needed As A Question

Required locality is still the most accurate reading of the current implementation,
but keeping that requirement forever may not match the product goal in every case.

It can become too strong when:

- the producer node is unavailable
- the scheduler cannot place the child because of the node selector
- the artifact is still reachable through a remote path
- pipeline progress matters more than preserving strict same-node locality

So the downgrade question is not “same-node was wrong.”
It is “when should same-node-required be lowered into a progress-preserving policy.”

## 4. Misreadings This Sprint Rejects

### A. If the pod is unschedulable, should it always jump straight to remote execution?

Not yet.

`Unschedulable` can still have multiple meanings.
The project needs the narrower case where lowering the current same-node requirement still preserves the artifact semantics.

### B. Does downgrade simply mean “allow any node”?

No.

Downgrade should be read in at least two layers:

1. same-node required -> same-node preferred
2. same-node preferred -> remote-capable target resolution

So downgrade does not automatically mean throwing away locality policy.

## 5. Minimum Downgrade Conditions Fixed In This Sprint

The minimum conditions fixed here are:

### A. preconditions for allowing downgrade

Downgrade can be opened only when all of the following are true:

1. the same-node-required failure signal is confirmed through an API-level observable
2. that failure is separated as a placement/scheduling failure rather than an application-command failure
3. the artifact-consume semantics are not a hard same-node semantic requirement
4. a remote-capable path is allowed by the product semantics

So downgrade is not just a reaction to failure.
It requires confidence that lowering locality does not violate the artifact contract.

### B. cases where downgrade should still stay closed

The following remain closed for downgrade at this stage:

1. same-node itself is the semantic requirement
2. remote-path artifact consistency or availability is still not assured
3. the failure comes from container/app execution rather than placement
4. the cluster only shows admission pressure (`kueue_pending`)

## 6. Downgrade Direction Fixed In This Sprint

This sprint does not yet fix the concrete implementation path,
but it does fix the direction.

### A. first downgrade direction

- `required same-node`
  ->
- `preferred same-node`

The default direction is to lower the strong selector first.

### B. second downgrade direction

- `preferred same-node`
  ->
- `remote-capable placement resolution`

The broader path that reads recorded replicas, remote-ok policy, or producer/replica ordering should be treated as the next stage after the first downgrade.

## 7. Entry Judgments Fixed In This Sprint

This sprint fixes the following entry judgments.

1. the current path still implements only required locality
2. downgrade should be considered only after a placement-failure signal such as `Unschedulable`
3. the first downgrade step is `required -> preferred`, not immediate policy collapse
4. the remote-capable path should be read as the next resolution stage after preferred locality

## 8. Next Direct Follow-Up

`U9 - K8s Observable Integration Validation` is the right next step.

The next need is not more downgrade philosophy.
It is to fix how `K8sObserver.ObservePod()` and `ObserveWorkload()` should actually connect into the current fallback-judgment path.
