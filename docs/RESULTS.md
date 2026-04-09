# RESULTS

## Summary

This file captures actual validation results for Sprint 1.

Important:

- The results below are based on execution records collected on `2026-04-03` and `2026-04-04`.
- On `2026-04-06`, I re-ran same-node, cross-node, and second-hit validation against the `multipass-k8s-lab` environment using the latest code.
- So this file now combines the earlier execution history with fresh rerun results from `2026-04-06`.

## Environment

- Lab repo: `../multipass-k8s-lab`
- Expected cluster shape: `1 control-plane + 2 workers`
- PoC namespace: `artifact-handoff`

## Observed Status

- `2026-04-03`: initial check from `multipass-k8s-lab/scripts/k8s-tool.sh status` showed only `k8s-master-0` running.
- `2026-04-03`: `multipass-k8s-lab/scripts/k8s-tool.sh up` failed before 3-node bring-up because Multipass could not resolve the configured image alias `rocky-8`.
- `2026-04-03`: kubeconfig was exported directly from the existing `k8s-master-0` VM to allow partial validation on the remaining single-node cluster.
- `2026-04-03`: PoC baseline deployed successfully to namespace `artifact-handoff` on that single-node cluster.
- `2026-04-04`: after the lab baseline was switched to Ubuntu 24.04 and the worker join/runtime issues were resolved, the intended `1 control-plane + 2 workers` cluster became available again.
- `2026-04-04`: cross-node validation succeeded on the recovered 3-node lab.

## Same-Node Reuse

- Status: passed in the recorded `2026-04-03` run
- Parent job `parent-same-node` registered artifact `demo-artifact`
- Child job `child-same-node` completed successfully
- Observed child output:
  - payload: `artifact-handoff sprint1 sample payload`
  - source: `local`
  - digest: `d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1`
- Catalog contents after the run:
  - `artifactId`: `demo-artifact`
  - `producerNode`: `k8s-master-0`
  - `producerAddress`: `http://10.87.127.29:8080`
  - `state`: the recorded run showed `ready`
  - `replicaNodes`: `[]`

Current code interpretation:

- In the latest code, the catalog top-level state is handled as `produced` for parent registration.
- Same-node child placement is now assisted by scripts that read `producerNode` from the catalog after the parent run.
- So the same-node flow is still shell-script-orchestrated, but the placement input is now closer to metadata-driven behavior than before.

`2026-04-06` rerun:

- fresh artifact ID: `demo-artifact-20260406-same`
- parent on `lab-worker-0`
- child output `source=local`
- digest matched
- parent job local metadata included:
  - `producerNode`: `lab-worker-0`
  - `producerAddress`: `http://10.87.127.94:8080`
  - `localNode`: `lab-worker-0`
  - `localAddress`: `http://10.87.127.94:8080`
  - `state`: `available-local`
- catalog record:
  - `artifactId`: `demo-artifact-20260406-same`
  - `producerNode`: `lab-worker-0`
  - `producerAddress`: `http://10.87.127.94:8080`
  - `state`: `produced`
  - `replicaNodes`: `[]`

Log snapshot:

```text
== parent log ==
{
  "artifactId": "demo-artifact-20260406-same",
  "digest": "d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1",
  "localAddress": "http://10.87.127.94:8080",
  "localNode": "lab-worker-0",
  "localPath": "/var/lib/artifact-handoff/demo-artifact-20260406-same/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "size": 40,
  "source": "local-put",
  "state": "available-local"
}

== child log ==
artifact-handoff sprint1 sample payload
source=local
digest=d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1
```

## Cross-Node Peer Fetch

- `2026-04-03` status: blocked by lab readiness
- `2026-04-03` script result: `need at least two schedulable nodes for cross-node validation`
- `2026-04-04` status: passed after lab recovery
- Successful scenario:
  - parent on `lab-worker-0`
  - child on `lab-worker-1`
  - child output `source=peer-fetch`
  - digest matched
  - catalog recorded producer and replica node information

Current code interpretation:

- The latest scripts read `producerNode` from the catalog after the parent run, then choose a different node for the cross-node child scenario.
- Fetch source selection is still producer-address-centric and does not yet implement replica-aware policy.

`2026-04-06` rerun:

- fresh artifact ID: `demo-artifact-20260406-cross`
- parent on `lab-worker-0`
- child on `lab-worker-1`
- child output `source=peer-fetch`
- digest matched
- second-hit child output `source=local`
- catalog record:
  - `artifactId`: `demo-artifact-20260406-cross`
  - `producerNode`: `lab-worker-0`
  - `producerAddress`: `http://10.87.127.94:8080`
  - `state`: `produced`
  - `replicaNodes[0].node`: `lab-worker-1`
  - `replicaNodes[0].address`: `http://10.87.127.150:8080`
  - `replicaNodes[0].state`: `replicated`

Log snapshot:

```text
== parent log ==
{
  "artifactId": "demo-artifact-20260406-cross",
  "digest": "d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1",
  "localAddress": "http://10.87.127.94:8080",
  "localNode": "lab-worker-0",
  "localPath": "/var/lib/artifact-handoff/demo-artifact-20260406-cross/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "size": 40,
  "source": "local-put",
  "state": "available-local"
}

== child log ==
artifact-handoff sprint1 sample payload
source=peer-fetch
digest=d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1

== second hit log ==
artifact-handoff sprint1 sample payload
source=local
digest=d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1
```

## Second-Hit Cache

- Status: not captured in the final notes
- Earlier status on `2026-04-03`: not run because cross-node fetch could not be validated without a second node

Current code interpretation:

- The script still supports `--second-hit` and expects the second child on node B to observe `source=local`.
- In the `2026-04-06` rerun, the second-hit local cache path passed for `demo-artifact-20260406-cross`.

## Failure Scenario Validation

On `2026-04-08`, I validated whether the B6 failure metadata recording actually leaves evidence in local metadata by running two small failure scenarios.

Terminology note:

- the terms `fetch-failed`, `lastError`, `peer fetch exception`, `peer digest mismatch`, and `peer fetch http 409: digest mismatch` in this section follow the taxonomy in [peer-fetch-failure-paths.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.md).
- for a one-page view of the representative validated failures, see [FAILURE_MATRIX.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/FAILURE_MATRIX.md).

### Scenario A: producer points to self

- scenario name: `producer points to self`
- artifact ID: `fail-self-20260408b`
- producer node: `lab-worker-1`
- consumer node: `lab-worker-1`
- injection method:
  - catalog record set with `producerNode=lab-worker-1`
  - `producerAddress=http://10.87.127.150:8080`
  - no real payload existed on worker1 local storage
- expected outcome:
  - after a local miss, peer fetch should detect that the producer points to self
  - local metadata should record `state=fetch-failed` and `lastError`
- result: pass
- interpretation:
  - a self-loop style producer reference is surfaced clearly by the agent, and the reason is left in local metadata.

Key log:

```text
status=404
{
  "error": "artifact missing locally and producer points to self"
}
```

Local metadata snapshot:

```json
{
  "artifactId": "fail-self-20260408b",
  "lastError": "artifact missing locally and producer points to self",
  "localAddress": "http://10.87.127.150:8080",
  "localNode": "lab-worker-1",
  "localPath": "/var/lib/artifact-handoff/fail-self-20260408b/payload.bin",
  "producerAddress": "http://10.87.127.150:8080",
  "producerNode": "lab-worker-1",
  "source": "peer-fetch",
  "state": "fetch-failed"
}
```

### Scenario B: peer fetch exception

- scenario name: `peer fetch exception`
- artifact ID: `fail-peer-exc-20260408`
- producer node: recorded as `lab-master-0`
- consumer node: `lab-worker-1`
- injection method:
  - catalog record set with `producerAddress=http://10.87.127.18:18080`
  - no agent was actually listening on that address
- expected outcome:
  - peer fetch should fail with a connection error
  - local metadata should record `state=fetch-failed` and `lastError`
- result: pass
- interpretation:
  - even when peer fetch fails because of a network/endpoint problem, the agent leaves a local failure record instead of only returning a transient HTTP error.

Key log:

```text
status=404
{
  "error": "<urlopen error [Errno 111] Connection refused>"
}
```

Local metadata snapshot:

```json
{
  "artifactId": "fail-peer-exc-20260408",
  "lastError": "<urlopen error [Errno 111] Connection refused>",
  "localAddress": "http://10.87.127.150:8080",
  "localNode": "lab-worker-1",
  "localPath": "/var/lib/artifact-handoff/fail-peer-exc-20260408/payload.bin",
  "producerAddress": "http://10.87.127.18:18080",
  "producerNode": "lab-master-0",
  "source": "peer-fetch",
  "state": "fetch-failed"
}
```

## Digest Mismatch Failure Validation

On `2026-04-08`, I ran one additional digest-mismatch-focused validation after B7 to confirm that this class of failure also leaves `fetch-failed` local metadata.

Terminology note:

- `local digest mismatch` is treated as a local verification failure with `source=local-verify`.
- the distinction between `peer digest mismatch` and `peer fetch http 409: digest mismatch` is documented in [peer-fetch-failure-paths.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.md).

### Scenario C: local digest mismatch

- scenario name: `local digest mismatch`
- artifact ID: `fail-internal-local-digest-20260408`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-0`
- reproduction method:
  - first `PUT` a valid payload into the worker0 agent
  - then overwrite the stored `payload.bin` on the same node
  - call `/internal/artifacts/{artifactId}` first to force the local verify path only
  - then call the public `/artifacts/{artifactId}` path again
- expected outcome:
  - local verification should fail with `local digest mismatch`
  - local metadata should record `state=fetch-failed`, `source=local-verify`, and `lastError=local digest mismatch`
  - the public path should also surface the preserved `lastError`
- result: pass
- interpretation:
  - a corrupted local artifact is now preserved as a local verification failure instead of being blurred by peer-fetch fallback semantics.

Key log:

`/internal/artifacts/...` call:

```text
status=404
{
  "error": "local digest mismatch"
}
```

public `/artifacts/...` call after the preserved failure metadata:

```text
status=404
{
  "error": "local digest mismatch"
}
```

Local metadata snapshot:

```json
{
  "artifactId": "fail-internal-local-digest-20260408",
  "lastError": "local digest mismatch",
  "localAddress": "http://10.87.127.94:8080",
  "localNode": "lab-worker-0",
  "localPath": "/var/lib/artifact-handoff/fail-internal-local-digest-20260408/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "source": "local-verify",
  "state": "fetch-failed"
}
```

Additional note:

- During this validation I found a narrow issue where the public `/artifacts/...` path could overwrite a fresh `local digest mismatch` with the later self-loop peer-fetch error.
- I applied a narrow GET-path fix so that, when `fetch-failed` local metadata already exists, the agent returns that preserved `lastError` instead of immediately re-entering peer-fetch fallback.
- After restarting the worker0 agent pod, the public path also returned `local digest mismatch` as intended.

### Scenario D: peer digest mismatch

- scenario name: `peer digest mismatch`
- artifact IDs:
  - end-to-end HTTP probe: `fail-peer-digest-http-20260408`
  - direct peer-fetch branch probe: `fail-peer-digest-direct-20260408`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-1`
- validation method:
  - first probe the real HTTP flow by intentionally corrupting the catalog digest for a cross-node fetch
  - then call the live consumer pod's `peer_fetch()` branch directly with a narrowly monkeypatched peer response
- expected outcome:
  - ideally confirm whether the real HTTP path can surface `peer digest mismatch`
  - at minimum confirm that the live branch records `fetch-failed` with `lastError=peer digest mismatch`

1. end-to-end HTTP probe

- I overwrote the catalog record digest with `0000...` and then requested the artifact from worker1 through the public `/artifacts/...` path.
- result:

```text
status=409
{
  "error": "catalog lookup failed"
}
```

- consumer local metadata:

```json
{
  "artifactId": "fail-peer-digest-http-20260408",
  "lastError": "catalog lookup failed",
  "localAddress": "http://10.87.127.150:8080",
  "localNode": "lab-worker-1",
  "localPath": "/var/lib/artifact-handoff/fail-peer-digest-http-20260408/payload.bin",
  "producerAddress": "",
  "producerNode": "",
  "source": "catalog-lookup",
  "state": "fetch-failed"
}
```

- interpretation:
  - in the current design, the producer's `/internal/artifacts/...` endpoint checks the expected digest first, so the end-to-end HTTP path does not cleanly reach the consumer-side `peer digest mismatch` branch.
  - the public `/artifacts/...` path currently collapses that `409` into `catalog lookup failed`, which also shows that observability for this case is still coarse.

2. direct peer-fetch branch probe

- inside the live worker1 pod, I called `peer_fetch()` directly while narrowly monkeypatching `fetch_catalog()` and the peer response so the returned payload digest would not match the expected digest.
- result:

```text
ValueError
peer digest mismatch
```

- consumer local metadata:

```json
{
  "artifactId": "fail-peer-digest-direct-20260408",
  "lastError": "peer digest mismatch",
  "localAddress": "http://10.87.127.150:8080",
  "localNode": "lab-worker-1",
  "localPath": "/var/lib/artifact-handoff/fail-peer-digest-direct-20260408/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "source": "peer-fetch",
  "state": "fetch-failed"
}
```

- result: partial pass
- interpretation:
  - the live branch correctly records `peer digest mismatch` as a consumer-side verification failure.
  - however, the current producer-side internal digest gate causes the same integrity issue to appear earlier as producer-side rejection in the end-to-end HTTP path.

## Peer Fetch HTTP Error Attribution Tightening

On `2026-04-08`, I followed up on the B9 attribution gap by tightening the public `/artifacts/...` error handling so producer-side HTTP failures are no longer collapsed into `catalog lookup failed`.

Terminology note:

- this section does not redefine `peer digest mismatch`; it makes producer-side rejection visible as `peer fetch http 409: digest mismatch`.
- the detailed distinction is captured in [peer-fetch-failure-paths.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.md).

### Scenario E: peer digest mismatch after attribution tightening

- scenario name: `peer digest mismatch after attribution tightening`
- artifact ID: `fail-peer-digest-http-b10-20260408`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-1`
- reproduction method:
  - create a valid artifact on worker0
  - overwrite the catalog digest with `0000...`
  - request the artifact from worker1 through the public `/artifacts/{artifactId}` path
- expected outcome:
  - the response should no longer be mislabeled as `catalog lookup failed`
  - consumer local metadata should preserve `source=peer-fetch` and producer information
- result: pass
- interpretation:
  - the end-to-end HTTP path now exposes the producer-side internal `409 digest mismatch` as `peer fetch http 409: digest mismatch`.

Key log:

```text
status=409
{
  "error": "peer fetch http 409: digest mismatch"
}
```

Local metadata snapshot:

```json
{
  "artifactId": "fail-peer-digest-http-b10-20260408",
  "lastError": "peer fetch http 409: digest mismatch",
  "localAddress": "http://10.87.127.150:8080",
  "localNode": "lab-worker-1",
  "localPath": "/var/lib/artifact-handoff/fail-peer-digest-http-b10-20260408/payload.bin",
  "producerAddress": "http://10.87.127.94:8080",
  "producerNode": "lab-worker-0",
  "source": "peer-fetch",
  "state": "fetch-failed"
}
```

Additional interpretation:

- This change does not remove the producer-side digest gate itself.
- The producer still rejects the request before the consumer-side branch can independently conclude `peer digest mismatch`.
- What changed is the attribution: the public path now reports that failure as a peer-side HTTP error instead of incorrectly labeling it as a catalog lookup failure.

## Edge Case Truth Tightening

On `2026-04-08`, the first post-freeze edge-case truth was validated in a narrow form.

Terminology note:

- this scenario is not a new failure-taxonomy expansion; it is a validation of the authority boundary between the `catalog` and `local metadata`
- see [EDGE_CASE_TRUTH_TIGHTENING.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/EDGE_CASE_TRUTH_TIGHTENING.md) for the focused interpretation note

### Scenario F: catalog record exists + local artifact missing (same-node)

- scenario: `catalog record exists + local artifact missing`
- artifact id: `edge-local-miss-20260408-same`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-0`
- reproduction:
  - create a fresh artifact on worker0
  - keep the catalog record intact
  - remove only `/var/lib/artifact-handoff/edge-local-miss-20260408-same` from worker0 hostPath
  - request `/artifacts/{id}` again from the same node
- verdict: pass
- interpretation:
  - catalog truth remains intact, but if actual local availability is gone, the same-node path surfaces as a self-loop failure

Key log:

```text
mode=same-node
producer_node=lab-worker-0
consumer_node=lab-worker-0

== consumer log ==
status=404
{
  "error": "artifact missing locally and producer points to self"
}
```

Catalog snapshot:

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

Local metadata snapshot:

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

### Scenario G: catalog record exists + local artifact missing (cross-node)

- scenario: `catalog record exists + local artifact missing`
- artifact id: `edge-local-miss-20260408-cross`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-1`
- reproduction:
  - create a fresh artifact on worker0
  - keep the catalog record intact
  - remove only `/var/lib/artifact-handoff/edge-local-miss-20260408-cross` from worker1
  - request `/artifacts/{id}` from worker1
- verdict: pass
- interpretation:
  - producer truth remains intact, and a non-producer node can recover through peer fetch

Key log:

```text
mode=cross-node
producer_node=lab-worker-0
consumer_node=lab-worker-1

== consumer log ==
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

### Scenario H: catalog record missing + local artifact exists (same-node)

- scenario: `catalog record missing + local artifact exists`
- artifact id: `edge-catalog-miss-20260408-v2`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-0`
- reproduction:
  - create a fresh artifact on worker0
  - restart `artifact-catalog` to clear the emptyDir-backed catalog state
  - keep the local artifact copy intact
  - request `/artifacts/{id}` again from the same node
- verdict: pass
- interpretation:
  - in the current implementation, the public same-node path checks local hit before catalog lookup, so the request still succeeds as `source=local` even after the catalog record disappears.

Key log:

```text
producer_node=lab-worker-0
consumer_node=lab-worker-0

== drop-catalog log ==
restarted artifact-catalog to clear emptyDir-backed catalog state

== consumer log ==
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

### Scenario I: catalog record missing + local artifact exists (cross-node)

- scenario: `catalog record missing + local artifact exists`
- artifact id: `edge-catalog-miss-20260408-cross`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-1`
- reproduction:
  - create a fresh artifact on worker0
  - restart `artifact-catalog` to clear the emptyDir-backed catalog state
  - request `/artifacts/{id}` from worker1
- verdict: pass
- interpretation:
  - in the cross-node view, there is no local hit and no catalog truth, so the current implementation ends with `catalog lookup failed` and `fetch-failed` metadata.

Key log:

```text
producer_node=lab-worker-0
consumer_node=lab-worker-1

== drop-catalog log ==
restarted artifact-catalog to clear emptyDir-backed catalog state

== consumer log ==
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

Local metadata snapshot:

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

## Replica-Aware Fetch First Validation

On `2026-04-08`, the first live evidence for the replica-aware fetch track was collected.

The key finding has two parts:

- `replicaNodes` and replica local metadata are actually prepared
- but the current fetch path still remains centered on `producerAddress`

scenario:

- artifact id: `replica-aware-20260408`
- producer node: `lab-worker-0`
- first replica node: `lab-worker-1`
- helper:
  - [run-replica-aware-prep.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-replica-aware-prep.sh)

verdict:

- `replica-ready state`: pass
- `replica-aware source selection`: not yet

key log:

```text
== child log ==
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

replica metadata snapshot:

```json
{
  "localNode": "lab-worker-1",
  "producerNode": "lab-worker-0",
  "replicaNode": "lab-worker-1",
  "source": "peer-fetch",
  "state": "replicated"
}
```

current-code interpretation:

- the catalog keeps `replicaNodes`
- but the agent `peer_fetch()` still reads `record.get("producerAddress")` directly
- so the current state should be read as **replica-ready but still producer-biased**, not yet replica-aware fetch

## Producer-Bias Validation Kickoff

On `2026-04-08`, the first live evidence that more directly exposes the producer-only bias was collected.

scenario:

- artifact id: `producer-bias-20260408c`
- producer node: `lab-worker-0`
- first replica node: `lab-worker-1`
- third consumer node: `lab-master-0`
- helper:
  - [run-producer-bias-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-producer-bias-check.sh)

execution flow:

- first prepare the first replica and populated `replicaNodes`
- then rewrite only the catalog top-level `producerAddress` to `http://10.255.255.1:8080`
- then call `/artifacts/{id}` from a third node that is neither the producer nor the first replica

verdict:

- `producer-only bias`: pass
- `replica-aware source selection`: still not implemented

key log:

```text
== step 4: third-node request ==
status=404
{
  "error": "<urlopen error timed out>"
}
```

catalog snapshot after producer rewrite:

```json
{
  "artifactId": "producer-bias-20260408c",
  "producerAddress": "http://10.255.255.1:8080",
  "replicaNodes": [
    {
      "address": "http://10.87.127.150:8080",
      "localPath": "/var/lib/artifact-handoff/producer-bias-20260408c/payload.bin",
      "node": "lab-worker-1",
      "state": "replicated"
    }
  ]
}
```

third-node consumer local metadata:

```json
{
  "artifactId": "producer-bias-20260408c",
  "lastError": "<urlopen error timed out>",
  "localAddress": "http://10.87.127.18:8080",
  "localNode": "lab-master-0",
  "localPath": "/var/lib/artifact-handoff/producer-bias-20260408c/payload.bin",
  "producerAddress": "http://10.255.255.1:8080",
  "producerNode": "lab-worker-0",
  "source": "peer-fetch",
  "state": "fetch-failed"
}
```

current code interpretation:

- the third-node consumer has no local copy, so it enters the peer-fetch path
- but `peer_fetch()` still does not use `replicaNodes` as a source candidate
- so even when the first replica exists, the request still follows only the broken producer endpoint and fails
- this gives a more direct confirmation that the current implementation is still **producer-biased**, not replica-aware

## Replica Source-Selection Validation

On `2026-04-09`, the live validation checked whether the `F8` minimum cut produced a real source-selection change.

scenario:

- artifact id: `replica-source-select-20260409`
- producer node: `lab-worker-0`
- first replica node: `lab-worker-1`
- third consumer node: `lab-master-0`
- helper:
  - [run-producer-bias-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-producer-bias-check.sh)

execution flow:

- prepare the first replica and populated `replicaNodes`
- rewrite only the catalog top-level `producerAddress` to `http://10.255.255.1:8080`
- request `/artifacts/{id}` from a third node that is neither the producer nor the first replica

verdict:

- `replica fallback after producer failure`: pass
- `replica-aware source selection`: first live pass

key log:

```text
== step 4: third-node request ==
status=200
source=peer-fetch
artifact-handoff sprint1 sample payload
```

catalog snapshot after producer rewrite:

```json
{
  "artifactId": "replica-source-select-20260409",
  "producerAddress": "http://10.255.255.1:8080",
  "replicaNodes": [
    {
      "address": "http://10.87.127.150:8080",
      "localPath": "/var/lib/artifact-handoff/replica-source-select-20260409/payload.bin",
      "node": "lab-worker-1",
      "state": "replicated"
    }
  ]
}
```

third-node consumer local metadata:

```json
{
  "artifactId": "replica-source-select-20260409",
  "digest": "d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1",
  "localAddress": "http://10.87.127.18:8080",
  "localNode": "lab-master-0",
  "localPath": "/var/lib/artifact-handoff/replica-source-select-20260409/payload.bin",
  "producerAddress": "http://10.255.255.1:8080",
  "producerNode": "lab-worker-0",
  "size": 40,
  "source": "peer-fetch",
  "state": "replicated"
}
```

current code interpretation:

- after the current cut, the implementation can move from a failed producer candidate to a replica candidate
- so `replicaNodes` now participates in the actual source-selection path
- however, local metadata still keeps `producerAddress` as the origin producer field, so it does not necessarily identify the actual fetch endpoint

## Notes

- The repository baseline and scripts are intended to run against a lab cluster prepared by `multipass-k8s-lab`.
- `scripts/check-lab.sh` defaults to `MIN_NODES=3` and fails fast when the intended lab shape is missing.
- For partial debugging on the leftover single-node cluster, `MIN_NODES=1` was used to deploy and run same-node validation only.
- The earlier blocked state in this file reflects the `2026-04-03` checkpoint rather than the final recovered lab state.
- The later recovery and successful cross-node validation are summarized in [TROUBLESHOOTING_NOTES.md](TROUBLESHOOTING_NOTES.md) and [VALIDATION_HISTORY.md](VALIDATION_HISTORY.md).
- The `2026-04-06` rerun also exposed two operational issues that are now part of the validation story:
- The latest agent code now writes local failure metadata with `state=fetch-failed` and `lastError` when peer fetch or local verification fails.
  - the host `python3` was 3.6, so the metadata helper in the scripts needed a compatibility fix away from `text=True`
  - the first cross-node rerun hit old cache and old running pods, so a fresh `ARTIFACT_ID` and pod restart were needed before the expected `peer-fetch` path was observed
- In the `2026-04-08` failure scenario validation, both `producer points to self` and `peer fetch exception` produced the expected `fetch-failed` local metadata.
- In the `2026-04-08` digest mismatch validation, `local digest mismatch` produced the expected `source=local-verify`, `state=fetch-failed`, and `lastError=local digest mismatch`.
- In the `2026-04-08` peer digest mismatch validation, the live consumer pod's `peer_fetch()` branch recorded `lastError=peer digest mismatch`, but the end-to-end HTTP path still stopped earlier at the producer-side digest gate.
- After the `2026-04-08` B10 attribution tightening, the same end-to-end HTTP path surfaced `peer fetch http 409: digest mismatch`, and the local metadata kept `source=peer-fetch` plus producer information.
