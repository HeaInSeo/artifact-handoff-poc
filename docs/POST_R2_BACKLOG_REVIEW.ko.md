# POST_R2_BACKLOG_REVIEW

## 목적

이 문서는 `R1`, `R2` 이후 남은 구현 backlog를 다시 가장 작은 질문 단위로 좁히기 위한 review note다.

## 이번에 고정한 것

- `producer -> recorded replica order` reading은 direct implementation entry와 replayable helper까지 이미 확보됐다.
- 따라서 지금 남은 가장 작은 질문은 같은 reading을 더 넓히는 것이 아니라, 그 reading을 다음 implementation entry에서 어떤 범위로 유지할지 다시 고정하는 것이다.
- 다음 직접 핵심 스프린트는 `S2 - Post-S1 Implementation Entry`로 둔다.

## 왜 이렇게 정리하는가

- `Q2`에서 reading은 direct implementation entry로 고정됐다.
- `R1`에서 ordered-candidate replay helper가 추가됐다.
- `R2`에서 completion/progress 정렬도 끝났다.
- 따라서 지금은 helper를 더 쌓는 단계가 아니라, 남은 구현 질문을 다시 한 번 작게 묶어 entry로 넘기는 단계가 맞다.

## 이번에도 계속 보류한 것

- broader multi-replica policy commitment
- health/freshness-aware ranking
- actual fetch endpoint observability field 확장
- retry / recovery policy

## 다음 직접 흐름

1. `S2 - Post-S1 Implementation Entry`
2. `T1 - Post-S2 Execution Cut`
3. 그 다음 completion refresh 또는 backlog review
