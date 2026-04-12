# U2 - Dynamic Placement Interface Cut

## 1. Sprint Question

`U1` already fixed the following through remote validation.

- the `poc-dynplace-20260412-01-a` Job had an empty `nodeSelector`
- the same Job also had an empty `affinity`
- `poc-dynplace-20260412-01-b1` had the same empty placement fields
- yet all Pods landed on `lab-worker-1`
- and the PVC annotation `volume.kubernetes.io/selected-node` was `lab-worker-1`

So the current same-node outcome is a storage-binding side effect, not explicit placement mutation.

That narrows this sprint down to one question:

- what is the minimum interface cut required to implement real parent-result-driven dynamic placement?

## 2. Actual Observations Used In This Sprint

This note is not based on abstract design only.
It is grounded in the remote Multipass Kubernetes lab on `100.123.80.48`, where the previous execution was re-checked.

Re-checked values:

- `kubectl get job poc-dynplace-20260412-01-a -o jsonpath='{.spec.template.spec.nodeSelector}'`
  - result: empty
- `kubectl get job poc-dynplace-20260412-01-a -o jsonpath='{.spec.template.spec.affinity}'`
  - result: empty
- `kubectl get job poc-dynplace-20260412-01-b1 -o jsonpath='{.spec.template.spec.nodeSelector}'`
  - result: empty
- `kubectl get job poc-dynplace-20260412-01-b1 -o jsonpath='{.spec.template.spec.affinity}'`
  - result: empty
- `kubectl get pods -o wide`
  - `a`, `b1`, `b2`, `b3`, `c` all on `lab-worker-1`
- `kubectl get pvc poc-shared-pvc -o jsonpath='{.metadata.annotations.volume\.kubernetes\.io/selected-node}'`
  - result: `lab-worker-1`

The meaning is straightforward.

- the runtime did not write placement
- storage pulled the Pods onto the same node

So the next step is not another vague same-node check.
It is to fix an interface that makes the placement writer explicit.

## 3. Why Direct `RunSpec` Expansion Is Not Enough

The current `RunSpec` is still execution-facing:

- `ImageRef`
- `Command`
- `Env`
- `Labels`
- `Annotations`
- `Mounts`
- `Resources`

Fields such as `producerNode`, `replicaNodes`, artifact binding, and fallback policy are different in nature.
They are higher-level orchestration semantics, not low-level Kubernetes Job fields.

The `spawner` docs already point in the same direction.
[spawner/docs/SPAWNER_REINFORCEMENT_REVIEW.en.md](/opt/go/src/github.com/HeaInSeo/spawner/docs/SPAWNER_REINFORCEMENT_REVIEW.en.md:142) says it is better not to keep stuffing everything directly into `RunSpec`, and suggests a split such as:

- `RunSpec`: execution-facing fields
- `RunMeta` or `SubmitRequest`: higher-level orchestration/control fields

The dynamic-placement problem should follow the same principle.

## 4. Minimum Structures Fixed In This Sprint

### A. `ArtifactBinding`

This expresses which artifact the child should use for placement decisions.

Minimum fields:

- `ArtifactID`
- `ConsumeMode`
  - `same-node-preferred`
  - `remote-ok`
- `FallbackPolicy`
  - `same-node-only`
  - `same-node-then-remote`

### B. `PlacementIntent`

This expresses the placement direction the child wants after reading parent results.

Minimum fields:

- `Mode`
  - `none`
  - `co-locate-with-producer`
  - `co-locate-with-recorded-replica`
- `Required`
- `SourceArtifactID`

This layer still does not carry raw Kubernetes placement fields.
It is product-owned intent, not concrete Kubernetes translation.

### C. `ResolvedPlacement`

This is the concrete placement shape ready to be merged into the Job spec.

Minimum fields:

- `NodeSelector map[string]string`
- `RequiredNodeAffinity`
- `PreferredNodeAffinity`
- `Reason`

This should exist only as the output of a `PlacementResolver`.

## 5. Recommended Execution Flow

Current flow:

1. static `RunSpec` creation
2. `SpawnerNode.RunE()`
3. `Driver.Prepare()`
4. `buildJob()`

Recommended flow:

1. parent completes
2. artifact-handoff metadata becomes available
3. child `ArtifactBinding` is checked
4. `PlacementResolver.Resolve(binding, metadata)` runs
5. `ResolvedPlacement` is produced
6. the submit path merges `RunSpec + ResolvedPlacement`
7. the concrete Job spec is built

So the mutation point should be explicit and narrow right before child submission, not hidden as implicit logic inside `buildJob()`.

## 6. Alternatives Rejected In This Sprint

### A. Add `RunSpec.NodeSelector` / `RunSpec.Affinity` directly

Pros:

- simplest implementation path

Cons:

- mixes product-owned artifact semantics with Kubernetes concrete fields
- weakens the `poc` / `spawner` boundary

Sprint judgment:

- acceptable as a temporary shortcut
- not recommended as the main structure

### B. Hide mutation inside `SpawnerNode`

Pros:

- close to the current code shape

Cons:

- hides mutation inside node runtime behavior
- blurs the boundaries between catalog read, placement resolve, and Job translation again

Sprint judgment:

- acceptable as an experiment helper
- not recommended as the main structure

## 7. Core Cut Fixed In This Sprint

This sprint fixes the following minimum shape:

```text
Pipeline Node
  -> RunSpec
  -> ArtifactBinding[]
  -> PlacementIntent

Parent completes
  -> producerNode / replicaNodes available

PlacementResolver
  -> emits ResolvedPlacement

Submit path
  -> merges RunSpec + ResolvedPlacement
  -> builds concrete Job spec
```

Ownership should remain split like this:

- `artifact-handoff-poc`
  - `producerNode`, `replicaNodes`, ordering/fallback semantics
- `poc`
  - DAG readiness and node-to-node orchestration
- `spawner`
  - concrete Kubernetes Job translation and submission

## 8. What This Sprint Still Does Not Claim

- no code patch yet
- no actual `nodeSelector` injection yet
- no final `affinity` shape chosen yet
- no automated remote fallback yet
- no retry / recovery policy yet

So this sprint fixes where the interface should live.
It does not claim that the live path already uses it.

## 9. Next Direct Step

The next sprint should be `U3 - Parent-Result Placement Injection Validation`.

Its completion criteria should be:

1. read `producerNode` right before child submission
2. actually produce `ResolvedPlacement`
3. inject `nodeSelector` or `affinity` into the created Job spec
4. validate again on the remote Multipass Kubernetes lab that the same-node outcome now comes from explicit placement mutation rather than PVC side effects
