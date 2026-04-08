# REPLICA_AWARE_FOLLOW_UP_ORDERING

## 목적

이 문서는 `Sprint F5 - Replica-Aware Follow-Up Ordering`의 판단을 고정하기 위한 메모다.

질문:

- `Sprint F4`가 replica-ready state는 확인했지만 actual fetch source selection은 아직 producer-biased라고 보여 준 뒤,
- 다음 두 개의 follow-up 질문을 어떤 순서로 둘 것인가?

## 기준 문서

- [REPLICA_AWARE_FIRST_VALIDATION.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_FIRST_VALIDATION.ko.md)
- [NEXT_BACKLOG_ORDERING_NOTE.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/NEXT_BACKLOG_ORDERING_NOTE.ko.md)

## 현재까지 확인된 점

- first replica는 실제로 생성된다.
- catalog의 `replicaNodes`도 실제로 채워진다.
- replica node local metadata도 `state=replicated`, `source=peer-fetch`로 남는다.
- 하지만 actual fetch source selection은 아직 `producerAddress`만 사용한다.

즉 현재 상태는:

- `replica-ready state`: yes
- `replica-aware source selection`: no

## follow-up ordering 판단

현재 다음 순서는 아래처럼 두는 것이 맞다.

1. producer-only bias를 더 직접적으로 드러내는 validation을 한 번 더 둔다.
2. 그 다음에 `replicaNodes`를 actual source selection에 연결하는 가장 작은 implementation cut로 간다.

## 왜 이 순서가 맞는가

- `Sprint F4`는 준비 상태와 현재 한계를 이미 보여 줬다.
- 다음 한 번의 validation을 더 두면, 실제로 무엇이 아직 빠져 있는지 더 직접적인 evidence를 확보할 수 있다.
- 그 뒤 implementation cut로 가면, cut의 의미를 더 좁고 명확하게 읽을 수 있다.

반대로 바로 implementation cut로 가면:

- producer-only bias가 현재 어떤 상황에서 실제 제한으로 드러나는지
- `replicaNodes`가 왜 단순 기록을 넘어 control input이 되어야 하는지

를 설명하는 evidence가 상대적으로 약해질 수 있다.

## 고정한 후속 순서

- `F6 - Replica-Aware Decision Note`
  - producer-bias validation을 먼저 할지, 바로 최소 source-selection cut로 갈지를 최종 결정
- 그 다음 실제 실행
  - producer-only bias validation
  - 또는 가장 작은 replica source-selection cut

현재 판단은 `validation first, cut second` 쪽이다.

## 한 줄 결론

다음 후속은 먼저 producer-only bias를 더 직접적으로 검증하고, 그 다음에 가장 작은 source-selection cut로 가는 순서가 맞다.
