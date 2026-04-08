# EDGE_CASE_TRUTH_TIGHTENING

## 목적

이 문서는 `Sprint D5 - Edge Case Truth Tightening`에서 실제로 확인한 edge case truth를 고정하기 위한 메모다.

이번 스프린트에서는 `D3`에서 선택한 다음 질문을 실검증했다.

- `catalog record exists + local artifact missing`

## 검증한 시나리오

이번에는 same-node 관점에서 아래 상황을 재현했다.

1. producer node에서 fresh artifact 생성
2. catalog record는 그대로 유지
3. 같은 node의 hostPath artifact 디렉터리만 제거
4. 같은 node에서 `/artifacts/{id}` 재요청

artifact id:

- `edge-local-miss-20260408-same`

producer/consumer node:

- `lab-worker-0`

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

## 이번 스프린트에서 고정한 해석

- producer origin truth는 catalog 기준이다.
- current node local availability는 local metadata와 실제 hostPath 기준이다.
- same-node에서 local artifact가 사라져도 catalog truth는 유지될 수 있다.
- 하지만 그 경우 same-node 경로는 자동 성공이 아니라 self-loop failure로 드러난다.

즉 이 edge case는 “catalog truth가 남아 있는 것”과 “현재 node local copy가 실제로 존재하는 것”이 같은 의미가 아니라는 점을 분명히 보여 준다.

## 아직 남는 점

- 이번 스프린트는 same-node path만 먼저 확인했다.
- cross-node 모드에서 local artifact missing이 peer fetch recovery로 이어지는지는 다음 검증 후보다.
- `catalog record missing + local artifact exists` edge case는 아직 남아 있다.

## 결론 한 줄

`Sprint D5` 기준으로 same-node의 `catalog record exists + local artifact missing`는 **catalog truth는 유지되지만, 실제 local availability가 없으면 self-loop failure로 드러난다**는 사실로 정리된다.
