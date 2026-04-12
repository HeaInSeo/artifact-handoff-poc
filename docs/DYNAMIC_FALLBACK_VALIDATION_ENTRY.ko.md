# U5 - Dynamic Fallback Validation Entry

## 1. 스프린트 질문

`U3`에서 원격 멀티패스 K8s 랩 실검증으로 아래 사실은 이미 고정됐다.

- child Job은 parent 결과를 읽어 explicit `nodeSelector`를 받는다.
- 그 mutation은 실제 Job spec에 들어간다.
- 하지만 그 경로는 `producer-pod-node -> required same-node`라는 가장 좁은 형태다.

이번 스프린트 질문은 하나다.

- explicit placement mutation 이후, dynamic fallback은 정확히 무엇을 검증 질문으로 잡아야 하는가?

이번 문서는 새 실험을 넓히지 않고, 이미 확보한 실제 실행 결과와 현재 코드 경로를 기준으로 다음 validation question을 고정한다.

## 2. 이번 entry의 근거가 되는 실제 관찰

근거 1. `U3` 원격 실행 결과

- run: `dynplace-20260412-04`
- `a` Job의 `nodeSelector`: 빈 값
- `b1`, `b2`, `b3`, `c` Job의 `nodeSelector`: 모두 `{"kubernetes.io/hostname":"lab-worker-1"}`
- child Job annotation:
  - `poc.seoy.io/placement-source=producer-pod-node`
  - `poc.seoy.io/producer-node=lab-worker-1`

이 결과는 current path가 “same-node를 시도한다” 수준이 아니라,
“same-node를 required selector로 강제한다”는 뜻이다.

근거 2. 현재 코드 경로

`poc`의 current mutator는 parent pod node를 읽고 아래 형태로 child spec을 바꾼다.

- `spec.Placement.NodeSelector["kubernetes.io/hostname"] = producerNode`

그리고 `spawner`는 그 값을 그대로 Job Pod spec의 `nodeSelector`로 번역한다.

즉 현재 구조에는 아래가 아직 없다.

- preferred placement
- same-node 실패 감지 후 retry
- same-node 실패 후 remote-ok path로 spec 재해석
- child 단위 fallback state 기록

## 3. 이번 스프린트에서 버리는 오해

이번 entry에서 먼저 버려야 하는 오해는 두 가지다.

### A. 지금 이미 fallback이 있는가

아니다.

현재 구현은 child 제출 전에 producer node를 읽고,
그 값을 required `nodeSelector`로 바로 넣는다.
이 경로에는 “안 되면 다른 노드로 다시 간다”는 단계가 없다.

### B. same-node가 보였으니 fallback도 가까운 것 아닌가

아니다.

same-node success는 fallback semantics를 설명하지 않는다.
fallback 질문은 성공 경로가 아니라 실패 전환 조건을 정의해야 닫힌다.

## 4. 이번 스프린트에서 고정하는 최소 fallback 질문

이번에 고정하는 다음 직접 validation question은 아래다.

- parent 결과로 child에 same-node placement를 먼저 주입했을 때,
  그 placement가 불가능하거나 유지할 가치가 없다고 판단되는 순간을 runtime이 어떻게 감지하고,
  그 다음 child를 어떤 remote-capable 형태로 다시 제출할 것인가?

이 질문은 세 부분으로 쪼개 읽어야 한다.

1. trigger
- 어떤 상태를 same-node failure로 볼 것인가
- 예: unschedulable, node unavailable, locality mismatch, artifact missing

2. transition
- 실패를 감지한 뒤 child를 같은 Job의 재시도로 볼 것인가
- 아니면 새 submit cycle로 볼 것인가

3. target semantics
- fallback은 “아무 노드나 허용”인가
- 아니면 recorded replica / remote-ok policy를 읽는 별도 placement resolution인가

## 5. 이번 entry에서 고정하는 범위

이번 entry의 직접 범위는 아래까지다.

- fallback question을 same-node success 질문과 분리
- current implementation이 required `nodeSelector` 경로뿐이라는 점을 고정
- 다음 validation에서 확인해야 할 trigger / transition / target semantics를 좁게 정의

이번 entry에서 다루지 않는 범위는 아래다.

- 실제 fallback 구현
- retry/backoff 정책
- scheduler/controller 일반화
- replica among replica ordering

## 6. 다음 validation이 답해야 하는 최소 항목

다음 직접 validation은 최소한 아래를 답해야 한다.

1. same-node required path가 깨졌을 때 observable signal이 무엇인가
2. 그 signal을 child-level fallback trigger로 읽을 수 있는가
3. fallback 후 Job spec은 required selector를 제거하는가, preferred로 낮추는가, 다른 remote target으로 바꾸는가
4. 그 결과 artifact handoff semantics가 same-node preferred / remote fallback으로 읽힐 수 있는가

즉 다음 검증은 “same-node가 되느냐”가 아니라,
“same-node가 안 될 때 runtime이 어떤 구조로 remote path로 넘어가느냐”를 보는 검증이어야 한다.

## 7. 이번 스프린트에서 고정되는 판단

이번 스프린트로 아래 판단은 고정한다.

1. current path는 dynamic placement까지는 들어왔지만 dynamic fallback은 아직 없다.
2. 현재의 explicit `nodeSelector`는 preferred locality가 아니라 required locality다.
3. 따라서 다음 직접 validation은 fallback trigger와 fallback resubmit semantics를 여는 쪽이어야 한다.

## 8. 다음 직접 후속

다음은 `U6 - Same-Node Required vs Preferred Validation`가 맞다.

먼저 required selector를 그대로 유지할지,
preferred placement로 낮춘 뒤 다른 fallback 메커니즘을 둘지 판단 기준을 고정해야 한다.
그 다음 단계에서야 실제 remote fallback validation을 더 정확하게 설계할 수 있다.
