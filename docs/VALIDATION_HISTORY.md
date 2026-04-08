# VALIDATION_HISTORY

This document records how Sprint 1 validation actually progressed over time, and why the result history contains both partial success and later full validation.

## Summary

Sprint 1 in `artifact-handoff-poc` did not complete in a single straight line.

The actual sequence was:

1. the PoC baseline was implemented
2. the lab cluster was not ready as a 3-node environment, so full validation was blocked
3. same-node validation was partially confirmed in a leftover single-node environment
4. `multipass-k8s-lab` image / join / runtime issues were fixed
5. cross-node peer fetch was confirmed after the 3-node lab recovered
6. same-node / cross-node / second-hit were rerun against the latest code on `2026-04-06`
7. two failure scenarios were validated on `2026-04-08`
8. local digest mismatch was validated on `2026-04-08`
9. the peer digest mismatch branch was validated on `2026-04-08`
10. peer fetch HTTP attribution was tightened on `2026-04-08`

So when reading the results of this repository, application-logic validation and infrastructure readiness should be separated.

## Related Commits

- `084d54c` `Add sprint1 artifact handoff baseline`
- `8aacf7f` `Add troubleshooting notes for sprint1 validation`

Related infrastructure commits:

- `multipass-k8s-lab` `4843572` `Switch lab baseline guest to Ubuntu 24.04`
- `multipass-k8s-lab` `9a704d6` `Fix worker join script permissions`
- `multipass-k8s-lab` `0e660a5` `Document Rocky8 runtime troubleshooting note`

## 1. Baseline Implementation Phase

At `084d54c`, the following were added together:

- `artifact-agent`
- `catalog`
- base manifests
- `deploy.sh`
- `run-same-node.sh`
- `run-cross-node.sh`
- the first scope and results documents

So the experiment structure itself existed early. The main blocker afterward was not missing application logic, but whether validation could run to completion in a real 3-node lab.

## 2. First Real Blocker: 3-Node Lab Not Ready

The early results documents recorded that:

- `multipass-k8s-lab/scripts/k8s-tool.sh up` failed because of the `rocky-8` image alias problem
- only a single node was left, so the default `MIN_NODES=3` requirement could not be satisfied
- `run-cross-node.sh` stopped because it needs at least two schedulable nodes

The important judgment at that stage was to separate infrastructure blockage from PoC logic.

## 3. Partial Validation: Same-Node In A Single-Node Environment

Even while the full lab was not ready, the same-node path could still be validated in the leftover single-node cluster.

What was confirmed:

- the parent job registered the artifact
- the child reused the artifact on the same node
- the child output showed `source=local`
- the digest matched
- the catalog state was `ready` in the early record

That matters because even before cross-node validation recovered, the write / register / local-reuse path was already proven.

## 4. Cross-Node Validation After Infrastructure Recovery

Later, `multipass-k8s-lab` resolved:

- the guest baseline was switched to Ubuntu 24.04
- worker join permission problems were fixed
- the control plane / containerd / CNI path recovered

Then the following was confirmed:

- parent on `lab-worker-0`
- child on `lab-worker-1`
- child result `source=peer-fetch`
- digest match
- producer / replica node information recorded in the catalog

So the main Sprint 1 question, "can same-node reuse and cross-node peer fetch both hold in a real lab?", could finally be answered with "yes".

## 5. How To Read The Results Documents

The earlier `docs/RESULTS.md` is mostly an intermediate `2026-04-03` checkpoint. That is why it still contains:

- cross-node blocked
- second-hit cache not run
- full acceptance incomplete

That document is not wrong. It records that moment in time.

So the proper reading is:

- `docs/RESULTS.md`: the earlier checkpoint view
- `docs/TROUBLESHOOTING_NOTES.md`: later notes including lab recovery and successful cross-node validation
- this document: the full time-ordered validation history

## 6. Latest-Code Rerun

On `2026-04-06`, validation was rerun on a healthy `multipass-k8s-lab` environment using the latest code.

Confirmed:

- same-node validation passed with a fresh artifact ID
- cross-node validation passed with a fresh artifact ID
- second-hit local cache validation passed

Additional observations:

- child placement now uses the catalog's `producerNode` as script input
- catalog top-level state is now `produced`, and replica state is `replicated`
- local metadata now records both producer origin and local copy location

Operational issues exposed during the rerun:

1. the host `python3` was 3.6, so script helpers using `text=True` needed a compatibility fix
2. the first cross-node rerun showed `source=local` because of stale cache and old pod processes, and only behaved correctly after using a fresh `ARTIFACT_ID` and restarting pods
3. after that, the agent was tightened to write `state=fetch-failed` and `lastError` into local metadata on peer-fetch or local-verify failure

## 7. Failure Scenario Validation

On `2026-04-08`, two small failure scenarios were used to confirm that the B6 failure metadata recording was actually written.

Terminology note:

- failure terms in this document should be read using [peer-fetch-failure-paths.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.md).
- for a one-page recap of the representative failure scenarios, read [FAILURE_MATRIX.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/FAILURE_MATRIX.md) alongside this document.

Validated scenarios:

1. `producer points to self`
2. `peer fetch exception` (`Connection refused`)

What was confirmed:

- both scenarios left `state=fetch-failed` in consumer-node local metadata
- `lastError` matched the observed cause
  - self-producer case: `artifact missing locally and producer points to self`
  - peer fetch exception case: `<urlopen error [Errno 111] Connection refused>`

So the B6 failure recording reached its minimum goal in a live environment.

Still open:

- failure is reflected in local metadata, but not in catalog top-level state
- node-local forensic trails exist, but cluster-wide failure observability is still limited

## 8. Remaining Recording Tasks

The main remaining follow-up worth keeping is:

- add clearer cross-links between `multipass-k8s-lab` infrastructure incidents and this repository's validation history

## 9. Local Digest Mismatch Validation

On `2026-04-08`, the next narrow validation targeted `local digest mismatch`, which was the most reproducible digest-mismatch case.

Terminology note:

- `local digest mismatch` is a local verification failure, not a peer failure, so `source=local-verify` is the correct reading.

Method:

1. register a valid payload on the `lab-worker-0` agent
2. corrupt `payload.bin` in worker0 local storage
3. call `/internal/artifacts/{artifactId}` directly to force local verification only
4. inspect the local metadata snapshot
5. then check whether the public `/artifacts/{artifactId}` path preserves the same `lastError`

What was confirmed:

- `/internal/artifacts/...` returned `404` with `local digest mismatch`
- worker0 local metadata recorded:
  - `state=fetch-failed`
  - `source=local-verify`
  - `lastError=local digest mismatch`

So the B6 failure recording also worked for a digest-mismatch path.

A small implementation issue was exposed at the same time:

- the public `/artifacts/...` path could initially re-enter peer fallback after local mismatch and overwrite `lastError` with a self-loop style error
- a narrow GET-path fix was added, and after restarting the worker0 agent pod the public path also returned `local digest mismatch`

Still open:

- this sprint did not yet record peer digest mismatch evidence
- so digest mismatch coverage was still only half filled

## 10. Peer Digest Mismatch Validation

On `2026-04-08`, digest-mismatch coverage was extended to `peer digest mismatch`, but the result had to be split into two layers: end-to-end HTTP flow and live branch probe.

Terminology note:

- `peer digest mismatch` in this section means consumer-side verification failure.
- the distinction from producer-side rejection is documented in [peer-fetch-failure-paths.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.md).

1. end-to-end HTTP probe

- a valid producer artifact was created, then only the catalog digest was overwritten with `0000...`
- worker1 then called the public `/artifacts/{artifactId}` path
- the result was `409` with `catalog lookup failed`, and local metadata recorded `source=catalog-lookup`, `lastError=catalog lookup failed`

Meaning:

- the producer's `/internal/artifacts/...` path checks the expected digest first
- so the producer blocks the request before the consumer-side `peer_fetch()` path can read payload bytes and independently conclude `peer digest mismatch`
- therefore the current implementation could not easily surface `peer digest mismatch` through a clean end-to-end HTTP path

2. live peer-fetch branch probe

- on the same day, `peer_fetch()` was called directly inside the live worker1 pod
- only `fetch_catalog()` and the peer response were narrowly monkeypatched so that the returned payload digest would differ from the expected digest
- that produced `ValueError: peer digest mismatch`, and local metadata recorded:
  - `state=fetch-failed`
  - `source=peer-fetch`
  - `lastError=peer digest mismatch`

Summary:

- the branch itself records correctly
- but the current end-to-end HTTP design still hits the producer-side digest gate earlier
- so this sprint was recorded as live-branch evidence plus confirmation of the current HTTP limitation, not as a full end-to-end pass

## 11. Peer Fetch HTTP Attribution Tightening

On `2026-04-08`, the B9 attribution problem was tightened directly afterward.

Terminology note:

- this section does not redefine `peer digest mismatch`; it makes producer-side rejection observable as `peer fetch http 409: digest mismatch`.

Core change:

- public `/artifacts/...` error handling now separates `fetch_catalog()` failures from `peer_fetch()` failures
- producer-side `HTTPError` is no longer collapsed into `catalog lookup failed`
- when the peer HTTP body includes `{"error":"digest mismatch"}`, the consumer response and local metadata now preserve a more specific message such as `peer fetch http 409: digest mismatch`

Live validation:

- a fresh artifact `fail-peer-digest-http-b10-20260408` was created on worker0
- the catalog digest was changed to `0000...`
- worker1 called the public `/artifacts/{artifactId}` path
- result:
  - HTTP response: `409`
  - response body: `peer fetch http 409: digest mismatch`
  - local metadata:
    - `state=fetch-failed`
    - `source=peer-fetch`
    - `producerNode=lab-worker-0`
    - `lastError=peer fetch http 409: digest mismatch`

Summary:

- the producer-side digest gate still exists
- but from the outside, the failure is now correctly labeled as a peer-fetch HTTP failure rather than a catalog lookup failure
- the B9 structural limitation remains, but B10 made the attribution accurate

## 12. post-freeze edge case truth tightening

On `2026-04-08`, the first post-freeze validation narrowed in on the edge case selected in `D3`.

Selected question:

- `catalog record exists + local artifact missing`

This sprint validated the same-node path first.

Execution flow:

1. create fresh artifact `edge-local-miss-20260408-same` on worker0
2. keep the catalog record intact
3. remove only the worker0 hostPath artifact directory
4. request `/artifacts/{artifactId}` again from the same node

What was confirmed:

- the catalog record still remained as `state=produced`
- same-node local availability was gone, so the local path saw a miss
- the agent entered peer-fetch fallback, but because the producer still pointed to self, the result became a self-loop failure
- worker0 local metadata recorded:
  - `state=fetch-failed`
  - `source=peer-fetch`
  - `lastError=artifact missing locally and producer points to self`

Why this matters:

- it confirms with live evidence that catalog truth and actual local availability are not the same thing
- a producer record can still exist in the catalog while the same-node local path fails because the local copy is gone

What still remains:

- this sprint confirmed only the same-node path first
- the cross-node version, where the same edge case may recover through peer fetch, remains a follow-up candidate
- the `catalog record missing + local artifact exists` edge case also remains open

## Reference

Detailed infrastructure-side incident history is recorded separately in `../../multipass-k8s-lab/docs/TROUBLESHOOTING_HISTORY.md`.
