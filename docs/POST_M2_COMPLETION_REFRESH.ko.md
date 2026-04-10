# POST_M2_COMPLETION_REFRESH

## 목적

이 문서는 `Sprint N2 - Post-M2 Completion Refresh`에서
`M2`, `N1` 이후 completion view와 progress board가 같은 남은 질문 세트를 가리키도록 다시 정렬한다.

## 이번 refresh에서 고정한 것

- `M2`는 multi-replica ordering semantics를 implementation question으로 여는 entry 스프린트다.
- `N1`은 그 ordering question을 바로 실험할 수 있게 만드는 first execution cut 스프린트다.
- 따라서 이제 직접 다음 핵심 스프린트는 `O1 - Post-N2 Backlog Review`로 넘어간다.

## 정렬 결과

이번 refresh 이후 두 문서는 아래를 같은 방식으로 가리킨다.

1. `O1 - Post-N2 Backlog Review`
2. `O2 - Post-O1 Implementation Entry`
3. 그 다음에 retry/recovery 등 더 큰 backlog

## 이번에 의도적으로 하지 않은 것

- ordering semantics live validation
- retry / recovery 구현
- observability field 확장

이 스프린트는 completion/progress refresh 스프린트다.
