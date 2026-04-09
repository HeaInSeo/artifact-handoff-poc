# POST_J1_VALIDATION_ENTRY

## Purpose

This document fixes which multi-replica validation question should come first after the `J1` helper.

The role of `J1` was to make the producer + first replica + second replica state repeatable.
So the role of `K1` is to choose the **smallest first validation question** that should use that prepared state.

## Selected First Validation Question

The first question fixed here is:

- if the `producer` and the `first replica` are made unavailable in sequence,
- does the consumer still succeed by falling through to the `second replica`

In short:

- `producer broken`
- `first replica unavailable`
- `second replica present`
- then `GET /artifacts/{id}` should still succeed

## Why This Question Comes First

- the current source-selection semantics is still `producer -> replicaNodes`
- single-replica fallback was already validated in `F9`
- the smallest next multi-replica question is not a full ordering redesign, but whether **candidate iteration really reaches the second replica**

So this question is intentionally narrow:

- it does not close the full multi-replica ordering policy
- it only checks whether the current cut actually opens a real second-replica path

## What This Sprint Intentionally Does Not Do

- define a broader multi-replica preference policy
- compare replica freshness
- add richer observability fields
- combine the work with retry / recovery policy

This sprint is a validation-entry selection sprint.

## Minimum Completion Criteria For K2

The minimum completion criteria for `K2 - Multi-Replica First Validation` is fixed as:

1. prepare the two-replica state with [run-multi-replica-prep.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-multi-replica-prep.sh)
2. rewrite the top-level `producerAddress` to a broken endpoint
3. make the first replica temporarily unavailable so the first replica hop also fails
4. perform the artifact GET from a third consumer or equivalent consumer node
5. confirm a `200` response or equivalent success
6. record the consumer local metadata together with the catalog snapshot

## Next Direct Connection

The next direct sprint after this note is `K2 - Multi-Replica First Validation`.
