# EDGE_CASE_TRUTH_TIGHTENING

## 목적

이 문서는 `Sprint D5 - Edge Case Truth Tightening`에서 실제로 확인한 edge case truth를 고정하기 위한 메모다.

이번 스프린트에서는 `D3`에서 선택한 다음 질문을 실검증했다.

- `catalog record exists + local artifact missing`

## 검증한 시나리오

이번에는 아래 두 관점을 확인했다.

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

## 실제로 확인한 것

### 1. catalog truth는 남아 있었다

catalog record snapshot:

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

### 2. same-node/local miss는 self-loop failure로 드러났다

consumer log:

```text
status=404
{
  "error": "artifact missing locally and producer points to self"
}
```

### 3. local metadata는 failure forensic trail로 남았다

worker0 agent local metadata:

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

### 4. cross-node에서는 peer fetch recovery가 실제로 이어졌다

consumer log:

```text
status=200
source=peer-fetch
artifact-handoff sprint1 sample payload
```

catalog snapshot:

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

worker1 local metadata:

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

## 이번 스프린트에서 고정한 해석

- producer origin truth는 catalog 기준이다.
- current node local availability는 local metadata와 실제 hostPath 기준이다.
- same-node에서 local artifact가 사라져도 catalog truth는 유지될 수 있다.
- 하지만 그 경우 same-node 경로는 자동 성공이 아니라 self-loop failure로 드러난다.
- 반면 non-producer node에서는 같은 producer truth를 기준으로 peer fetch recovery가 가능하다.

즉 이 edge case는 “catalog truth가 남아 있는 것”과 “현재 node local copy가 실제로 존재하는 것”이 같은 의미가 아니라는 점을 분명히 보여 준다. 또한 local availability가 사라진 node와 아닌 node는 같은 catalog truth를 보고도 다른 결과를 낼 수 있다는 점도 함께 드러난다.

## 아직 남는 점

- `catalog record missing + local artifact exists` edge case는 아직 남아 있다.

## 결론 한 줄

`Sprint D7` 기준으로 `catalog record exists + local artifact missing`는 **same-node에서는 self-loop failure, cross-node에서는 peer-fetch recovery**로 드러난다는 사실로 정리된다.
