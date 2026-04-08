# REPLICA_AWARE_DECISION_NOTE

## 목적

이 문서는 `Sprint F6 - Replica-Aware Decision Note`의 결론을 고정하기 위한 메모다.

질문:

- `Sprint F4`가 replica-ready state는 확인했지만 actual fetch source selection은 아직 producer-biased라고 보여 준 뒤,
- `Sprint F5`가 후속 순서를 `validation first, cut second`로 좁힌 상태에서,
- 다음 즉시 실행을 producer-bias validation으로 둘지, 아니면 바로 최소 source-selection cut로 갈지?

## 기준 문서

- [REPLICA_AWARE_FIRST_VALIDATION.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_FIRST_VALIDATION.ko.md)
- [REPLICA_AWARE_FOLLOW_UP_ORDERING.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_FOLLOW_UP_ORDERING.ko.md)
- [REPLICA_AWARE_EXECUTION_CUT.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_EXECUTION_CUT.ko.md)

## 현재까지 확인된 사실

- `replicaNodes`는 실제로 catalog에 기록된다.
- first replica의 local metadata도 `state=replicated`, `source=peer-fetch`로 남는다.
- 하지만 현재 `peer_fetch()`는 여전히 `producerAddress`만 직접 사용한다.

즉 현재 구현은:

- `replica-ready`: yes
- `replica-aware source selection`: no

## 선택지 비교

### 선택지 A. producer-bias validation 먼저

장점:

- 현재 limitation이 실제로 어떻게 드러나는지 evidence를 한 번 더 확보할 수 있다.
- 이후 source-selection cut의 의미를 더 좁고 명확하게 읽을 수 있다.
- 범위를 크게 넓히지 않는다.

단점:

- 실제 구현 변화는 한 스프린트 더 뒤로 밀린다.

### 선택지 B. 최소 source-selection cut로 바로 이동

장점:

- `replicaNodes`를 control input으로 끌어오는 실제 코드를 더 빨리 시작할 수 있다.

단점:

- 현재 producer-only bias가 어떤 상황에서 제한으로 드러나는지 설명하는 evidence가 아직 얇다.
- 구현 cut 해석이 더 쉽게 섞일 수 있다.

## 최종 판단

현재는 `선택지 A`가 맞다.

즉:

- 다음 즉시 실행은 **producer-bias validation**
- 그 다음에 **가장 작은 replica source-selection cut**

으로 가는 것이 맞다.

## 왜 이 판단이 맞는가

- 현재 catalog와 metadata에는 이미 replica 관련 정보가 존재한다.
- 부족한 것은 “source selection이 왜 아직 producer-only bias를 갖는가”에 대한 더 직접적인 실행 evidence다.
- 그 evidence를 먼저 확보하면, 다음 implementation cut를 더 작고 명확한 범위로 제한할 수 있다.

## 다음 즉시 스프린트

- `F7 - Producer-Bias Validation Kickoff`

최소 완료 기준:

- producer-only bias를 더 직접적으로 드러내는 scenario 1개 선택
- live validation 또는 그에 준하는 좁은 evidence 확보
- 결과를 `RESULTS` / `VALIDATION_HISTORY` / `SPRINT_PROGRESS`에 반영

## 한 줄 결론

다음 즉시 실행은 producer-bias validation을 먼저 두고, 최소 replica source-selection cut는 그 다음으로 미루는 것이 맞다.
