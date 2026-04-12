# U8 - Required-To-Preferred Downgrade Entry

## 1. 스프린트 질문

`U7`에서 current same-node required path의 1순위 fallback trigger 후보를
`PodScheduled=False, Unschedulable`로 고정했다.

이제 다음 질문은 그 trigger가 왔을 때
current required locality를 어떤 조건에서 낮출 것인가다.

이번 스프린트 질문은 하나다.

- 어떤 경우에 current `same-node required`를 `preferred locality` 또는 `remote-capable` path로 downgrade해야 하는가?

이번 문서는 새 구현을 넣지 않고,
현재 API-level placement truth와 `U7` trigger 기준을 바탕으로 downgrade entry를 고정한다.

## 2. 먼저 고정해야 하는 현재 truth

현재 구현 truth는 아래와 같다.

1. child submit 직전에 `RunSpec`이 mutate된다.
2. `spec.Placement.NodeSelector["kubernetes.io/hostname"] = producerNode`
3. 이 값은 Job Pod spec의 required `nodeSelector`로 들어간다.
4. 현재 runtime에는 second submit path가 없다.

즉 지금은:

- required same-node를 먼저 넣고
- 안 되면 어떻게 낮출지에 대한 구조는 아직 비어 있다.

그래서 이번 entry는 “이미 downgrade가 있다”가 아니라
“downgrade를 언제 허용해야 하는가”를 좁히는 단계다.

## 3. downgrade가 필요한 이유

required locality는 현재 implementation truth를 가장 정확하게 보여 주지만,
그 상태를 계속 유지하는 것이 항상 product goal과 일치하는 것은 아니다.

특히 아래 상황에서는 required locality가 너무 강할 수 있다.

- producer node가 unavailable
- scheduler가 node selector mismatch로 child를 배치하지 못함
- artifact는 remote path로는 여전히 접근 가능
- same-node locality를 지키는 것보다 pipeline progress가 더 중요함

즉 downgrade question은 “same-node가 틀렸다”가 아니라,
“same-node required를 언제 progress-preserving policy로 낮춰야 하는가”다.

## 4. 이번 스프린트에서 버리는 오해

### A. unschedulable이면 항상 바로 remote로 가야 하는가

아직 그렇게 고정하면 안 된다.

`Unschedulable`에도 여러 이유가 있을 수 있다.
우리가 찾는 것은 그중에서도
current same-node requirement를 낮춰도 artifact semantics가 유지되는 경우다.

### B. downgrade는 곧 “any node 허용”인가

아니다.

downgrade는 최소 두 층위로 나눠 봐야 한다.

1. same-node required -> same-node preferred
2. same-node preferred -> remote-capable target resolution

즉 downgrade가 바로 policy 포기를 뜻하지는 않는다.

## 5. 이번 스프린트에서 고정하는 최소 downgrade 조건

이번에 고정하는 최소 조건은 아래다.

### A. downgrade를 고려할 수 있는 전제

아래가 모두 맞아야 downgrade를 열 수 있다.

1. same-node required path 실패 signal이 API observable로 확인됨
2. 그 실패가 application command failure가 아니라 placement/scheduling failure임이 분리됨
3. artifact consume semantics가 same-node hard requirement가 아님
4. remote-capable path가 product 의미론상 허용됨

즉 downgrade는 단순 실패 반응이 아니라
“locality requirement를 낮춰도 artifact contract가 유지된다”는 전제가 있어야 한다.

### B. downgrade를 열면 안 되는 경우

아래는 아직 downgrade를 열면 안 되는 경우로 고정한다.

1. same-node 자체가 semantic requirement인 경우
2. remote path의 artifact consistency/availability가 아직 보장되지 않은 경우
3. failure 원인이 placement가 아니라 container/app execution인 경우
4. cluster admission pressure만 있는 경우 (`kueue_pending`)

## 6. 이번 스프린트에서 고정하는 downgrade 방향

이번 entry에서 바로 구현 방향까지 좁히지는 않지만,
방향성은 아래처럼 고정할 수 있다.

### A. 1차 downgrade 방향

- `required same-node`
  ->
- `preferred same-node`

즉 먼저 강한 selector를 낮추는 방향이 기본값이다.

### B. 2차 downgrade 방향

- `preferred same-node`
  ->
- `remote-capable placement resolution`

즉 recorded replica, remote-ok policy, producer/replica ordering을 읽는 더 넓은 path는
1차 downgrade 이후 단계로 보는 것이 맞다.

## 7. 이번 스프린트에서 고정하는 entry 판단

이번에 고정하는 직접 entry 판단은 아래다.

1. current path는 아직 required locality만 구현한다.
2. downgrade는 `Unschedulable` 같은 placement failure signal 이후에만 검토해야 한다.
3. downgrade의 첫 단계는 “required -> preferred”이지, 바로 “policy 없음”이 아니다.
4. remote-capable path는 preferred locality 이후의 다음 resolution 단계로 읽는 것이 맞다.

## 8. 다음 직접 후속

다음은 `U9 - K8s Observable Integration Validation`가 맞다.

이제 필요한 것은 downgrade 철학을 더 말하는 것이 아니라,
`K8sObserver.ObservePod()`와 `ObserveWorkload()`를 current fallback 판단 경로에 어떻게 붙일지를 validation 기준으로 고정하는 것이다.
