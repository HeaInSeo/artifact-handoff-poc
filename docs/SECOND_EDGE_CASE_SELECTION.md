# SECOND_EDGE_CASE_SELECTION

## Purpose

This note records the result of `Sprint D8 - Second Edge Case Selection`.

By `Sprint D7`, the first edge case, `catalog record exists + local artifact missing`, had already been closed as:

- same-node: self-loop failure
- cross-node: peer-fetch recovery

The next step is to select the second edge-case question.

## Candidate

The smallest remaining candidate is:

- `catalog record missing + local artifact exists`

## Selection Result

The next edge-case question is selected as `catalog record missing + local artifact exists`.

So the conclusion of `Sprint D8` is:

- the first edge-case track is closed at `D7`
- the second edge-case track begins with `catalog record missing + local artifact exists`

## Why This Question Now

This is the most direct opposite-side case remaining in the current authority boundary.

- the first edge case was `catalog truth exists, but the local copy is gone`
- the second edge case is `a local copy remains, but catalog truth is gone`

So the two questions form a natural pair.

This also connects directly to the core problem of the repository:

- if `catalog` is the entry point for the location-aware decision layer
- what should a local artifact mean when the catalog record is gone
- should it still be reused locally, rejected, or treated as an orphan/local leftover

## Why Not Jump to a Bigger Question

This sprint does not expand immediately into:

- catalog top-level failure reflection
- replica-aware fetch policy
- retry / recovery policy
- scheduler/controller integration

Each of those would open a larger semantic expansion.

By contrast, `catalog record missing + local artifact exists` is the smallest follow-up question that still tests the current authority boundary.

## Current Working Hypothesis

The working hypothesis at this stage is:

- even if a local artifact remains
- if the catalog record is gone
- the current implementation will likely not treat that artifact as an authoritative handoff target
- so the behavior will likely surface more as a lookup/control-layer failure than as a valid local-only reuse path

This is not yet a validated fact.
It must be checked in the next sprint through a minimal helper or procedure.

## Minimum Completion Criteria For The Next Sprint

The minimum completion criteria for `D9` are:

1. create one fresh artifact id
2. keep the local artifact copy
3. intentionally remove the catalog record or make catalog lookup unavailable for that id
4. run one minimal path first, preferably same-node
5. record the HTTP response, local metadata, and interpretation

## Conclusion

The conclusion of `Sprint D8` is simple:

- the second edge case is `catalog record missing + local artifact exists`
- the next step is to turn this into the smallest reproducible helper/procedure
- it should remain inside authority-boundary validation, without expanding semantics yet
