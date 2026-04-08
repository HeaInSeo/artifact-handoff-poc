# REPLICA_AWARE_FOLLOW_UP_ORDERING

## Purpose

This note fixes the judgment for `Sprint F5 - Replica-Aware Follow-Up Ordering`.

Question:

- after `Sprint F4` showed that the system is replica-ready but still producer-biased in actual fetch source selection,
- what should the next two follow-up questions be, and in what order?

## Reference Documents

- [REPLICA_AWARE_FIRST_VALIDATION.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_FIRST_VALIDATION.md)
- [NEXT_BACKLOG_ORDERING_NOTE.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/NEXT_BACKLOG_ORDERING_NOTE.md)

## What Is Already Confirmed

- the first replica is created in practice
- `replicaNodes` is populated in the catalog
- the replica node local metadata is recorded as `state=replicated`, `source=peer-fetch`
- but actual fetch source selection still uses only `producerAddress`

So the current state is:

- `replica-ready state`: yes
- `replica-aware source selection`: no

## Follow-Up Ordering Judgment

The next order should be:

1. one more validation that makes the current producer-only bias more explicit
2. then the smallest implementation cut that connects `replicaNodes` to actual source selection

## Why This Order Fits

- `Sprint F4` already showed both the prepared state and the current limitation.
- One more validation step will make the missing behavior more explicit in evidence.
- After that, the implementation cut will be easier to interpret and keep narrow.

If the work jumps directly into implementation, the evidence for:

- how the producer-only bias currently surfaces in practice
- and why `replicaNodes` should become a control-layer input instead of a recorded observation

will remain weaker than necessary.

## Fixed Follow-Up Order

- `F6 - Replica-Aware Decision Note`
  - make the final choice between one more producer-bias validation step and moving directly into the smallest source-selection cut
- then the real next execution
  - producer-only bias validation
  - or the smallest replica source-selection cut

The current judgment favors `validation first, cut second`.

## One-Line Conclusion

The follow-up should first validate the current producer-only bias more directly, and only then move to the smallest source-selection cut.
