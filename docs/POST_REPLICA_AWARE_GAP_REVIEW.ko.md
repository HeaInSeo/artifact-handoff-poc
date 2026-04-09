# POST_REPLICA_AWARE_GAP_REVIEW

## 목적

이 문서는 `Sprint G1 - Post-Replica-Aware Gap Review`의 판단을 고정하기 위한 메모다.

질문:

- `Sprint F4`부터 `Sprint F9`까지의 replica-aware 첫 구현/검증 사이클 이후,
- 지금 바로 다음으로 봐야 할 남은 갭은 무엇인가?

## 기준 문서

- [REPLICA_AWARE_FIRST_VALIDATION.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_FIRST_VALIDATION.ko.md)
- [PRODUCER_BIAS_VALIDATION_KICKOFF.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PRODUCER_BIAS_VALIDATION_KICKOFF.ko.md)
- [REPLICA_SOURCE_SELECTION_MINIMAL_CUT.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_MINIMAL_CUT.ko.md)
- [REPLICA_SOURCE_SELECTION_VALIDATION.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_VALIDATION.ko.md)

## 이번 사이클에서 이미 확인된 것

- `replicaNodes`는 실제로 catalog에 기록된다.
- first replica의 local metadata는 `state=replicated`, `source=peer-fetch`로 남는다.
- broken producer 상황에서도 third-node consumer가 replica fallback으로 성공할 수 있다.
- 따라서 `replicaNodes`는 더 이상 단순 observation만이 아니라, 최소한 fallback candidate set에는 참여한다.

## 지금 남아 있는 최소 갭

### 1. actual fetch endpoint observability

- 현재 third-node consumer가 replica fallback으로 성공해도 local metadata의 `producerAddress`는 origin producer 주소를 유지한다.
- 즉 “실제로 어디에서 가져왔는가”를 metadata만으로 바로 읽기 어렵다.

### 2. source-selection ordering semantics

- current cut는 producer-first ordering을 유지한다.
- producer가 살아 있을 때 replica를 절대 쓰지 않는 것이 의도인지, 단지 현재 최소 cut의 결과인지가 아직 완전히 닫히지 않았다.

### 3. multi-replica policy

- 지금 검증은 first replica 1개만 다뤘다.
- replica가 여러 개일 때 어떤 순서나 기준으로 source를 고를지는 아직 범위 밖이다.

## 지금 당장 열지 않을 갭

- retry / backoff / recovery semantics
- catalog top-level failure reflection
- scheduler/controller integration
- cleanup/GC

이 항목들은 replica-aware 첫 사이클 직후에 다시 열기에는 범위가 크다.

## 이번 스프린트의 결론

- 현재 가장 작은 다음 질문은 “replica-aware 이후 무엇이 정말 다음 순번인가”를 다시 정렬하는 것이다.
- 즉 `G2 - Post-Replica-Aware Backlog Ordering`로 바로 이어지는 것이 맞다.
- 그 ordering 이후에 completion overview를 한 번 갱신하는 `H1`이 뒤따르는 구조가 적절하다.

## 한 줄 verdict

`replica-aware first cycle closed once, but observability and ordering semantics remain as the next narrow gaps`
