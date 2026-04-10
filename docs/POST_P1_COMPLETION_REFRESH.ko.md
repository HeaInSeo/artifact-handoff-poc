# POST_P1_COMPLETION_REFRESH

## 목적

이 문서는 `Sprint P2 - Post-P1 Completion Refresh`에서
`O2`, `P1` 이후 completion view와 progress board를 같은 남은 질문 세트로 다시 정렬하기 위한 refresh note다.

## 이번 refresh에서 고정한 것

- `O2`는 recorded replica-order semantics를 다음 직접 implementation topic으로 고정한 entry 스프린트로 유지
- `P1`은 그 semantics를 더 직접 읽을 수 있게 만드는 최소 probe helper cut로 유지
- 이 둘 이후의 다음 직접 핵심 스프린트는 `Q1 - Post-P2 Backlog Review`
- 그 다음은 `Q2 - Post-Q1 Implementation Entry`

즉 이제 문서상 다음 흐름은:

- `Q1`에서 남은 구현 backlog를 다시 좁힘
- `Q2`에서 그 결과를 다음 직접 implementation entry로 고정

으로 읽는 것이 맞다.

## 왜 이렇게 정리하는가

- `P1`은 execution cut까지 추가했지만, 아직 new live validation을 닫은 스프린트는 아니다
- 따라서 다음 단계는 곧바로 더 큰 policy로 가는 것이 아니라, backlog를 다시 한 번 좁게 review하는 것이 더 자연스럽다
- retry/recovery, broader multi-replica policy commitment, actual fetch endpoint observability field 확장은 계속 후순위다

## 한 줄 결론

`P2`는 `O2`, `P1` 이후의 남은 질문 세트를 `Q1 -> Q2` 흐름으로 다시 정렬하는 completion refresh 스프린트다.
