# NEXT_VALIDATION_IMPLEMENTATION_QUESTION_SELECTION

## Purpose

This note fixes the result of `Sprint F1 - Next Validation/Implementation Question Selection`.

Question:

- after closing the `E1~E5` policy/document cleanup flow, what should be the next real validation or implementation question

## Basis for this selection

This judgment is based on:

- [POST_E2_FREEZE_CHECK.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/POST_E2_FREEZE_CHECK.md)
- [SPRINT_PROGRESS.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SPRINT_PROGRESS.md)
- [CATALOG_FAILURE_REFLECTION_RECHECK.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/CATALOG_FAILURE_REFLECTION_RECHECK.md)

The main remaining backlog candidates were:

1. catalog top-level failure reflection
2. replica-aware fetch policy
3. retry / recovery policy
4. scheduler/controller integration evaluation

## Selection result of this sprint

The next real question is fixed as:

- **the smallest validation/implementation question around promoting `replicaNodes` into a real fetch-policy input**

In shorter form:

- choose `replica-aware fetch policy` as the next question

## Why this is the right next question

### 1. It connects most directly to the current evidence

The current evidence already shows:

- successful cross-node peer fetch records `replicaNodes` in the catalog
- but the current fetch path still mainly relies on `producerAddress`

So `replicaNodes` already exists, but it is still weak as a control-layer input.
That makes it the most natural next question after the current validation truth.

### 2. It is smaller than catalog top-level failure reflection

`catalog top-level failure reflection` has already been deferred multiple times for good reason.

Reopening it as the next implementation question would immediately reopen:

- top-level truth ownership
- transient vs durable failure semantics
- multi-consumer aggregate state

That is too large for the current scope.

Replica-aware fetch is narrower:

- can the existing `replicaNodes` field be used
- can replicas become a fallback source instead of always favoring the producer

### 3. It is much smaller than retry/recovery or scheduler/controller work

Retry/recovery would require more policy and state-machine work.
Scheduler/controller integration would move beyond the current PoC scope immediately.

So replica-aware fetch is the smallest next execution question.

## Minimum narrowed question fixed in this sprint

The next question should be read narrowly:

- using the current `replicaNodes` field
- can we design the smallest replica-aware fetch experiment
- for situations where producer-only fetch is too narrow or producer availability is constrained

So the next step is not “general replica-aware distribution.”
It is simply:

- can the existing catalog field become meaningful for fetch source selection

## What this sprint still does not open

The following remain deferred:

- implementing catalog top-level failure reflection
- implementing retry / recovery policy
- scheduler/controller integration
- cleanup/GC

## Connection to the next two sprints

After this selection, the next two steps should be:

- `F2 - Next Backlog Ordering Note`
  - reorder the remaining backlog with replica-aware fetch as the new top priority
- `F3 - Next Execution Cut`
  - define the smallest helper or implementation cut for a replica-aware fetch experiment

## One-line conclusion

The conclusion of `Sprint F1` is that **the next real validation/implementation question should be the smallest replica-aware fetch question: whether `replicaNodes` can be made meaningful for fetch source selection**.
