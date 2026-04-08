# NEXT_VALIDATION_IMPLEMENTATION_QUESTION_SELECTION

## 목적

이 문서는 `Sprint F1 - Next Validation/Implementation Question Selection` 결과를 고정하기 위한 메모다.

질문:

- `E1~E5` policy/document cleanup을 닫은 뒤, 다음 실제 validation 또는 implementation 질문으로 무엇을 먼저 가져갈 것인가

## 이번 선택의 기준

이번 판단은 아래 문서를 기준으로 한다.

- [POST_E2_FREEZE_CHECK.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/POST_E2_FREEZE_CHECK.ko.md)
- [SPRINT_PROGRESS.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SPRINT_PROGRESS.ko.md)
- [CATALOG_FAILURE_REFLECTION_RECHECK.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/CATALOG_FAILURE_REFLECTION_RECHECK.ko.md)

현재 backlog 후보는 크게 아래였다.

1. catalog top-level failure reflection
2. replica-aware fetch policy
3. retry / recovery policy
4. scheduler/controller integration evaluation

## 이번 스프린트의 선택 결과

다음 실제 질문은 아래로 고정한다.

- **`replicaNodes`를 실제 fetch policy 입력으로 승격할지 검토하는 가장 작은 validation/implementation 질문**

더 짧게 쓰면:

- `replica-aware fetch policy`를 다음 질문으로 선택

## 왜 이 질문이 다음으로 맞는가

### 1. 현재 evidence와 가장 직접적으로 이어진다

지금까지 이미 아래는 확인됐다.

- cross-node peer fetch가 성공하면 catalog에 `replicaNodes`가 기록된다
- 하지만 현재 fetch path는 여전히 주로 `producerAddress` 기준이다

즉 `replicaNodes`는 존재하지만 아직 control-layer 입력으로는 약하다.

이건 지금까지 쌓인 validation truth와 가장 자연스럽게 이어지는 다음 질문이다.

### 2. `catalog top-level failure reflection`보다 작다

`catalog top-level failure reflection`은 이미 여러 번 defer가 맞다고 고정됐다.

그걸 다시 구현 질문으로 올리면 바로 아래가 다시 열린다.

- top-level truth ownership
- transient/durable failure 구분
- multi-consumer aggregate state

현재 범위에서는 이게 너무 크다.

반면 replica-aware fetch는:

- 기존 `replicaNodes` 기록을 활용할 수 있는가
- producer만 보지 않고 replica를 fallback source로 볼 수 있는가

라는 더 좁은 control-layer 질문으로 잡을 수 있다.

### 3. retry/recovery나 scheduler/controller보다 훨씬 작다

retry/recovery는 state machine과 policy를 더 요구한다.
scheduler/controller integration은 현재 PoC 범위를 바로 넘는다.

따라서 현재 단계의 다음 실행 질문으로는 replica-aware fetch가 가장 작다.

## 이번 스프린트에서 고정한 다음 최소 질문

다음 질문은 아래처럼 더 좁게 본다.

- 현재 `replicaNodes`를 활용해
- producer unavailable 또는 producer-only bias가 있는 상황에서
- 가장 작은 replica-aware fetch 실험을 설계할 수 있는가

즉 바로 “범용 replica-aware distribution”으로 가지 않고,
**현재 catalog field가 실제 fetch source selection에 의미를 가질 수 있는지**부터 본다.

## 이번 스프린트에서 아직 하지 않는 것

아래는 계속 보류한다.

- catalog top-level failure reflection 구현
- retry / recovery policy 구현
- scheduler/controller integration
- cleanup/GC

## 다음 두 스프린트와의 연결

이번 선택 뒤 다음 두 단계는 아래처럼 둔다.

- `F2 - Next Backlog Ordering Note`
  - replica-aware fetch를 1순위로 두고 나머지 backlog 순서를 다시 정리
- `F3 - Next Execution Cut`
  - replica-aware fetch 실험을 위한 가장 작은 helper 또는 구현 cut 정의

## 결론 한 줄

`Sprint F1`의 결론은 **다음 실제 validation/implementation 질문은 `replicaNodes`를 fetch source selection에 의미 있게 연결할 수 있는지 검토하는 가장 작은 replica-aware fetch 질문으로 둔다**는 것이다.
