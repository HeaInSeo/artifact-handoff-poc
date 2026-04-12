# POST_T2_BACKLOG_REVIEW

## 목적

이 문서는 `Sprint T3 - Post-T2 Backlog Review`에서
`T2` 이후 남은 ordering/refinement backlog를 다시 가장 작은 질문 단위로 좁히기 위한 review note다.

## 이번 review에서 고정한 것

- `consumer perspective-aware producer -> recorded replica order` reading은 entry와 replayable helper까지 이미 확보됐다
- 따라서 지금 남은 가장 작은 질문은 같은 reading을 더 넓히는 것이 아니라, 그 reading을 다음 implementation entry에서 어디까지 current implementation scope로 유지할지 다시 고정하는 것이다
- 다음 직접 핵심 스프린트는 `U1 - Post-T3 Implementation Entry`로 둔다

즉 지금 단계의 핵심은 새로운 ranking rule이나 policy commitment를 여는 것이 아니라,
현재 semantics를 다음 direct implementation entry에서 어떤 범위로 읽을지 다시 한 번 작게 묶는 것이다.

## 왜 이렇게 정리하는가

- `S2`에서 perspective-aware reading이 direct implementation entry로 고정됐다
- `T1`에서 그 reading을 각 agent pod 관점에서 재실행 가능한 helper로 만들었다
- `T2`에서 completion/progress 문서도 `T3 -> U1` 흐름으로 정렬됐다
- 따라서 지금은 helper를 더 쌓거나 policy를 넓히는 단계가 아니라, 남은 refinement question을 다시 한 번 작게 묶어 entry로 넘기는 단계가 맞다

## 이번에도 계속 보류한 것

- broader multi-replica policy commitment
- health/freshness-aware ranking
- actual fetch endpoint observability field 확장
- retry / recovery policy

## 다음 직접 흐름

1. `U1 - Post-T3 Implementation Entry`
2. `U2 - Post-U1 Execution Cut`
3. 그 다음 completion refresh 또는 backlog review

## 한 줄 결론

`T3`는 perspective-aware reading 이후 남은 refinement question을 다시 작은 entry 범위로 넘기기 위해 backlog를 재축소하는 review 스프린트다.
