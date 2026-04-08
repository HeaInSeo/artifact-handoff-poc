# SECOND_EDGE_CROSS_NODE_CHECK

## Purpose

This note fixes the cross-node view confirmed in `Sprint D12 - Second Edge Cross-Node Check`.

Question:

- under `catalog record missing + local artifact exists`, what happens on a non-producer node

## Live Validation Scenario

- artifact id: `edge-catalog-miss-20260408-cross`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-1`

Execution flow:

1. create a fresh artifact on worker0
2. read `producerNode` from the catalog once
3. restart `artifact-catalog` to clear the emptyDir-backed catalog state
4. request `/artifacts/{id}` from worker1

## What Was Actually Observed

Consumer log:

```text
status=404
{
  "error": "catalog lookup failed"
}
```

Catalog lookup:

```text
HTTP/1.0 404 Not Found
```

Consumer local metadata snapshot:

```json
{
  "artifactId": "edge-catalog-miss-20260408-cross",
  "lastError": "catalog lookup failed",
  "localAddress": "http://10.87.127.150:8080",
  "localNode": "lab-worker-1",
  "localPath": "/var/lib/artifact-handoff/edge-catalog-miss-20260408-cross/payload.bin",
  "producerAddress": "",
  "producerNode": "",
  "source": "catalog-lookup",
  "state": "fetch-failed"
}
```

## Interpretation

Unlike the same-node view, the cross-node consumer does not have the local artifact copy.

So, in the current implementation:

- no local hit succeeds first
- catalog truth is also gone
- the public `/artifacts/...` path ends as `catalog lookup failed`

So the same edge-case family splits by node position:

- same-node: local-first reuse
- cross-node: catalog-lookup failure

## What This Means

This makes the meaning of `catalog absence` more precise across node position.

- on the producer/local node, a surviving local copy can mask catalog absence
- on a non-producer node, without catalog truth there is not enough information to enter the peer path

## One-Line Conclusion

As of `Sprint D12`, `catalog record missing + local artifact exists` surfaces **as `catalog lookup failed` with `fetch-failed` metadata in the cross-node view**.
