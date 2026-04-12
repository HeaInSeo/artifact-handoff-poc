# SPRINT_PROGRESS

## Purpose

This document tracks sprint progress for `artifact-handoff-poc` in one place.

It exists to:

- quickly show which sprints are complete
- show what remains in backlog
- make the next small sprint easier to choose

This is not a design document. It is a **progress board** and should be updated whenever a sprint finishes.

For a one-page view of current completion and remaining sprints, also see [PROJECT_COMPLETION_VIEW.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PROJECT_COMPLETION_VIEW.md).
For the conservative six-week parallel schedule that includes the full backlog, see [PARALLEL_6W_DELIVERY_PLAN.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PARALLEL_6W_DELIVERY_PLAN.md).

## Current Summary

- completed sprints: `B1` through `B16`, `C1`, `C2`, `C3`, `C4`, `C5`, `C6`, `C7`, `C8`, `C9`, `C10`, `C11`, `C12`, `D1`, `D2`, `D3`, `D4`, `D5`, `D6`, `D7`, `D8`, `D9`, `D10`, `D11`, `D12`, `D13`, `E1`, `E2`, `E3`, `E4`, `E5`, `F1`, `F2`, `F3`, `F4`, `F5`, `F6`, `F7`, `F8`, `F9`, `G1`, `G2`, `H1`, `H2`, `H3`, `I1`, `I2`, `I3`, `J1`, `J2`, `K1`, `K2`, `L1`, `L2`, `M1`, `M2`, `N1`, `N2`, `O1`, `O2`, `P1`, `P2`, `Q1`, `Q2`, `R1`, `R2`, `S1`, `S2`, `T1`, `T2`, `T3`, `U1`, `U2`
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
  - multi-replica first validation track `K2`: `1/1` complete, `100%`
  - post-K2 backlog review track `L1`: `1/1` complete, `100%`
  - post-K2 completion refresh track `L2`: `1/1` complete, `100%`
  - post-L2 implementation reset track `M1`: `1/1` complete, `100%`
  - multi-replica ordering entry track `M2`: `1/1` complete, `100%`
  - post-M2 execution cut track `N1`: `1/1` complete, `100%`
  - post-M2 completion refresh track `N2`: `1/1` complete, `100%`
  - post-N2 backlog review track `O1`: `1/1` complete, `100%`
  - post-O1 implementation entry track `O2`: `1/1` complete, `100%`
  - post-O2 execution cut track `P1`: `1/1` complete, `100%`
  - post-P1 completion refresh track `P2`: `1/1` complete, `100%`
  - post-P2 backlog review track `Q1`: `1/1` complete, `100%`
  - post-Q1 implementation entry track `Q2`: `1/1` complete, `100%`
  - post-Q2 execution cut track `R1`: `1/1` complete, `100%`
  - post-R1 completion refresh track `R2`: `1/1` complete, `100%`
  - post-R2 backlog review track `S1`: `1/1` complete, `100%`
  - post-S1 implementation entry track `S2`: `1/1` complete, `100%`
  - post-S2 execution cut track `T1`: `1/1` complete, `100%`
  - post-T1 completion refresh track `T2`: `1/1` complete, `100%`
  - post-T2 backlog review track `T3`: `1/1` complete, `100%`
  - dynamic DAG placement validation track `U1`: `1/1` complete, `100%`
  - dynamic placement interface cut track `U2`: `1/1` complete, `100%`
  - currently documented sprint set `B1~B16` + `C1~C12` + `D1~D13` + `E1~E5` + `F1~U2`: `88/88` complete, `100%`
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
  - `Sprint K2` collected the first live evidence that a producer-node consumer can still succeed through a second-replica fallback after both the producer candidate and the first replica candidate fail
  - `Sprint L1` narrowed the next minimum gaps after `K2` to multi-replica ordering semantics, observability refinement, and retry/recovery, and fixed the direct flow as `L2 -> M1 -> ordering semantics`
  - `Sprint L2` realigned the completion view and the progress board so they now point to the same next-question set: `M1 -> M2`
  - `Sprint M1` regrouped the remaining post-L2 implementation backlog and fixed the next direct implementation question as multi-replica ordering semantics
  - `Sprint M2` fixed multi-replica ordering semantics as an explicit implementation question about `producer -> recorded replica order`
  - `Sprint N1` added the first execution helper cut that makes recorded replica order repeatable and testable
  - `Sprint N2` realigned the completion view and the progress board so they now point to the same next-question set: `O1 -> O2`
  - `Sprint O1` narrowed the remaining post-N2 implementation backlog further toward recorded replica-order semantics
  - `Sprint O2` fixed recorded replica-order semantics as the next direct implementation topic and passed broader policy commitment to a later stage while routing the next step to `P1`
  - `Sprint P1` added the minimum probe helper cut that prints catalog recorded order and producer-side metadata together for the recorded replica-order question
  - `Sprint P2` realigned the completion view and progress board into the `Q1 -> Q2` flow
  - `Sprint Q1` narrowed the recorded replica-order question back down to current-implementation reading rather than broader policy
  - `Sprint Q2` fixed the `producer -> recorded replica order` reading as the next direct implementation entry
  - `Sprint R1` added the minimum wrapper helper for replaying that reading as ordered-candidate output
  - `Sprint R2` realigned the completion view and progress board to the same remaining-question set after `Q2` and `R1`
  - `Sprint S1` narrowed the remaining implementation backlog again after `R1` and `R2`, and fixed the next direct question as `S2`
  - `Sprint S2` fixed the next direct implementation entry as the `consumer perspective-aware producer -> recorded replica order` reading
  - `Sprint T1` added the minimum perspective helper cut that replays the remote candidate order from each agent pod's point of view
  - `Sprint T2` realigned the remaining question set after `S2` and `T1` into the `T3 -> U1` flow
  - `Sprint T3` narrowed the remaining post-perspective-reading refinement question again into a small next entry scope
  - as a separate research extension, the repository has started expanding `docs/research/dragonfly-with*` around Dragonfly fork-fit and upstream-alignment questions
  - based on remote lab validation at `100.123.80.48`, the repository added a `dragonfly-adapter-contract` research note grounded in Helm install and `dfcache` export checks
  - `Sprint U1` fixed the current understanding that the remote Multipass K8s validation of `poc` does not show parent-result-driven dynamic placement; the observed same-node outcome was a `local-path` PVC `selected-node` side effect
  - `Sprint U2` fixed the minimum interface cut for dynamic placement from the same remote evidence, separating it into `ArtifactBinding + PlacementIntent + ResolvedPlacement`
  - the full-backlog completion schedule is separately fixed in [PARALLEL_6W_DELIVERY_PLAN.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PARALLEL_6W_DELIVERY_PLAN.md) as a `6-week / 4-track` plan

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
| K2 | Complete | live validation confirmed second-replica fallback after producer and first-replica failure |
| L1 | Complete | narrowed the remaining minimum gaps and follow-up order after K2 |
| L2 | Complete | realigned completion view and progress board to the same next-question set after K2 |
| M1 | Complete | reset the post-L2 implementation backlog around multi-replica ordering semantics |
| M2 | Complete | fixed multi-replica ordering semantics as an implementation question around `producer -> recorded replica order` |
| N1 | Complete | added the first execution helper cut for repeatable recorded-replica-order checks |
| N2 | Complete | realigned completion view and progress board to the same next-question set after `M2` and `N1` |
| O1 | Complete | narrowed the remaining post-N2 implementation backlog further toward recorded replica-order semantics |
| O2 | Complete | fixed recorded replica-order semantics as the next direct implementation topic |
| P1 | Complete | added the minimum probe helper cut for reading recorded replica-order semantics more directly |
| P2 | Complete | realigned completion/progress into the `Q1 -> Q2` flow |
| Q1 | Complete | narrowed the recorded replica-order question down to current-implementation reading |
| Q2 | Complete | fixed the `producer -> recorded replica order` reading as the next direct implementation entry |
| R1 | Complete | added the minimum wrapper helper for replaying the `producer -> recorded replica order` reading |
| R2 | Complete | realigned completion/progress to the same remaining-question set after `Q2` and `R1` |
| S1 | Complete | narrowed the remaining implementation backlog again after `R1` and `R2`, and fixed the next direct question as `S2` |
| S2 | Complete | fixed the next direct implementation entry as the `consumer perspective-aware producer -> recorded replica order` reading |
| T1 | Complete | added the minimum perspective helper cut that replays the remote candidate order from each agent pod's point of view |
| T2 | Complete | realigned the remaining question set after `S2` and `T1` into the `T3 -> U1` flow |
| T3 | Complete | narrowed the remaining post-perspective-reading refinement question again into a small next entry scope |
| U1 | Complete | validated on the remote Multipass K8s lab that the current `poc` path has no dynamic placement hints in Job specs and that the observed same-node outcome comes from PVC `selected-node` side effects |
| U2 | Complete | fixed the minimum dynamic-placement interface cut from the same remote evidence, separating it into `ArtifactBinding + PlacementIntent + ResolvedPlacement` |

## Current Backlog

| Area | Item | Priority | Current Judgment |
|---|---|---|---|
| Implementation | multi-replica ordering semantics | Medium | perspective-aware reading review is closed, and the next step is to refix the next entry scope in `U1` |
| Research | Dragonfly fork-fit / upstream alignment | High | opened as a research track, with shallow adapter fit favored over a deep fork |
| Research | Dragonfly adapter contract | High | added a product-owned contract draft backed by remote lab validation |
| Validation | dynamic DAG placement | High | remote validation now shows the current `poc` path does not implement dynamic placement, and `U2` fixed the minimum interface cut from that result |
| Implementation | placement interface / submit mutation | High | the next step is `U3`, which should validate real child Job mutation |
| Implementation | catalog top-level failure reflection | Medium | still deferred |
| Implementation | retry / recovery policy | Low | the next follow-up after multi-replica ordering |
| Implementation | scheduler/controller integration evaluation | Low | still in script-assisted validation phase |
| Process | keep adding bilingual pairs for new documents | High | policy is fixed, execution must continue |

## Six-Week Parallel Operating Baseline

- conservative full-backlog schedule: `6 weeks`
- parallel tracks:
  - validation
  - implementation
  - policy/decision
  - docs/release
- detailed schedule: [PARALLEL_6W_DELIVERY_PLAN.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PARALLEL_6W_DELIVERY_PLAN.md)

## Recommended Next 3 Sprints

### U3 - Parent-Result Placement Injection Validation

Goal:

- connect the `U2` interface to actual child Job placement mutation

Completion criteria:

- explicit placement-mutation evidence is captured on the remote Multipass K8s lab

### U4 - Post-U3 Completion Refresh

Goal:

- realign completion/progress documents to the same remaining-question set after `U3`

Completion criteria:

- a refresh note is fixed in one document

### U5 - Dynamic Fallback Validation Entry

Goal:

- fix the remote-fallback question as the next direct validation entry after explicit placement mutation

Completion criteria:

- the next validation-entry note is fixed in one document

## Update Rule

Whenever a sprint finishes, update these sections together:

1. `Current Summary`
2. `Completed Sprint Table`
3. `Current Backlog`
4. `Recommended Next 3 Sprints`

So this document should be maintained as an ongoing **sprint progress board**, not as a one-off memo.
