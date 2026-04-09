# NEXT_IMPLEMENTATION_QUESTION_SELECTION

## Purpose

This note records the decision for `Sprint I3 - Next Implementation Question Selection`.

Question:

- After `I1` and `I2`, what should the next real implementation question be?
- Between `multi-replica policy` and `retry / recovery policy`, which one is the smaller next step?

## Reference Documents

- [POST_H3_BACKLOG_RESET.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/POST_H3_BACKLOG_RESET.md)
- [POST_H3_COMPLETION_VIEW_REFRESH.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/POST_H3_COMPLETION_VIEW_REFRESH.md)
- [PROJECT_COMPLETION_VIEW.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PROJECT_COMPLETION_VIEW.md)

## Candidate Questions

### Candidate 1. Multi-replica policy

- So far the project only handled one first replica.
- Source selection across multiple replicas is still undefined.

### Candidate 2. Retry / recovery policy

- Producer failure and replica fallback were validated.
- But timeout/backoff/retry semantics are still untouched.

## Selection Result

- The next real implementation question is fixed as `multi-replica policy`.

## Why This Question Comes First

### 1. It connects most directly to the current replica-aware flow

- `replicaNodes` were moved into the source candidate set
- single-replica fallback was already validated live

The next natural question is: “what happens when there are multiple replicas?”

### 2. It is still smaller than retry / recovery

- retry / recovery opens timeout, backoff, retry count, and state interaction together
- multi-replica policy only extends the current source-selection semantics by one step

### 3. It already matches the current metadata model

- `replicaNodes` are already recorded in the catalog
- so this is about turning an existing field into a real policy question rather than inventing a new concept

## Sprint Conclusion

- the next execution cut is `J1 - Post-I3 Execution Cut`
- its scope should be the smallest helper or implementation cut that opens the `multi-replica policy` question

## One-Line Verdict

`the next real implementation question is multi-replica policy, not retry/recovery`
