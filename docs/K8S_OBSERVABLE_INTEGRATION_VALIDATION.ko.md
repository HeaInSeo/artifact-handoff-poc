# U9 - K8s Observable Integration Validation

## 1. 스프린트 질문

`U7`에서 current same-node required path의 1순위 fallback trigger 후보를
`PodScheduled=False, Unschedulable`로 고정했고,
`U8`에서는 downgrade를 `required -> preferred -> remote-capable resolution`의
2단계로 읽어야 한다고 고정했다.

이제 남은 직접 질문은 이것이다.

- `K8sObserver.ObservePod()`와 `ObserveWorkload()`를 current fallback 판단 경로에 어떻게 연결해야 하는가?

이번 문서는 새 구현을 넣지 않고,
현재 코드 경로와 observable model을 기준으로 integration validation 기준을 고정한다.

## 2. 현재 코드가 보여 주는 분리 상태

현재 구조는 이미 두 경로를 갖고 있지만, 아직 하나로 연결되어 있지는 않다.

### A. main execution path

- `SpawnerNode.RunE()`
- `DriverK8s.Prepare()`
- `DriverK8s.Start()`
- `DriverK8s.Wait()`

이 경로는 현재 main path다.
하지만 `Wait()`는 `JobComplete` / `JobFailed` 같은 terminal state만 본다.

### B. observable path

- `K8sObserver.ObserveWorkload()`
- `K8sObserver.ObservePod()`
- `poc/pkg/observe/pipeline_status.go`

이 경로는 이미:

- `kueue_pending`
- `scheduler_unschedulable`

를 분리해서 읽는다.

즉 관찰 경로는 있는데,
그 결과가 아직 current fallback 판단 로직에 연결돼 있지 않다.

## 3. 이번 스프린트에서 버리는 오해

### A. observer를 `Wait()` 안으로 바로 넣으면 되는가

지금 단계에서는 그렇게 단순화하면 안 된다.

`Wait()`의 역할은 현재 terminal event 반환이다.
여기에 pre-terminal scheduling / admission 관찰까지 섞으면,

- terminal result
- fallback trigger
- operator observability

가 한 함수에 혼합된다.

현재 문서 기준으로는 먼저 “무엇을 어디서 읽을지”를 분리해서 고정하는 편이 맞다.

### B. observer path는 운영용이고 runtime 판단에는 못 쓰는가

그렇게 볼 필요는 없다.

현재 `U7`에서 fallback trigger를 API observable로 읽어야 한다고 고정했기 때문에,
observer path는 단순 operator-only path가 아니라
future fallback 판단의 후보 입력으로 봐야 한다.

다만 지금 당장 `Wait()`와 합치지는 않는 것이 맞다.

## 4. 이번 스프린트에서 고정하는 integration 방향

이번에 고정하는 최소 방향은 아래다.

### A. 역할 분리 유지

- `DriverK8s.Wait()`
  - terminal state 담당
- `K8sObserver`
  - pre-terminal admission / scheduling signal 담당

즉 둘을 당장 하나의 함수로 합치기보다,
역할 분리를 유지한 채 fallback 판단 레이어가 두 신호를 읽는 구조가 맞다.

### B. fallback judgment layer가 observer를 읽어야 함

current same-node required path에서 필요한 것은:

1. `ObservePod()`로 `scheduler_unschedulable` 확인
2. 필요 시 `ObserveWorkload()`로 `kueue_pending`과 구분
3. 그 결과를 current Job spec / annotation과 같이 읽어 locality failure 여부 판단

즉 integration의 핵심은 “observer를 어디에 붙일까”가 아니라,
“누가 observer 결과를 fallback judgment input으로 읽을까”다.

### C. 현재 기준의 가장 자연스러운 integration 지점

현재 문서 기준으로는
`SpawnerNode.RunE()` 안으로 바로 넣기보다,
별도의 fallback judgment layer 또는 resolution step이 observer를 읽는 구조가 더 맞다.

이유:

- `RunE()`는 제출/대기 실행 경로다.
- observer는 pre-terminal diagnosis 경로다.
- downgrade와 resubmit 판단은 그 위의 policy step이어야 한다.

## 5. 이번 스프린트에서 고정하는 최소 integration 기준

이번에 고정하는 기준은 아래다.

1. `Wait()`는 여전히 terminal result 경로로 유지
2. fallback trigger 판정은 `ObservePod()` / `ObserveWorkload()` 같은 pre-terminal observable 경로에서 읽음
3. `scheduler_unschedulable`와 `kueue_pending`은 절대 합쳐 읽지 않음
4. observer 결과만 단독으로 보지 않고,
   current Job의 `nodeSelector`, `producer-node` annotation과 함께 읽어야 함

즉 observer integration은 단순 wiring이 아니라
`observable + current placement intent`를 같이 읽는 판단 경로다.

## 6. 이번 스프린트에서 고정되는 판단

이번 스프린트로 아래를 고정한다.

1. current fallback judgment는 `Wait()`를 직접 확장하기보다 observer 경로를 별도로 읽는 것이 맞다.
2. `ObservePod()`는 1순위 trigger input이고, `ObserveWorkload()`는 구분 보조 input이다.
3. integration의 책임은 execution driver가 아니라 future fallback judgment layer 쪽에 두는 것이 맞다.

## 7. 다음 직접 후속

다음은 `U10 - Remote-Capable Resolution Entry`가 맞다.

이제 observable integration 경계는 좁혔다.
다음은 downgrade 이후 remote-capable resolution을 어떤 policy input으로 열지,
즉 producer/replica/remote-ok semantics를 어느 층에서 읽을지를 entry 수준으로 고정해야 한다.
