# U10 - Remote-Capable Resolution Entry

## 1. 스프린트 질문

`U8`에서 downgrade는

- `required -> preferred`
- `preferred -> remote-capable resolution`

의 2단계로 읽어야 한다고 고정했고,
`U9`에서는 `ObservePod()` / `ObserveWorkload()`를 별도 fallback judgment layer가 읽는 구조가 맞다고 고정했다.

이제 남은 직접 질문은 이것이다.

- preferred locality 이후 remote-capable resolution은 어떤 policy input을 읽어 열어야 하는가?

이번 문서는 새 구현을 넣지 않고,
현재 저장소에 이미 존재하는 metadata/validation truth를 기준으로 remote-capable resolution entry를 고정한다.

## 2. remote-capable resolution이 뜻하는 것

이번 문서에서 remote-capable resolution은 단순히
“same-node를 포기하고 아무 노드나 허용한다”는 뜻이 아니다.

의미는 더 좁다.

- current same-node preference를 더 이상 강제하지 않되,
- artifact handoff semantics를 유지하는 범위 안에서
- remote fetch / replica / producer ordering을 읽을 수 있는 placement/consume path로 넘어가는 것

즉 resolution은 단순 scheduling 완화가 아니라
artifact-aware target selection을 포함한다.

## 3. 현재 저장소에 이미 있는 policy input

현재 기준으로 remote-capable resolution 후보 입력은 이미 몇 가지가 존재한다.

### A. `producerNode`

- artifact의 producer 위치
- current same-node path의 첫 기준

이 값은 same-node required / preferred 단계에서 가장 먼저 쓰인다.

### B. `replicaNodes`

- remote candidate set의 실제 후속 입력
- 이미 replica-aware fetch 검증에서 current behavior truth로 다뤘다

즉 remote path가 열린 뒤에는,
이 값이 “아무 원격”이 아니라 “어떤 원격 후보 집합”인지를 정한다.

### C. recorded replica order

- multi-replica validation에서 이미
  `producer -> recorded replica order`
  그리고 consumer perspective-aware reading까지 고정했다

즉 remote-capable resolution은 단순 replica 존재 여부가 아니라
recorded order semantics를 읽는 단계여야 한다.

### D. consume semantics

`DYNAMIC_PLACEMENT_INTERFACE_CUT`에서 이미 아래 구분을 열어 두었다.

- `same-node-preferred`
- `remote-ok`
- `same-node-only`
- `same-node-then-remote`

즉 remote-capable resolution은 위치 정보만으로 열 수 없고,
artifact consume mode와 fallback policy도 같이 읽어야 한다.

## 4. 이번 스프린트에서 버리는 오해

### A. remote-capable resolution은 replicaNodes만 읽으면 되는가

아니다.

`replicaNodes`는 후보 집합 일부일 뿐이다.
그 전에:

- remote path가 product semantics상 열려 있는지
- producer를 먼저 볼지
- recorded replica order를 실제로 읽을지

가 같이 정해져야 한다.

### B. remote-capable resolution은 scheduling 문제만 풀면 되는가

아니다.

이 단계는 scheduling 완화보다 넓다.
왜냐하면 remote-capable path는 결국:

- 어디에 child를 두는가
- 어떤 artifact source를 읽는가

를 함께 정해야 하기 때문이다.

## 5. 이번 스프린트에서 고정하는 최소 resolution 입력 집합

이번에 고정하는 최소 입력 집합은 아래다.

1. `ArtifactBinding` / consume mode
- `same-node-only`인지
- `same-node-then-remote`인지
- `remote-ok`인지

2. producer locality input
- `producerNode`
- 필요 시 producer-side annotation / current placement intent

3. remote candidate input
- `replicaNodes`
- recorded replica order

4. current failure/judgment input
- `ObservePod()` 결과
- 필요 시 `ObserveWorkload()` 결과

즉 remote-capable resolution은
`failure signal + locality metadata + remote candidate metadata + consume policy`
를 같이 읽는 단계다.

## 6. 이번 스프린트에서 고정하는 제외 기준

아래는 아직 remote-capable resolution의 기본 입력으로 고정하지 않는다.

1. 단순 “any available node”
- artifact-aware resolution이 아니다.

2. application log만 기반한 source 선택
- scheduling / placement / artifact policy가 섞인다.

3. broader freshness/health ranking
- 아직 current backlog 범위 밖이다.

4. controller-wide global optimization
- 아직 script-assisted / narrow validation 단계다.

## 7. 이번 스프린트에서 고정되는 entry 판단

이번에 고정하는 직접 판단은 아래다.

1. remote-capable resolution은 scheduler 완화가 아니라 artifact-aware policy step이다.
2. 최소 입력은 `consume policy + producerNode + replicaNodes/recorded order + observable failure signal`이다.
3. remote path는 “아무 원격”이 아니라 current recorded producer/replica semantics를 읽는 방식으로 열어야 한다.

## 8. 다음 직접 후속

다음은 `U11 - Controller-Owned Placement Resolution Entry`가 맞다.

이제 remote-capable resolution에 필요한 입력은 좁혔다.
다음은 이 판단을 `poc`의 현재 node-level mutate / observer 조합 위에 둘지,
아니면 product/controller-owned resolution step으로 올릴지를 entry 수준으로 고정해야 한다.
