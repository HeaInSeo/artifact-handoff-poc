# SECOND_EDGE_CASE_TRUTH_TIGHTENING

## 목적

이 문서는 `Sprint D10 - Second Edge Case Truth Tightening`에서 확인한 두 번째 edge case의 실제 동작을 고정한다.

선택된 질문:

- `catalog record missing + local artifact exists`

## 실검증 시나리오

- artifact id: `edge-catalog-miss-20260408-v2`
- producer node: `lab-worker-0`
- consumer node: `lab-worker-0`

실행 흐름:

1. worker0에 fresh artifact 생성
2. catalog에서 `producerNode`를 한 번 확인
3. `artifact-catalog`를 재시작해 emptyDir-backed catalog state를 비움
4. local artifact copy는 그대로 둔 채 same-node에서 `/artifacts/{id}` GET 수행

## 실제로 관찰된 것

consumer log:

```text
status=200
source=local
artifact-handoff sprint1 sample payload
```

catalog lookup:

```text
HTTP/1.0 404 Not Found
```

local metadata snapshot:

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

## 해석

현재 구현에서는 same-node 공개 `/artifacts/...` 경로가 local hit를 catalog lookup보다 먼저 확인한다.

따라서:

- catalog truth가 사라져도
- same-node local copy와 local metadata가 유효하면
- 요청은 `source=local`로 그대로 성공한다

즉 이 edge case는 현재 단계에서는 lookup failure가 아니라 **local-first reuse가 catalog absence를 가리는 동작**으로 드러난다.

## 이 결과가 의미하는 것

이 결과는 `catalog`와 `local metadata`의 authority 경계를 더 선명하게 보여 준다.

- `catalog`는 placement와 peer-fetch 판단의 진입점이다
- 하지만 same-node local hit 경로에서는 catalog가 필수 gate가 아니다
- 결과적으로 local artifact가 살아 있으면 catalog absence가 즉시 user-visible failure가 되지 않을 수 있다

## 아직 남는 점

- 이번 검증은 same-node 경로만 확인했다.
- cross-node에서 `catalog record missing + local artifact exists`가 어떤 의미를 가지는지는 아직 열려 있다.
- orphan/local-leftover를 현재 설계에서 허용된 reuse로 볼지, 기술적 부산물로만 볼지는 후속 판단이 필요하다.

## 결론 한 줄

`Sprint D10` 기준으로 `catalog record missing + local artifact exists`는 **same-node에서 `source=local` 성공으로 드러나며, catalog absence가 local hit보다 앞서지 않는다**.
