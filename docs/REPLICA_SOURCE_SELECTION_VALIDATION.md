# REPLICA_SOURCE_SELECTION_VALIDATION

## Purpose

This note fixes the live evidence for `Sprint F9 - Replica Source-Selection Validation`.

Question:

- after `Sprint F8` expanded the remote candidate set in `peer_fetch()` from producer-only to `producer + replicaNodes`,
- does a third-node consumer actually succeed through replica fallback when the producer is broken?

## Reference Documents

- [REPLICA_SOURCE_SELECTION_MINIMAL_CUT.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_MINIMAL_CUT.md)
- [PRODUCER_BIAS_VALIDATION_KICKOFF.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PRODUCER_BIAS_VALIDATION_KICKOFF.md)
- [run-producer-bias-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-producer-bias-check.sh)

## Execution Flow

1. create the parent artifact on worker0
2. create the first replica on worker1
3. confirm that `replicaNodes` is populated in the catalog
4. rewrite only the catalog top-level `producerAddress` to a broken endpoint
5. call `/artifacts/{id}` from a third node (`lab-master-0`) that is neither the producer nor the first replica

## What Was Confirmed

- artifact id: `replica-source-select-20260409`
- producer node: `lab-worker-0`
- first replica node: `lab-worker-1`
- third consumer node: `lab-master-0`
- the producerAddress was intentionally broken as `http://10.255.255.1:8080`
- even in that state, the third-node consumer result became:
  - `status=200`
  - `source=peer-fetch`
- the third-node local metadata was recorded as:
  - `state=replicated`
  - `source=peer-fetch`
  - `producerNode=lab-worker-0`
  - `producerAddress=http://10.255.255.1:8080`

## Interpretation

- after this cut, the implementation can move from a failed producer candidate to a replica candidate
- so `replicaNodes` is no longer only an observation; it now participates in the actual source-selection path
- however, local metadata still keeps `producerAddress` as the origin producer field, so it may differ from the actual fetch endpoint

## Sprint Conclusion

- `replica fallback after producer failure`: pass
- `replica-aware source selection`: first live pass

## Next Connection Point

The next question now becomes:

- what backlog should be prioritized next after this first replica-aware implementation/validation sequence?
