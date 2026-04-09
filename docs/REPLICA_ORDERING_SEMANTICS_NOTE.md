# REPLICA_ORDERING_SEMANTICS_NOTE

## Purpose

This note records the decision for `Sprint H3 - Replica Ordering Semantics Note`.

Question:

- How should the current `producer-first ordering` be interpreted?
- Should it already be treated as a committed policy, or only as the truth of the current minimal implementation cut?

## Reference Documents

- [REPLICA_SOURCE_SELECTION_MINIMAL_CUT.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_MINIMAL_CUT.md)
- [REPLICA_SOURCE_SELECTION_VALIDATION.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_VALIDATION.md)
- [REPLICA_AWARE_OBSERVABILITY_FOLLOW_UP.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_OBSERVABILITY_FOLLOW_UP.md)

## What Is Currently Confirmed

- If a local hit exists, the local path is used.
- The remote candidate set is currently built in this order:
  - producer
  - replicaNodes
- When the producer is broken, replica fallback really works.
- When the producer is healthy, the current implementation does not prefer replicas ahead of the producer.

## Decision

- At the current stage, `producer-first ordering` should be treated as **current implementation truth**.
- But it should **not yet** be treated as a broader **policy commitment**.

## Why This Is The Right Reading

### 1. The goal of the cut was not to finalize ordering policy

- The goal of `F8` was to move `replicaNodes` into the source candidate set.
- Designing the optimal ordering policy remained out of scope.

### 2. The current evidence is enough to explain the current behavior

- If the producer breaks, the code falls through to a replica.
- If the producer is healthy, replicas are not preferred ahead of it.

So the current behavior is clear enough.

### 3. But this is still not the final policy

Questions about:

- multi-replica ordering
- replica freshness / preference
- interaction with retry/recovery

remain open.

## Rule Fixed For Now

- producer-first ordering remains the truth of the current implementation
- replica fallback remains the current behavior after producer failure
- broader ordering policy remains a later refinement question

## One-Line Conclusion

`producer-first ordering is the current implementation truth, but not yet a broader policy commitment`
