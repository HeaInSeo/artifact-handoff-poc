# PARALLEL_6W_DELIVERY_PLAN

## 목적

이 문서는 `artifact-handoff-poc`의 **전체 남은 backlog를 보수적으로 6주 안에 마감**하려는 기준선 일정을 정리한다.

이 일정은 현재 문서화된 직접 남은 스프린트뿐 아니라 아래 후속 backlog까지 포함한다.

- multi-replica 후속 정책
- retry / recovery
- cleanup / GC
- catalog top-level failure reflection 재검토
- scheduler/controller integration evaluation

## 일정 읽는 방식

이 일정은 순차 처리 기준이 아니라 **병렬 트랙 기준**으로 읽는다.

병렬 트랙은 아래 네 개로 고정한다.

1. validation
2. implementation
3. policy/decision
4. docs/release

핵심 원칙:

- validation evidence와 implementation cut를 가능한 한 분리한다.
- policy note는 implementation blocker를 줄이는 방향으로 먼저 고정한다.
- docs/release track은 스프린트 직후 문서 반영과 GitHub push까지 닫는다.

## 보수적 6주 일정표

### Week 1

핵심 목표:

- `K2 - Multi-Replica First Validation`
- `L1 - Post-K2 Backlog Review` 초안

병렬 처리:

- validation:
  - second-replica fallback live evidence 확보
- docs/release:
  - `RESULTS`, `VALIDATION_HISTORY`, `SPRINT_PROGRESS` 반영
- policy/decision:
  - multi-replica first validation 이후 남는 ordering question 초안

### Week 2

핵심 목표:

- `L1 - Post-K2 Backlog Review`
- `L2 - Post-K2 Completion Refresh`
- multi-replica ordering 후속 질문 고정

병렬 처리:

- policy/decision:
  - multi-replica ordering을 어디까지 implementation 대상으로 볼지 고정
- docs/release:
  - completion/progress 문서 정렬
- implementation:
  - 다음 minimal multi-replica cut 준비

### Week 3

핵심 목표:

- multi-replica ordering 또는 candidate iteration 관련 최소 cut 1개
- 그 cut에 대한 follow-up validation 1개

병렬 처리:

- implementation:
  - smallest multi-replica policy cut
- validation:
  - 해당 cut live validation
- docs/release:
  - 결과 문서화 + bilingual parity

### Week 4

핵심 목표:

- retry / recovery를 **small cut + decision note** 조합으로 정리

병렬 처리:

- policy/decision:
  - retry/recovery 범위 고정
- implementation:
  - minimal retry/backoff 또는 failure-handling cut
- validation:
  - 최소 retry evidence 확보

### Week 5

핵심 목표:

- cleanup/GC 및 orphan/local-leftover 후속 정책 정리
- catalog top-level failure reflection 재검토 마감

병렬 처리:

- policy/decision:
  - cleanup/GC note
  - catalog reflection recheck
- docs/release:
  - roadmap/completion refresh
- implementation:
  - 필요 시 smallest cleanup helper 또는 observation helper

### Week 6

핵심 목표:

- scheduler/controller integration evaluation
- 전체 backlog closure review
- final completion refresh

병렬 처리:

- policy/decision:
  - scheduler/controller evaluation note
- docs/release:
  - final closure summary
  - final completion/progress alignment
- validation:
  - 필요한 마지막 확인 1개

## 병렬 트랙별 책임

### Validation Track

- live evidence 확보
- same-node / cross-node / replica path truth 확인
- `RESULTS`, `VALIDATION_HISTORY`에 들어갈 raw evidence 생산

### Implementation Track

- helper script
- minimal code cut
- bounded patch

### Policy/Decision Track

- retry/recovery
- cleanup/GC
- catalog reflection
- ordering semantics

### Docs/Release Track

- bilingual docs 유지
- `SPRINT_PROGRESS`
- `PROJECT_COMPLETION_VIEW`
- sprint closure note
- GitHub push

## 6주 완료 기준

이 계획에서 말하는 “완료”는 아래를 모두 만족할 때다.

1. current documented roadmap closure
2. multi-replica first cycle와 후속 작은 policy question closure
3. retry/recovery 최소 구현 또는 defer-with-note closure
4. cleanup/GC와 orphan/local-leftover 후속 정책 note closure
5. catalog top-level failure reflection 재검토 closure
6. scheduler/controller integration evaluation closure
7. bilingual docs + GitHub release hygiene 유지

## 왜 보수적으로도 6주가 필요한가

- multi-replica는 evidence, implementation, ordering semantics가 서로 연결된다.
- retry/recovery는 failure semantics와 validation을 다시 건드린다.
- cleanup/GC와 catalog reflection은 note만으로도 검토 범위가 넓다.
- scheduler/controller integration은 실구현이 아니어도 별도 evaluation cycle이 필요하다.

즉 병렬화로 속도는 올릴 수 있지만, 통합 판단과 final refresh 구간은 완전히 사라지지 않는다.

## 한 줄 요약

전체 backlog 완료를 목표로 할 때, `artifact-handoff-poc`는 **4개 병렬 트랙을 전제로 한 6주 보수 일정**으로 운영하는 것이 가장 안전하다.
