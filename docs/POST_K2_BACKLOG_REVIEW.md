# POST_K2_BACKLOG_REVIEW

## Purpose

This note narrows the remaining backlog again after the first multi-replica validation in `Sprint L1 - Post-K2 Backlog Review`.

`K2` already closed the live fact that the current source-selection path can continue to a second replica under:

- a broken producer
- a broken first replica
- a live second replica

So the question now moves from
"does a second-replica fallback path exist"
to
"what is the next smallest policy or implementation question after that path is confirmed"

## What Is Closed After K2

The following points are now treated as closed for this review:

- a producer-first plus replica-fallback candidate set participates in a real live path
- single-replica fallback works in practice
- second-replica fallback can also happen on a real live path
- the current multi-replica path works at least as a linear candidate iteration

## Smallest Remaining Gaps

This review narrows the remaining minimum gaps to:

1. multi-replica ordering semantics
2. actual fetch-endpoint observability refinement
3. retry / recovery policy

Among them, the most direct next question is `multi-replica ordering semantics`.

## Why Ordering Semantics Comes Next

- `K2` showed that the path can reach a second replica
- but replica-among-replica ordering is still undefined
- the repository can now say:
  - the path reaches a second replica
  - but not yet why that order should be treated as policy
  - and not yet how freshness or preference should be interpreted

By contrast, these topics are still larger than the current step:

- retry / recovery
- richer observability fields
- catalog top-level failure reflection
- scheduler/controller integration

## Follow-Up Order Fixed Here

1. `L2 - Post-K2 Completion Refresh`
2. `M1 - Post-L2 Implementation Reset`
3. after that, the next real question becomes `multi-replica ordering semantics`

So the flow is fixed as:
first align the completion/progress documents with the new `K2` state,
then promote ordering semantics as the next implementation question,
instead of opening a larger implementation immediately.

## Intentionally Not Done Here

- multi-replica ordering implementation
- retry / recovery implementation
- observability-field expansion
- reopening catalog failure reflection

This sprint is a backlog-review sprint.
