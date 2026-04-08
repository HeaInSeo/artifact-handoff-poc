# NEXT_BACKLOG_ORDERING_NOTE

## 목적

이 문서는 `Sprint F2 - Next Backlog Ordering Note` 결과를 고정하기 위한 메모다.

질문:

- `F1`에서 `replica-aware fetch`를 다음 실제 질문으로 선택한 뒤,
- 남아 있는 구현 backlog를 어떤 순서로 보는 것이 맞는가

## 기준 문서

- [NEXT_VALIDATION_IMPLEMENTATION_QUESTION_SELECTION.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/NEXT_VALIDATION_IMPLEMENTATION_QUESTION_SELECTION.ko.md)
- [SPRINT_PROGRESS.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SPRINT_PROGRESS.ko.md)
- [CATALOG_FAILURE_REFLECTION_RECHECK.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/CATALOG_FAILURE_REFLECTION_RECHECK.ko.md)

## 이번 스프린트의 backlog ordering 결과

현재 기준 우선순위는 아래로 고정한다.

1. `replica-aware fetch policy`
2. `catalog top-level failure reflection`
3. `retry / recovery policy`
4. `scheduler/controller integration evaluation`

## 왜 이 순서가 맞는가

### 1. `replica-aware fetch policy`가 1순위인 이유

이 항목은 현재 evidence와 가장 직접적으로 연결된다.

- `replicaNodes`는 이미 catalog에 기록된다
- 하지만 fetch source selection에는 아직 거의 쓰이지 않는다

즉 현재 field가 존재하는데 control-layer input으로는 약한 상태다.
이걸 가장 작은 구현/검증 질문으로 올리는 것이 가장 자연스럽다.

### 2. `catalog top-level failure reflection`이 2순위인 이유

이 항목은 중요하지만, 지금 당장 다시 열기에는 범위가 크다.

다시 열면 바로 아래가 같이 열린다.

- top-level truth ownership
- transient / durable failure semantics
- multi-consumer aggregate state

따라서 중요도는 있지만, 다음 즉시 실행 질문으로 두기에는 크다.

### 3. `retry / recovery policy`가 3순위인 이유

이 항목은 state machine과 policy를 더 요구한다.
현재는 fetch source selection 자체가 아직 단순하므로,
replica-aware fetch보다 먼저 갈 이유가 약하다.

### 4. `scheduler/controller integration evaluation`이 4순위인 이유

이건 현재 PoC 범위를 가장 빨리 넘어가는 항목이다.
현재는 script-assisted validation 단계이므로,
지금 당장 여는 것은 과하다.

## 이번 스프린트에서 고정한 다음 3단계 흐름

다음 흐름은 아래로 둔다.

1. `F3 - Next Execution Cut`
   - replica-aware fetch 실험을 시작하는 최소 helper 또는 구현 cut 추가
2. `F4 - Replica-Aware Fetch First Validation`
   - 가장 작은 replica-aware fetch 가설을 실제로 검증
3. 그 다음에야
   - `catalog top-level failure reflection` 재검토 여부를 다시 판단

## 이번 스프린트에서 아직 하지 않는 것

- replica-aware fetch 구현 자체
- retry / recovery 구현
- scheduler/controller integration 설계

이번 스프린트는 우선순위 정렬만 고정한다.

## 결론 한 줄

`Sprint F2`의 결론은 **다음 구현 backlog는 `replica-aware fetch policy`를 1순위로 두고, 그 다음은 `catalog top-level failure reflection`, 그 다음은 `retry / recovery`, 마지막은 `scheduler/controller integration`으로 본다**는 것이다.
