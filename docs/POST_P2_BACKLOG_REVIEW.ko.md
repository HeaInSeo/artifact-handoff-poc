# POST_P2_BACKLOG_REVIEW

## 목적

이 문서는 `Sprint Q1 - Post-P2 Backlog Review`에서
`P1`, `P2` 이후 남은 구현 backlog를 다시 가장 작은 질문 단위로 좁히기 위한 review note다.

## 이번 review에서 고정한 것

- `recorded replica order semantics`는 여전히 다음 실제 implementation topic이다
- 하지만 다음 단계에서 더 넓은 multi-replica policy를 열지는 않는다
- 다음 직접 질문은:
  - current implementation이 `producer -> recorded replica order`를 실제 ordered remote iteration semantics로 읽히는지
  - 그리고 그 reading을 다음 implementation entry로 고정할지
  로 제한한다

즉 지금 단계의 핵심은 policy 확장이 아니라 current implementation reading을 더 좁게 정리하는 것이다.

## 계속 보류하는 것

이번 review에서도 아래 항목은 그대로 후순위에 둔다.

- broader multi-replica policy commitment
- health/freshness-aware ranking
- actual fetch endpoint observability field 확장
- retry / recovery policy

## 다음 직접 흐름

이 review 이후 다음 직접 흐름은 아래와 같다.

- `Q2 - Post-Q1 Implementation Entry`
- `R1 - Post-Q2 Execution Cut`

즉 `Q1`은 backlog를 다시 좁히는 단계이고,
`Q2`는 그 결과를 다음 직접 implementation entry로 고정하는 단계다.

## 한 줄 결론

`Q1`은 recorded replica-order question을 broader policy가 아니라 current implementation reading 수준으로 다시 좁히는 backlog review 스프린트다.
