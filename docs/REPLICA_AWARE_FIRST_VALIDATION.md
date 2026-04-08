# REPLICA_AWARE_FIRST_VALIDATION

## Purpose

This note fixes the first evidence gathered in `Sprint F4 - Replica-Aware Fetch First Validation`.

Question:

- in the current implementation, are `replicaNodes` and replica local metadata actually prepared
- and does that already mean the system is replica-aware

## Live validation scenario

- artifact id: `replica-aware-20260408`
- producer node: `lab-worker-0`
- first replica node: `lab-worker-1`
- helper used:
  - [run-replica-aware-prep.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-replica-aware-prep.sh)

Flow:

1. create the producer and first replica through the existing cross-node flow
2. verify that the catalog actually contains `replicaNodes`
3. verify replica-node local metadata
4. read the current code path together with the live result

## What was actually observed

parent log:

```text
{
  "artifactId": "replica-aware-20260408",
  "digest": "d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1",
  "localAddress": "http://10.87.127.94:8080",
  "localNode": "lab-worker-0",
  "localPath": "/var/lib/artifact-handoff/replica-aware-20260408/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "size": 40,
  "source": "local-put",
  "state": "available-local"
}
```

child log:

```text
artifact-handoff sprint1 sample payload
source=peer-fetch
digest=d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1
```

catalog snapshot:

```json
{
  "artifactId": "replica-aware-20260408",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "replicaNodes": [
    {
      "address": "http://10.87.127.150:8080",
      "localPath": "/var/lib/artifact-handoff/replica-aware-20260408/payload.bin",
      "node": "lab-worker-1",
      "state": "replicated"
    }
  ]
}
```

replica local metadata snapshot:

```json
{
  "localNode": "lab-worker-1",
  "producerNode": "lab-worker-0",
  "replicaNode": "lab-worker-1",
  "source": "peer-fetch",
  "state": "replicated"
}
```

## What was also confirmed from the code

The current agent still reads `record.get("producerAddress")` directly as the fetch source.

Evidence:

- [agent.py](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/app/agent/agent.py), inside `peer_fetch()`
- `producer = record.get("producerAddress")`

Meanwhile, the catalog does keep `replicaNodes`, but the current fetch path does not yet use it for actual source selection.

## Conclusion of this validation

This sprint confirmed two things:

1. `replicaNodes` and replica local metadata are actually prepared in live runs
2. but the current implementation still does not perform replica-aware fetch; it still has producer-only bias

So the current state is:

- `replica-ready state`: yes
- `replica-aware source selection`: not yet

## One-line conclusion

The conclusion of `Sprint F4` is that **the current implementation can create a replica-ready state in live validation, but fetch source selection is still centered on `producerAddress`, so it cannot yet be called replica-aware fetch**.
