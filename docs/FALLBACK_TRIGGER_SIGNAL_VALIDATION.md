# U7 - Fallback Trigger Signal Validation

## 1. Sprint Question

`U6` fixed that the current implementation truth is `same-node required`.
The next question is what should count as proof that this required path has actually failed.

This sprint asks one direct question.

- What observable signal should be read as the fallback trigger for the same-node-required path?

This document adds no new implementation.
It fixes the next validation criteria from the current code and the observable model already in place.

## 2. First Premise To Fix

The current dynamic placement already happens at the API level.

Actual path:

1. `SpawnerNode.RunE()` mutates the child `RunSpec` right before submit
2. `spec.Placement.NodeSelector["kubernetes.io/hostname"] = producerNode`
3. `DriverK8s.buildJob()` translates that into the Job Pod spec `nodeSelector`
4. `DriverK8s.Start()` submits it through the Kubernetes `Jobs.Create()` API

So the same-node requirement itself lives in an API object.
That means the fallback trigger should also be read from API-level observables, not from a later data-plane symptom.

## 3. Observable Paths Already Visible In The Current Code

The current `spawner` and `poc` code already split observation into two paths.

### A. Job completion path

- `DriverK8s.Wait()`
- observed states: `JobComplete`, `JobFailed`

This path sees only terminal state.
That is too late for fallback-trigger purposes.
If fallback starts here, “same-node scheduling failed” gets mixed with “the container ran and later failed.”

### B. pre-terminal observation path

- `K8sObserver.ObserveWorkload()`
- `K8sObserver.ObservePod()`

And `poc/pkg/observe/pipeline_status.go` already separates these into:

- `kueue_pending`
- `scheduler_unschedulable`

That split is directly relevant to the current question.

## 4. Misreadings This Sprint Rejects

### A. Is `JobFailed` enough as the fallback trigger?

No.

`JobFailed` is too late and too broad.
It can collapse:

- nodeSelector mismatch
- image pull failure
- command failure
- artifact-processing failure

But the current question is narrower:

- did the same-node-required path fail at scheduling time?

### B. Is `kueue_pending` also a fallback trigger?

As a default answer, no.

`kueue_pending` is a quota/admission-layer problem.
It is not a locality failure.

So for the current question:

- `kueue_pending` should not be the default fallback trigger
- the primary candidate should be `scheduler_unschedulable`

## 5. Fallback Trigger Candidate Fixed In This Sprint

The minimum judgment fixed here is:

### A. primary trigger candidate

- `PodScheduled=False`
- reason: `Unschedulable`
- message indicates node-selector mismatch or node-placement impossibility

This is the most direct signal.
The current same-node requirement is expressed through `nodeSelector`,
so the first place to observe its failure is the Pod scheduling condition.

### B. secondary supporting evidence

- Job annotation `producer-node`
- Job spec `nodeSelector`
- workload admission status when needed

These are supporting inputs for interpretation, not the trigger itself.

## 6. Exclusion Rules Fixed In This Sprint

The following are not treated as the default fallback trigger at the current stage.

1. `JobFailed`
- too terminal and too late

2. application-level artifact miss
- mixes scheduling failure with execution failure

3. `kueue_pending`
- quota/admission pressure, not locality failure

4. operator manual interpretation
- not a runtime-level trigger

## 7. Validation Criteria Fixed In This Sprint

The minimum criteria fixed here are:

1. the fallback trigger should be observable after submit but before terminal state when possible
2. because the current same-node requirement is expressed as `nodeSelector`, the first candidate signal is `PodScheduled=False, Unschedulable`
3. `kueue_pending` should be read separately as admission pressure rather than fallback trigger
4. `JobFailed` should be treated as a late result signal, not the fallback trigger

## 8. Judgments Fixed By This Sprint

This sprint fixes the following.

1. because dynamic placement now lands in the API object, the fallback trigger should also be read from API-level observables
2. the primary fallback-trigger candidate for the current same-node-required path is `PodScheduled=False, Unschedulable`
3. `kueue_pending` and `JobFailed` are not appropriate default fallback triggers

## 9. Next Direct Follow-Up

`U8 - Required-To-Preferred Downgrade Entry` is the right next step.

This sprint narrowed what should count as the trigger.
The next step is to fix, at entry level, under what conditions that trigger should downgrade the current required locality into preferred locality or a remote-capable path.
