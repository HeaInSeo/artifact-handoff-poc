# POST_REPLICA_AWARE_BACKLOG_ORDERING

## 목적

이 문서는 `Sprint G2 - Post-Replica-Aware Backlog Ordering`의 판단을 고정하기 위한 메모다.

질문:

- replica-aware 첫 구현/검증 사이클과 `G1` gap review 이후,
- 다음 2~3개 구현/검증 질문의 순서를 어떻게 잡는 것이 현재 범위에 맞는가?

## 기준 문서

- [POST_REPLICA_AWARE_GAP_REVIEW.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/POST_REPLICA_AWARE_GAP_REVIEW.ko.md)
- [REPLICA_SOURCE_SELECTION_VALIDATION.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_VALIDATION.ko.md)
- [REPLICA_SOURCE_SELECTION_MINIMAL_CUT.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_MINIMAL_CUT.ko.md)

## 후보 질문

- actual fetch endpoint observability를 더 다룰 것인가
- producer-first ordering semantics를 더 명시적으로 고정할 것인가
- multi-replica policy를 바로 열 것인가
- catalog top-level failure reflection을 다시 열 것인가

## 우선순위 정리

### 1순위: H1 - Post-Replica-Aware Completion View Refresh

- replica-aware 첫 사이클이 한 차례 닫힌 지금, completion view와 남은 roadmap를 먼저 정리하는 편이 맞다.
- 현재까지 얻은 evidence와 남은 질문을 한 번 다시 정돈하는 역할이다.

### 2순위: H2 - Replica-Aware Observability Follow-Up

- 지금 가장 작은 기술적 후속 질문은 actual fetch endpoint observability다.
- 현재 metadata의 `producerAddress`는 origin producer를 유지하므로, 실제 fetch endpoint를 바로 설명하지 못한다.
- 다만 이것이 즉시 코드 변경 질문인지, note 수준 판단으로 멈출지부터 먼저 정리하는 것이 맞다.

### 3순위: H3 - Replica Ordering Semantics Note

- producer-first ordering을 current implementation truth로 둘지, 다음 policy 후보로 올릴지 note로 먼저 좁히는 것이 적절하다.
- multi-replica policy로 바로 가기 전에, single-replica ordering semantics를 먼저 고정하는 편이 더 작다.

## 지금 보류하는 질문

- multi-replica policy
- catalog top-level failure reflection
- retry / recovery
- scheduler/controller integration

이 항목들은 replica-aware 첫 사이클 직후에 다시 열기에는 여전히 크다.

## 이번 스프린트의 결론

- 다음 스프린트는 `H1 - Post-Replica-Aware Completion View Refresh`
- 그 다음은 `H2 - Replica-Aware Observability Follow-Up`
- 그 다음은 `H3 - Replica Ordering Semantics Note`

## 한 줄 verdict

`completion refresh first, observability second, ordering semantics third`
