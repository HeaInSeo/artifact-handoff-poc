# PROJECT_COMPLETION_VIEW

## 목적

이 문서는 `artifact-handoff-poc`의 현재 완료 범위와 남은 스프린트, 후속 backlog를 한 번에 보기 위한 overview 문서다.

이 문서는 진행판([SPRINT_PROGRESS.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SPRINT_PROGRESS.ko.md))을 대체하지 않는다.
대신 아래 질문에 빠르게 답하기 위한 보조 문서다.

- 지금까지 어디까지 완료됐는가
- 현재 문서화된 로드맵 기준으로 어떤 스프린트가 남았는가
- 프로젝트를 더 실제로 확장하려면 어떤 backlog가 남아 있는가
- “완료”를 어떤 층위로 읽어야 하는가

전체 backlog를 포함한 보수적 6주 병렬 일정은 [PARALLEL_6W_DELIVERY_PLAN.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PARALLEL_6W_DELIVERY_PLAN.ko.md)에서 본다.

## 현재 완료된 것

현재까지 완료된 큰 묶음은 아래와 같다.

1. Sprint 1 baseline / README / research / results 정리
2. failure semantics / failure evidence / bilingual docs 정리
3. catalog-local metadata edge-case 2 family 실검증
4. replica-aware fetch 준비 상태 검증
5. producer-only bias 실증
6. `replicaNodes`를 remote candidate set에 연결하는 최소 구현 cut
7. multi-replica 상태를 준비하는 최소 execution cut
8. consumer perspective-aware remote candidate order reading 고정과 재실행 helper cut
9. 원격 multipass K8s VM에서 current `poc` path의 same-node 결과가 dynamic DAG placement가 아니라 storage binding side effect임을 실검증
10. 그 원격 실검증 결과를 바탕으로 dynamic placement를 `ArtifactBinding + PlacementIntent + ResolvedPlacement`로 분리하는 최소 interface cut 고정
11. 실제 `poc`/`spawner` 변경과 원격 재실행으로 child Job의 explicit placement mutation을 실검증
12. 그 실검증과 current code path를 바탕으로 dynamic fallback의 다음 직접 validation question을 entry note로 고정
13. current `nodeSelector` path를 기준으로 현재 구현 truth는 `same-node required`이고 `preferred locality`는 아직 future validation target이라는 판단 고정
14. dynamic placement가 API object에 들어가므로 fallback trigger도 API observable에서 읽어야 하고, 1순위 후보는 `PodScheduled=False, Unschedulable`라는 판단 고정
15. downgrade는 바로 remote path가 아니라 `required -> preferred`, 그 다음 `preferred -> remote-capable resolution`의 2단계 entry로 읽어야 한다는 판단 고정
16. `Wait()`는 terminal path로 유지하고, `ObservePod()` / `ObserveWorkload()`는 별도 fallback judgment layer가 읽는 구조가 맞다는 integration 판단 고정
17. remote-capable resolution은 단순 scheduling 완화가 아니라 `consume policy + producerNode + replicaNodes/recorded order + observable failure signal`을 함께 읽는 artifact-aware policy step이라는 판단 고정

즉 현재 저장소는:

- same-node reuse
- cross-node peer fetch
- failure-path recording
- edge-case truth
- replica-ready state
- producer-only bias evidence
- second-replica fallback evidence
- perspective-aware remote candidate order replay

까지는 실제 문서와 실검증으로 상당히 고정된 상태다.

## 현재 문서화된 로드맵 기준 남은 스프린트

현재 진행판 기준으로 `U10`까지의 문서화된 로드맵은 모두 완료됐다.

즉 현재는 문서화된 현재 로드맵 안의 미완료 스프린트가 없고,
다음 직접 후속은 `U11 - Controller-Owned Placement Resolution Entry`처럼 이 판단을 어느 층에 둘지 더 좁히는 단계다.

## 현재 로드맵 기준 진행률

현재 문서화된 로드맵 기준 진행률은 다음과 같이 읽는다.

- 완료: `95/95`
- `100%`

중요:

- 이 수치는 **현재 문서화된 sprint roadmap 기준**이다.
- 이 수치는 저장소의 전체 제품 완성도나 production readiness를 뜻하지 않는다.

## 후속 backlog

현재 로드맵 밖이지만, 프로젝트를 더 실제로 확장하려면 남아 있는 후속 backlog는 아래와 같다.

### 1. replica-aware fetch policy 정교화

- producer 우선 / replica fallback ordering
- replica among replica 선택 기준
- policy semantics 명확화

### 2. catalog top-level failure reflection

- 현재는 defer 상태
- cluster-wide failure state를 catalog에 올릴지 재검토 필요

### 3. retry / recovery policy

- peer fetch retry
- timeout/backoff
- recovery semantics

### 4. orphan/local-leftover 후속 정책

- cleanup/GC
- retention window
- catalog-local divergence 허용 범위

### 5. scheduler/controller integration evaluation

- script-assisted validation에서 더 자동화된 placement/control layer로 갈지 판단
- `U3`에서 child Job의 explicit placement mutation까지는 원격 실검증으로 확보됨
- `U5`에서 다음 직접 질문은 same-node required path 이후의 fallback semantics로 고정됨
- `U6`에서 current implementation truth는 required locality라는 판단까지 고정됨
- `U7`에서 fallback trigger는 API observable에서 읽어야 하고, 1순위 후보는 `PodScheduled=False, Unschedulable`라고 고정됨
- `U8`에서 downgrade 방향은 `required -> preferred -> remote-capable` 2단계로 고정됨
- `U9`에서 observer integration은 `Wait()` 확장이 아니라 별도 fallback judgment layer 쪽이 맞다고 고정됨
- `U10`에서 remote-capable resolution 입력 집합도 고정됨
- 다음 단계는 이 판단을 controller-owned resolution으로 올릴지 정하는 것
- 현재 구현은 node-level mutate hook까지는 들어갔지만, broader controller/scheduler 일반화는 아직 열려 있음

### 6. 필요 시 storage option 후속 비교

- `hostPath`
- `local PersistentVolume`

### 7. Dragonfly fork-fit / upstream alignment research

- Dragonfly를 distribution backend candidate로 얕게 붙일 수 있는지
- deep fork 없이도 현재 PoC semantics와 정합성을 유지할 수 있는지
- 업스트림 릴리스 변화가 adapter boundary에서 흡수 가능한지

### 8. Dragonfly adapter contract research

- product-owned contract를 먼저 두고 Dragonfly를 backend로 붙일 수 있는지
- `Put / EnsureOnNode / Stat / Warm / Evict` 같은 최소 contract로 좁힐 수 있는지
- remote lab 실검증으로 lower-layer transport 근거를 확보했는지

### 9. dynamic DAG placement validation

- 원격 multipass K8s VM에서 `U1`로 current `poc` path의 same-node 결과가 storage binding side effect라는 부정 결과를 먼저 고정
- `U3`에서 child Job의 `nodeSelector`와 placement annotation이 explicit mutation으로 들어간다는 점을 재실검증
- `U5`에서 same-node failure 이후 remote fallback semantics를 다음 직접 validation question으로 고정
- `U6`에서 current path는 `same-node required`로 읽어야 한다는 validation 기준을 고정
- `U7`에서 observable fallback trigger signal의 1순위 후보를 `PodScheduled=False, Unschedulable`로 고정
- `U8`에서 그 trigger 이후 downgrade는 먼저 preferred locality, 그 다음 remote-capable resolution로 가야 한다는 entry를 고정
- `U9`에서 이 흐름은 `ObservePod()` / `ObserveWorkload()`를 별도 fallback judgment layer가 읽는 방식으로 연결해야 한다고 고정
- `U10`에서 remote-capable resolution은 `consume policy + producerNode + replicaNodes/recorded order + observable failure signal`을 읽는 단계로 고정
- 다음 단계는 이 판단을 어느 runtime/controller 층에 둘지 정하는 것

## 보수적 6주 병렬 일정

- 보수 일정: `6주`
- 운영 방식: `4개 병렬 트랙`
  - validation
  - implementation
  - policy/decision
  - docs/release

자세한 주차별 계획은 [PARALLEL_6W_DELIVERY_PLAN.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PARALLEL_6W_DELIVERY_PLAN.ko.md)에 고정한다.

## 완료를 어떻게 읽어야 하는가

이 저장소는 일반적인 단일 앱 프로젝트처럼 “한 번에 완료”되는 구조와 다르다.

따라서 완료는 아래처럼 층위별로 읽는 것이 맞다.

### A. Sprint 1 validation 완료

- baseline
- same-node / cross-node
- failure-path
- edge-case truth

이 층위는 상당 부분 닫혀 있다.

### B. replica-aware fetch 첫 번째 검증 사이클 완료

- replica-ready state
- producer-only bias evidence
- minimal source-selection cut
- replica fallback after producer failure
- minimum multi-replica execution cut
- post-replica-aware gap review
- post-replica-aware backlog ordering
- post-replica-aware completion view refresh
- replica-aware observability follow-up
- replica ordering semantics note
- post-H3 backlog reset
- post-H3 completion-view refresh
- next implementation question selection
- first multi-replica validation

이 층위는 이제 한 차례 닫힌 것으로 볼 수 있다.

### C. 후속 policy / control-layer 확장 완료

- retry/recovery
- cleanup/GC
- scheduler/controller

이 층위는 아직 시작 전 backlog에 가깝다.

## 현재 한 줄 요약

현재 `artifact-handoff-poc`는 Sprint 1 validation과 replica-aware fetch의 첫 번째 구현/검증 사이클, multi-replica policy를 여는 최소 execution cut, first multi-replica validation evidence, 그 이후 backlog review, completion/progress refresh, implementation reset, ordering semantics entry, 그 ordering question을 위한 첫 execution cut, 그 이후 refresh, post-N2 backlog review, recorded replica-order semantics를 다음 직접 implementation topic으로 고정하는 entry, 그 의미를 더 직접 읽기 위한 최소 probe helper cut, 그 이후 남은 질문 세트를 `Q1 -> Q2` 흐름으로 정렬하는 refresh, recorded replica-order question을 current implementation reading 수준으로 다시 좁히는 backlog review, 그 reading을 다음 직접 implementation entry로 고정하는 단계, 그 reading을 재실행 가능한 ordered-candidate 출력으로 보여 주는 최소 wrapper helper cut, `Q2`, `R1` 이후 completion/progress 문서를 같은 남은 질문 세트로 맞추는 refresh, 그 이후 남은 구현 backlog를 다시 좁히는 review, consumer perspective-aware remote candidate order reading을 고정하는 entry와 그 reading을 각 agent pod 관점에서 재실행하는 최소 helper cut, 그 이후 남은 질문 세트를 `T3 -> U1` 흐름으로 다시 정렬하는 refresh, perspective-aware reading 이후 남은 refinement question을 다시 작은 entry 범위로 넘기는 backlog review, 원격 multipass K8s VM에서 current `poc` path의 same-node 결과가 dynamic DAG placement가 아니라 storage binding side effect라는 점을 확인하는 실검증, 그 결과를 바탕으로 dynamic placement를 `ArtifactBinding + PlacementIntent + ResolvedPlacement`로 분리하는 최소 interface cut 고정, 실제 `poc`/`spawner` 변경과 원격 재실행으로 child Job의 explicit placement mutation을 확인하는 validation, 그 실검증과 current code path를 바탕으로 dynamic fallback의 다음 직접 validation question을 고정하는 entry, current `nodeSelector` path를 `same-node required`로 읽어야 한다는 validation 기준 고정, fallback trigger는 API observable에서 읽어야 하며 1순위 후보는 `PodScheduled=False, Unschedulable`라는 판단 고정, downgrade는 `required -> preferred -> remote-capable resolution`의 2단계 entry로 읽어야 한다는 판단 고정, `Wait()`는 terminal path로 유지하고 `ObservePod()` / `ObserveWorkload()`는 별도 fallback judgment layer가 읽는 구조가 맞다는 integration 판단 고정, 그리고 remote-capable resolution은 `consume policy + producerNode + replicaNodes/recorded order + observable failure signal`을 읽는 artifact-aware policy step이라는 판단 고정까지는 상당히 진행됐다. 현재 문서화된 로드맵은 `U10`까지 모두 완료됐고, 전체 backlog 완료는 보수적으로 [PARALLEL_6W_DELIVERY_PLAN.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PARALLEL_6W_DELIVERY_PLAN.ko.md) 기준 `6주`로 본다. 다음 직접 후속 단계는 `U11 - Controller-Owned Placement Resolution Entry`다.
