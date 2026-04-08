# BASELINE_GAP_REVIEW

## 1. Purpose

This document records how well the current implementation aligns with `PROJECT_BASELINE`, `README`, `SPRINT1_SCOPE`, and the research notes.

Scope:

- `app/agent/agent.py`
- `app/catalog/catalog.py`
- `manifests/base/*`
- `scripts/*.sh`

This is not a code-change document. It is a gap review that freezes the difference between the baseline and the current state before the next implementation sprint.

## 2. Summary Judgment

The current implementation mostly holds as a minimal Sprint 1 same-node / cross-node validation PoC. In particular, these are already true:

- one DaemonSet agent per node
- one central catalog
- `hostPath`-based node-local storage
- digest validation
- same-node local hit
- cross-node peer fetch
- second-hit local cache reuse

But the current implementation still does not fully demonstrate the `metadata-driven location-aware decision layer` emphasized in the documents. That said, a recent tightening did introduce a flow where the child placement reads `producerNode` from the catalog after the parent completes.

The most accurate reading is:

- a minimal PoC that chooses a fetch source based on an existing artifact
- a system where child placement has started to reference catalog metadata, but is still heavily script-driven

## 3. Where It Matches The Baseline Well

### 3.1 Repository boundaries are respected

- `scripts/check-lab.sh` refers to the sibling `multipass-k8s-lab` repository for kubeconfig and lab status, but does not pull provisioning or bootstrap logic into this repo.
- `scripts/deploy.sh` deploys only PoC resources from this repository.
- There is no Multipass lifecycle, kubeadm bootstrap, or host preparation logic inside this codebase.

Judgment:

- repository boundaries remain aligned with the baseline

### 3.2 The node-local agent pattern fits the baseline well

- the agent is deployed as a DaemonSet
- it uses `hostNetwork: true`, `hostPort: 8080`, and `hostPath: /var/lib/artifact-handoff`
- each node performs local artifact lookup and peer serving

Judgment:

- the current structure matches the `node-local-agent-patterns` research note well

### 3.3 The minimal same-node / cross-node scenarios match the intended flow

- a parent job PUTs an artifact on a chosen node
- a same-node child expects `local`
- a cross-node child expects `peer-fetch`
- with `--second-hit`, the second child expects `local`

Judgment:

- the Sprint 1 acceptance flow is implemented as an actual runnable script path

### 3.4 Digest validation exists at a minimal but sufficient level

- PUT rejects mismatches between declared and actual digest
- local read removes the local artifact directory on digest mismatch
- peer fetch also compares expected and actual digest

Judgment:

- integrity validation is present at the right level for the current sprint

## 4. Where It Is Weak Or Still Misaligned

### 4.1 Placement is closer to metadata-driven than before, but still script-driven

The baseline emphasizes:

- record artifact location
- use that location to drive same-node placement

The current scripts now read catalog metadata after the parent completes and feed it into child placement.

Actual implementation:

- `scripts/run-same-node.sh` reads `producerNode` from the catalog and pins the child there
- `scripts/run-cross-node.sh` reads `producerNode` from the catalog and picks a different node for the child

So placement is now closer to "decide based on artifact location", but shell scripts still assemble the scenario.

Judgment:

- this gap has narrowed
- the current implementation is acceptable as a validation scenario, and metadata is now truly used as placement input
- but without a scheduler/controller or richer policy, it is still too early to call it a full decision layer

### 4.2 The catalog is a location registry, but still thin as a decision layer

Current catalog responsibilities:

- `PUT /artifacts/{id}` stores a record
- `GET /artifacts/{id}` returns a record
- `POST /artifacts/{id}/replicas` stores replica information

What it still lacks:

- state-transition validation
- richer field validation
- placement hint calculation
- fetch source selection policy
- stale replica handling

Judgment:

- it already plays the minimum registry role described in the baseline
- but actual decision logic or policy still lives mostly in the agent or scripts

### 4.3 Metadata naming and state are better than before, but not fully unified

The catalog now mostly stores `producerNode`, `producerAddress`, `localPath`, `state`, and `replicaNodes`, and the implementation is close to that model.

More specifically:

- local metadata now stores `producerNode`, `producerAddress`, `localNode`, `localAddress`, and `state`
- catalog top-level state currently allows only `produced`
- replica entries use `replicated`
- failure states are now reflected in local metadata, but catalog and local semantics are still not a fully unified transition model

Judgment:

- naming consistency improved
- state is no longer just a `"ready"` placeholder
- but the transition model is still not fully formalized

### 4.4 Peer fetch is still producer-only and does not use replicas

The current cross-node fetch path looks up the catalog and uses only `producerAddress`.

That means:

- `replicaNodes` is recorded, but not used for fetch source selection
- there is no replica fallback when the producer is down or unreachable
- `register_replica` is not yet connected to fetch optimization

Judgment:

- acceptable in the current sprint
- but from the README and research perspective, `replicaNodes` is still more recording than decision input

### 4.5 The agent/catalog role split is clearer, but API-boundary documentation still needs work

The current agent process still does all of the following:

- local storage writes
- local digest validation
- catalog registration
- catalog reads
- remote peer fetch
- replica registration

That is reasonable for a PoC, but these boundaries still need clearer documentation:

- whether the catalog is the authoritative location source
- whether local metadata or catalog record has priority
- how to interpret "local artifact exists but catalog record does not"
- how to interpret "catalog record exists but local artifact does not"

Judgment:

- the structure is still small and explainable
- the current narrow rule is: the catalog is authoritative for producer origin and placement input, while local metadata is an observation of a node-local copy
- but that rule still needs stronger reflection in README and results docs

### 4.6 There are effectively no dedicated test assets

- `test/` is empty
- validation still relies on shell-script scenarios

Judgment:

- acceptable for Sprint 1
- but reproducibility and failure-path coverage remain weak

## 5. File-Level Notes

### `app/agent/agent.py`

Strengths:

- handles digest mismatch on PUT, local read, and peer fetch
- the local-first, remote-fallback flow is clear
- catalog registration and replica registration exist at a minimal level

Gaps:

- the difference between catalog top-level state and local metadata state still needs documentation
- fetch source selection is fixed to `producerAddress`
- the state model improved, but still lacks a formal failure transition model

### `app/catalog/catalog.py`

Strengths:

- the in-memory + JSON snapshot structure fits Sprint 1 well
- `replicaNodes` can be accumulated and updated

Gaps:

- payload validation is still minimal
- there is no explicit state transition or stale handling
- it remains a registry rather than a decision engine

### `scripts/run-same-node.sh`

Strengths:

- same-node hit validation is explicit
- it fails if the source is not local

Gap:

- child placement depends on the script scenario even though it now reads `producerNode`

### `scripts/run-cross-node.sh`

Strengths:

- validates both peer fetch and second-hit local cache

Gaps:

- the script still assembles the placement scenario itself
- fetch optimization is still producer-only

### `manifests/base/*`

Strengths:

- the DaemonSet + Deployment + namespace structure fits Sprint 1
- injecting code through ConfigMaps is simple enough for a PoC

Gap:

- the structure intentionally favors simplicity over operational maturity, so documentation should not overstate it as production-like

## 6. Current Conclusion

The current implementation can answer "yes" to these questions:

- is same-node reuse possible?
- is cross-node peer fetch possible?
- is digest validation enforced at a minimum level?
- does a node-local agent + central catalog structure hold in minimal form?

But it still answers only partially to these:

- does it dynamically drive child placement based on artifact location?
- is the metadata/state model strong enough to serve as a handoff decision layer?
- is replica metadata actually used in fetch strategy?

So the current PoC already demonstrates the minimum execution path of location-aware handoff, and it has started to use metadata as placement input. But policy and state-transition depth are still weak.

## 7. Candidate Next Implementation Sprint

Priority 1:

- tighten the metadata/state semantics further and keep aligning results and README wording with the actual implementation
