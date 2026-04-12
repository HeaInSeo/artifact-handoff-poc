# U6 - Same-Node Required vs Preferred Validation

## 1. 스프린트 질문

`U3`에서 child Job에는 실제 `nodeSelector`가 들어갔고,
`U5`에서는 current path가 아직 `same-node required`만 구현한다는 점을 고정했다.

이번 스프린트 질문은 하나다.

- 현재 explicit same-node placement를 `required locality`로 읽는 것이 맞는가, 아니면 이미 `preferred locality`로 읽어도 되는가?

이번 문서는 새 실험을 늘리지 않고,
이미 확보한 원격 실검증 결과와 current code path를 기준으로 validation 기준을 고정한다.

## 2. 이번 판단의 실제 근거

근거 1. 원격 `U3` 실행 결과

- child Job `b1`, `b2`, `b3`, `c`에는 실제 `nodeSelector={"kubernetes.io/hostname":"lab-worker-1"}`가 들어갔다.
- parent `a`에는 같은 값이 없었다.
- child Job annotation에는 `placement-source=producer-pod-node`가 남았다.

즉 child 쪽 placement는 “우연히 같은 노드에 갔다”가 아니라,
submit 시점에 concrete selector가 들어간 결과다.

근거 2. current code path

현재 `poc` mutator는 아래처럼 동작한다.

- parent pod node 조회
- `spec.Placement.NodeSelector["kubernetes.io/hostname"] = producerNode`

현재 `spawner`는 이 값을 그대로 Job Pod spec의 `nodeSelector`로 번역한다.

이 구조에서 중요한 점은 아래다.

- `nodeSelector`는 hint가 아니다.
- scheduler가 만족해야 하는 required constraint다.
- current path에는 preferred affinity나 soft locality path가 없다.

근거 3. current path에 아직 없는 것

현재 구조에는 아래가 없다.

- preferred node affinity
- same-node miss를 허용한 뒤 다른 노드에서 계속 실행하는 soft path
- required locality 실패 후 자동 downgrade
- fallback resolution과 retry policy

즉 코드와 실행 결과를 같이 읽으면,
현재 구현 truth를 `preferred`라고 부를 근거가 없다.

## 3. 왜 지금은 `required`로 읽어야 하는가

이번 스프린트에서 고정하는 첫 판단은 이것이다.

- 현재 explicit same-node placement는 `preferred locality`가 아니라 `required locality`다.

이유는 단순하다.

1. 실제 Job spec에 들어간 값이 `nodeSelector`다.
2. `nodeSelector`는 만족되지 않으면 해당 노드 밖으로 넘어가는 soft rule이 아니다.
3. current runtime에는 그 제약을 낮추는 second submit path가 없다.

즉 현재 semantics는:

- “가능하면 same-node”
가 아니라
- “child는 우선 producer node에 붙어야 한다”

로 읽는 것이 맞다.

## 4. 왜 지금 바로 `preferred`로 낮춰 읽으면 안 되는가

이번 스프린트에서 버려야 하는 오해는 이것이다.

- 프로젝트 목표가 eventually same-node preferred / remote fallback이라고 해서,
  현재 구현도 이미 preferred라고 읽어도 되는가

아니다.

그렇게 읽으면 세 가지가 섞인다.

1. 목표 semantics
- 앞으로 가고 싶은 방향

2. current implementation truth
- 지금 실제 코드가 하는 일

3. future fallback design
- 나중에 붙일 downgrade / retry / remote resolution

현재 우리가 문서에서 고정해야 하는 것은 2번이다.
2번 기준으로는 아직 `preferred`라고 부르면 안 된다.

## 5. 그렇다고 `required`가 최종 policy라는 뜻은 아니다

이번 스프린트의 두 번째 판단은 이것이다.

- current path를 `required locality`로 읽어야 하지만, 그것이 곧 최종 product policy commitment는 아니다.

즉 아래 두 문장은 다르다.

- 현재 구현은 required same-node selector를 쓴다.
- 제품 정책은 required same-node여야 한다.

첫 번째는 이번에 고정할 수 있다.
두 번째는 아직 고정하면 안 된다.

왜냐하면 아직 아래가 검증되지 않았기 때문이다.

- required selector가 실제 운영 failure를 얼마나 크게 늘리는가
- preferred locality + explicit fallback이 더 맞는가
- artifact miss / node unavailable 상황에서 어느 쪽이 더 product-owned semantics와 맞는가

## 6. 이번 스프린트에서 고정하는 validation 기준

이번에 고정하는 최소 기준은 아래다.

### A. `required`로 읽는 기준

아래가 모두 맞으면 current path는 `required locality`다.

- concrete `nodeSelector`가 생성됨
- 그 selector를 낮추는 alternate path가 없음
- 실패 시 automatic remote continuation이 없음

현재 path는 이 조건을 모두 만족한다.

### B. `preferred`로 읽기 위한 최소 기준

아래 중 적어도 하나는 추가로 있어야 `preferred locality`라고 읽을 수 있다.

- preferred affinity 기반 submit
- same-node miss 후 remote-capable resubmit
- same-node constraint downgrade가 runtime에 명시됨
- child가 same-node miss에도 semantic failure 없이 계속 진행됨

현재 path에는 이 조건이 없다.

## 7. 이번 스프린트에서 고정되는 판단

이번 스프린트로 아래를 고정한다.

1. current implementation truth는 `same-node required`
2. 이 판단은 원격 실검증 결과와 실제 `nodeSelector` 경로에 근거한다.
3. 하지만 이것은 final policy commitment가 아니라 current validation reading이다.
4. 따라서 다음 검증은 preferred locality로 내려갈 조건과 fallback trigger를 따로 확인해야 한다.

## 8. 다음 직접 후속

다음은 `U7 - Fallback Trigger Signal Validation`가 맞다.

이제 필요한 것은 “required를 preferred로 낮출 수 있는가”를 추상적으로 말하는 것이 아니라,
same-node required path가 실제로 깨졌다고 읽을 수 있는 observable signal을 fallback trigger로 쓸 수 있는지 검증 질문으로 고정하는 것이다.
