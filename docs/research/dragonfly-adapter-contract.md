# dragonfly-adapter-contract

## 1. Research Question

If `artifact-handoff-poc` uses Dragonfly as a distribution backend, what adapter contract should the project own, and where should that boundary sit?

## 2. Key Summary

The safest direction is:

- `artifact-handoff-poc` should own a **product-owned adapter contract**
- Dragonfly should sit behind that contract as a **replaceable backend**
- catalog, placement intent, and handoff semantics should remain outside Dragonfly

So this project should not expose raw Dragonfly CLI/API as if it were the product contract.
It should first fix a thin adapter boundary and then map Dragonfly underneath it.

This judgment is not based only on document reading.
It is also based on **live Dragonfly installation and `dfcache` validation on the remote Multipass K8s lab at `100.123.80.48` on April 12, 2026**.

## 3. Directly Validated Evidence In This Turn

Remote lab environment:

- host: `100.123.80.48`
- user: `seoy`
- lab baseline: `multipass-k8s-lab`
- cluster: 3-node kubeadm cluster
- Kubernetes nodes: `lab-master-0`, `lab-worker-0`, `lab-worker-1`
- Cilium: `1.19.1`

Dragonfly installation validation:

- Helm chart: `dragonfly/dragonfly`
- namespace: `dragonfly-system`
- status: `deployed`
- core components observed:
  - `dragonfly-manager`
  - `dragonfly-scheduler`
  - `dragonfly-client`
  - `dragonfly-seed-client`
  - `mysql`
  - `redis`

`dfcache` validation:

- `dfcache import --help` and `dfcache export --help` were inspected directly
- the deployed CLI contract is not `--cid`; it is:
  - `dfcache import <PATH>`
  - `dfcache export -O <OUTPUT> <ID>`
- when the same content was re-imported:
  - Dragonfly reported that the persistent cache task already existed and was already `Succeeded`
- when the known task ID was exported from another client pod:
  - output path: `/tmp/dragonfly-demo.out`
  - resulting payload: `hello-dragonfly`

So the minimum validated facts are:

1. Dragonfly installs successfully on the current lab
2. `dfcache` exposes a real local-file import / task-ID export contract
3. another client pod can export and reuse the payload through that task ID

## 4. Why A Product-Owned Adapter Contract Is Needed

The core semantics of this repository are:

- which artifact was produced by which producer
- which child should consume which artifact
- whether same-node reuse should be attempted first
- how replica fallback should be ordered
- how orphan/local-leftover states should be interpreted

Those semantics are not Dragonfly's native model.

Dragonfly mainly provides:

- payload distribution
- persistent cache tasks
- node-local daemon runtime
- optional preheat/task control APIs

So if we do not define the product contract first, Dragonfly's transport surface can accidentally harden into product semantics.

## 5. Recommended Adapter Contract

The recommended minimum contract between the current PoC and Dragonfly is:

### A. `Put`

Meaning:

- upload a producer-created artifact into the distribution backend

Example inputs:

- `artifactId`
- `localPath`
- `digest`
- `ttl`
- `replicaHint`

Dragonfly mapping:

- `dfcache import <PATH>`
- optionally `--ttl`
- optionally `--persistent-replica-count`
- task ID recorded inside the adapter

Example outputs:

- `backendTaskId`
- `backendType=dragonfly`
- `state=stored`

### B. `EnsureOnNode`

Meaning:

- make sure an artifact is actually available on a target node

Example inputs:

- `artifactId`
- `targetNode`
- `backendTaskId`
- `outputPath`

Dragonfly mapping:

- `dfcache export -O <OUTPUT> <ID>` on the target node

Example outputs:

- `resolvedPath`
- `source=dragonfly-export`
- `state=available-local`

### C. `Stat`

Meaning:

- query artifact/backend-task status

Example inputs:

- `artifactId`
- `backendTaskId`

Dragonfly mapping candidates:

- `dfcache stat`
- Manager task/job query

Example outputs:

- `exists`
- `backendState`
- `lastObservedAt`

### D. `Warm`

Meaning:

- prepare an artifact set ahead of fan-out

Dragonfly mapping candidate:

- Manager Open API preheat

Note:

- in the current PoC, this is closer to an optional capability than a required first-cut contract

### E. `Evict`

Meaning:

- clean up or remove backend cache state

Dragonfly mapping candidates:

- task cleanup/delete paths
- local cache cleanup

Note:

- this must stay coordinated with product-owned catalog policy

## 6. What Must Stay Outside Dragonfly

The following must remain product-owned:

- workflow meaning of `artifactId`
- `producerNode`, `producerAddress`, `replicaNodes`
- same-node priority policy
- replica fallback ordering semantics
- orphan / cleanup policy
- scheduler/controller integration semantics

So the Dragonfly adapter is a transport/cache backend, not the source of truth for artifact handoff.

## 7. What Can Be Delegated To Dragonfly

- payload upload/import
- task ID creation and persistent cache creation
- node-local export
- cache replication hints
- preheat / warm-up
- some transport-level retry behavior

But even these should be delegated only through the product-owned contract.

## 8. Current Risks And Cautions

### 1. Do not mistake Dragonfly CLI/API for the product contract

In this live validation, the deployed `dfcache` CLI did not match the initially assumed `--cid` style.
It used `import <PATH>` and `export <ID>`.

That is exactly why Dragonfly should stay behind an adapter boundary.

### 2. Do not treat task ID and `artifactId` as the same thing

The observed task ID behaves like a content-based persistent cache task identifier.

Our `artifactId` may carry DAG/workflow meaning, so the two values must not be collapsed into one.

Recommended rule:

- `artifactId` is product-owned
- `backendTaskId` is adapter-owned

### 3. Re-import semantics should be read as idempotent backend reuse

For duplicate content, Dragonfly reported that the persistent cache task already existed and had already succeeded.

So `Put` should be designed with this interpretation:

- duplicate content may map to reuse of an existing backend object, not creation of a new product artifact identity

### 4. The remote upper-layer PoC is not there yet

At the time of validation, the remote host had `multipass-k8s-lab` under `/opt/go/src/github.com/HeaInSeo`, but not yet `artifact-handoff-poc`.

So this turn closes the lower-layer Dragonfly validation, not the full upper-layer integration.

## 9. Recommended Immediate Next Steps

1. in `U1` or a dedicated research sprint, narrow the `DragonflyAdapter` interface further at code level
2. decide how `backendTaskId` should map into the current catalog
3. place `artifact-handoff-poc` on the remote lab too, then compare the current hand-rolled peer-fetch path with a Dragonfly-backed path in the same experiment
4. keep preheat/stat/evict as second-pass capabilities

## 10. One-Line Conclusion

The core of the Dragonfly adapter contract is to use Dragonfly only as a replaceable backend that implements `Put / EnsureOnNode / Stat / Warm / Evict`, while keeping product semantics outside Dragonfly.
