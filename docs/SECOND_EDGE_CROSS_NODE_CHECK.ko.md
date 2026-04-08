# SECOND_EDGE_CROSS_NODE_CHECK

## 목적

이 문서는 `Sprint D12 - Second Edge Cross-Node Check`에서 확인한 cross-node 관점의 두 번째 edge case 동작을 고정한다.

질문:

- `catalog record missing + local artifact exists` 상황에서 non-producer node는 어떤 결과를 내는가

## 실검증 시나리오

- artifact id: `edge-catalog-miss-20260408-cross`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-1`

실행 흐름:

1. worker0에 fresh artifact 생성
2. catalog에서 `producerNode`를 한 번 확인
3. `artifact-catalog`를 재시작해 emptyDir-backed catalog state를 비움
4. worker1에서 `/artifacts/{id}` 호출

## 실제로 관찰된 것

consumer log:

```text
status=404
{
  "error": "catalog lookup failed"
}
```

catalog lookup:

```text
HTTP/1.0 404 Not Found
```

consumer local metadata snapshot:

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

## 해석

same-node와 달리 cross-node consumer는 local artifact copy를 갖고 있지 않다.

따라서 현재 구현에서는:

- local hit가 먼저 성립하지 않고
- catalog truth도 비어 있기 때문에
- 공개 `/artifacts/...` 경로는 `catalog lookup failed`로 종료된다

즉 같은 edge case family라도 node 위치에 따라 결과가 갈린다.

- same-node: local-first reuse
- cross-node: catalog-lookup failure

## 이 결과가 의미하는 것

이 결과는 `catalog absence`의 의미가 node 위치에 따라 달라진다는 점을 더 분명히 한다.

- producer/local node에서는 surviving local copy가 catalog absence를 가릴 수 있다
- non-producer node에서는 catalog truth가 없으면 peer path로 들어갈 정보 자체가 부족하다

## 결론 한 줄

`Sprint D12` 기준으로 `catalog record missing + local artifact exists`는 **cross-node에서는 `catalog lookup failed`와 `fetch-failed` metadata로 드러난다**.
