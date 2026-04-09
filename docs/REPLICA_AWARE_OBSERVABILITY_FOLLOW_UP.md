# REPLICA_AWARE_OBSERVABILITY_FOLLOW_UP

## Purpose

This note records the decision for `Sprint H2 - Replica-Aware Observability Follow-Up`.

Question:

- Now that replica fallback has been validated with live evidence,
- should actual fetch-endpoint observability be added to the metadata model right away?

## Reference Documents

- [REPLICA_SOURCE_SELECTION_VALIDATION.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_VALIDATION.md)
- [POST_REPLICA_AWARE_GAP_REVIEW.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/POST_REPLICA_AWARE_GAP_REVIEW.md)
- [POST_REPLICA_AWARE_COMPLETION_VIEW_REFRESH.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/POST_REPLICA_AWARE_COMPLETION_VIEW_REFRESH.md)

## What Is Observable Right Now

- A third-node consumer can succeed through replica fallback after the producer is broken.
- The local metadata still keeps `producerAddress` as the origin producer address.
- That means the current local metadata can tell us the producer origin, but not the actual fetch endpoint directly.

## Decision

- At the current stage, actual fetch-endpoint observability will **not** be pulled into the metadata model yet.
- In other words, this question remains **deferred** for now.

## Why Defer Is Still The Right Choice

### 1. The current sprint question is already answered

- Did `replicaNodes` enter the actual source-selection path?
- Does replica fallback really happen after a broken producer?

Those questions are already closed with live evidence.

### 2. Fetch-endpoint observability belongs to a refinement step

It would immediately open follow-up questions such as:

- do we need a new field
- should it live in local metadata
- is documentation-level evidence already enough
- should it also be reflected in the catalog

### 3. The current evidence is already explainable with existing documents

By reading:

- the results document
- validation history
- the replica-aware validation note

we can already explain that the actual fetch endpoint was a replica.

## Rule Fixed For Now

- `producerAddress` keeps its meaning as the origin producer address.
- The actual fetch endpoint is not promoted to a metadata field yet.
- This question should be revisited only when the project opens:
  - multi-replica policy
  - retry/recovery
  - richer source-selection observability

## One-Line Conclusion

`actual fetch endpoint observability is useful, but it is still a refinement topic and remains deferred for now`
