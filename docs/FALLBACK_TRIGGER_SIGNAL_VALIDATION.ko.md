# U7 - Fallback Trigger Signal Validation

## 1. 스프린트 질문

`U6`에서 current implementation truth는 `same-node required`라고 고정했다.
이제 다음 질문은 required path가 실제로 깨졌다고 무엇을 보고 판단할 것인가다.

이번 스프린트 질문은 하나다.

- same-node required path의 실패를 fallback trigger로 읽기 위한 observable signal은 무엇인가?

이번 문서는 새 구현을 넣지 않고,
현재 코드와 이미 정리된 observable model을 기준으로 다음 validation 기준을 고정한다.

## 2. 먼저 고정해야 하는 전제

현재 dynamic placement는 API 레벨에서 일어난다.

실제 경로:

1. `SpawnerNode.RunE()`에서 child `RunSpec`을 submit 직전에 mutate
2. `spec.Placement.NodeSelector["kubernetes.io/hostname"] = producerNode`
3. `DriverK8s.buildJob()`가 이를 Job Pod spec의 `nodeSelector`로 번역
4. `DriverK8s.Start()`가 Kubernetes `Jobs.Create()` API로 제출

즉 same-node requirement 자체가 API object에 들어간다.
그러므로 fallback trigger도 같은 수준의 observable, 즉 Kubernetes API 상태에서 읽는 것이 맞다.

## 3. 현재 코드가 보여 주는 observable 경로

현재 `spawner`와 `poc`에는 이미 관찰 경로가 둘로 나뉘어 있다.

### A. Job completion path

- `DriverK8s.Wait()`
- 관찰 대상: `JobComplete`, `JobFailed`

이 경로는 terminal state만 본다.
즉 너무 늦다.
fallback trigger를 여기서 읽으면 “same-node scheduling이 안 됐다”와 “container가 실행 후 실패했다”가 섞인다.

### B. pre-terminal observation path

- `K8sObserver.ObserveWorkload()`
- `K8sObserver.ObservePod()`

그리고 `poc/pkg/observe/pipeline_status.go`는 이를 아래 두 stop cause로 이미 분리한다.

- `kueue_pending`
- `scheduler_unschedulable`

이 분리는 이번 질문과 직접 연결된다.

## 4. 이번 스프린트에서 버리는 오해

### A. fallback trigger는 JobFailed면 충분한가

아니다.

`JobFailed`는 너무 늦고 너무 넓다.
이 신호는:

- nodeSelector mismatch
- 이미지 pull 실패
- command 실패
- artifact 처리 실패

를 구분하지 못한다.

우리가 지금 찾는 것은 “same-node required path가 scheduling 단계에서 막혔다”는 신호다.

### B. Kueue pending도 fallback trigger인가

원칙적으로는 아니다.

`kueue_pending`은 quota/admission 계층 문제다.
이건 locality failure가 아니라 cluster admission pressure다.

즉 current question 기준으로:

- `kueue_pending`은 fallback trigger 기본값이 되면 안 된다.
- 우선 후보는 `scheduler_unschedulable` 쪽이다.

## 5. 이번 스프린트에서 고정하는 fallback trigger 후보

이번에 고정하는 최소 판단은 아래다.

### A. 1순위 trigger 후보

- `PodScheduled=False`
- reason: `Unschedulable`
- message에 node selector mismatch 또는 node placement 불가가 드러남

이 신호가 가장 직접적이다.
왜냐하면 current same-node requirement는 실제로 `nodeSelector`로 표현되기 때문이다.

즉 `required same-node`가 깨졌는지 보려면,
가장 먼저 볼 것은 `Pod` scheduling condition이다.

### B. 2순위 보조 정보

- Job annotation의 `producer-node`
- Job spec의 `nodeSelector`
- 필요 시 workload admission 상태

이들은 trigger 자체라기보다 원인 해석용 증거다.

## 6. 이번 스프린트에서 고정하는 제외 기준

아래는 현재 단계에서 fallback trigger 기본값으로 쓰지 않는다.

1. `JobFailed`
- terminal이 너무 늦다.

2. application log의 artifact miss
- scheduling 실패와 실행 실패가 섞인다.

3. `kueue_pending`
- locality failure가 아니라 quota/admission 문제다.

4. operator의 수동 판단
- runtime-level trigger가 아니다.

## 7. 이번 스프린트에서 고정되는 validation 기준

이번에 고정하는 최소 기준은 아래다.

1. fallback trigger는 submit 이후 가능한 한 terminal 이전 signal이어야 한다.
2. current same-node requirement가 `nodeSelector`로 표현되므로, 첫 후보 signal은 `PodScheduled=False, Unschedulable`이다.
3. `kueue_pending`은 fallback trigger라기보다 admission pressure signal로 분리해 읽어야 한다.
4. `JobFailed`는 fallback trigger가 아니라 너무 늦은 결과 signal로 취급해야 한다.

## 8. 이번 스프린트에서 고정되는 판단

이번 스프린트로 아래 판단을 고정한다.

1. dynamic placement가 API object에 들어가므로, fallback trigger도 API observable에서 읽는 것이 맞다.
2. current same-node required path의 fallback trigger 1순위 후보는 `PodScheduled=False, Unschedulable`이다.
3. `kueue_pending`과 `JobFailed`는 fallback trigger 기본값으로는 부적절하다.

## 9. 다음 직접 후속

다음은 `U8 - Required-To-Preferred Downgrade Entry`가 맞다.

이제 “무엇을 trigger로 볼 것인가”는 좁혔다.
다음은 그 trigger가 왔을 때 current required locality를 어떤 조건에서 preferred locality 또는 remote-capable path로 낮출지를 entry 수준으로 고정해야 한다.
