# PROJECT_COMPLETION_VIEW

## 목적

이 문서는 `artifact-handoff-poc`의 현재 완료 범위와 남은 스프린트, 후속 backlog를 한 번에 보기 위한 overview 문서다.

이 문서는 진행판([SPRINT_PROGRESS.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SPRINT_PROGRESS.ko.md))을 대체하지 않는다.
대신 아래 질문에 빠르게 답하기 위한 보조 문서다.

- 지금까지 어디까지 완료됐는가
- 현재 문서화된 로드맵 기준으로 어떤 스프린트가 남았는가
- 프로젝트를 더 실제로 확장하려면 어떤 backlog가 남아 있는가
- “완료”를 어떤 층위로 읽어야 하는가

## 현재 완료된 것

현재까지 완료된 큰 묶음은 아래와 같다.

1. Sprint 1 baseline / README / research / results 정리
2. failure semantics / failure evidence / bilingual docs 정리
3. catalog-local metadata edge-case 2 family 실검증
4. replica-aware fetch 준비 상태 검증
5. producer-only bias 실증
6. `replicaNodes`를 remote candidate set에 연결하는 최소 구현 cut

즉 현재 저장소는:

- same-node reuse
- cross-node peer fetch
- failure-path recording
- edge-case truth
- replica-ready state
- producer-only bias evidence

까지는 실제 문서와 실검증으로 상당히 고정된 상태다.

## 현재 문서화된 로드맵 기준 남은 스프린트

현재 진행판 기준으로 바로 남아 있는 스프린트는 아래와 같다.

### H2 - Replica-Aware Observability Follow-Up

목표:

- actual fetch endpoint observability를 지금 더 다룰지, 아니면 현재 metadata model에서 defer할지 판단

완료 기준:

- observability follow-up 필요 여부가 한 문서로 고정됨

### H3 - Replica Ordering Semantics Note

목표:

- producer-first ordering을 current implementation truth로 둘지, 다음 policy 후보로 둘지 note로 먼저 고정

완료 기준:

- ordering semantics의 현재 판단이 한 문서로 고정됨

### I1 - Post-H3 Backlog Reset

목표:

- observability와 ordering semantics note 이후 남은 구현 backlog를 다시 작게 정리

완료 기준:

- 다음 implementation 질문이 한 문서로 고정됨

## 현재 로드맵 기준 진행률

현재 문서화된 로드맵 기준 진행률은 다음과 같이 읽는다.

- 완료: `58/60`
- 약 `97%`

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

### 6. 필요 시 storage option 후속 비교

- `hostPath`
- `local PersistentVolume`

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
- post-replica-aware gap review
- post-replica-aware backlog ordering
- post-replica-aware completion view refresh

이 층위는 이제 한 차례 닫힌 것으로 볼 수 있다.

### C. 후속 policy / control-layer 확장 완료

- retry/recovery
- cleanup/GC
- scheduler/controller

이 층위는 아직 시작 전 backlog에 가깝다.

## 현재 한 줄 요약

현재 `artifact-handoff-poc`는 Sprint 1 validation과 replica-aware fetch의 첫 번째 구현/검증 사이클, 그리고 그 직후 review/order/refresh 정리까지는 상당히 진행됐고, 다음 직접 남은 핵심 스프린트는 `H2 - Replica-Aware Observability Follow-Up`이다.
