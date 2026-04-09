# POST_K2_BACKLOG_REVIEW

## 목적

이 문서는 `Sprint L1 - Post-K2 Backlog Review`에서
first multi-replica validation 이후 남은 backlog를 다시 좁게 정리한다.

`K2`는 아래 사실을 live로 닫았다.

- broken producer
- broken first replica
- live second replica

조건에서도 current source-selection path가 second replica까지 이어질 수 있다.

따라서 이제 질문은
“second replica fallback path가 존재하는가”가 아니라,
“그 다음에 어떤 policy/implementation 질문을 가장 작게 열 것인가”로 이동한다.

## K2 이후 닫힌 것

이번 review 기준으로 이미 닫힌 것은 아래다.

- producer-first + replica fallback 후보 집합이 actual live path에 참여한다는 점
- single-replica fallback이 실제로 동작한다는 점
- second replica fallback까지 실제로 이어질 수 있다는 점
- current multi-replica path가 최소한 linear candidate iteration으로는 동작한다는 점

## 지금 남은 가장 작은 갭

이번에 남은 최소 갭은 아래 세 가지로 정리했다.

1. multi-replica ordering semantics
2. actual fetch endpoint observability refinement
3. retry / recovery policy

이 중에서 가장 직접적인 다음 질문은 `multi-replica ordering semantics`다.

## 왜 ordering semantics가 다음 질문인가

- `K2`는 second replica까지 갈 수 있다는 사실을 보여 줬다.
- 하지만 replica among replica ordering은 아직 비어 있다.
- 즉 지금은:
  - second replica까지 간다
  - 그러나 왜 그 순서인가
  - replica freshness나 preference를 어떻게 볼 것인가
  는 아직 닫히지 않았다.

반면 아래 항목은 이번 단계에서 더 크다.

- retry / recovery
- richer observability field
- catalog top-level failure reflection
- scheduler/controller integration

## 이번에 고정한 후속 순서

1. `L2 - Post-K2 Completion Refresh`
2. `M1 - Post-L2 Implementation Reset`
3. 그 다음 실제 질문은 `multi-replica ordering semantics`

즉 지금 당장 큰 구현을 더 여는 대신,
먼저 completion/progress를 `K2` 상태에 맞추고,
그 다음 ordering semantics를 다음 implementation 질문으로 올리는 흐름으로 고정한다.

## 이번에 의도적으로 하지 않은 것

- multi-replica ordering 구현
- retry / recovery 구현
- observability field 추가
- catalog failure reflection 재개

이 스프린트는 backlog review 스프린트다.
