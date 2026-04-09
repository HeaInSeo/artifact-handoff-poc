# REPLICA_AWARE_OBSERVABILITY_FOLLOW_UP

## 목적

이 문서는 `Sprint H2 - Replica-Aware Observability Follow-Up`의 판단을 고정하기 위한 메모다.

질문:

- replica fallback이 실제로 동작한다는 evidence까지 확보된 현재,
- actual fetch endpoint observability를 지금 metadata model에 더 넣어야 하는가?

## 기준 문서

- [REPLICA_SOURCE_SELECTION_VALIDATION.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_VALIDATION.ko.md)
- [POST_REPLICA_AWARE_GAP_REVIEW.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/POST_REPLICA_AWARE_GAP_REVIEW.ko.md)
- [POST_REPLICA_AWARE_COMPLETION_VIEW_REFRESH.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/POST_REPLICA_AWARE_COMPLETION_VIEW_REFRESH.ko.md)

## 현재 관찰 가능한 사실

- third-node consumer는 broken producer 이후 replica fallback으로 성공할 수 있다.
- local metadata의 `producerAddress`는 여전히 origin producer 기준으로 유지된다.
- 따라서 local metadata만 보면 “producer origin”은 알 수 있지만, “실제 fetch endpoint”는 바로 읽을 수 없다.

## 판단

- 현재 단계에서는 actual fetch endpoint observability를 metadata model 확장으로 바로 가져가지 않는다.
- 즉 이 질문은 **defer**가 맞다.

## 왜 defer가 맞는가

### 1. 현재 스프린트 질문은 이미 답을 얻었다

- `replicaNodes`가 actual source-selection path에 들어갔는가?
- broken producer 이후 replica fallback이 실제로 일어나는가?

이 질문들은 이미 live evidence로 닫혔다.

### 2. fetch endpoint observability는 다음 단계의 refinement에 가깝다

- 새 필드가 필요한지
- local metadata에 넣을지
- 결과 문서 수준으로 충분한지
- catalog에도 반영할지

같은 추가 질문을 한 번에 연다.

### 3. 현재 evidence 해석에는 기존 문서로도 충분하다

- 결과 문서
- validation history
- replica-aware validation note

를 같이 읽으면, actual fetch endpoint가 replica였다는 사실은 이미 설명 가능하다.

## 현재 고정하는 규칙

- `producerAddress`는 origin producer 의미를 유지한다.
- actual fetch endpoint는 현재 metadata 필드로 승격하지 않는다.
- 실제 fetch endpoint가 중요해지는 시점은:
  - multi-replica policy
  - retry/recovery
  - 더 정교한 source-selection observability
  가 열릴 때 다시 검토한다.

## 한 줄 결론

`actual fetch endpoint observability is useful, but it is still a refinement topic and remains deferred for now`
