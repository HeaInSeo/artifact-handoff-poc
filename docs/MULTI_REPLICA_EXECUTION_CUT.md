# MULTI_REPLICA_EXECUTION_CUT

## Purpose

This document explains the smallest multi-replica execution cut added in `Sprint J1 - Post-I3 Execution Cut`.

The purpose of this cut is not to implement the multi-replica policy itself.
Instead, it is to make the producer + first replica + second replica state repeatable so that the next validation can start immediately.

## What This Cut Adds

- dedicated helper:
  - [run-multi-replica-prep.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-multi-replica-prep.sh)

The helper only does the following:

1. It uses the existing cross-node flow to create the producer and the first replica.
2. It reads the producer node and first replica node from the catalog.
3. It selects the remaining third node as the second-replica target.
4. It performs one more GET for the same artifact from the third node to create the second replica.
5. It checks that the catalog now has at least two entries in `replicaNodes`.
6. It checks that the local metadata on both replica nodes has `state=replicated`.

## What This Cut Intentionally Does Not Do

- implement multi-replica ordering policy
- add replica-among-replica selection rules
- add retry / recovery policy
- add richer endpoint observability fields
- integrate scheduler/controller logic

In other words, this is not a policy implementation cut.
It is a **helper cut that prepares a multi-replica state**.

## Why This Is The Smallest Reasonable Cut

- It reuses the existing [run-cross-node.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-cross-node.sh) and [run-replica-aware-prep.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-replica-aware-prep.sh) flows.
- It does not change the current source-selection semantics in `agent.py`.
- It makes the next sprint about a real multi-replica validation question, instead of about setup work.

## Next Direct Connection

The next direct connection after this cut is `Sprint J2 - Post-I3 Completion Refresh`, followed by `Sprint K1 - Post-J1 Validation Entry`.
