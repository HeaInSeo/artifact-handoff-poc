# catalog-failure-semantics-decision

## 1. 조사 질문

현재 단계의 `artifact-handoff-poc`에서 failure 정보를 catalog top-level state에 반영해야 하는가, 아니면 local metadata 중심으로 유지하는 것이 맞는가?

## 2. 핵심 요약

현재 단계에서는 **catalog top-level failure reflection을 도입하지 않고 local metadata 중심으로 유지하는 것이 맞다.**

이 판단의 이유는 간단하다.

1. 현재 저장소의 핵심 질문은 global failure registry가 아니라 `location-aware handoff validation`이다.
2. 이미 실증된 failure는 consumer node local metadata에 `state=fetch-failed`, `lastError`, `source` 형태로 충분히 남는다.
3. catalog top-level failure state를 섣불리 넣으면 authority 규칙, state transition, cleanup semantics가 한 번에 커진다.

즉 현 단계에서는 failure를 cluster-wide truth로 승격시키는 것보다, node-local forensic trail을 유지하는 편이 현재 스프린트 범위와 더 잘 맞는다.

## 3. 현재 판단

판정: `defer`

현재는 아래처럼 본다.

- catalog top-level record
  - producer origin과 placement 판단의 authoritative source
- local metadata
  - current node에서 관찰된 local hit, replicated copy, verification result, fetch failure의 관찰값

따라서 현재 failure semantics는 아래 원칙을 따른다.

- same-node / cross-node handoff 판단:
  - catalog 기준
- failure forensic trail:
  - local metadata 기준

## 4. 왜 지금 catalog top-level failure state를 넣지 않는가

### A. 프로젝트 핵심 질문과 직접 연결되지 않음

현재 저장소가 먼저 검증하려는 것은 다음이다.

- artifact 위치를 기록할 수 있는가
- 그 위치로 same-node reuse를 유도할 수 있는가
- 아니면 cross-node peer fetch를 할 수 있는가

여기서 중요한 것은 producer origin과 current location을 아는 것이지, cluster 전체 failure registry를 먼저 완성하는 것이 아니다.

### B. local metadata만으로 이미 필요한 흔적이 남음

지금까지 실증한 failure는 local metadata에 아래처럼 남는다.

- `source=catalog-lookup`
- `source=peer-fetch`
- `source=local-verify`
- `state=fetch-failed`
- `lastError=<human-readable cause>`

현재 범위에서는 이것만으로도 “어느 node에서 어떤 단계가 실패했는가”를 추적하는 데 충분하다.

### C. catalog에 failure를 넣으면 authority 경계가 흐려짐

catalog top-level state에 `fetch-failed`류를 넣기 시작하면 곧바로 아래 질문이 열린다.

- 어떤 node의 실패를 top-level truth로 볼 것인가
- producer는 healthy인데 특정 consumer만 실패한 경우 top-level state를 실패로 바꿀 것인가
- transient transport failure와 durable artifact corruption을 같은 level로 둘 것인가
- failure가 해소되면 누가 state를 되돌릴 것인가

이 질문들은 현재 스프린트 범위를 넘어선다.

### D. state transition 비용이 커짐

현재 catalog top-level state는 사실상 producer origin registry로 좁게 쓰이고 있다.

- `produced`

여기에 failure-aware state를 넣으면 최소한 아래가 같이 따라온다.

- state transition 규칙
- multi-consumer concurrency 처리
- stale failure cleanup
- success after retry의 재정의

현재 단계에서는 이 비용이 얻는 이익보다 크다.

## 5. 지금 유지할 규칙

현재 단계의 운영 규칙은 다음처럼 고정한다.

1. catalog는 producer origin과 placement hint의 기준점이다.
2. local metadata는 node-local copy와 failure forensic trail의 기준점이다.
3. `fetch-failed`는 local metadata에만 남긴다.
4. 결과 문서와 failure matrix는 local metadata evidence를 기준으로 해석한다.

## 6. catalog 반영을 다시 검토할 조건

아래 조건 중 하나 이상이 생기면 catalog-level failure reflection을 다시 검토할 수 있다.

### A. 여러 consumer 관점 failure를 집계해야 할 때

- 특정 artifact에 대해 여러 node에서 반복적으로 실패하는지를 cluster-wide로 보고 싶을 때

### B. placement decision이 failure history를 직접 써야 할 때

- same-node reuse 후보나 peer fetch 후보를 고를 때 최근 failure history를 참고해야 할 때

### C. controller/scheduler 연동을 평가할 때

- catalog가 단순 registry가 아니라 placement control input으로 더 직접 쓰일 때

### D. retry / recovery policy를 도입할 때

- failure를 local note가 아니라 shared state로 다뤄야 할 필요가 생길 때

## 7. 차용할 것

- catalog authority와 local observation을 분리하는 관점
- global state 확장을 늦추고 현재 검증 질문에 맞는 최소 semantics로 멈추는 관점
- failure를 local forensic trail로 남기고, 결과 문서에서 evidence를 해석하는 관점

## 8. 차용하지 않을 것

- 지금 단계에서 catalog top-level state machine 확장
- global failure registry 설계
- retry / recovery policy를 이 문서에서 같이 설계
- multi-consumer conflict resolution 설계

## 9. 현재 스프린트에 바로 연결되는 포인트

- catalog failure semantics는 `defer`가 현재 결정이다.
- 구현은 그대로 두고 문서 기준선만 고정한다.
- 이후 `catalog lookup failed` 세분화나 controller 연동 검토는 이 결정 위에서 별도 스프린트로 다룬다.

## 10. 다음 스프린트 후보 포인트

- `TROUBLESHOOTING_NOTES.md` 영문 parity 보강
- README 또는 results/history에서 failure matrix 진입 링크 추가
- `catalog lookup failed` 404/5xx 세분화가 실제로 필요한지 판단 메모 작성
