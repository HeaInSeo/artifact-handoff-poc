# REPLICA_AWARE_EXECUTION_CUT

## Purpose

This note fixes the result of `Sprint F3 - Next Execution Cut`.

Question:

- without implementing replica-aware fetch broadly yet,
- what is the smallest execution cut that prepares `F4`

## Conclusion of this cut

This sprint keeps the scope to **adding one dedicated preparation helper**.

Added helper:

- [run-replica-aware-prep.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-replica-aware-prep.sh)

This helper automates three steps:

1. run the existing cross-node flow once to create the first replica
2. confirm that `replicaNodes` is actually populated in the catalog
3. confirm that the replica node local metadata shows `state=replicated`, `source=peer-fetch`

## Why this is the smallest cut

### 1. It does not change agent/catalog semantics yet

This cut does not change the current `producerAddress`-centric fetch path.

So:

- it does not implement replica selection yet
- it only prepares a verifiable input state for later validation

### 2. It connects directly to `F4`

With this helper, the next sprint can immediately ask:

- under the current producer-only bias
- what producer/replica prepared state is needed
- to test the smallest replica-aware source-selection hypothesis

### 3. It does not touch the existing happy-path or edge-case scripts

The existing scripts remain unchanged:

- [run-same-node.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-same-node.sh)
- [run-cross-node.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-cross-node.sh)
- [run-edge-case-local-miss.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-edge-case-local-miss.sh)
- [run-edge-case-catalog-miss.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-edge-case-catalog-miss.sh)

## What this sprint still does not do

- implement replica-aware fetch source selection
- run a live producer-down scenario
- implement a priority policy over `replicaNodes`

## What was verified in this sprint

- helper script syntax check: `bash -n` passed

## Connection to the next sprint

In `F4`, the right next step is to use this prepared state to:

- define one replica-aware fetch hypothesis
- compare it against the current producer-only behavior
- leave the smallest evidence possible

## One-line conclusion

The conclusion of `Sprint F3` is that **the smallest execution cut for replica-aware fetch is not a new fetch policy yet, but a dedicated helper that makes the `replicaNodes` and replica metadata state repeatable and ready for validation**.
