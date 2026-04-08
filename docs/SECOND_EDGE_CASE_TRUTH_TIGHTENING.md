# SECOND_EDGE_CASE_TRUTH_TIGHTENING

## Purpose

This note fixes the observed behavior confirmed in `Sprint D10 - Second Edge Case Truth Tightening`.

Selected question:

- `catalog record missing + local artifact exists`

## Live Validation Scenario

- artifact id: `edge-catalog-miss-20260408-v2`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-0`

Execution flow:

1. create a fresh artifact on worker0
2. read `producerNode` from the catalog once
3. restart `artifact-catalog` to clear the emptyDir-backed catalog state
4. keep the local artifact copy intact and request `/artifacts/{id}` from the same node

## What Was Actually Observed

Consumer log:

```text
status=200
source=local
artifact-handoff sprint1 sample payload
```

Catalog lookup:

```text
HTTP/1.0 404 Not Found
```

Local metadata snapshot:

```json
{
  "artifactId": "edge-catalog-miss-20260408-v2",
  "digest": "d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1",
  "localAddress": "http://10.87.127.94:8080",
  "localNode": "lab-worker-0",
  "localPath": "/var/lib/artifact-handoff/edge-catalog-miss-20260408-v2/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "size": 40,
  "source": "local-put",
  "state": "available-local"
}
```

## Interpretation

In the current implementation, the public same-node `/artifacts/...` path checks the local hit before it checks catalog lookup.

So:

- even if the catalog truth is gone
- if the same-node local copy and local metadata are still valid
- the request still succeeds as `source=local`

At this stage, the edge case does not surface as a lookup failure. It surfaces as **local-first reuse masking catalog absence**.

## What This Means

This sharpens the authority boundary between `catalog` and `local metadata`.

- `catalog` remains the entry point for placement and peer-fetch decisions
- but the same-node local-hit path does not require catalog as a front gate
- so a surviving local artifact can prevent catalog absence from becoming an immediate user-visible failure

## What Still Remains Open

- This validation only checked the same-node path.
- The cross-node meaning of `catalog record missing + local artifact exists` is still open.
- It is still undecided whether this should be interpreted as acceptable reuse or only as an orphan/local-leftover side effect.

## One-Line Conclusion

As of `Sprint D10`, `catalog record missing + local artifact exists` surfaces as a **same-node `source=local` success, where catalog absence does not outrank a valid local hit**.
