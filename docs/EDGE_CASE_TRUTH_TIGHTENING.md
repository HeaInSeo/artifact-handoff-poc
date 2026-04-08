# EDGE_CASE_TRUTH_TIGHTENING

## Purpose

This note records the confirmed edge-case truth from `Sprint D5 - Edge Case Truth Tightening`.

This sprint validated the question selected in `D3`:

- `catalog record exists + local artifact missing`

## Scenario Validated

This sprint reproduced the same-node case:

1. create a fresh artifact on the producer node
2. keep the catalog record intact
3. remove only the hostPath artifact directory on the same node
4. request `/artifacts/{id}` again from that same node

artifact id:

- `edge-local-miss-20260408-same`

producer/consumer node:

- `lab-worker-0`

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

## Interpretation Fixed By This Sprint

- producer-origin truth is catalog-owned
- current-node local availability is local-metadata and hostPath-owned
- same-node local artifact loss does not erase catalog truth
- but it does cause the same-node path to surface as a self-loop failure

So this edge case makes it explicit that “catalog truth still exists” and “the local copy is actually present on the current node” are not the same thing.

## What Still Remains

- this sprint confirmed only the same-node path first
- whether the cross-node version recovers through peer fetch remains the next candidate
- the `catalog record missing + local artifact exists` edge case also remains open

## One-Line Conclusion

As of `Sprint D5`, the same-node `catalog record exists + local artifact missing` case is fixed as: **catalog truth remains, but if actual local availability is gone, the current implementation surfaces a self-loop failure.**
