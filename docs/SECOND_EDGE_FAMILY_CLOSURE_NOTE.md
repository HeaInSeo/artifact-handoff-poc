# SECOND_EDGE_FAMILY_CLOSURE_NOTE

## Purpose

This note records the conclusion of `Sprint D13 - Second Edge Family Closure Note`.

Target edge-case family:

- `catalog record missing + local artifact exists`

Reference evidence:

- [SECOND_EDGE_CASE_TRUTH_TIGHTENING.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_CASE_TRUTH_TIGHTENING.md)
- [SECOND_EDGE_CROSS_NODE_CHECK.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_CROSS_NODE_CHECK.md)

## The Two Views Now Covered

Same-node:

- catalog lookup returned `404`
- public `/artifacts/{id}` still returned `source=local`, `200`
- local metadata stayed `available-local`

Cross-node:

- the consumer had no local hit
- catalog lookup returned `404`
- public `/artifacts/{id}` returned `catalog lookup failed`, `404`
- consumer local metadata became `fetch-failed`, `source=catalog-lookup`

So this family is now covered with live evidence in both node-position views.

## Closure Judgment

The conclusion of this sprint is:

- this edge-case family should be treated as **closed for the current Sprint 1 scope**

Reasoning:

1. both the same-node and cross-node views are now backed by live evidence
2. the minimum truth needed to explain the current implementation is already in place
3. going further would expand the question from `authority boundary validation` into `orphan semantics / cleanup policy`

So the current family-closure verdict is:

- `closed for current validation scope`

## What Is Closed And What Is Not

Closed:

- the truth of the current implementation
- the fact that results diverge by node position
- the split between same-node local-first reuse and cross-node catalog-lookup failure

Not closed:

- whether orphan/local-leftover reuse should be allowed as a policy
- orphan cleanup policy
- catalog top-level failure reflection
- replica-aware fetch policy

So this is a **validation closure for current behavior**, not a policy closure or a production-semantics closure.

## Why No Extra Follow-Up Note Is Added Now

Opening a separate orphan-semantics note at this point would be too much.

That would expand into larger questions such as:

- should a leftover local copy still count as a reusable artifact
- should there be GC/cleanup policy between local copies and catalog truth
- how should scheduler/controller integration treat this situation later

Those are all beyond the current Sprint 1 scope.

## Final Conclusion

The second edge-case family is now fixed in the current scope as:

- same-node: a surviving local copy can mask catalog absence
- cross-node: without a local hit, catalog absence surfaces as lookup failure

That is sufficient closure for the current validation scope.

## One-Line Conclusion

The conclusion of `Sprint D13` is: **close the `catalog record missing + local artifact exists` family for the current Sprint 1 validation scope, and leave orphan semantics or cleanup policy for a later scope.**
