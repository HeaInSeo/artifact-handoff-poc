# U9 - K8s Observable Integration Validation

## 1. Sprint Question

`U7` fixed the primary fallback-trigger candidate for the current same-node-required path as:

- `PodScheduled=False, Unschedulable`

And `U8` fixed that downgrade should be read as:

- `required -> preferred -> remote-capable resolution`

The remaining direct question is this:

- How should `K8sObserver.ObservePod()` and `ObserveWorkload()` be connected into the current fallback-judgment path?

This document adds no new implementation.
It fixes the integration-validation criteria from the current code path and observable model.

## 2. The Current Separation Shown By The Code

The current structure already has two paths, but they are not yet wired together.

### A. main execution path

- `SpawnerNode.RunE()`
- `DriverK8s.Prepare()`
- `DriverK8s.Start()`
- `DriverK8s.Wait()`

This is the current main path.
But `Wait()` only sees terminal states such as `JobComplete` and `JobFailed`.

### B. observable path

- `K8sObserver.ObserveWorkload()`
- `K8sObserver.ObservePod()`
- `poc/pkg/observe/pipeline_status.go`

That path already separates:

- `kueue_pending`
- `scheduler_unschedulable`

So the observation path already exists,
but its result is not yet wired into the current fallback-judgment logic.

## 3. Misreadings This Sprint Rejects

### A. Should the observer just be merged directly into `Wait()`?

Not at this stage.

`Wait()` currently returns terminal events.
If pre-terminal scheduling/admission observation is mixed into it too early,
these concerns collapse together:

- terminal result
- fallback trigger
- operator observability

At the current documentation level, it is better to fix what should be read where before collapsing them into one function.

### B. Is the observer path only for operators and not for runtime judgment?

No.

`U7` already fixed that the fallback trigger should be read from API-level observables.
That means the observer path is not just operator-only.
It should be treated as a future input to fallback judgment.

But it still does not mean it should be merged into `Wait()` immediately.

## 4. Integration Direction Fixed In This Sprint

The minimum direction fixed here is:

### A. keep the role split

- `DriverK8s.Wait()`
  - terminal state path
- `K8sObserver`
  - pre-terminal admission / scheduling path

So rather than collapsing them into one function now,
the safer direction is to keep the role split and let a fallback-judgment layer read both signals.

### B. the fallback-judgment layer should read the observer

The current same-node-required path needs:

1. `ObservePod()` to confirm `scheduler_unschedulable`
2. `ObserveWorkload()` when needed to separate that from `kueue_pending`
3. those results to be read together with the current Job spec and annotations to decide whether the failure is a locality failure

So the integration question is not really “where do we plug in the observer.”
It is “who reads the observer result as fallback-judgment input.”

### C. the most natural integration point, for now

At the current documentation level,
it is more correct to let a separate fallback-judgment or resolution layer read the observer,
rather than wiring it directly into `SpawnerNode.RunE()`.

Why:

- `RunE()` is the submit-and-wait execution path
- the observer is the pre-terminal diagnosis path
- downgrade and resubmit judgment should sit above that as a policy step

## 5. Minimum Integration Criteria Fixed In This Sprint

The minimum criteria fixed here are:

1. `Wait()` remains the terminal-result path
2. fallback-trigger judgment reads from pre-terminal observables such as `ObservePod()` and `ObserveWorkload()`
3. `scheduler_unschedulable` and `kueue_pending` must never be collapsed into one signal
4. the observer result should not be read alone; it should be interpreted together with the current Job `nodeSelector` and `producer-node` annotation

So observer integration is not just wiring.
It is a judgment path that reads:

- observable signal
- current placement intent

together.

## 6. Judgments Fixed By This Sprint

This sprint fixes the following.

1. the current fallback judgment should read the observer path separately rather than extending `Wait()` directly
2. `ObservePod()` is the primary trigger input, while `ObserveWorkload()` is a supporting separation input
3. the responsibility for integration should sit in a future fallback-judgment layer, not in the execution driver itself

## 7. Next Direct Follow-Up

`U10 - Remote-Capable Resolution Entry` is the right next step.

The observable-integration boundary is now narrowed.
The next step is to fix what policy inputs should open the remote-capable resolution path after downgrade, including where producer / replica / remote-ok semantics should be read.
