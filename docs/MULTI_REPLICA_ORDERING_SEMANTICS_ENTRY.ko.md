# MULTI_REPLICA_ORDERING_SEMANTICS_ENTRY

## 목적

이 문서는 `Sprint M2 - Multi-Replica Ordering Semantics Entry`에서
multi-replica ordering semantics를 다음 실제 implementation question으로 여는 범위를 고정한다.

## 이번 entry에서 고정한 질문

다음 구현 질문은 아래처럼 좁게 읽는다.

- current multi-replica remote candidate iteration을
  `producer -> replicaNodes in recorded order`
  라는 현재 구현 semantics로 명시할 것인가?
- 그리고 그 ordering을 더 분명하게 드러내는 최소 execution cut를 다음 단계로 둘 것인가?

즉 이번 entry는
더 똑똑한 replica selection policy를 설계하는 스프린트가 아니다.

## 왜 이 질문이 가장 작은 다음 단계인가

### 1. 현재 live evidence는 second replica fallback까지는 이미 보여 줬다

- broken producer
- broken first replica
- second replica fallback success

이 경로는 이미 `K2`에서 확보됐다.

### 2. 현재 code path는 candidate ordering을 갖고 있지만 policy로는 아직 고정되지 않았다

- local hit가 먼저다.
- remote candidate set은 producer를 먼저 넣는다.
- replica 후보는 `replicaNodes`를 순서대로 따라간다.

하지만 이걸 아직 broader policy commitment로는 올리지 않았다.

### 3. 지금 더 큰 질문으로 가면 범위가 커진다

이번 단계에서 아직 열지 않을 것:

- replica freshness scoring
- health-based source preference
- multi-replica retry/backoff policy
- actual fetch endpoint observability field 확장

## 이번에 고정하는 규칙

- 다음 직접 implementation question은 `ordering semantics explicitness`다.
- current behavior는 우선
  `producer -> replicaNodes in recorded order`
  로 읽는다.
- 더 넓은 replica policy는 후속 refinement로 남긴다.

## 다음 단계 기준

다음 스프린트 `N1 - Post-M2 Execution Cut`에서는
아래 중 가장 작은 형태를 고른다.

1. candidate iteration rule을 코드/문서에서 더 명시하는 작은 cut
2. recorded replica order가 실제로 의미를 갖는지 확인하는 최소 helper 또는 validation cut

## 한 줄 결론

`multi-replica ordering semantics should now be opened as an explicit implementation question about producer-first, then recorded-replica order`
