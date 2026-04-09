# NEXT_IMPLEMENTATION_QUESTION_SELECTION

## 목적

이 문서는 `Sprint I3 - Next Implementation Question Selection`의 판단을 고정하기 위한 메모다.

질문:

- `I1`, `I2` 이후 다음 실제 implementation 질문을 무엇으로 잡아야 하는가?
- `multi-replica policy`와 `retry / recovery policy` 중 어느 쪽을 먼저 여는 것이 더 작은 다음 단계인가?

## 기준 문서

- [POST_H3_BACKLOG_RESET.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/POST_H3_BACKLOG_RESET.ko.md)
- [POST_H3_COMPLETION_VIEW_REFRESH.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/POST_H3_COMPLETION_VIEW_REFRESH.ko.md)
- [PROJECT_COMPLETION_VIEW.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PROJECT_COMPLETION_VIEW.ko.md)

## 후보 질문

### 후보 1. multi-replica policy

- 현재는 first replica 1개만 다뤘다.
- replica가 여러 개일 때 어떤 순서나 기준으로 source를 고를지 아직 비어 있다.

### 후보 2. retry / recovery policy

- producer failure와 replica fallback은 검증했다.
- 하지만 timeout/backoff/retry semantics는 아직 다루지 않았다.

## 선택 결과

- 다음 실제 implementation 질문은 `multi-replica policy`로 고정한다.

## 왜 이 질문을 먼저 고르는가

### 1. 지금까지의 replica-aware 흐름과 가장 직접 연결된다

- `replicaNodes`를 source candidate set에 넣었고
- single-replica fallback까지 live로 확인했다.

다음 가장 자연스러운 질문은 “replica가 여러 개면 어떻게 할 것인가”다.

### 2. retry / recovery보다 더 좁다

- retry / recovery는 timeout, backoff, retry count, state interaction까지 함께 연다.
- 반면 multi-replica policy는 current source-selection semantics를 한 단계만 더 넓히는 질문이다.

### 3. 현재 metadata model과도 직접 맞닿아 있다

- `replicaNodes`가 이미 catalog에 기록되고 있다.
- 즉 새로운 개념을 만들기보다 existing field를 더 실제 policy 질문으로 끌어오는 편이 맞다.

## 이번 스프린트의 결론

- 다음 execution cut는 `J1 - Post-I3 Execution Cut`
- 그 범위는 `multi-replica policy`를 여는 가장 작은 helper 또는 구현 cut가 된다.

## 한 줄 verdict

`the next real implementation question is multi-replica policy, not retry/recovery`
