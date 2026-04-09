# MULTI_REPLICA_EXECUTION_CUT

## 목적

이 문서는 `Sprint J1 - Post-I3 Execution Cut`에서 추가한 가장 작은 multi-replica execution cut를 설명한다.

이번 cut의 목적은 multi-replica policy 자체를 구현하는 것이 아니다.
대신 다음 validation이 바로 가능하도록, producer + first replica + second replica 상태를 반복 가능하게 만드는 데 있다.

## 이번 cut에서 추가한 것

- 전용 helper:
  - [run-multi-replica-prep.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-multi-replica-prep.sh)

이 helper는 아래 순서만 수행한다.

1. 기존 cross-node flow로 producer와 first replica를 만든다.
2. producer node와 first replica node를 catalog에서 읽는다.
3. 남은 third node를 second replica target으로 고른다.
4. third node에서 같은 artifact를 한 번 더 GET 해서 second replica를 만든다.
5. catalog의 `replicaNodes`가 두 개 이상인지 확인한다.
6. 두 replica node의 local metadata가 `state=replicated`인지 확인한다.

## 이번 cut에서 의도적으로 하지 않은 것

- multi-replica ordering policy 구현
- replica among replica 선택 규칙 추가
- retry / recovery policy 추가
- richer endpoint observability field 추가
- scheduler/controller 통합

즉 이번 cut은 policy 구현이 아니라 **multi-replica 상태를 준비하는 helper cut**이다.

## 왜 이 범위가 가장 작은가

- 기존 [run-cross-node.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-cross-node.sh)와 [run-replica-aware-prep.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-replica-aware-prep.sh)를 그대로 재사용한다.
- current `agent.py` source-selection semantics는 건드리지 않는다.
- 다음 스프린트는 이 helper를 기반으로 실제 multi-replica validation question을 고르면 된다.

## 다음 직접 연결점

이 cut 다음 직접 연결점은 `Sprint J2 - Post-I3 Completion Refresh`와 `Sprint K1 - Post-J1 Validation Entry`다.
