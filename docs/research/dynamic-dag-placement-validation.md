# Dynamic DAG Placement Validation

## 1. Research Question

- Does the current DAG execution path in `/opt/go/src/github.com/HeaInSeo/poc` dynamically change child Job placement after reading parent results?

Dynamic placement here does not mean that Pods merely happened to land on the same node. It must include all three of the following:

1. parent completion produces artifact/location metadata,
2. the runtime/controller reads that metadata right before child submission,
3. the child Job spec gets dynamic placement hints such as `nodeSelector` or `affinity`.

## 2. Summary

- The current `poc` path does **not** implement dynamic parent-result-driven placement.
- In the remote Multipass Kubernetes validation, the created Jobs had empty `nodeSelector` and `affinity`.
- The observed same-node outcome came from the `local-path` PVC being pinned to `lab-worker-1` via `selected-node`, not from the runtime reading parent artifact location and rewriting child Job placement.

So the current `poc` solves `when to run`, but not yet `where to run based on parent result`.

## 3. Local Code Evidence

### 3.1 `poc-pipeline` attaches static `RunSpec`s to DAG nodes

In [cmd/poc-pipeline/main.go](/opt/go/src/github.com/HeaInSeo/poc/cmd/poc-pipeline/main.go:126) through [cmd/poc-pipeline/main.go](/opt/go/src/github.com/HeaInSeo/poc/cmd/poc-pipeline/main.go:144), each node is given a prebuilt `api.RunSpec` through `adapter.SpawnerNode`.

- `poc-a` → `specA(...)`
- `poc-b1/b2/b3` → `specWorker(...)`
- `poc-c` → `specCollect(...)`

There is no step that reads parent results and rebuilds child specs.

### 3.2 `SpawnerNode` passes the static `Spec` through unchanged

In [pkg/adapter/spawner_node.go](/opt/go/src/github.com/HeaInSeo/poc/pkg/adapter/spawner_node.go:23) through [pkg/adapter/spawner_node.go](/opt/go/src/github.com/HeaInSeo/poc/pkg/adapter/spawner_node.go:41), `RunE()` passes `s.Spec` directly into `Driver.Prepare()`.

That means `dag-go` controls readiness, but there is no placement-rewrite hook here.

### 3.3 `RunSpec` has no placement fields

In [spawner/pkg/api/types.go](/opt/go/src/github.com/HeaInSeo/spawner/pkg/api/types.go:96) through [spawner/pkg/api/types.go](/opt/go/src/github.com/HeaInSeo/spawner/pkg/api/types.go:107), `RunSpec` does not include fields such as `nodeSelector`, `affinity`, `nodeName`, `placementHint`, or `artifactLocationRef`.

### 3.4 `buildJob()` does not populate Pod placement either

In [spawner/cmd/imp/k8s_driver.go](/opt/go/src/github.com/HeaInSeo/spawner/cmd/imp/k8s_driver.go:157) through [spawner/cmd/imp/k8s_driver.go](/opt/go/src/github.com/HeaInSeo/spawner/cmd/imp/k8s_driver.go:205), `buildJob()` fills PodSpec fields such as `RestartPolicy`, `Containers`, and `Volumes`, but not `nodeSelector` or `affinity`.

### 3.5 The `poc` tests state the same limitation

In [pkg/integration/kueue_observe_test.go](/opt/go/src/github.com/HeaInSeo/poc/pkg/integration/kueue_observe_test.go:204) through [pkg/integration/kueue_observe_test.go](/opt/go/src/github.com/HeaInSeo/poc/pkg/integration/kueue_observe_test.go:207), the test explicitly says that injecting `nodeSelector` into the Job spec would require extending `api.RunSpec` or `buildJob`.

## 4. Remote Multipass Kubernetes Validation

### 4.1 Environment

- remote host: `100.123.80.48`
- user: `seoy`
- Kubernetes lab: `multipass-k8s-lab`
- nodes:
  - `lab-master-0`
  - `lab-worker-0`
  - `lab-worker-1`
- kubeconfig: `/opt/go/src/github.com/HeaInSeo/multipass-k8s-lab/kubeconfig`

I cloned these repositories onto the remote host:

- `pipeline-lite-poc` → `/opt/go/src/github.com/HeaInSeo/poc`
- `spawner` → `/opt/go/src/github.com/HeaInSeo/spawner`
- `dag-go` → `/opt/go/src/github.com/HeaInSeo/dag-go`

I also prepared the cluster with:

- Kueue `v0.16.4`
- `deploy/kueue/queues.yaml`
- `poc-shared-pvc`
  - `storageClassName: local-path`
  - `ReadWriteOnce`

### 4.2 Execution

I ran the following on the remote host:

```bash
cd /opt/go/src/github.com/HeaInSeo/poc
KUBECONFIG=/opt/go/src/github.com/HeaInSeo/multipass-k8s-lab/kubeconfig \
  /usr/local/go/bin/go run ./cmd/poc-pipeline --run-id dynplace-20260412-01
```

The run completed successfully.

- `poc-a`
- `poc-b1`
- `poc-b2`
- `poc-b3`
- `poc-c`

all reached `Complete`.

### 4.3 Placement fields in the actual Job specs

On the remote cluster, I checked:

```bash
kubectl get job poc-dynplace-20260412-01-a  -o jsonpath='{.spec.template.spec.nodeSelector}'
kubectl get job poc-dynplace-20260412-01-a  -o jsonpath='{.spec.template.spec.affinity}'
kubectl get job poc-dynplace-20260412-01-b1 -o jsonpath='{.spec.template.spec.nodeSelector}'
kubectl get job poc-dynplace-20260412-01-b1 -o jsonpath='{.spec.template.spec.affinity}'
```

Result:

- `nodeSelector`: empty
- `affinity`: empty

So the current `poc-pipeline` path does not inject placement based on parent results.

### 4.4 All Pods landed on `lab-worker-1`

Remote `kubectl get pods -o wide` showed:

- `poc-dynplace-20260412-01-a-*` → `lab-worker-1`
- `poc-dynplace-20260412-01-b1-*` → `lab-worker-1`
- `poc-dynplace-20260412-01-b2-*` → `lab-worker-1`
- `poc-dynplace-20260412-01-b3-*` → `lab-worker-1`
- `poc-dynplace-20260412-01-c-*` → `lab-worker-1`

At a glance, this looks like a same-node pipeline. But that alone is not evidence of dynamic placement.

### 4.5 The actual same-node cause was the PVC's selected node

The key output from remote `kubectl describe pvc poc-shared-pvc -n default` was:

- `StorageClass: local-path`
- `Access Modes: RWO`
- annotation:
  - `volume.kubernetes.io/selected-node: lab-worker-1`

So after the first consumer appeared, the local-path provisioner bound the PVC to `lab-worker-1`, and later Pods using the same PVC were pulled onto the same node by storage constraints.

That is not the same as:

- reading parent artifact location,
- then injecting a child Job placement hint such as
- `nodeSelector=producerNode`

## 5. What This Validation Confirms

1. The current `poc` does handle DAG dependency/readiness.
2. The current `poc` does run successfully through Kueue + Jobs + shared PVC.
3. The current `poc` does not yet implement parent-result-driven dynamic placement.
4. A same-node outcome can currently be a storage-binding side effect rather than evidence of artifact-aware placement logic.

So at this stage it would be incorrect to say that Kubernetes already solves dynamic parent/child locality automatically.

The more accurate reading is:

- Kubernetes provides placement primitives and storage constraints.
- But the semantics that read parent artifact metadata and dynamically change child placement still need to be implemented in the product/runtime layer.

## 6. Why This Matters To This Project

`artifact-handoff-poc` already validated that metadata such as `producerNode` can be recorded and that scripts can read that metadata to drive same-node or cross-node experiments.

This `poc` validation separates the next layer more clearly:

- having DAG readiness does not automatically mean having dynamic placement,
- and seeing same-node execution does not by itself prove artifact-aware placement.

Taken together, the two repositories now separate the layers like this:

- `artifact-handoff-poc`: minimum truth for location-aware semantics
- `poc`: DAG runtime / Kueue / Job orchestration baseline
- still missing layer: parent-result-driven placement controller/adapter

## 7. Next Sprint Candidates

1. `U2 - Dynamic Placement Interface Cut`
   - decide how placement hints should be represented in `RunSpec` or a higher-level abstraction

2. `U3 - Parent-Result Placement Injection Validation`
   - read `producerNode` after parent completion,
   - inject `nodeSelector` or `affinity` into the child Job spec before submission,
   - validate the behavior again on the remote Multipass Kubernetes lab

`U2` should be the immediate priority.
