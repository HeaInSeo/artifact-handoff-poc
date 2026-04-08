# NEXT_BACKLOG_ORDERING_NOTE

## Purpose

This note fixes the result of `Sprint F2 - Next Backlog Ordering Note`.

Question:

- after `F1` selected `replica-aware fetch` as the next real question,
- what is the right order for the remaining implementation backlog

## Reference documents

- [NEXT_VALIDATION_IMPLEMENTATION_QUESTION_SELECTION.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/NEXT_VALIDATION_IMPLEMENTATION_QUESTION_SELECTION.md)
- [SPRINT_PROGRESS.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SPRINT_PROGRESS.md)
- [CATALOG_FAILURE_REFLECTION_RECHECK.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/CATALOG_FAILURE_REFLECTION_RECHECK.md)

## Backlog ordering fixed in this sprint

The current order is fixed as:

1. `replica-aware fetch policy`
2. `catalog top-level failure reflection`
3. `retry / recovery policy`
4. `scheduler/controller integration evaluation`

## Why this order is right

### 1. Why `replica-aware fetch policy` is first

This item connects most directly to the current evidence.

- `replicaNodes` is already recorded in the catalog
- but it is still barely used for fetch source selection

So the field already exists, but it is still weak as a control-layer input.
That makes it the most natural next execution question.

### 2. Why `catalog top-level failure reflection` is second

This item is important, but still too large to reopen immediately.

Reopening it would immediately reopen:

- top-level truth ownership
- transient vs durable failure semantics
- multi-consumer aggregate state

So it matters, but it is still larger than the next immediate execution question.

### 3. Why `retry / recovery policy` is third

This item needs more state-machine and policy work.
The current fetch-source logic is still simple enough that retry/recovery should not come before replica-aware fetch.

### 4. Why `scheduler/controller integration evaluation` is fourth

This is the item that most quickly exceeds the current PoC scope.
The repository is still in a script-assisted validation phase, so opening this now would be premature.

## Next 3-step flow fixed in this sprint

The next flow should be:

1. `F3 - Next Execution Cut`
   - add the smallest helper or implementation cut for a replica-aware fetch experiment
2. `F4 - Replica-Aware Fetch First Validation`
   - validate the smallest replica-aware fetch hypothesis
3. only after that
   - reconsider whether to reopen `catalog top-level failure reflection`

## What this sprint still does not do

- implementing replica-aware fetch itself
- implementing retry / recovery
- designing scheduler/controller integration

This sprint only fixes the ordering.

## One-line conclusion

The conclusion of `Sprint F2` is that **the next implementation backlog should be ordered with `replica-aware fetch policy` first, then `catalog top-level failure reflection`, then `retry / recovery`, and finally `scheduler/controller integration`**.
