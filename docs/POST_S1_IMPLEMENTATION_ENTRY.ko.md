# POST_S1_IMPLEMENTATION_ENTRY

## 목적

이 문서는 `Sprint S2 - Post-S1 Implementation Entry`에서
`S1`에서 좁힌 다음 구현 질문을 실제 implementation entry로 고정하기 위한 note다.

## 이번 entry에서 고정한 것

다음 직접 implementation topic은 아래와 같이 고정한다.

- current implementation은 catalog record를 **consumer perspective-aware remote candidate order**로 읽는다
- 이 reading은 구체적으로 `producer -> recorded replica order`, 단 `self address`와 duplicate address를 제외하는 현재 `fetch_candidates()` 의미를 가리킨다

즉 현재 단계의 핵심은 broader ordering policy를 설계하는 것이 아니라,
이미 들어가 있는 source-selection 로직을 “consumer 관점에서 어떻게 읽어야 하는가”를 다음 cut 기준으로 고정하는 것이다.

## 왜 여기서 entry로 고정하는가

- `Q2`, `R1`까지는 `producer -> recorded replica order` reading을 catalog output 기준으로 재실행 가능하게 만들었다
- 하지만 실제 fetch candidate iteration은 current node 주소를 제외하는 consumer 관점을 함께 읽어야 더 정확하다
- 따라서 지금 가장 작은 다음 단계는 policy를 넓히는 것이 아니라, 이 perspective-aware reading을 next direct implementation entry로 고정하는 것이다

## 이번 단계에서 계속 열지 않는 것

- broader multi-replica policy commitment
- health/freshness-aware ranking
- actual fetch endpoint observability field 확장
- retry / recovery policy

## 다음 직접 흐름

이 entry 이후 다음 직접 흐름은 아래와 같다.

- `T1 - Post-S2 Execution Cut`
- 그 다음 completion refresh 또는 backlog review

즉 `T1`의 목표는 지금 고정한 perspective-aware reading을 다시 실행 가능한 최소 helper cut로 보여 주는 것이다.

## 한 줄 결론

`S2`는 current implementation을 `consumer perspective-aware producer -> recorded replica order` semantics로 읽는다는 점을 다음 직접 implementation entry로 고정하는 스프린트다.
