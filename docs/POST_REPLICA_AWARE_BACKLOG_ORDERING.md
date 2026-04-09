# POST_REPLICA_AWARE_BACKLOG_ORDERING

## Purpose

This note records the decision for `Sprint G2 - Post-Replica-Aware Backlog Ordering`.

Question:

- After the first replica-aware implementation/validation cycle and the `G1` gap review,
- what should the next 2-3 implementation/validation questions be, and in what order?

## Reference Documents

- [POST_REPLICA_AWARE_GAP_REVIEW.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/POST_REPLICA_AWARE_GAP_REVIEW.md)
- [REPLICA_SOURCE_SELECTION_VALIDATION.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_VALIDATION.md)
- [REPLICA_SOURCE_SELECTION_MINIMAL_CUT.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_MINIMAL_CUT.md)

## Candidate Questions

- should actual fetch-endpoint observability be handled next
- should producer-first ordering semantics be fixed more explicitly
- should multi-replica policy be opened now
- should catalog top-level failure reflection be reopened

## Ordering Decision

### Priority 1: H1 - Post-Replica-Aware Completion View Refresh

- Now that the first replica-aware cycle is closed once, it makes sense to refresh the completion view and the remaining roadmap first.
- This is the cleanest way to restate what is already established and what still remains.

### Priority 2: H2 - Replica-Aware Observability Follow-Up

- The smallest technical follow-up is actual fetch-endpoint observability.
- The current metadata keeps `producerAddress` as the origin producer, so it does not directly expose the real fetch endpoint.
- But before turning this into code work, it is better to decide whether it should remain a note-level follow-up.

### Priority 3: H3 - Replica Ordering Semantics Note

- It is more appropriate to narrow producer-first ordering into a note first: is it current implementation truth, or is it the next policy candidate?
- This is still smaller than jumping directly into multi-replica policy.

## Questions Deferred For Now

- multi-replica policy
- catalog top-level failure reflection
- retry / recovery
- scheduler/controller integration

These are still too large to reopen immediately after the first replica-aware cycle.

## Sprint Conclusion

- next sprint: `H1 - Post-Replica-Aware Completion View Refresh`
- after that: `H2 - Replica-Aware Observability Follow-Up`
- then: `H3 - Replica Ordering Semantics Note`

## One-Line Verdict

`completion refresh first, observability second, ordering semantics third`
