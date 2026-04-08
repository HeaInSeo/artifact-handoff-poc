# PRODUCER_BIAS_VALIDATION_KICKOFF

## Purpose

This note fixes the first live evidence for `Sprint F7 - Producer-Bias Validation Kickoff`.

Question:

- when `replicaNodes` is populated in the catalog and the first replica is already available,
- does a non-producer third-node consumer still follow only `producerAddress` instead of using the replica as a source candidate?

## Reference Documents

- [REPLICA_AWARE_FIRST_VALIDATION.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_FIRST_VALIDATION.md)
- [REPLICA_AWARE_DECISION_NOTE.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_DECISION_NOTE.md)
- [run-producer-bias-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-producer-bias-check.sh)

## Execution Flow

1. create the parent artifact on worker0
2. create the first replica on worker1
3. confirm that `replicaNodes` is populated in the catalog
4. intentionally rewrite only the catalog top-level `producerAddress` to a broken endpoint
5. call `/artifacts/{id}` from a third node (`lab-master-0`) that is neither the producer nor the first replica

## What Was Confirmed

- artifact id: `producer-bias-20260408c`
- producer node: `lab-worker-0`
- first replica node: `lab-worker-1`
- third consumer node: `lab-master-0`
- the catalog still kept:
  - `producerNode=lab-worker-0`
  - `replicaNodes[0].node=lab-worker-1`
  - `replicaNodes[0].state=replicated`
- but the third-node consumer response became:
  - `status=404`
  - `error=<urlopen error timed out>`
- the consumer local metadata was recorded as:
  - `source=peer-fetch`
  - `state=fetch-failed`
  - `producerAddress=http://10.255.255.1:8080`
  - `lastError=<urlopen error timed out>`

## Interpretation

- in the current implementation, a third-node consumer enters the peer-fetch path when there is no local hit
- but peer-fetch still does not treat `replicaNodes` as a source candidate, and instead uses only the top-level `producerAddress`
- so even when the first replica is available, the request still follows the broken producer endpoint and fails

## Sprint Conclusion

- `producer-only bias`: pass
- `replica-aware source selection`: still not implemented

## Next Connection Point

The next question is no longer whether the producer-only bias exists.

It is now:

- what is the smallest cut that can connect `replicaNodes` to actual source selection?
