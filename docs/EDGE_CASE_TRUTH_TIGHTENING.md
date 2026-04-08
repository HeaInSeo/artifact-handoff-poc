# EDGE_CASE_TRUTH_TIGHTENING

## Purpose

This note records the confirmed edge-case truth from `Sprint D5 - Edge Case Truth Tightening`.

This sprint validated the question selected in `D3`:

- `catalog record exists + local artifact missing`

## Scenario Validated

This work now confirms both:

1. same-node
2. cross-node

artifact ids:

- `edge-local-miss-20260408-same`
- `edge-local-miss-20260408-cross`

producer/consumer node:

- same-node:
  - producer `lab-worker-0`
  - consumer `lab-worker-0`
- cross-node:
  - producer `lab-worker-0`
  - consumer `lab-worker-1`

## What Was Confirmed

### 1. Catalog truth remained intact

Catalog record snapshot:

```json
{
  "artifactId": "edge-local-miss-20260408-same",
  "digest": "d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1",
  "localPath": "/var/lib/artifact-handoff/edge-local-miss-20260408-same/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "replicaNodes": [],
  "state": "produced"
}
```

### 2. The same-node local miss surfaced as a self-loop failure

Consumer log:

```text
status=404
{
  "error": "artifact missing locally and producer points to self"
}
```

### 3. Local metadata remained as the failure forensic trail

Worker0 agent local metadata:

```json
{
  "artifactId": "edge-local-miss-20260408-same",
  "lastError": "artifact missing locally and producer points to self",
  "localAddress": "http://10.87.127.94:8080",
  "localNode": "lab-worker-0",
  "localPath": "/var/lib/artifact-handoff/edge-local-miss-20260408-same/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "source": "peer-fetch",
  "state": "fetch-failed"
}
```

### 4. In the cross-node view, peer-fetch recovery actually succeeded

Consumer log:

```text
status=200
source=peer-fetch
artifact-handoff sprint1 sample payload
```

Catalog snapshot:

```json
{
  "artifactId": "edge-local-miss-20260408-cross",
  "digest": "d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1",
  "localPath": "/var/lib/artifact-handoff/edge-local-miss-20260408-cross/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "replicaNodes": [
    {
      "address": "http://10.87.127.150:8080",
      "localPath": "/var/lib/artifact-handoff/edge-local-miss-20260408-cross/payload.bin",
      "node": "lab-worker-1",
      "state": "replicated"
    }
  ],
  "state": "produced"
}
```

Worker1 local metadata:

```json
{
  "artifactId": "edge-local-miss-20260408-cross",
  "digest": "d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1",
  "localAddress": "http://10.87.127.150:8080",
  "localNode": "lab-worker-1",
  "localPath": "/var/lib/artifact-handoff/edge-local-miss-20260408-cross/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "size": 40,
  "source": "peer-fetch",
  "state": "replicated"
}
```

## Interpretation Fixed By This Sprint

- producer-origin truth is catalog-owned
- current-node local availability is local-metadata and hostPath-owned
- same-node local artifact loss does not erase catalog truth
- but it does cause the same-node path to surface as a self-loop failure
- by contrast, a non-producer node can still recover through peer fetch from the same catalog truth

So this edge case makes it explicit that “catalog truth still exists” and “the local copy is actually present on the current node” are not the same thing. It also shows that different nodes can observe different outcomes while referring to the same catalog truth.

## What Still Remains

- the `catalog record missing + local artifact exists` edge case also remains open

## One-Line Conclusion

As of `Sprint D7`, `catalog record exists + local artifact missing` is fixed as: **same-node surfaces a self-loop failure, while cross-node recovers through peer fetch.**
