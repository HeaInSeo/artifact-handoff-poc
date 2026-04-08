# CATALOG_FAILURE_REFLECTION_RECHECK

## Purpose

This note records the result of `Sprint E3 - Catalog Failure Reflection Recheck`.

Question:

- after closing the second edge-case family, is it still correct to defer `catalog top-level failure reflection`

Reference points:

- [catalog-failure-semantics-decision.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/catalog-failure-semantics-decision.md)
- [SECOND_EDGE_CASE_TRUTH_TIGHTENING.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_CASE_TRUTH_TIGHTENING.md)
- [SECOND_EDGE_CROSS_NODE_CHECK.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_CROSS_NODE_CHECK.md)

## What Became Clear From The New Evidence

The second edge-case family made the following more explicit.

Same-node:

- catalog lookup returned `404`
- but a surviving local copy still let the public `/artifacts/{id}` path succeed as `source=local`

Cross-node:

- there was no local hit
- and no catalog truth
- so the public `/artifacts/{id}` path ended as `catalog lookup failed` with `fetch-failed` metadata

So even inside the same family, consumer-visible failure and same-node local success diverge by node position.

## Recheck Conclusion

The conclusion remains the same.

- `catalog top-level failure reflection` should still be **deferred**

Verdict:

- `continue defer`

## Why Defer Still Fits

### 1. The new evidence does not strongly justify a catalog-level global failure state

What became clearer is:

- a local hit can mask catalog absence
- on a non-producer node, catalog absence can surface directly as lookup failure

That improves the explanation of **node-position-dependent observed behavior**.
It does not, by itself, justify promoting failure into global catalog truth.

### 2. Promoting consumer-specific failures into top-level truth would blur the authority boundary

A cross-node consumer can observe `catalog lookup failed`.
At the same time, the same-node producer/local node can observe `source=local` success.

If we start writing failure into the catalog top-level state, then questions immediately open such as:

- which node observation becomes the top-level truth
- if same-node success and cross-node failure coexist, which state is representative
- should cluster-wide state become failure even when a local leftover still serves successfully

Those questions would make the current authority boundary more complex, not simpler.

### 3. The current evidence is already interpretable through local metadata plus results/history

The validated paths can already be read through this split:

- catalog:
  - producer origin
  - placement input
- local metadata:
  - current-node local copy
  - `fetch-failed`
  - `lastError`
- results/history docs:
  - node-position-dependent interpretation

For the current Sprint 1 scope, this is still enough to explain what happened.

## Additional Rules Fixed In This Recheck

- same-node local success does not redefine the catalog top-level state as success
- cross-node lookup failure does not promote catalog top-level state into failure
- catalog remains a producer-origin / placement-input registry
- the failure forensic trail stays in local metadata plus results/history

## What Still Remains Open

- whether orphan/local-leftover semantics should be treated only as observed current behavior or given a stronger policy meaning still needs its own note
- if multi-consumer aggregate failure visibility ever becomes necessary, catalog reflection can be revisited later

## One-Line Conclusion

The conclusion of `Sprint E3` is: **even after the second edge-case family, catalog top-level failure reflection should still remain deferred, and the current structure should stay as local metadata plus results/history interpretation.**
