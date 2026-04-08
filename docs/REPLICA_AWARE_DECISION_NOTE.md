# REPLICA_AWARE_DECISION_NOTE

## Purpose

This note fixes the conclusion for `Sprint F6 - Replica-Aware Decision Note`.

Question:

- after `Sprint F4` showed that replica-ready state exists but actual fetch source selection is still producer-biased,
- and after `Sprint F5` narrowed the follow-up order to `validation first, cut second`,
- should the next immediate execution be a producer-bias validation step, or should it move directly into the smallest source-selection cut?

## Reference Documents

- [REPLICA_AWARE_FIRST_VALIDATION.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_FIRST_VALIDATION.md)
- [REPLICA_AWARE_FOLLOW_UP_ORDERING.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_FOLLOW_UP_ORDERING.md)
- [REPLICA_AWARE_EXECUTION_CUT.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_EXECUTION_CUT.md)

## What Is Already Confirmed

- `replicaNodes` is actually recorded in the catalog.
- the first replica local metadata is recorded as `state=replicated`, `source=peer-fetch`.
- but `peer_fetch()` still uses only `producerAddress` directly.

So the current implementation is:

- `replica-ready`: yes
- `replica-aware source selection`: no

## Option Comparison

### Option A. Validate the producer bias first

Pros:

- gives one more concrete piece of evidence showing how the current limitation surfaces in practice
- makes the later source-selection cut easier to interpret in a narrow way
- keeps scope smaller

Cons:

- delays the first implementation change by one sprint

### Option B. Move straight to the smallest source-selection cut

Pros:

- starts real code that pulls `replicaNodes` into the control path sooner

Cons:

- the evidence showing where the current producer-only bias actually limits behavior is still thin
- the meaning of the implementation cut can become easier to blur

## Final Judgment

`Option A` is the right choice for now.

That means:

- the next immediate execution should be **producer-bias validation**
- and only after that should the work move to **the smallest replica source-selection cut**

## Why This Fits

- the catalog and metadata already contain replica-related information
- what is still missing is a more direct execution-level demonstration of why source selection is still producer-biased
- once that evidence is fixed, the next implementation cut can stay smaller and more explicit

## Next Immediate Sprint

- `F7 - Producer-Bias Validation Kickoff`

Minimum completion criteria:

- choose one scenario that exposes the producer-only bias more directly
- obtain live validation or equivalently narrow evidence
- reflect the result in `RESULTS`, `VALIDATION_HISTORY`, and `SPRINT_PROGRESS`

## One-Line Conclusion

The next immediate execution should validate the current producer bias first, and only then move into the smallest replica source-selection cut.
