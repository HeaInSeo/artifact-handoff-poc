# artifact-handoff-poc

English: [README.en.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/README.en.md)
한국어: [README.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/README.md)

`artifact-handoff-poc` is a narrow experiment repository for validating node-local artifact handoff on top of a Kubernetes lab cluster.

This repository is not responsible for VM creation or Kubernetes bootstrap. `multipass-k8s-lab` is the lab infrastructure repo. `artifact-handoff-poc` is the experiment repo that deploys a minimal artifact handoff stack onto that lab.

## Goal

Sprint 1 validates one question:

Can a 3-node K8s VM lab support a minimal node-local artifact handoff flow with same-node reuse and cross-node peer fetch?

## Repo Boundary

- `multipass-k8s-lab` owns VM lifecycle, kubeadm bootstrap, kubeconfig export, and reusable lab infrastructure.
- `artifact-handoff-poc` owns the PoC implementation, Kubernetes manifests, experiment scripts, and result capture.
- This repo does not implement Multipass provisioning, kubeadm bootstrap, or host setup logic.

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

More detail: [docs/SPRINT1_SCOPE.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SPRINT1_SCOPE.md)

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
5. Review logs and [docs/RESULTS.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/RESULTS.md).

## Known Limitations

- catalog data is not durable
- artifact storage uses hostPath directly
- peer discovery is address-based and intentionally simple
- no authn/authz or TLS between agents
- no scheduler integration beyond explicit node pinning in the test jobs

## Next Steps

- replace the in-memory catalog with a more durable backing store
- introduce cleanup and eviction rules
- formalize metadata transitions and error states
- evaluate scheduler hints or controller-driven placement
- add richer failure-path tests
