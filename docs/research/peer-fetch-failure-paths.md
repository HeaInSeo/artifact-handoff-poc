# peer-fetch-failure-paths

## 1. Research Question

How should `artifact-handoff-poc` distinguish peer-fetch failures semantically, and what should be made explicit now versus left for later?

## 2. Key Summary

At this stage, the important thing is not to invent many failure types. It is to keep the already observed failures from being confused with one another.

For a one-page recap of the representative failure scenarios, read [FAILURE_MATRIX.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/FAILURE_MATRIX.md) alongside this note.

Based on the validations completed so far, at least these four cases should stay distinct:

1. `catalog lookup failed`
2. `peer fetch exception`
3. `peer fetch http 409: digest mismatch`
4. `peer digest mismatch`

All four may look like "cross-node fetch failed", but they do not mean the same thing.

- `catalog lookup failed` means the failure happened while reading the catalog record.
- `peer fetch exception` means the failure happened while connecting to or reading from the peer endpoint.
- `peer fetch http 409: digest mismatch` means the producer-side internal gate rejected the request before serving bytes.
- `peer digest mismatch` means the consumer actually read peer payload bytes and then detected the mismatch itself.

The current sprint needs to keep the last two separate rather than collapsing them into one label.

## 3. How It Resembles Our Project

- Dragonfly-like systems also need to distinguish failures by hop instead of treating everything as a generic download failure.
- Kubernetes-based distributed data paths also need to separate control-plane lookup failure from data-plane fetch failure.
- `artifact-handoff-poc` is also a location-aware handoff repository, so "where and why it failed" matters more than a generic "artifact missing" label.

## 4. How It Differs From Our Project

- This repository is not a general distribution system. It is a focused DAG artifact handoff validation repo.
- So it does not need a broad global error taxonomy, retry framework, or recovery policy right now.
- For the current sprint, a node-local forensic trail is more important than a durable cluster-wide failure registry.

## 5. What To Borrow

- the distinction between control-plane and data-plane failure
- the distinction between transport exception and integrity failure
- the distinction between producer-side rejection and consumer-side verification failure
- human-readable `lastError` strings in local metadata

## 6. What Not To Borrow

- a large global error-code system at this stage
- mixing retry or recovery policy into this note
- expanding the catalog top-level state machine now
- designing a full observability stack in the current sprint

## 7. Points That Connect Directly To The Current Sprint

The current failure semantics should be read like this.

### A. catalog lookup failed

- failure point: the consumer tries to read the catalog record
- meaning: peer fetch has not started yet
- expected local metadata:
  - `source=catalog-lookup`
  - `state=fetch-failed`
  - `producerNode` / `producerAddress` may be empty
- The decision on whether this should later be split into finer buckets such as 404/5xx is documented in [catalog-lookup-failure-split-note.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/catalog-lookup-failure-split-note.md).

### B. peer fetch exception

- failure point: the consumer connects to or reads from the producer or peer endpoint
- meaning: peer fetch was attempted, but transport failed
- examples:
  - `Connection refused`
  - timeout
- expected local metadata:
  - `source=peer-fetch`
  - `state=fetch-failed`
  - `lastError=<transport exception>`

### C. peer fetch http 409: digest mismatch

- failure point: the producer-side `/internal/artifacts/...` endpoint
- meaning: the producer rejected the request before serving bytes because the expected digest did not match
- current implementation meaning:
  - the producer-side internal gate stops the request before the consumer branch can inspect payload bytes
- expected local metadata:
  - `source=peer-fetch`
  - `state=fetch-failed`
  - `lastError=peer fetch http 409: digest mismatch`

### D. peer digest mismatch

- failure point: inside the consumer-side `peer_fetch()` path
- meaning: the consumer read payload bytes from the peer and then detected the digest mismatch itself
- expected local metadata:
  - `source=peer-fetch`
  - `state=fetch-failed`
  - `lastError=peer digest mismatch`

In the current repo, C and D are not the same.

- C is producer-side rejection.
- D is consumer-side verification failure.
- Both are integrity failures, but the failure detection point is different.

### Difference from local digest mismatch

- `local digest mismatch` is not a peer path failure. It is a failure while verifying the current node's local copy.
- So `source=local-verify` is the right label.
- This is tied more directly to same-node reuse and second-hit local cache semantics.

### Current judgment on catalog reflection

At the current stage, it is still reasonable to keep failure reflection only in local metadata.

Why:

- the main question is still whether location can drive handoff decisions, not whether a global failure registry is complete
- local metadata is already enough for a node-local forensic trail
- adding catalog-level failure state too early would widen authority and state-transition scope

## 8. Candidate Points For The Next Sprint

- decide how to link this taxonomy from README without bloating the repository entry point
- decide whether `catalog lookup failed` should later split into 404 vs 5xx
- decide how producer-side HTTP failures other than 409 should be normalized
- write a separate note on which failure subset, if any, deserves catalog reflection later

Related one-page scenario summary:

- [FAILURE_MATRIX.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/FAILURE_MATRIX.md)
