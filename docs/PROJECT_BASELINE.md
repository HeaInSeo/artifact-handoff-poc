# PROJECT_BASELINE

## 1. Why This Repository Exists

This repository exists to validate whether a Kubernetes-based DAG execution environment can hand off artifacts by recognizing and using artifact location first, instead of relying only on central storage or PV/PVC-heavy approaches.

Core questions:

- can the location of a parent artifact be recorded in Kubernetes?
- can a child be placed on the same node to encourage same-node reuse?
- if same-node placement is not possible, can the child fetch from the producer node through cross-node peer fetch?
- can this full flow hold in a deliberately narrow environment such as a 3-node Kubernetes VM lab?

The core question is not "where should we copy the file?" but "where is the data now, and can that location be used as input to handoff decisions?"

---

## 2. Project Starting Point

This repository is inspired by the problem framing of peer-based distribution systems such as Dragonfly.

But the goal is narrower:

- it does not reproduce Dragonfly itself
- it does not build a general-purpose P2P platform
- it borrows the locality-aware reuse / peer-based distribution mindset and applies it to Kubernetes DAG artifact handoff

Key idea:

- do not look only at a central source or central storage
- use the fact that data already exists on a specific node
- prefer same-node hits and extend to peer fetch only when needed

Reference links:

- Dragonfly official site: https://d7y.io/
- Dragonfly GitHub: https://github.com/dragonflyoss/dragonfly
- Dragonfly docs: https://d7y.io/docs/
- Dragonfly blog: https://d7y.io/blog/

---

## 3. Repository Boundary

### multipass-k8s-lab

- prepares the VM-based Kubernetes lab environment
- owns Multipass VM lifecycle
- owns kubeadm bootstrap
- owns kubeconfig export
- owns reusable 3-node lab infrastructure

### artifact-handoff-poc

- implements and validates node-local artifact handoff on top of that lab
- includes the minimum catalog / agent / manifests / experiment scripts / result docs
- validates location-aware artifact handoff step by step, including same-node reuse and cross-node peer fetch

Boundary rules:

- do not place Multipass provisioning, kubeadm bootstrap, or host preparation logic inside `artifact-handoff-poc`
- do not blur responsibilities between `multipass-k8s-lab` and `artifact-handoff-poc`
- do not try to solve lab-environment issues and handoff semantics in one repository

---

## 4. Default View Of The Kubernetes-Based Approach

This project assumes the experiment can be built on top of primitives Kubernetes already provides.

### Placement

- `nodeSelector`
- `nodeAffinity`
- `nodeName`

### Node-local artifact storage

- early validation: `hostPath`
- later comparison candidates: `local PersistentVolume`

### Cross-node handoff

- peer fetch from the producer node
- used as fallback when same-node reuse is not possible

### Metadata / catalog

The following are treated as core control points:

- artifactId
- digest
- producerNode
- producerAddress
- localPath
- state

Important distinction:

- Kubernetes provides scheduling, storage, and networking primitives
- but the semantics of recording artifact location and deciding reuse or fetch based on that location must be designed in this repository
- technologies such as Cilium may later improve cross-node transfer paths
- but they do not replace artifact-location semantics or DAG handoff semantics

Failure semantics note: [docs/research/peer-fetch-failure-paths.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.md)

---

## 5. Repository Character

This is not just an application repository.

It should be treated as a **research-backed validation repository** that includes all three of the following:

1. research
2. experiment implementation
3. result documentation

So this repository should not be interpreted as implementation-only. Related concepts must be investigated, and the findings must be reflected in documentation and code.

---

## 6. README Principles

`README.md` and `README.en.md` are entry documents, not full design documents.

The README should answer these first:

- why does this repository exist?
- how is it related to `multipass-k8s-lab`?
- what problem is it trying to validate?
- why look at location-aware handoff rather than a PV/PVC-centric approach?
- how are the experiments run?
- what is in scope for the current sprint?

Implementation detail, internal component detail, and long design background should move under `docs/`.

## 6.1 Bilingual Document Rule

Core documents in this repository should be kept in separate Korean and English files where practical.

Rule:

- Korean documents use `.ko.md`
- English documents use `.md`
- do not mix both languages inside a single file
- when a new core document is added, add its paired Korean or English document in the same turn whenever practical

The goal of this rule is not perfect translation symmetry. The goal is to keep the repository entry documents, baseline, scope, results, validation history, and research notes traceable in both languages.

---

## 7. Basic Working Rules

Work in this repository should be organized by **sprints**, not only by micro-steps.

Rules:

- propose the sprint unit before starting work
- try to complete one meaningful sprint in a work turn
- keep sprint scope small, but make the sprint output complete

Each sprint should explicitly include:

1. sprint name
2. sprint goal
3. in-scope items
4. out-of-scope items
5. completion criteria
6. key risks
7. expected output files
8. items deferred to the next sprint

---

## 8. Current State Recognition

Some of the intended direction has already started to appear:

- the README has started to move toward an entry-document role
- the repository identity and boundary have started to be fixed by `docs/PROJECT_BASELINE*.md`
- the importance of research documents has started to be made explicit by `docs/research/README*.md`

But there is still work left:

- many actual research notes may still be empty or early-stage
- whether the existing `manifests/`, `scripts/`, and `app/` implementation fully matches the baseline still needs a separate review
- so at the current stage, research, organization, and alignment review may still be more important than code changes

---

## 9. Recommended Current Sprints

### Recommended Sprint A: Research Baseline Fill

Goal:

- fill the `docs/research/` area with real research notes and establish comparison baselines across nearby projects and technologies

Scope:

- Dragonfly / Kraken / Volcano / Alluxio / JuiceFS / Datashim / Pachyderm / kube-fledged / NodeLocal DNSCache research
- nearby-opensource-map
- dragonfly-vs-artifact-handoff-poc
- k8s-locality-and-placement-notes
- node-local-agent-patterns
- first draft of catalog-metadata-model

Completion criteria:

- the research note set is filled with real content
- what to borrow and what not to borrow is stated
- ideas that apply now are separated from ideas that are still too early

Key risks:

- the research may become too broad and remain shallow
- the research may become too deep but disconnected from the actual project

### Recommended Sprint B: Baseline-to-Implementation Gap Review

Goal:

- review how well the current `app/`, `manifests/`, and `scripts/` match `PROJECT_BASELINE`

Scope:

- agent/catalog structure
- metadata model
- run-same-node / run-cross-node flow
- manifests/base structure
- wording alignment between `docs/SPRINT1_SCOPE` and the baseline

Completion criteria:

- at least one gap-analysis document is written
- alignment and misalignment are distinguished
- candidate implementation-tightening sprints are identified

Key risks:

- if the baseline documents and actual code flow are not connected carefully, the review can collapse into abstract impressions

At the current stage, Sprint A first and Sprint B second remains the recommended order.
