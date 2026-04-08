# Research README

## Purpose

`docs/research/` is not an implementation sidecar. It is the place where this repository records **research findings**, which are one of its core deliverables.

This repository is not just an implementation project. It is a research-backed validation repository that carries three outputs together:

1. research
2. experiment implementation
3. result documentation

Research findings should not stay only in conversations. They should be written down when possible so they can feed back into the README, baseline, manifests, scripts, and app design.

## Bilingual Document Rule

Core research notes under `docs/research/` should be kept as separate Korean and English files where practical.

Rule:

- Korean documents use `.ko.md`
- English documents use `.md`
- do not combine both languages in a single file
- when adding a new research note, add the paired document in the same turn whenever practical

So the default is not "write it only in one language now and organize it later", but to manage research notes as document pairs from the start.

## Research Principles

The goal is not to find an open-source project that is **exactly the same** as this one.
Instead, the goal is to study nearby projects that share parts of the same problem framing, then separate **what to borrow** from **what not to borrow**.

While doing that, keep this repository's identity clear:

- Do not misread it as a general-purpose P2P platform.
- Do not misread it as a simple storage cache project.
- Do not misread it as a full workflow engine.
- Treat it as a **location-aware validation repo for Kubernetes DAG artifact handoff**.

## Research Axes

### A. Peer-Based Distribution Layer

Targets:

- Dragonfly
- Kraken

Research points:

- peer-based distribution
- reducing load on a central source or registry
- producer / peer / source concepts
- scheduler or parent-peer selection ideas
- the difference between a distribution layer and workflow-aware handoff

### B. Kubernetes-Native Batch Scheduling Layer

Targets:

- Volcano

Research points:

- batch and elastic workload scheduling
- fit for genomics or bioinformatics workloads
- placement and scheduling-hint perspective
- how it may connect to future artifact-aware placement experiments

### C. Data Locality / Cache / Data Access Layer

Targets:

- Alluxio
- JuiceFS

Research points:

- local cache and near-local access
- how Kubernetes deployments improve data locality
- central storage plus local cache models
- node-local hit and cache-sharing concepts

### D. Dataset / Metadata / Lineage Layer

Targets:

- Datashim
- Pachyderm

Research points:

- dataset / metadata / pointer models
- data lineage, versioning, and pipeline awareness
- concepts that may connect to an artifact metadata catalog
- data-centric workflow thinking

### E. Node-Local Agent / Cache Pattern

Targets:

- kube-fledged
- NodeLocal DNSCache

Research points:

- putting an agent or cache on every node
- DaemonSet-based node-local service patterns
- same-node hit priority and central traffic reduction patterns

## Recommended Research Notes

Create or update these documents where practical:

- `docs/research/nearby-opensource-map.ko.md`
- `docs/research/nearby-opensource-map.md`
- `docs/research/dragonfly-vs-artifact-handoff-poc.ko.md`
- `docs/research/dragonfly-vs-artifact-handoff-poc.md`
- `docs/research/k8s-locality-and-placement-notes.ko.md`
- `docs/research/k8s-locality-and-placement-notes.md`
- `docs/research/node-local-agent-patterns.ko.md`
- `docs/research/node-local-agent-patterns.md`
- `docs/research/catalog-metadata-model.ko.md`
- `docs/research/catalog-metadata-model.md`

These can follow later if needed:

- `docs/research/hostpath-vs-localpv.ko.md`
- `docs/research/peer-fetch-failure-paths.ko.md`
- `docs/research/cilium-fit-gap.ko.md`

## Common Structure For Each Research Note

Each research note should follow this structure when practical:

1. research question
2. key summary
3. how it resembles our project
4. how it differs from our project
5. what to borrow
6. what not to borrow
7. points that connect directly to the current sprint
8. candidate points for the next sprint

## Conclusions To Extract After Research

After the research pass, the repository should be able to answer:

- Which combination of open-source projects is closest to `artifact-handoff-poc`?
- What is the most relevant reference from the peer-based distribution perspective?
- What is the most relevant reference from the Kubernetes placement and scheduling perspective?
- What is the most relevant reference from the metadata and catalog perspective?
- What is the most relevant reference from the node-local daemon pattern perspective?
- Which projects look similar at first glance but actually solve a different problem?
- Which concepts are directly useful in the current sprint, and which ones are still too early?

## Current Suggested Research Order

For now, this is the suggested starting order:

1. `dragonfly-vs-artifact-handoff-poc`
2. `nearby-opensource-map`
3. `k8s-locality-and-placement-notes`
4. `catalog-metadata-model`
5. `node-local-agent-patterns`

This order is a starting point, not a hard rule.
It can be adjusted based on the current sprint goal and risks.
