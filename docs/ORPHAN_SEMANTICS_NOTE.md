# ORPHAN_SEMANTICS_NOTE

## Purpose

This note fixes the result of `Sprint E2 - Orphan Semantics Note`.

Question:

- how should the observed behavior of `catalog record missing + local artifact exists` be read in the current validation scope

It specifically clarifies how to read these two observations:

- same-node: `source=local` success
- cross-node: `catalog lookup failed`

## Evidence Base

This note is based on the following live validation results:

- [SECOND_EDGE_CASE_TRUTH_TIGHTENING.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_CASE_TRUTH_TIGHTENING.md)
- [SECOND_EDGE_CROSS_NODE_CHECK.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_CROSS_NODE_CHECK.md)
- [SECOND_EDGE_FAMILY_CLOSURE_NOTE.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_FAMILY_CLOSURE_NOTE.md)

## What has been observed

### Same-node

- catalog lookup returns `404`
- but if the surviving local copy and local metadata remain valid, public `/artifacts/{id}` still succeeds with `200`, `source=local`

### Cross-node

- the consumer node has no local hit
- catalog lookup is also `404`
- public `/artifacts/{id}` ends with `catalog lookup failed` and `fetch-failed` metadata

## Conclusion of this note

For the current scope, read the behavior like this:

- same-node local-first reuse is an **allowed observed behavior of the current implementation**
- but this does **not** yet mean that orphan retention is policy-approved

So the verdict is:

- `current behavior truth`: yes
- `policy approval`: not yet

## Why this is the right reading

### 1. The current implementation checks local hit before catalog lookup

The same-node evidence shows that the public `/artifacts/...` path checks local hit first.

So even if the catalog record disappears:

- if the local copy survives
- and the local metadata is still valid
- the current implementation keeps reusing the artifact

It is more accurate to accept that as **current implementation truth** first, rather than to label it a bug immediately.

### 2. But it is still too early to elevate this into orphan policy

The following questions are still open:

- should orphan/local-leftover be intentionally retained
- should cleanup/GC exist
- how long should catalog-local divergence be tolerated
- should local-only reuse be documented as policy

Those questions are larger than the current Sprint 1 validation scope.

### 3. The cross-node evidence does not turn same-node reuse into policy truth

In cross-node access, the same family surfaces immediately as `catalog lookup failed`.

So this is not a cluster-wide general rule.
It is closer to:

- a current behavior that appears only when a local hit still survives

For the current stage, it is more accurate to read orphan/local-leftover as **node-position-dependent current behavior**, not as a broader approved policy.

## Boundary fixed in this sprint

This note allows the following interpretation:

- a same-node surviving local copy can mask catalog absence
- in cross-node access, catalog absence surfaces as lookup failure
- this difference is current implementation truth

This note does not yet fix:

- orphan/local-leftover retention policy
- cleanup/GC policy
- tolerated duration of catalog-local divergence
- whether orphan artifacts should be formalized as a supported feature

## Current wording rule

So the right wording level is:

- `same-node local-first reuse can mask catalog absence`
- `this is an observed current behavior, not yet a broader orphan-retention policy`

## One-line conclusion

The conclusion of `Sprint E2` is that **the same-node local reuse observed in `catalog record missing + local artifact exists` should be accepted as current implementation truth, but it should not yet be interpreted as policy approval for orphan/local-leftover retention**.
