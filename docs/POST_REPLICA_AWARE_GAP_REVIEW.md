# POST_REPLICA_AWARE_GAP_REVIEW

## Purpose

This note records the decision for `Sprint G1 - Post-Replica-Aware Gap Review`.

Question:

- After the first replica-aware implementation/validation cycle from `Sprint F4` through `Sprint F9`,
- what are the next remaining gaps that deserve attention right now?

## Reference Documents

- [REPLICA_AWARE_FIRST_VALIDATION.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_FIRST_VALIDATION.md)
- [PRODUCER_BIAS_VALIDATION_KICKOFF.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PRODUCER_BIAS_VALIDATION_KICKOFF.md)
- [REPLICA_SOURCE_SELECTION_MINIMAL_CUT.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_MINIMAL_CUT.md)
- [REPLICA_SOURCE_SELECTION_VALIDATION.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_VALIDATION.md)

## What This Cycle Already Confirmed

- `replicaNodes` are actually recorded in the catalog.
- First-replica local metadata is recorded as `state=replicated`, `source=peer-fetch`.
- Even with a broken producer, a third-node consumer can succeed through replica fallback.
- That means `replicaNodes` are no longer observation-only; they now participate in the fallback candidate set.

## Narrow Gaps That Still Remain

### 1. Actual fetch endpoint observability

- Even when a third-node consumer succeeds via replica fallback, local metadata still keeps `producerAddress` as the origin producer address.
- In other words, the metadata alone does not clearly tell us which endpoint actually served the artifact.

### 2. Source-selection ordering semantics

- The current cut still preserves producer-first ordering.
- It is still not fully settled whether “never use replicas when the producer is healthy” is an intended policy or simply the result of the current minimal cut.

### 3. Multi-replica policy

- The current validation only covered one first replica.
- Source ordering across multiple replicas remains out of scope.

## Gaps Not Worth Opening Right Now

- retry / backoff / recovery semantics
- catalog top-level failure reflection
- scheduler/controller integration
- cleanup/GC

These are too large to reopen right after the first replica-aware cycle.

## Sprint Conclusion

- The smallest next step is to reorder the remaining backlog after the replica-aware cycle.
- That means going directly to `G2 - Post-Replica-Aware Backlog Ordering`.
- After that ordering note, `H1` should refresh the completion overview.

## One-Line Verdict

`the first replica-aware cycle is closed once, but observability and ordering semantics remain as the next narrow gaps`
