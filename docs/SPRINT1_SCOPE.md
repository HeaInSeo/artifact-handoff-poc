# SPRINT1_SCOPE

## Purpose

Sprint 1 exists to prove the minimum structure of artifact handoff on a small Kubernetes VM lab.

The target is not a production system. The target is a small but real baseline that demonstrates:

1. parent creates an artifact on node A
2. same-node child on node A reuses it locally
3. cross-node child on node B pulls it from the peer agent on node A
4. digest validation and minimal metadata are enforced

## Responsibility Split

- `multipass-k8s-lab` is the lab infrastructure repo.
- `artifact-handoff-poc` is the experiment repo.
- This PoC repo does not own VM lifecycle, kubeadm bootstrap, or host setup.

## In Scope

- one DaemonSet-based node agent per node
- one minimal central catalog
- hostPath-backed node-local artifact storage
- HTTP-based artifact put, get, and peer fetch
- same-node and cross-node validation scripts
- result capture for the sprint

## Out of Scope

- durable artifact persistence
- fine-grained garbage collection
- production security posture
- CRD/operator control plane
- forced dependency on Cilium
- high-performance benchmarking

## Minimal Data Model

Each artifact record tracks:

- `artifactId`
- `digest`
- `producerNode`
- `producerAddress`
- `localPath`
- `state`
- `replicaNodes`

Failure semantics note: [docs/research/peer-fetch-failure-paths.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.md)

This scope document does not expand the full failure taxonomy. It only points to the note above for interpreting `state`, `fetch-failed`, and digest-mismatch semantics.

## Success Criteria

- same-node child succeeds without remote fetch
- cross-node child succeeds after peer fetch
- second hit on node B can succeed from local cache when requested
- digest mismatch is rejected
- `producerNode` metadata is actually used as child-placement input
- the flow is reproducible on top of `multipass-k8s-lab`

## Non-Goals

This sprint does not try to answer:

- long-term storage strategy
- catalog HA
- lifecycle policy completeness
- operator API shape
- network-stack-specific optimization

## Deliverables

- runnable baseline manifests
- deploy and cleanup scripts
- scenario scripts for same-node and cross-node checks
- sprint result notes with observed constraints
