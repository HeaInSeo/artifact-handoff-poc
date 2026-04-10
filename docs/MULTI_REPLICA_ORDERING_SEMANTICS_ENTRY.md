# MULTI_REPLICA_ORDERING_SEMANTICS_ENTRY

## Purpose

This document records `Sprint M2 - Multi-Replica Ordering Semantics Entry` and fixes the scope for opening multi-replica ordering semantics as the next real implementation question.

## Question Fixed In This Entry

The next implementation question should be read narrowly as follows.

- should the current multi-replica remote candidate iteration be made explicit as
  `producer -> replicaNodes in recorded order`?
- and should the next step be the smallest execution cut that makes that ordering clearer?

In other words, this entry does not open a broader smart replica-selection policy.

## Why This Is The Smallest Next Step

### 1. The live evidence already reaches second-replica fallback

- broken producer
- broken first replica
- successful second-replica fallback

That path is already fixed by `K2`.

### 2. The current code path already has candidate ordering, but it is not yet fixed as an implementation question

- local hit comes first
- the remote candidate set starts with the producer
- replica candidates follow `replicaNodes` in order

But that still has not been opened as an explicit broader policy commitment.

### 3. Larger questions would widen the scope too early

This step still does not open:

- replica freshness scoring
- health-based source preference
- multi-replica retry/backoff policy
- actual fetch-endpoint observability field expansion

## Rules Fixed Here

- the next direct implementation question is `ordering semantics explicitness`
- the current behavior should be read first as
  `producer -> replicaNodes in recorded order`
- broader replica policy remains a later refinement topic

## Next-Step Criteria

In `N1 - Post-M2 Execution Cut`, choose the smallest form of one of these:

1. a small cut that makes the candidate-iteration rule more explicit in code/docs
2. a minimum helper or validation cut that checks whether recorded replica order has real meaning

## One-Line Conclusion

`multi-replica ordering semantics should now be opened as an explicit implementation question about producer-first, then recorded-replica order`
