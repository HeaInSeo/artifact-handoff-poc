# failure-taxonomy-scope-check

## 1. 조사 질문

현재 `artifact-handoff-poc`의 failure taxonomy가 Sprint 1 범위를 넘어 과도하게 커지고 있는가, 아니면 아직 적절한 수준으로 유지되고 있는가?

## 2. 핵심 요약

현재 failure taxonomy는 **Sprint 1 범위 안에서 아직 적절한 수준으로 유지되고 있다.**

판정: `keep narrow`

현재 taxonomy는 다음 질문에 답하는 데 필요한 만큼만 유지하는 것이 맞다.

- failure가 control-plane lookup 단계인가
- peer fetch transport 단계인가
- producer-side rejection인가
- consumer-side verification failure인가
- local verification failure인가

즉 지금 단계에서는 “failure를 많이 나누는 것”보다 “현재 검증 질문에 필요한 축만 분명히 남기는 것”이 더 중요하다.

## 3. 지금 유지할 taxonomy

현재 Sprint 1 범위에서 유지할 핵심 축은 아래 정도다.

1. `catalog lookup failed`
2. `peer fetch exception`
3. `peer fetch http 409: digest mismatch`
4. `peer digest mismatch`
5. `local digest mismatch`

이 다섯 개는 현재까지의 실증과 문서 흐름에 직접 연결된다.

- `catalog lookup failed`
  - peer fetch가 시작되기 전 control-plane failure
- `peer fetch exception`
  - peer endpoint transport failure
- `peer fetch http 409: digest mismatch`
  - producer-side rejection
- `peer digest mismatch`
  - consumer-side verification failure
- `local digest mismatch`
  - same-node/local copy verification failure

## 4. 지금 계속 보류할 것

현재 단계에서 계속 보류하는 것이 맞는 항목은 아래다.

### A. global error code taxonomy

- 숫자 코드나 넓은 분류 체계를 지금 설계하지 않는다.

### B. `catalog lookup failed` 세분화

- 404 / 5xx / timeout family를 지금 taxonomy에 올리지 않는다.
- 이 판단은 [catalog-lookup-failure-split-note.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/catalog-lookup-failure-split-note.ko.md)에 따로 정리했다.

### C. catalog top-level failure state

- cluster-wide failure truth를 현재 taxonomy에 포함하지 않는다.
- 이 판단은 [catalog-failure-semantics-decision.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/catalog-failure-semantics-decision.ko.md)에 정리했다.

### D. retry / recovery semantics

- retriable vs non-retriable 구분을 지금 taxonomy에 넣지 않는다.

### E. replica-aware failure classes

- fetch source selection failure를 더 세부 클래스까지 확장하지 않는다.

## 5. 왜 지금 수준이 맞는가

### A. 실증과 문서가 아직 이 다섯 축에 맞춰 정리되어 있음

현재 RESULTS, VALIDATION_HISTORY, FAILURE_MATRIX는 모두 위 다섯 축으로 읽히도록 정리돼 있다.

즉 taxonomy를 더 키우면 실증 근거보다 분류 체계가 앞서가기 쉽다.

### B. 현재 저장소의 본질은 location-aware handoff validation

지금 프로젝트의 본질은 다음이다.

- 위치를 기록할 수 있는가
- 위치 기반 same-node reuse가 가능한가
- 안 되면 cross-node peer fetch가 가능한가

failure taxonomy는 이 질문을 보조해야지, 그 자체가 새로운 주제가 되어서는 안 된다.

### C. 문서 탐색 비용도 이미 충분히 관리되고 있음

C5, C7, C8을 거치며 failure docs navigation은 현재 수준이면 충분하다는 결론이 이미 나와 있다. taxonomy까지 계속 늘리면 문서군 전체가 다시 무거워질 수 있다.

## 6. 다시 taxonomy 확장을 검토할 조건

아래 조건 중 하나 이상이 생기면 taxonomy를 다시 키울 수 있다.

### A. 반복적으로 같은 failure class가 실험을 막을 때

- coarse-grained label만으로는 디버깅 비용이 너무 커질 때

### B. retry / recovery 정책을 실제로 도입할 때

- failure class가 실행 정책과 직접 연결될 때

### C. scheduler/controller 연동을 실제 평가할 때

- failure class가 placement decision과 직접 연결될 때

### D. catalog durability/authority 모델을 확장할 때

- catalog 쪽 state semantics가 더 중요해질 때

## 7. 현재 스프린트에 바로 연결되는 포인트

- taxonomy는 지금 수준에서 유지
- 새 failure class를 추가하지 않음
- 기존 note:
  - [peer-fetch-failure-paths.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.ko.md)
  - [catalog-failure-semantics-decision.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/catalog-failure-semantics-decision.ko.md)
  - [catalog-lookup-failure-split-note.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/catalog-lookup-failure-split-note.ko.md)
  를 그대로 유지

## 8. 결론

현재 failure taxonomy는 Sprint 1 범위를 넘어가지 않았다. 따라서 `Sprint C9` 기준 결론은 다음과 같다.

- taxonomy는 계속 좁게 유지한다.
- 새 분류를 추가하기보다, 이미 있는 분류를 안정적으로 해석하는 데 집중한다.
