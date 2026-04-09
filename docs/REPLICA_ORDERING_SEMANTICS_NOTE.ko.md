# REPLICA_ORDERING_SEMANTICS_NOTE

## 목적

이 문서는 `Sprint H3 - Replica Ordering Semantics Note`의 판단을 고정하기 위한 메모다.

질문:

- 현재 `producer-first ordering`을 어떻게 읽어야 하는가?
- 이것을 이미 확정된 policy로 볼 것인가, 아니면 현재 최소 cut의 구현 truth로만 볼 것인가?

## 기준 문서

- [REPLICA_SOURCE_SELECTION_MINIMAL_CUT.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_MINIMAL_CUT.ko.md)
- [REPLICA_SOURCE_SELECTION_VALIDATION.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_VALIDATION.ko.md)
- [REPLICA_AWARE_OBSERVABILITY_FOLLOW_UP.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_OBSERVABILITY_FOLLOW_UP.ko.md)

## 현재 확인된 사실

- local hit가 있으면 그대로 local을 사용한다.
- remote candidate set은 현재:
  - producer
  - replicaNodes
  순서로 구성된다.
- broken producer 상황에서는 replica fallback이 실제로 동작한다.
- producer가 정상일 때 replica를 우선 쓰는 동작은 현재 구현돼 있지 않다.

## 판단

- `producer-first ordering`은 현재 단계에서는 **current implementation truth**로 본다.
- 하지만 이것을 곧바로 더 넓은 **policy commitment**로 읽지는 않는다.

## 왜 이렇게 읽는가

### 1. 현재 cut의 목적이 ordering policy 확정이 아니었다

- `F8`의 목표는 `replicaNodes`를 source candidate set 안으로 넣는 것이었다.
- 최적 ordering policy를 설계하는 것은 범위 밖이었다.

### 2. 현재 evidence는 “producer-first가 동작한다”까지는 보여 준다

- producer가 깨지면 replica로 넘어간다.
- producer가 살아 있을 때 replica를 앞세우는 동작은 아직 없다.

즉 현재 behavior는 설명 가능하다.

### 3. 하지만 이것이 최종 policy라는 뜻은 아니다

- multi-replica ordering
- replica freshness / preference
- retry/recovery와의 결합

같은 후속 질문이 아직 열려 있다.

## 현재 고정하는 규칙

- producer-first ordering은 현재 구현의 truth로 유지한다.
- replica fallback은 producer failure 뒤의 current behavior로 유지한다.
- 더 넓은 ordering policy는 후속 refinement 질문으로 남긴다.

## 한 줄 결론

`producer-first ordering is the current implementation truth, but not yet a broader policy commitment`
