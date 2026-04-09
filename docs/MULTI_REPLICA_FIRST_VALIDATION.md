# MULTI_REPLICA_FIRST_VALIDATION

## Purpose

This note records the first live evidence from `Sprint K2 - Multi-Replica First Validation`.

## Question

- when the `producer` is broken
- and the `first replica` is also unavailable
- while the `second replica` is still available
- does the current source-selection path really fall through to the `second replica`

## Execution Summary

- artifact id: `multi-replica-k2-20260409`
- producer node: `lab-worker-0`
- first replica node: `lab-worker-1`
- second replica node: `lab-master-0`

Execution flow:

1. prepare a two-replica state with [run-multi-replica-prep.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-multi-replica-prep.sh)
2. rewrite the catalog top-level `producerAddress` to `http://10.255.255.1:8080`
3. rewrite the first replica address to `http://10.255.255.2:8080`
4. remove the producer node's local artifact to block the local hit
5. call `/artifacts/{id}` again from the producer node

## Result

- request result:
  - `status=200`
  - `source=peer-fetch`
- producer-node local metadata:
  - `state=replicated`
  - `source=peer-fetch`
  - `producerAddress=http://10.255.255.1:8080`

## Interpretation

- the current source-selection path can continue past both a failed producer candidate and a failed first-replica candidate to a second replica candidate
- this is the first live confirmation of a multi-replica fetch path
- this sprint does not close the broader multi-replica ordering policy; it only records the first evidence that a second-replica fallback path now exists

## Next Direct Link

The next direct sprint after this note is `L1 - Post-K2 Backlog Review`.
