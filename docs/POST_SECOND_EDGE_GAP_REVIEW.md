# POST_SECOND_EDGE_GAP_REVIEW

## Purpose

This note records the result of `Sprint E1 - Post-Second-Edge Gap Review`.

Background:

- the first edge-case family was closed at `D7`
- the second edge-case family was closed for the current Sprint 1 validation scope at `D13`

So the next question is no longer which edge-case family to extend, but which backlog item should become the next smallest step.

## Current Backlog Candidates

The current backlog can be summarized as:

1. `catalog top-level failure reflection`
2. orphan/local-leftover semantics
3. replica-aware fetch policy
4. retry / recovery policy
5. scheduler/controller integration evaluation

## Review Conclusion

The next priority is fixed as:

- document `orphan/local-leftover semantics` first as a note

So the next question becomes:

- how should the current-stage implementation interpret the same-node local reuse observed under `catalog record missing + local artifact exists`

This should be handled first as a **research/validation note**, not as a policy or implementation expansion.

## Why This Is The Right Next Step

There are three reasons.

1. it connects directly to the second edge-case family that was just closed
2. it can be fixed first with documentation judgment rather than code expansion
3. it is closer to the current implementation truth than `catalog top-level failure reflection`

In contrast, `catalog top-level failure reflection` would immediately open larger questions such as:

- global failure-state semantics
- state-transition ownership
- the boundary between transient failures and durable state

Orphan/local-leftover semantics is smaller. It is mainly about how to read what was already observed:

- same-node local-first reuse
- cross-node catalog-lookup failure

## Priority Fixed In This Sprint

Priority 1:

- `E2 - Orphan Semantics Note`

Priority 2:

- `E3 - Catalog Failure Reflection Recheck`

Priority 3:

- after that, choose one smallest validation or implementation question

## What Still Stays Deferred

These remain deferred:

- replica-aware fetch policy
- retry / recovery policy
- scheduler/controller integration

Each of them would require a broader expansion than the current stage.

## One-Line Conclusion

The conclusion of `Sprint E1` is: **the next smallest question is to document orphan/local-leftover semantics first, while catalog top-level failure reflection stays as the following priority**.
