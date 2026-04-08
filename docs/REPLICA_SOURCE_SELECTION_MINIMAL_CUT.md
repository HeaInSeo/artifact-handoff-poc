# REPLICA_SOURCE_SELECTION_MINIMAL_CUT

## Purpose

This note fixes the minimum implementation cut introduced in `Sprint F8 - Replica Source-Selection Minimal Cut`.

Question:

- what is the smallest cut that connects `replicaNodes` to actual source selection?

## Reference Documents

- [PRODUCER_BIAS_VALIDATION_KICKOFF.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PRODUCER_BIAS_VALIDATION_KICKOFF.md)
- [REPLICA_AWARE_DECISION_NOTE.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_DECISION_NOTE.md)

## Scope of This Cut

This sprint changes only the following:

- the remote candidate set inside `peer_fetch()`
  - before: only `producerAddress`
  - after: `producerAddress` + `replicaNodes[*].address`

The following remain unchanged:

- local-first hit behavior
- catalog top-level authority
- retry / recovery policy
- complex replica-priority policy
- scheduler/controller integration

## Current Implementation Rule

The current minimum-cut rule is:

1. if there is a local hit, use it as before
2. if remote fetch is needed, build a candidate list
3. the candidate order is:
   - producer
   - replicaNodes
4. self address and duplicate addresses are excluded
5. if the producer candidate fails, move to a replica candidate

## Why This Is the Minimum Cut

- it connects `replicaNodes` to the real control path
- but it keeps producer-first ordering, so the meaning change stays narrow
- the current validation question is “can a replica become a source candidate?”
  not “what is the optimal source-selection policy?”

## What Remains Deferred

- more refined ordering between producer and replica
- selection among multiple replicas
- failure aggregation
- retry / backoff

## Next Connection Point

The next sprint should validate whether this cut produces an actual source-selection change.
