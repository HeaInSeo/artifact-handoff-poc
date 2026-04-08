# SECOND_EDGE_CASE_REASSESSMENT

## Purpose

This note records the result of `Sprint D11 - Second Edge Case Reassessment`.

Question being reassessed:

- `catalog record missing + local artifact exists`

Reference evidence:

- [SECOND_EDGE_CASE_TRUTH_TIGHTENING.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_CASE_TRUTH_TIGHTENING.md)

## What Is Already Confirmed

`Sprint D10` confirmed the following in the same-node view:

- catalog lookup returned `404 Not Found`
- the public same-node `/artifacts/{id}` response was still `200`
- the observed response source was `local`
- local metadata stayed as `state=available-local`, `source=local-put`

So, in the current implementation, same-node local hit outranks catalog absence.

## Reassessment Conclusion

The conclusion of this sprint is:

- from the same-node view, the current behavior of the second edge case is now fixed strongly enough
- so `D10` should be treated as closing the same-node truth
- but it is still too early to call the entire edge-case family fully closed
- because the cross-node view is still missing

So the verdict is:

- `same-node closed`
- `overall edge-case family still partially open`

## Why This Is Not Fully Closed Yet

This is not only a local reuse question. It is an authority-boundary question.

In the same-node view, local hit can mask catalog absence.
But in the cross-node view, the question changes:

- the consumer node does not have the local copy
- the catalog also no longer has producer truth
- what exact failure appears in the current implementation
- and does the outcome change if leftover local metadata or an old replica exists

So the cross-node view is still needed to explain what `catalog absence` means across node position more completely.

## Why Not Expand Into Bigger Questions Yet

This reassessment still defers:

- catalog top-level failure reflection
- orphan cleanup policy
- replica-aware fetch policy
- retry / recovery semantics

Each of those would open a larger semantic expansion than the current question.

The next step needed now is smaller:

- check `catalog record missing + local artifact exists` once from the cross-node view

## Next Sprint Judgment

The next sprint should be `Sprint D12 - Second Edge Cross-Node Check`.

Minimum completion criteria:

1. create one fresh artifact id
2. keep the producer-node local artifact intact
3. clear the catalog state
4. call `/artifacts/{id}` from a non-producer node
5. record the HTTP response, local metadata, and interpretation

## One-Line Conclusion

The conclusion of `Sprint D11` is: **the second edge case is closed for the same-node truth, but the full edge-case family should not be treated as fully closed until the cross-node view is checked**.
