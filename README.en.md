# artifact-handoff-poc

English: [README.en.md](README.en.md)
한국어: [README.md](README.md)

`artifact-handoff-poc` is a narrow experiment repository for validating node-local artifact handoff on top of a Kubernetes lab cluster.

This repository is not responsible for VM creation or Kubernetes bootstrap. `multipass-k8s-lab` is the lab infrastructure repo. `artifact-handoff-poc` is the experiment repo that deploys a minimal artifact handoff stack onto that lab.

Its central concept is not generic file transfer but `artifact location awareness`. The goal is to record where a parent artifact lives and use that location to decide between same-node reuse and cross-node peer fetch.

The current implementation is closer to **script-assisted location-aware validation** than to a full scheduler/controller-driven decision layer. It combines catalog metadata, experiment scripts, and node-local agents rather than a richer placement control plane.

Project baseline: [docs/PROJECT_BASELINE.md](docs/PROJECT_BASELINE.md)

## Goal

Sprint 1 validates one question:

Can a 3-node K8s VM lab support a minimal node-local artifact handoff flow with same-node reuse and cross-node peer fetch?

This is closer to "can location drive the handoff decision" than to "where should the file be copied."

## Repo Boundary

- `multipass-k8s-lab` owns VM lifecycle, kubeadm bootstrap, kubeconfig export, and reusable lab infrastructure.
- `artifact-handoff-poc` owns the PoC implementation, Kubernetes manifests, experiment scripts, and result capture.
- This repo does not implement Multipass provisioning, kubeadm bootstrap, or host setup logic.

## Why This Repository Exists

In Kubernetes DAG or genomics-style workflows, handing large parent outputs to child workloads through a PV/PVC-first model can become heavy in both cost and operational complexity. This repository validates a narrower alternative: use a catalog/metadata layer to recognize the producer artifact's physical location first, then:

- place the child on the same node to enable same-node reuse
- or fall back to cross-node peer fetch from the producer node

The repository exists to validate whether that minimal location-aware handoff flow works in a constrained lab.

At the current stage, child placement is assisted by scripts that read `producerNode` from the catalog. A dedicated scheduler or controller is not part of the current scope.

## Sprint 1 Scope

In scope:

- one `artifact-agent` per node as a DaemonSet
- one minimal central catalog service
- hostPath-backed node-local artifact storage
- parent job produces an artifact on node A
- same-node child reuses it on node A
- cross-node child on node B fetches it from node A through peer transfer
- minimal digest verification and metadata tracking

Out of scope:

- durable storage
- production hardening
- advanced GC
- CRD/operator integration
- Cilium-specific optimization
- performance benchmarking

More detail: [docs/SPRINT1_SCOPE.md](docs/SPRINT1_SCOPE.md)

Research note entry point: [docs/research/README.md](docs/research/README.md)
Failure semantics note: [docs/research/peer-fetch-failure-paths.md](docs/research/peer-fetch-failure-paths.md)
Failure matrix: [docs/FAILURE_MATRIX.md](docs/FAILURE_MATRIX.md)
Sprint progress board: [docs/SPRINT_PROGRESS.md](docs/SPRINT_PROGRESS.md)
Conservative six-week parallel plan: [docs/PARALLEL_6W_DELIVERY_PLAN.md](docs/PARALLEL_6W_DELIVERY_PLAN.md)

## Layout

```text
.
├── app/
│   ├── agent/      # Python HTTP agent used by the DaemonSet
│   └── catalog/    # Python HTTP catalog used by the Deployment
├── docs/
├── manifests/
│   └── base/       # kustomize baseline
├── scripts/
└── test/
```

## Components

### artifact-agent

- runs as a DaemonSet with `hostNetwork: true`
- stores artifacts under `/var/lib/artifact-handoff`
- serves local lookup and peer fetch over HTTP
- registers metadata with the catalog
- verifies artifact content against the declared SHA-256 digest

### catalog

- single Deployment
- stores minimal metadata in memory plus a JSON snapshot on `emptyDir`
- tracks:
  - `artifactId`
  - `digest`
  - `producerNode`
  - `producerAddress`
  - `localPath`
  - `state`
  - `replicaNodes`

### workloads

- `run-same-node.sh`: parent on node A, child on node A
- `run-cross-node.sh`: parent on node A, child on node B

The current scripts read `producerNode` from the catalog after the parent run and use that metadata when building the child scenario, but the overall experiment flow is still organized by shell scripts.

## Prerequisites

1. `multipass-k8s-lab` exists as a sibling repository.
2. The lab cluster is already prepared through that repository.
3. `kubectl` is installed on the host.
4. `python3` is available on the host for helper scripts.

## Quick Start

```bash
./scripts/check-lab.sh
./scripts/deploy.sh
./scripts/run-same-node.sh
./scripts/run-cross-node.sh
```

Optional cache re-hit check:

```bash
./scripts/run-cross-node.sh --second-hit
```

Cleanup:

```bash
./scripts/cleanup.sh
```

## Execution Order

1. Confirm the lab cluster through `multipass-k8s-lab`.
2. Deploy the PoC namespace, catalog, and agents.
3. Run same-node reuse.
4. Run cross-node peer fetch.
5. Review logs and [docs/RESULTS.md](docs/RESULTS.md).

## Known Limitations

- catalog data is not durable
- artifact storage uses hostPath directly
- peer discovery is address-based and intentionally simple
- no authn/authz or TLS between agents
- placement is assisted by scripts that read catalog metadata, but there is still no dedicated scheduler/controller integration
- the catalog top-level state is still a minimal `produced`-centric model rather than a richer transition system

## Next Steps

- replace the in-memory catalog with a more durable backing store
- introduce cleanup and eviction rules
- formalize metadata transitions and error states
- evaluate scheduler hints or controller-driven placement
- add richer failure-path tests

Any later step should still follow the scope guardrails in [docs/PROJECT_BASELINE.md](docs/PROJECT_BASELINE.md) and stay in small experiment increments.
