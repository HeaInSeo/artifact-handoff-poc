# SPRINT_PROGRESS

## Purpose

This document tracks sprint progress for `artifact-handoff-poc` in one place.

It exists to:

- quickly show which sprints are complete
- show what remains in backlog
- make the next small sprint easier to choose

This is not a design document. It is a **progress board** and should be updated whenever a sprint finishes.

For a one-page view of current completion and remaining sprints, also see [PROJECT_COMPLETION_VIEW.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PROJECT_COMPLETION_VIEW.md).

## Current Summary

- completed sprints: `B1` through `B16`, `C1`, `C2`, `C3`, `C4`, `C5`, `C6`, `C7`, `C8`, `C9`, `C10`, `C11`, `C12`, `D1`, `D2`, `D3`, `D4`, `D5`, `D6`, `D7`, `D8`, `D9`, `D10`, `D11`, `D12`, `D13`, `E1`, `E2`, `E3`, `E4`, `E5`, `F1`, `F2`, `F3`, `F4`, `F5`, `F6`, `F7`, `F8`, `F9`, `G1`, `G2`, `H1`, `H2`, `H3`, `I1`, `I2`, `I3`, `J1`, `J2`, `K1`
- progress:
  - failure-doc cleanup track `C1~C12`: `12/12` complete, `100%`
  - post-freeze transition track `D1~D3`: `3/3` complete, `100%`
  - first edge-case completion track `D4~D7`: `4/4` complete, `100%`
  - second edge-case kickoff track `D8~D9`: `2/2` complete, `100%`
  - second edge-case truth track `D10~D11`: `2/2` complete, `100%`
  - second edge-case cross-node follow-up track `D12~D13`: `2/2` complete, `100%`
  - post-second-edge planning track `E1~E4`: `4/4` complete, `100%`
  - post-E2 freeze track `E5`: `1/1` complete, `100%`
  - next execution planning track `F1~F3`: `3/3` complete, `100%`
  - replica-aware first validation track `F4~F5`: `2/2` complete, `100%`
  - replica-aware decision track `F6`: `1/1` complete, `100%`
  - producer-bias validation track `F7`: `1/1` complete, `100%`
  - replica source-selection minimal cut track `F8`: `1/1` complete, `100%`
  - replica-aware validation track `F9`: `1/1` complete, `100%`
  - post-replica-aware review track `G1~G2`: `2/2` complete, `100%`
  - current post-replica-aware follow-up track `H1~H3`: `3/3` complete, `100%`
  - next post-H3 reset track `I1~I2`: `2/2` complete, `100%`
  - next implementation selection track `I3`: `1/1` complete, `100%`
  - next execution cut track `J1`: `1/1` complete, `100%`
  - post-I3 refresh track `J2`: `1/1` complete, `100%`
  - post-J1 validation entry track `K1`: `1/1` complete, `100%`
  - multi-replica first validation track `K2`: `0/1` complete, `0%`
  - post-K2 backlog review track `L1`: `0/1` complete, `0%`
  - currently documented sprint set `B1~B16` + `C1~C12` + `D1~D13` + `E1~E5` + `F1~L1`: `66/68` complete, about `97%`
  - this percentage is for the current documentation/validation cleanup roadmap, not for every future implementation expansion
- current state:
  - Sprint 1 baseline validation and failure-semantics tightening are largely in place
  - README / baseline / scope / results / validation history / research note entry paths are mostly aligned
  - `Sprint C1` confirmed that core bilingual file-pair coverage is in place
  - `Sprint C2` consolidated the validated failures into a one-page matrix for quicker status reading
  - `Sprint C3` fixed the current decision to defer catalog top-level failure reflection
  - `Sprint C4` brought `TROUBLESHOOTING_NOTES.md` closer to the Korean document in English readability
  - `Sprint C5` added lightweight entry hooks to the failure matrix from README, RESULTS, and VALIDATION_HISTORY
  - `Sprint C6` fixed the decision that `catalog lookup failed` should remain unsplit for now
  - `Sprint C7` tightened the direct navigation path between the failure matrix and the failure-semantics research note
  - `Sprint C8` concluded that the current failure-doc navigation is already balanced enough
  - `Sprint C9` confirmed that the current failure taxonomy is still narrow enough for the Sprint 1 scope
  - `Sprint C10` concluded that the current failure-doc navigation should now be frozen at this level
  - `Sprint C11` fixed the decision to avoid adding a dedicated failure-note index to the research README
  - `Sprint C12` added a short summary that closes the current Sprint 1 failure-doc cleanup scope
  - the current failure-doc cleanup track should now be treated as closed for the present Sprint 1 scope
  - `Sprint D1` fixed the next connection point as a renewed control-layer gap review rather than more failure-doc expansion
  - `Sprint D2` narrowed the remaining catalog/local-metadata authority gaps into two small edge-case questions
  - `Sprint D3` selected `catalog record exists + local artifact missing` as the first post-freeze live validation question
  - `Sprint D4` added a dedicated helper script to reproduce the selected edge case without broadening the happy-path scripts
  - `Sprint D5` validated the same-node `catalog record exists + local artifact missing` case and fixed its interpretation with live evidence
  - `Sprint D6` fixed that the next smallest question is the cross-node recovery view of the same edge case
  - `Sprint D7` confirmed that the cross-node view of the same edge case recovers through `peer-fetch`
  - `Sprint D8` selected `catalog record missing + local artifact exists` as the second edge-case question and fixed the minimum cut for the next helper
  - `Sprint D9` added a dedicated helper to reproduce `catalog record missing + local artifact exists`
  - `Sprint D10` validated that same-node `catalog record missing + local artifact exists` surfaces as `source=local` success even when catalog lookup is `404`
  - `Sprint D11` fixed that the second edge case is closed for same-node truth, but the overall edge-case family remains partially open until the cross-node view is checked
  - `Sprint D12` validated that cross-node `catalog record missing + local artifact exists` surfaces as `catalog lookup failed` with `fetch-failed` metadata
  - `Sprint D13` fixed the closure judgment that the second edge-case family is closed for the current Sprint 1 validation scope, while orphan semantics remain out of scope
  - `Sprint E1` fixed the next priority as an orphan/local-leftover semantics note, with catalog top-level failure reflection left as the following review item
  - `Sprint E2` fixed the note that same-node local-first reuse should be accepted as current behavior truth, but not yet treated as orphan-policy approval
  - `Sprint E3` fixed the recheck conclusion that catalog top-level failure reflection should still remain deferred even after the second edge-case family
  - `Sprint E4` fixed the judgment that the broader policy boundary should not expand further, and that the only remaining narrow policy question should stay limited to `E2 - Orphan Semantics Note`
  - `Sprint E5` fixed the judgment that the current Sprint 1 policy/document cleanup should now freeze here and shift to the next validation/implementation question
  - `Sprint F1` fixed the next real question as the smallest replica-aware fetch question: whether `replicaNodes` can become meaningful for fetch source selection
  - `Sprint F2` reordered the implementation backlog and fixed `replica-aware fetch` as the new top priority, with `catalog top-level failure reflection` kept second
  - `Sprint F3` added the smallest execution cut for replica-aware fetch: a dedicated helper that makes the first replica and `replicaNodes` state repeatable for validation
  - `Sprint F4` fixed the first live evidence that replica-ready state exists, while actual fetch source selection still remains producer-biased
  - `Sprint F5` fixed the follow-up order as `validation first, cut second`, and narrowed the next judgment step to `F6 - Replica-Aware Decision Note`
  - `Sprint F6` fixed the decision that the next immediate execution should validate the producer bias first, and only then move into the smallest replica source-selection cut
  - `Sprint F7` fixed the first live evidence that a third-node consumer still follows only the broken top-level `producerAddress` and fails even while a first replica remains available
  - `Sprint F8` added the minimum cut that expands the remote candidate set in `peer_fetch()` from only the producer to producer plus `replicaNodes`
  - `Sprint F9` fixed the first live evidence that a third-node consumer now succeeds through replica fallback even after the producer endpoint is intentionally broken
  - `Sprint G1` fixed the next narrow post-replica-aware gaps as actual fetch-endpoint observability and ordering semantics
  - `Sprint G2` reordered the next follow-up questions as completion refresh first, observability second, and ordering semantics third
  - `Sprint H1` refreshed the completion overview and progress board so they now point to the same remaining post-replica-aware questions
  - `Sprint H2` fixed that actual fetch-endpoint observability remains a refinement topic and should stay deferred under the current metadata model
  - `Sprint H3` fixed that producer-first ordering should be read as current implementation truth, but not yet as a broader policy commitment
  - `Sprint I1` reset the next real implementation backlog so that multi-replica policy comes first and retry/recovery comes second
  - `Sprint I2` realigned the completion overview and progress board so they now point directly to `I3` and `J1`
  - `Sprint I3` fixed the next real implementation question as multi-replica policy rather than retry/recovery
  - `Sprint J1` added the smallest helper cut that makes producer + first replica + second replica state repeatable
  - `Sprint J2` realigned the completion view and progress board so the next direct question is `K1`, followed by `K2` as the first multi-replica validation sprint
  - `Sprint K1` fixed the first multi-replica validation question as the scenario where producer and first replica both fail before the second replica fallback succeeds

## Completed Sprint Table

| Sprint | Status | Key Result |
|---|---|---|
| B1 | Complete | baseline-to-implementation gap review documented |
| B2 | Complete | `producerNode` connected to child placement input |
| B3 | Complete | metadata naming/state tightened, catalog validation improved |
| B4 | Complete | README / RESULTS wording aligned to the actual implementation level |
| B5 | Complete | live same-node / cross-node / second-hit rerun on `multipass-k8s-lab` |
| B6 | Complete | `fetch-failed` / `lastError` failure metadata recording strengthened |
| B7 | Complete | self-loop and peer fetch exception validated with evidence |
| B8 | Complete | `local digest mismatch` validated, public-path handling tightened |
| B9 | Complete | `peer digest mismatch` live branch validated, HTTP limitation identified |
| B10 | Complete | peer-side HTTP error attribution tightened |
| B11 | Complete | failure semantics research note written |
| B12 | Complete | taxonomy cross-links added to RESULTS / VALIDATION_HISTORY |
| B13 | Complete | README entry hook added for failure semantics |
| B14 | Complete | PROJECT_BASELINE hook added for failure semantics |
| B15 | Complete | SPRINT1_SCOPE hook added and scope wording aligned |
| B16 | Complete | bilingual document policy note fixed |
| C1 | Complete | core bilingual coverage audited and cross-links tightened |
| C2 | Complete | validated failure scenarios summarized in one matrix |
| C3 | Complete | decision note added to defer catalog-level failure reflection for now |
| C4 | Complete | English parity of TROUBLESHOOTING_NOTES improved |
| C5 | Complete | failure-matrix entry hooks added from README, RESULTS, and VALIDATION_HISTORY |
| C6 | Complete | note added to defer splitting `catalog lookup failed` for now |
| C7 | Complete | direct hooks added between the failure matrix and the research note |
| C8 | Complete | entry-audit concluded the current failure-doc navigation is sufficient |
| C9 | Complete | scope check concluded the failure taxonomy still fits Sprint 1 |
| C10 | Complete | navigation-freeze conclusion added for the current failure-doc set |
| C11 | Complete | decision fixed to avoid a dedicated failure-note index in the research README |
| C12 | Complete | short summary added to close the current Sprint 1 failure-doc cleanup scope |
| D1 | Complete | post-freeze next-step judgment fixed on the catalog/local-metadata control-layer gap |
| D2 | Complete | minimum edge-case gap list fixed for the catalog/local-metadata authority boundary |
| D3 | Complete | first post-freeze validation question selected as `catalog record exists + local artifact missing` |
| D4 | Complete | dedicated validation helper added to reproduce the selected edge case |
| D5 | Complete | live same-node evidence fixed for `catalog record exists + local artifact missing` |
| D6 | Complete | next question narrowed to the cross-node recovery view of the same edge case |
| D7 | Complete | cross-node evidence fixed for `catalog record exists + local artifact missing` |
| D8 | Complete | second edge case selected as `catalog record missing + local artifact exists` |
| D9 | Complete | dedicated helper and cut note added for the second edge case |
| D10 | Complete | live same-node evidence fixed for `catalog record missing + local artifact exists` |
| D11 | Complete | reassessment fixed that same-node is closed but the full edge-case family is still partially open |
| D12 | Complete | live cross-node evidence fixed for `catalog record missing + local artifact exists` |
| D13 | Complete | second edge-case family closed for the current validation scope |
| E1 | Complete | next priority fixed as an orphan semantics note after second-edge closure |
| E2 | Complete | same-node local reuse fixed as current behavior truth, but not as orphan-policy approval |
| E3 | Complete | catalog top-level failure reflection still deferred after recheck |
| E4 | Complete | broader policy boundary should not expand further and should leave only `E2` open |
| E5 | Complete | current policy/document cleanup scope frozen here before moving to next question selection |
| F1 | Complete | next real question selected as the smallest form of replica-aware fetch |
| F2 | Complete | implementation backlog reordered with replica-aware fetch as the top priority |
| F3 | Complete | smallest execution cut added for preparing replica-aware fetch validation |
| F4 | Complete | first live evidence fixed that replica-ready state exists while actual fetch remains producer-biased |
| F5 | Complete | replica-aware follow-up order fixed as validation first, cut second |
| F6 | Complete | next immediate execution fixed as producer-bias validation, with the minimal cut left for the following step |
| F7 | Complete | live evidence fixed that a third-node consumer still follows only the broken producerAddress instead of the existing replica |
| F8 | Complete | minimum cut added to expand `peer_fetch()` remote candidates from producer-only to producer plus replicaNodes |
| F9 | Complete | live evidence fixed that a third-node consumer now succeeds through replica fallback after producer failure |
| G1 | Complete | narrowed the remaining post-replica-aware gaps to observability and ordering semantics |
| G2 | Complete | reordered the next follow-up questions as completion refresh, observability, then ordering semantics |
| H1 | Complete | refreshed the completion overview and progress board for the post-replica-aware state |
| H2 | Complete | fixed that actual fetch-endpoint observability should remain deferred as a refinement topic for now |
| H3 | Complete | fixed that producer-first ordering is current implementation truth, but not yet a broader policy commitment |
| I1 | Complete | reset the post-H3 implementation backlog with multi-replica policy first |
| I2 | Complete | realigned completion and progress after the post-H3 backlog reset |
| I3 | Complete | fixed the next real implementation question as multi-replica policy |
| J1 | Complete | added the minimum execution cut that prepares producer + first replica + second replica state |
| J2 | Complete | realigned the next directly remaining question set around `K1` and `K2` |
| K1 | Complete | fixed the first multi-replica validation question as the second-replica fallback scenario |

## Current Backlog

| Area | Item | Priority | Current Judgment |
|---|---|---|---|
| Implementation | replica-aware fetch policy | Medium | promoted as the next real question |
| Implementation | catalog top-level failure reflection | Medium | still deferred |
| Implementation | retry / recovery policy | Low | intentionally out of current scope |
| Implementation | scheduler/controller integration evaluation | Low | still in script-assisted validation phase |
| Process | keep adding bilingual pairs for new documents | High | policy is fixed, execution must continue |

## Recommended Next 3 Sprints

### K2 - Multi-Replica First Validation

Goal:

- validate the first multi-replica policy question using the `J1` helper

Completion criteria:

- the first multi-replica evidence is recorded in the results documents

### L1 - Post-K2 Backlog Review

Goal:

- narrow the remaining backlog again after the first multi-replica validation

Completion criteria:

- the next follow-up question set is fixed in one note

### L2 - Post-K2 Completion Refresh

Goal:

- realign the completion view and progress board after `K2` and `L1`

Completion criteria:

- the completion document and the progress board point to the same next-question set

## Update Rule

Whenever a sprint finishes, update these sections together:

1. `Current Summary`
2. `Completed Sprint Table`
3. `Current Backlog`
4. `Recommended Next 3 Sprints`

So this document should be maintained as an ongoing **sprint progress board**, not as a one-off memo.
