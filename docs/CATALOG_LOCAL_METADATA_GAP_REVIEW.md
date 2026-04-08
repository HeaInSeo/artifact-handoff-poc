# CATALOG_LOCAL_METADATA_GAP_REVIEW

## Purpose

This note records the result of `Sprint D2 - Catalog And Local Metadata Gap Review`.

The questions are:

- what narrow gaps still remain in the authority boundary between the `catalog` and `local metadata`
- what is the minimum gap list to hand off into the next implementation sprint

## Core Summary

Verdict: `authority boundary is mostly clear, but a few narrow gaps remain`

The current baseline is already mostly clear:

- `catalog`
  - producer origin
  - placement input
- `local metadata`
  - node-local copy presence
  - verification result
  - fetch-failure forensic trail

But that boundary is **not yet expressed with the same clarity across every code path and result document**.

So the next sprint should not expand the authority model. It should instead reduce the remaining narrow gaps listed below.

## Current Authority Boundary

### What the catalog is authoritative for

- `producerNode`
- `producerAddress`
- existence of the top-level producer record
- the input used for child placement

### What local metadata is not authoritative for

- producer-origin truth
- cluster-wide location truth
- placement decisions

### What local metadata is still valid for as observation

- whether a local copy exists on the current node
- whether that copy is `available-local` or `replicated`
- whether a fetch failure happened on the current node
- what the `lastError` was

## Minimum Remaining Gap List

### 1. The meaning of `local artifact exists but catalog record is missing` is not fully fixed in documents

The current interpretation is roughly:

- if only a local artifact exists without a catalog record:
  - it is not authoritative for cluster-wide handoff
  - it may just be a leftover or orphaned local copy

But that reading is not yet directly fixed all the way up to README/results level.

Judgment:
- this is a narrow gap that can be clarified with documentation or a small validation note

### 2. The meaning of `catalog record exists but local artifact is missing` is still spread across multiple paths

Today, in that case:

- same-node/local flow sees a local miss
- cross-node flow may continue into peer fetch
- if the producer points to self, it becomes a self-loop failure

So the behavior is explainable, but the semantics of “catalog truth remains while the local copy is absent” are not yet fixed in one short place.

Judgment:
- this is a good candidate for the next validation question

### 3. The role difference between top-level catalog state and local state still has to be re-explained in multiple places

Today:

- catalog top-level state: `produced`
- local metadata state: `available-local`, `replicated`, `fetch-failed`

That split is already moving in the right direction, but multiple documents still need to restate it.

Judgment:
- this is less a large implementation gap and more a small clarity gap to fix in the next sprint

### 4. Replica metadata is still weak inside the authority model

`replicaNodes` is recorded today.

But it is still:

- not used directly for placement
- not used for fetch-source selection
- weaker than the producer record in the authority hierarchy

Judgment:
- acceptable for the current scope
- but it should be described more clearly as observation/history rather than as a strong authoritative source

## Minimum Gaps To Hand Off Into The Next Sprint

The priority should be:

### A. documentation/validation-first gaps

- fix the meaning of `catalog record missing + local artifact exists`
- fix the meaning of `catalog record exists + local artifact missing`

These are the two edge cases that most directly expose the authority boundary.

### B. small code/validation candidates

- reproduce one of those two situations as a live validation scenario
- confirm that current behavior matches the intended interpretation

### C. what not to do immediately

- catalog top-level failure reflection
- replica-aware fetch policy
- retry / recovery policy
- broader state-machine expansion

## D2 Conclusion

The direction of the authority boundary is already correct.

What is needed next is not:

1. a larger new model
2. a larger new taxonomy

but:

1. a fixed interpretation for the edge cases
2. a small validation to confirm that interpretation

## One-Line Conclusion

As of `Sprint D2`, the next implementation/validation candidate is to **narrowly confirm the two edge cases at the catalog/local-metadata boundary**.
