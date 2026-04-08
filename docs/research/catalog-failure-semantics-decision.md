# catalog-failure-semantics-decision

## 1. Research Question

At the current stage of `artifact-handoff-poc`, should failure information be reflected in the catalog top-level state, or should the project remain centered on local metadata?

## 2. Key Summary

At the current stage, the right decision is to **defer catalog top-level failure reflection and remain local-metadata-centric.**

The reason is straightforward:

1. the core question of this repository is `location-aware handoff validation`, not a global failure registry
2. the validated failures already leave enough traces in consumer-side local metadata as `state=fetch-failed`, `lastError`, and `source`
3. adding catalog top-level failure state too early would immediately enlarge authority rules, state transitions, and cleanup semantics

So for now, promoting failure into cluster-wide truth is less useful than keeping a reliable node-local forensic trail.

## 3. Current Decision

Verdict: `defer`

The current model is:

- catalog top-level record
  - authoritative source for producer origin and placement decisions
- local metadata
  - observation record for local hit, replicated copy, verification result, and fetch failure on the current node

So the current failure-semantics rule is:

- same-node / cross-node handoff decisions:
  - driven by the catalog
- failure forensic trail:
  - driven by local metadata

## 4. Why Not Add Catalog Top-Level Failure State Yet

### A. It is not directly tied to the current core question

The repository is still trying to validate:

- can artifact location be recorded
- can same-node reuse be induced from that location
- can cross-node peer fetch work when same-node reuse is not available

The key thing here is knowing producer origin and current location, not building a cluster-wide failure registry first.

### B. Local metadata already carries the needed traces

The validated failures already leave the following in local metadata:

- `source=catalog-lookup`
- `source=peer-fetch`
- `source=local-verify`
- `state=fetch-failed`
- `lastError=<human-readable cause>`

At the current scope, that is already enough to trace which node failed at which step.

### C. Catalog-level failure would blur authority boundaries

Once `fetch-failed`-style states are added to the catalog top level, the following questions open immediately:

- whose failure becomes top-level truth
- if the producer is healthy but one consumer fails, should the top-level state become failed
- should transient transport failure and durable artifact corruption live at the same level
- who clears the failure state after the situation is recovered

Those questions are beyond the current sprint scope.

### D. The state-transition cost becomes much larger

Right now the catalog top-level state is intentionally narrow and producer-origin-centric:

- `produced`

If failure-aware states are added there, at least these concerns come with it:

- state-transition rules
- multi-consumer concurrency handling
- stale failure cleanup
- redefining success after retry

At the current stage, that cost is larger than the immediate value.

## 5. Rules To Keep For Now

The current operating rules should stay like this:

1. the catalog is the anchor for producer origin and placement hints
2. local metadata is the anchor for node-local copies and failure forensic trails
3. `fetch-failed` stays in local metadata only
4. results documents and the failure matrix should continue to interpret evidence from local metadata

## 6. Conditions For Reconsidering Catalog Reflection Later

Catalog-level failure reflection can be reconsidered if one or more of these conditions appear.

### A. Failure needs to be aggregated across multiple consumers

- when the project needs to see whether the same artifact is repeatedly failing across nodes

### B. Placement decisions need failure history directly

- when same-node reuse or peer-fetch candidate selection needs recent failure history

### C. Controller/scheduler integration is being evaluated

- when the catalog becomes a more direct placement-control input rather than a simple registry

### D. Retry / recovery policy is introduced

- when failure must be handled as shared state rather than as local notes

## 7. What To Borrow

- the separation between catalog authority and local observation
- delaying global state expansion until it is justified by the current validation question
- keeping failure as local forensic trail and interpreting it through results documents

## 8. What Not To Borrow

- expanding the catalog top-level state machine at this stage
- designing a global failure registry now
- bundling retry / recovery policy into this note
- designing multi-consumer conflict resolution now

## 9. Immediate Sprint-Level Outcome

- the current decision for catalog failure semantics is `defer`
- the implementation stays unchanged
- later work such as splitting `catalog lookup failed` or evaluating controller integration should build on top of this decision

## 10. Candidate Next Steps

- improve English parity in `TROUBLESHOOTING_NOTES.md`
- add a short entry hook to the failure matrix from README or results/history
- write a small note on whether splitting `catalog lookup failed` into 404/5xx is actually needed
