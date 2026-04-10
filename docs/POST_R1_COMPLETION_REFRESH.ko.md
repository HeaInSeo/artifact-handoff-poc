# POST_R1_COMPLETION_REFRESH

## 목적

이 문서는 `Q2`, `R1` 이후 completion view와 progress board를 다시 같은 남은 질문 세트로 맞추기 위한 짧은 refresh note다.

## 이번에 고정한 것

- `R1`은 `producer -> recorded replica order` reading을 ordered remote candidate output으로 재실행할 수 있게 만드는 최소 wrapper helper cut로 닫는다.
- 따라서 다음 직접 질문은 더 이상 `R1`이 아니라 `S1 - Post-R2 Backlog Review`다.
- 그 다음 직접 implementation entry는 `S2 - Post-S1 Implementation Entry`로 둔다.

## 왜 이렇게 정리하는가

- `Q2`에서 current implementation reading은 이미 direct implementation entry로 고정됐다.
- `R1`에서는 그 reading을 반복 가능하게 재출력하는 최소 helper까지 추가됐다.
- 그래서 지금 단계의 남은 직접 질문은 같은 reading을 다시 entry로 반복하는 것이 아니라, 그 이후 backlog를 다시 좁히는 것이다.

## 이번 단계에서 여전히 하지 않는 것

- broader multi-replica policy commitment
- health/freshness-aware ranking
- actual fetch endpoint observability field 확장
- retry / recovery policy 구현

## 다음 직접 흐름

1. `S1 - Post-R2 Backlog Review`
2. `S2 - Post-S1 Implementation Entry`
3. 그 다음 execution cut 또는 validation cut
