# POST_N2_BACKLOG_REVIEW

## 목적

이 문서는 `Sprint O1 - Post-N2 Backlog Review`에서
`N1`, `N2` 이후 남은 구현 backlog를 다시 가장 작은 질문 단위로 좁힌다.

## 이번 review에서 고정한 것

- `M2`로 multi-replica ordering semantics는 implementation question으로 열렸다.
- `N1`로 recorded replica order를 다시 실험할 수 있는 first execution helper도 생겼다.
- `N2`로 completion/progress 문서도 같은 남은 질문 세트로 정리됐다.

따라서 이제 다음 직접 구현 질문은
`recorded replica order가 current implementation semantics로 실제 의미를 갖는가`
로 좁히는 것이 맞다.

## 이번 review 결과

남은 구현 질문은 아래 순서로 읽는다.

1. `O2 - Post-O1 Implementation Entry`
2. `P1 - Post-O2 Execution Cut`
3. 그 다음에 `retry / recovery policy`

## 왜 이렇게 정리하는가

### 1. 아직 ordering semantics live evidence는 없다

- second replica fallback evidence는 있다.
- 하지만 catalog에 기록된 replica order 자체가
  current implementation에서 어떤 의미를 가지는지는 아직 직접 닫히지 않았다.

### 2. retry/recovery는 여전히 더 크다

- timeout/backoff
- repeated failure handling
- recovery semantics

이 질문들은 ordering semantics를 한 번 더 좁히고 난 뒤에 여는 편이 맞다.

### 3. broader policy 확장은 아직 이르다

- freshness scoring
- health-aware ranking
- richer observability

같은 주제는 아직 후속 refinement로 남긴다.

## 한 줄 결론

`O1`은 next direct implementation question을 recorded replica order semantics 쪽으로 다시 좁힌 review 스프린트다.
