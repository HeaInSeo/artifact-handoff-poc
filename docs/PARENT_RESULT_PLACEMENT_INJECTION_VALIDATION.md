# U3 - Parent-Result Placement Injection Validation

## 1. Sprint Question

`U1` fixed the negative result that the current `poc` path did not perform dynamic placement on the remote lab,
and `U2` fixed the minimum interface cut as `ArtifactBinding + PlacementIntent + ResolvedPlacement`.

This sprint asks one direct question.

- Can we now say that a parent result is actually connected to child Job placement mutation?

This document is grounded only in live execution results, not abstract design.

## 2. Actual Changes Included In This Validation

This validation includes real code changes in two sibling repositories.

- `spawner`
  - added `Placement` and downward-API-style `EnvFieldRefs` to `RunSpec`
  - reflected `Placement.NodeSelector` into the generated Pod spec
- `poc`
  - added a submit-time `Mutate` hook to `SpawnerNode`
  - made child nodes (`b1`, `b2`, `b3`, `c`) resolve the actual parent `a` pod node and inject a `nodeSelector`

Upstream states used in this validation:

- `spawner` commit: `2f9930e`
- `poc` commit: `dd77eb6`

The key question is not “did same-node happen,” but “did explicit placement mutation actually land in the child Job spec.”

## 3. Remote Multipass K8s Lab Conditions

Execution environment:

- host: `100.123.80.48`
- user: `seoy`
- cluster: `lab-master-0`, `lab-worker-0`, `lab-worker-1`
- kubeconfig: `/opt/go/src/github.com/HeaInSeo/multipass-k8s-lab/kubeconfig`

Pipeline execution:

- repo: `/opt/go/src/github.com/HeaInSeo/poc`
- command:

```bash
KUBECONFIG=/opt/go/src/github.com/HeaInSeo/multipass-k8s-lab/kubeconfig \
/usr/local/go/bin/go run ./cmd/poc-pipeline --run-id dynplace-20260412-04
```

That run completed successfully on the remote lab.

## 4. Actual Observations

### A. The parent Job still had no explicit placement mutation

Observed after the run:

- `kubectl -n default get job poc-dynplace-20260412-04-a -o jsonpath='{.spec.template.spec.nodeSelector}'`
  - result: empty

So the parent `a` was still submitted without explicit placement, just like before.

### B. The child Jobs did have explicit placement mutation

Observed after the run:

- `kubectl -n default get job poc-dynplace-20260412-04-b1 -o jsonpath='{.spec.template.spec.nodeSelector}'`
  - result: `{"kubernetes.io/hostname":"lab-worker-1"}`
- `kubectl -n default get job poc-dynplace-20260412-04-b2 -o jsonpath='{.spec.template.spec.nodeSelector}'`
  - result: `{"kubernetes.io/hostname":"lab-worker-1"}`
- `kubectl -n default get job poc-dynplace-20260412-04-b3 -o jsonpath='{.spec.template.spec.nodeSelector}'`
  - result: `{"kubernetes.io/hostname":"lab-worker-1"}`
- `kubectl -n default get job poc-dynplace-20260412-04-c -o jsonpath='{.spec.template.spec.nodeSelector}'`
  - result: `{"kubernetes.io/hostname":"lab-worker-1"}`

So the submit-time mutation did propagate into the actual Job specs.

### C. The child Job metadata also recorded why the mutation happened

Observed after the run:

- `kubectl -n default get job poc-dynplace-20260412-04-b1 -o jsonpath='{.metadata.annotations}'`
  - result included:
    - `poc.seoy.io/placement-source=producer-pod-node`
    - `poc.seoy.io/producer-node=lab-worker-1`
- `kubectl -n default get job poc-dynplace-20260412-04-c -o jsonpath='{.metadata.annotations}'`
  - result included:
    - `poc.seoy.io/placement-source=producer-pod-node`
    - `poc.seoy.io/producer-node=lab-worker-1`

That means this run did not just “happen” to land on one node.
The Job metadata also preserved the reason for the placement.

### D. Actual pod placement outcome

`kubectl -n default get pods -o wide | grep dynplace-20260412-04` showed:

- `a`: `lab-worker-1`
- `b1`: `lab-worker-1`
- `b2`: `lab-worker-1`
- `b3`: `lab-worker-1`
- `c`: `lab-worker-1`

And the PVC annotation at the same time was:

- `volume.kubernetes.io/selected-node=lab-worker-1`

So the storage side effect still exists in this run.
But unlike `U1`, the child Job specs now also contain explicit placement mutation,
so the same-node outcome can no longer be read as only a PVC side effect.

## 5. What This Sprint Fixes

This sprint is enough to fix the following judgments.

1. The current `poc` path can now read a parent result and create explicit placement mutation before child submission.
2. That mutation reaches the real K8s Job spec through `nodeSelector`.
3. Therefore the `parent result -> child placement mutation` connection itself is now validated on the remote Multipass K8s lab.

But the following are still open.

1. This run only validates the narrow same-node path of `producer-pod-node -> child nodeSelector`.
2. It does not yet validate automatic cross-node fallback after same-node becomes impossible.
3. It does not yet prove that the controller/scheduler layer generalizes this in a fully product-owned way.

## 6. What This Changes In Project Meaning

This result removes an important ambiguity.

- `U1` conclusion:
  - the current path did not perform dynamic placement
  - the same-node result was a storage-binding side effect
- `U3` conclusion:
  - child Job mutation now exists explicitly
  - regardless of the same-node outcome, the Job spec now carries explicit placement intent

So the next question is no longer “does a dynamic connection exist at all.”
It is now “how should that dynamic connection extend into same-node-preferred and remote-fallback semantics.”

## 7. Next Direct Question

The next direct question should move into `dynamic fallback`.

The minimum next question is:

- when same-node placement is attempted first from a parent result, how should remote fallback be connected when that node is unavailable or the artifact locality no longer matches?

That makes `U5 - Dynamic Fallback Validation Entry` the right next step after this explicit placement-mutation validation.
