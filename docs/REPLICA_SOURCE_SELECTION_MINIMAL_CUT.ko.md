# REPLICA_SOURCE_SELECTION_MINIMAL_CUT

## 목적

이 문서는 `Sprint F8 - Replica Source-Selection Minimal Cut`에서 넣은 최소 구현 보정을 고정하기 위한 메모다.

질문:

- `replicaNodes`를 actual source selection에 연결하는 가장 작은 cut는 무엇인가?

## 기준 문서

- [PRODUCER_BIAS_VALIDATION_KICKOFF.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PRODUCER_BIAS_VALIDATION_KICKOFF.ko.md)
- [REPLICA_AWARE_DECISION_NOTE.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_DECISION_NOTE.ko.md)

## 이번 cut의 범위

이번 스프린트는 아래만 바꾼다.

- `peer_fetch()`의 remote candidate set을
  - 기존: `producerAddress` 하나
  - 변경: `producerAddress` + `replicaNodes[*].address`
    로 확장

단, 다음은 그대로 둔다.

- local-first hit
- catalog top-level authority
- retry / recovery policy
- replica 우선순위의 복잡한 정책
- scheduler/controller 연계

## 현재 구현 규칙

현재 최소 cut의 규칙은 다음과 같다.

1. local hit가 있으면 그대로 local을 사용한다.
2. remote fetch가 필요하면 candidate list를 만든다.
3. candidate order는:
   - producer
   - replicaNodes
4. self address와 중복 address는 제외한다.
5. producer가 실패하면 replica candidate로 넘어간다.

## 왜 이 정도가 최소 cut인가

- `replicaNodes`를 control input으로 실제 연결한다.
- 하지만 producer-first ordering을 유지하므로 의미 변화가 과도하지 않다.
- current validation 질문은 “replica를 source 후보로 쓸 수 있는가”이지
  “최적의 source selection policy는 무엇인가”가 아니다.

## 남겨 둔 것

- producer와 replica 사이의 더 정교한 ordering
- replica among replica 선택 기준
- failure aggregation
- retry / backoff

## 다음 연결점

다음 스프린트에서는 이 cut가 실제로 source-selection 변화를 만드는지 검증한다.
