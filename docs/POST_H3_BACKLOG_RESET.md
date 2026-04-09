# POST_H3_BACKLOG_RESET

## Purpose

This note records the decision for `Sprint I1 - Post-H3 Backlog Reset`.

Question:

- After finishing `H2` and `H3`,
- how should the remaining implementation backlog now be regrouped into the smallest next questions?

## Reference Documents

- [REPLICA_AWARE_OBSERVABILITY_FOLLOW_UP.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_OBSERVABILITY_FOLLOW_UP.md)
- [REPLICA_ORDERING_SEMANTICS_NOTE.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_ORDERING_SEMANTICS_NOTE.md)
- [PROJECT_COMPLETION_VIEW.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PROJECT_COMPLETION_VIEW.md)

## What Is Already Closed

- replica fallback after producer failure
- the decision to defer actual fetch-endpoint observability
- the decision to read producer-first ordering as current implementation truth

In other words, the first replica-aware validation cycle is now closed once within the current scope.

## Backlog Regrouped From Here

### 1. Multi-replica policy

- So far the project only handled one first replica.
- Source selection across multiple replicas remains undefined.

### 2. Retry / recovery policy

- One producer-failure path and one replica fallback path were validated.
- Timeout/backoff/retry behavior is still outside the validated scope.

### 3. Catalog top-level failure reflection

- This remains deferred.
- It is still better to revisit it only when stronger operational pressure appears.

### 4. Scheduler/controller integration

- This remains larger than the current validation-repo scope.

## Reset Result

- The next real implementation backlog should now start with `multi-replica policy`.
- `retry / recovery policy` comes after that.
- `catalog top-level failure reflection` remains deferred.

## Sprint Conclusion

- the next cleanup sprint is `I2 - Post-H3 Completion View Refresh`
- the next actual selection sprint is `I3 - Next Implementation Question Selection`
- `I3` should narrow whether `multi-replica policy` or `retry/recovery` should become the next real implementation target

## One-Line Verdict

`after the first replica-aware cycle, the next real implementation backlog resets to multi-replica policy first, retry/recovery second`
