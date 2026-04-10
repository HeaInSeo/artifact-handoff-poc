# POST_Q1_IMPLEMENTATION_ENTRY

## 목적

이 문서는 `Sprint Q2 - Post-Q1 Implementation Entry`에서
`Q1`에서 좁힌 다음 구현 질문을 실제 implementation entry로 고정하기 위한 note다.

## 이번 entry에서 고정한 것

다음 직접 implementation topic은 아래와 같이 고정한다.

- current implementation은 `producer -> recorded replica order`를 ordered remote candidate iteration semantics로 읽힌다

이 문장은 broader multi-replica policy promise가 아니다.
현재 단계에서는 “현재 구현을 이렇게 읽고, 다음 execution cut도 이 reading을 확인하는 방향으로 둔다”는 의미다.

## 왜 여기서 entry로 고정하는가

- `Q1`에서 질문 범위는 이미 current implementation reading 수준으로 좁혀졌다
- `P1` probe helper도 이미 준비돼 있다
- 따라서 지금 가장 작은 다음 단계는 policy를 더 설계하는 것이 아니라, 이 reading을 next direct implementation entry로 고정하는 것이다

## 이번 단계에서 계속 열지 않는 것

- broader multi-replica policy commitment
- health/freshness-aware ranking
- actual fetch endpoint observability field 확장
- retry / recovery policy

## 다음 직접 흐름

이 entry 이후 다음 직접 흐름은 아래와 같다.

- `R1 - Post-Q2 Execution Cut`
- `R2 - Post-R1 Completion Refresh`

즉 `R1`은 지금 고정한 reading을 더 직접적으로 관찰하거나 재현하는 최소 execution cut를 정의하는 단계다.

## 한 줄 결론

`Q2`는 `producer -> recorded replica order` reading을 다음 직접 implementation entry로 고정하는 스프린트다.
