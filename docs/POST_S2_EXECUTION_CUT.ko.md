# POST_S2_EXECUTION_CUT

## 목적

이 문서는 `Sprint T1 - Post-S2 Execution Cut`에서
`S2`에서 고정한 perspective-aware ordering question을 다시 실행 가능한 최소 helper cut로 고정한다.

## 이번 cut에서 추가한 것

- [run-recorded-replica-order-perspective-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-recorded-replica-order-perspective-check.sh)

이 helper는 기존 [run-recorded-replica-order-entry-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-recorded-replica-order-entry-check.sh)를 먼저 실행한 뒤,
같은 catalog record를 각 agent pod 관점에서 다시 읽는다.

실제로 하는 일은 아래와 같다.

1. 기존 recorded replica-order entry check를 그대로 실행
2. catalog record를 다시 읽음
3. 각 agent pod의 `NODE_IP`를 기준으로 current address를 계산
4. 현재 `fetch_candidates()`와 같은 규칙으로 `remoteCandidates`를 다시 계산

즉 이 helper는 broader ordering policy를 추가하지 않고,
현재 implementation이 consumer perspective에서 어떤 remote candidate order를 갖는지 재실행 가능한 출력으로 보여 주는 데 집중한다.

## 왜 이 cut가 가장 작은가

- `peer_fetch()` 로직을 바꾸지 않는다
- replica ranking rule을 추가하지 않는다
- observability field를 추가하지 않는다
- retry/recovery를 열지 않는다

이번 cut는 현재 semantics를 consumer perspective까지 포함해 다시 읽게 만드는 wrapper helper까지만 담당한다.

## 이번에 고정하는 범위

- 다음 후속 스프린트는 `T2 - Post-T1 Completion Refresh`
- broader multi-replica policy commitment는 계속 보류한다
- health/freshness-aware ranking도 계속 보류한다

## 한 줄 결론

`T1`은 current implementation의 `consumer perspective-aware producer -> recorded replica order` reading을 재실행 가능한 helper output으로 보여 주는 최소 execution cut를 추가한 스프린트다.
