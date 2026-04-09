# POST_H3_BACKLOG_RESET

## 목적

이 문서는 `Sprint I1 - Post-H3 Backlog Reset`의 판단을 고정하기 위한 메모다.

질문:

- `H2`, `H3`까지 정리한 뒤,
- 지금 남은 실제 implementation backlog를 가장 작은 질문 단위로 다시 어떻게 묶어야 하는가?

## 기준 문서

- [REPLICA_AWARE_OBSERVABILITY_FOLLOW_UP.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_OBSERVABILITY_FOLLOW_UP.ko.md)
- [REPLICA_ORDERING_SEMANTICS_NOTE.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_ORDERING_SEMANTICS_NOTE.ko.md)
- [PROJECT_COMPLETION_VIEW.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PROJECT_COMPLETION_VIEW.ko.md)

## 현재 닫힌 것

- replica fallback after producer failure
- actual fetch endpoint observability defer 판단
- producer-first ordering을 current implementation truth로 읽는 판단

즉 replica-aware 첫 번째 validation cycle은 현재 범위에서 한 차례 닫힌 것으로 본다.

## 지금 다시 묶는 backlog

### 1. multi-replica policy

- 현재는 first replica 1개만 다뤘다.
- 여러 replica가 있을 때 선택 기준은 아직 비어 있다.

### 2. retry / recovery policy

- producer failure 한 번과 replica fallback 한 번은 검증했다.
- 그러나 timeout/backoff/retry는 아직 다루지 않았다.

### 3. catalog top-level failure reflection

- 여전히 defer 상태다.
- 지금 다시 여는 것보다, 실제 운영 압력이 생길 때 재검토하는 편이 맞다.

### 4. scheduler/controller integration

- 여전히 현재 validation repo 범위보다 크다.

## reset 결과

- 지금 바로 다음 실제 implementation backlog는 `multi-replica policy`로 본다.
- `retry / recovery policy`는 그 다음이다.
- `catalog top-level failure reflection`은 계속 defer 유지다.

## 이번 스프린트의 결론

- 다음 정리 스프린트는 `I2 - Post-H3 Completion View Refresh`
- 그 다음 실제 선택 스프린트는 `I3 - Next Implementation Question Selection`
- `I3`에서는 `multi-replica policy`와 `retry/recovery` 중 어떤 질문을 먼저 implementation 대상으로 잡을지 다시 좁힌다.

## 한 줄 verdict

`after the first replica-aware cycle, the next real implementation backlog resets to multi-replica policy first, retry/recovery second`
