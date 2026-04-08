# SECOND_EDGE_CASE_IMPLEMENTATION_CUT

## Purpose

This note records the smallest implementation/validation adjustment introduced in `Sprint D9 - Second Edge Case Implementation Cut`.

## Scope Of This Cut

This sprint does not add a new control plane or a new state model.

Instead, it adds a dedicated validation helper for the second edge case selected in `Sprint D8`:

- `catalog record missing + local artifact exists`

Added file:

- [run-edge-case-catalog-miss.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-edge-case-catalog-miss.sh)

## Why This Is The Smallest Reasonable Cut

The core of this question is to keep the local artifact copy intact while removing only the catalog truth.

If we heavily modify the existing helpers or happy-path scripts, the procedure can easily get mixed with:

- the first edge-case flow
- the normal Sprint 1 validation flow

So, again, a separate helper is the narrower and safer choice.

## What The Helper Does

1. create a fresh artifact on a producer node
2. read `producerNode` back from the catalog once
3. restart `artifact-catalog` to clear the emptyDir-backed catalog state
4. keep the local artifact copy intact and run `/artifacts/{id}` GET on the same node
5. leave the parent / drop-catalog / consumer logs visible for collection

So this helper is the narrowest possible procedure that creates a fresh artifact, clears only the catalog state, and keeps the local artifact copy intact.

Supported modes:

- default: `same-node`
- option: `--cross-node`

## What This Cut Intentionally Does Not Do

- change agent behavior
- add a catalog delete API
- expand the catalog state machine
- add orphan cleanup logic
- add replica-aware fetch policy

The purpose of this cut is not to expand semantics, but to **make the selected second edge case reproducible**.

## What It Hands Off To The Next Sprint

The next `D10` sprint can now run this helper and confirm:

- whether the local artifact is still reused after the catalog record disappears
- or whether the behavior surfaces as a lookup/control-layer failure
- what `state`, `source`, and `lastError` are written into local metadata

## One-Line Conclusion

The `Sprint D9` implementation cut is **a dedicated helper that keeps the local copy but removes only the catalog truth, making the second edge case reproducible**.
