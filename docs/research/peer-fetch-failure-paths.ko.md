# peer-fetch-failure-paths

## 1. 조사 질문

`artifact-handoff-poc`에서 peer fetch failure를 어떤 의미 단위로 구분해서 기록해야 하며, 현재 단계에서 무엇을 명확히 하고 무엇은 아직 보류해야 하는가?

## 2. 핵심 요약

현재 단계에서 중요한 것은 failure를 많이 만드는 것이 아니라, 이미 관찰된 failure가 어느 계층에서 발생했는지 헷갈리지 않게 구분하는 것이다.

대표 failure scenario를 한 장 표로 다시 보려면 [FAILURE_MATRIX.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/FAILURE_MATRIX.ko.md)를 같이 본다.

이번 스프린트까지의 실증 기준으로 보면 최소한 아래 네 가지는 분리해서 봐야 한다.

1. `catalog lookup failed`
2. `peer fetch exception`
3. `peer fetch http 409: digest mismatch`
4. `peer digest mismatch`

이 네 가지는 모두 "cross-node fetch 실패"처럼 보일 수 있지만, 실제 의미는 다르다.

- `catalog lookup failed`는 catalog 접근 또는 catalog record 조회 단계의 실패다.
- `peer fetch exception`은 peer endpoint 연결 또는 전송 단계의 실패다.
- `peer fetch http 409: digest mismatch`는 producer-side internal gate가 expected digest와 맞지 않는다고 먼저 거절한 경우다.
- `peer digest mismatch`는 consumer가 peer payload를 읽은 뒤 digest를 직접 계산해서 mismatch를 판단한 경우다.

현재 스프린트에서는 마지막 두 항목을 같은 것으로 뭉개지 않는 것이 중요하다.

## 3. 우리 프로젝트와 닮은 점

- Dragonfly류 시스템도 source/peer/scheduler 문제를 같은 "다운로드 실패"로만 보지 않고, 어느 hop에서 실패했는지 구분해야 운영과 디버깅이 가능하다.
- Kubernetes 기반 분산 데이터 경로도 control-plane lookup failure와 data-plane fetch failure를 분리해야 원인을 좁힐 수 있다.
- `artifact-handoff-poc`도 location-aware handoff 저장소라면 "artifact가 없었다"보다 "어느 레이어에서 왜 실패했는가"가 더 중요하다.

## 4. 우리 프로젝트와 다른 점

- 현재 저장소는 범용 분산 다운로드 시스템이 아니라, DAG artifact handoff를 검증하는 최소 PoC다.
- 그래서 retry policy, backoff, replica selection, global error code taxonomy까지 지금 당장 넣을 필요는 없다.
- 현재는 durable failure registry보다 node-local forensic trail을 먼저 확보하는 편이 맞다.

## 5. 차용할 것

- control-plane failure와 data-plane failure를 분리하는 관점
- transport exception과 integrity failure를 분리하는 관점
- producer-side rejection과 consumer-side verification failure를 구분하는 관점
- local metadata의 `lastError`를 사람이 읽을 수 있는 원인 문구로 유지하는 관점

## 6. 차용하지 않을 것

- 지금 단계에서 전역 error code 체계를 크게 설계하는 것
- retry / recovery policy를 failure semantics 문서에 섞어 넣는 것
- catalog top-level state machine을 한 번에 확장하는 것
- observability stack 전체를 이번 스프린트에서 설계하는 것

## 7. 현재 스프린트에 바로 연결되는 포인트

현재 기준 failure semantics는 아래처럼 정리하는 것이 맞다.

### A. catalog lookup failed

- 발생 지점: consumer가 catalog record를 가져오는 단계
- 의미: 아직 peer fetch를 시작하지도 못한 상태
- local metadata 기대값:
  - `source=catalog-lookup`
  - `state=fetch-failed`
  - `producerNode` / `producerAddress`가 비어 있을 수 있음
- 현재 단계에서 404/5xx 등으로 더 세분화할지에 대한 판단은 [catalog-lookup-failure-split-note.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/catalog-lookup-failure-split-note.ko.md)에 정리한다.

### B. peer fetch exception

- 발생 지점: consumer가 producer/peer endpoint로 접속하거나 읽는 단계
- 의미: peer fetch를 시도했지만 transport 예외가 났음
- 예시:
  - `Connection refused`
  - timeout
- local metadata 기대값:
  - `source=peer-fetch`
  - `state=fetch-failed`
  - `lastError=<transport exception>`

### C. peer fetch http 409: digest mismatch

- 발생 지점: producer-side `/internal/artifacts/...` endpoint
- 의미: producer가 expected digest와 local metadata digest가 다르다고 먼저 거절
- 현재 구현 의미:
  - consumer own-branch가 payload bytes를 읽기 전에 producer internal gate가 요청을 막음
- local metadata 기대값:
  - `source=peer-fetch`
  - `state=fetch-failed`
  - `lastError=peer fetch http 409: digest mismatch`

### D. peer digest mismatch

- 발생 지점: consumer-side `peer_fetch()` 내부
- 의미: consumer가 peer payload를 실제로 읽은 뒤 digest를 직접 계산해서 mismatch를 판단
- local metadata 기대값:
  - `source=peer-fetch`
  - `state=fetch-failed`
  - `lastError=peer digest mismatch`

현재 기준으로 C와 D는 다르다.

- C는 producer-side rejection이다.
- D는 consumer-side verification failure다.
- 둘 다 integrity 문제이지만, data path에서 실패를 감지한 위치가 다르다.

현재 문서와 결과를 읽을 때는 이 차이를 유지해야 한다.

### local digest mismatch와의 차이

- `local digest mismatch`는 peer path가 아니라 current node local copy 검증 실패다.
- 따라서 `source=local-verify`가 맞다.
- 이 failure는 same-node reuse나 second-hit local cache 해석과 더 직접적으로 연결된다.

### catalog 반영에 대한 현재 판단

현재 단계에서는 failure를 local metadata에만 남기는 것이 맞다.

이유:

- 현재 저장소의 핵심 질문은 "위치를 알고 handoff 결정을 할 수 있는가"이지, global failure registry를 완성하는 것이 아니다.
- local metadata만으로도 node-local forensic trail은 확보된다.
- catalog top-level failure state를 섣불리 추가하면 authority 규칙과 state transition을 더 크게 흔들 수 있다.

## 8. 다음 스프린트 후보 포인트

- failure taxonomy를 README가 아니라 별도 short note로 링크하는 방식 정리
- `catalog lookup failed` 안에서도 404와 5xx를 나눌지 검토
- peer-side 409 외 다른 producer-side HTTP errors를 어떻게 표준화할지 검토
- catalog 반영이 필요한 최소 failure subset이 무엇인지 별도 메모 작성

관련 대표 scenario 요약 표:

- [FAILURE_MATRIX.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/FAILURE_MATRIX.ko.md)
