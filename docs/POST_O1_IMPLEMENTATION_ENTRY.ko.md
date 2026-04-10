# POST_O1_IMPLEMENTATION_ENTRY

## 목적

이 문서는 `O1`에서 좁힌 다음 구현 질문을 실제 implementation entry로 고정하기 위한 note다.

이번 단계의 목적은 broader multi-replica policy를 설계하는 것이 아니라, 현재 구현이 `recorded replica order`를 실제 remote candidate iteration 의미로 가지는지 다음 직접 구현 질문으로 여는 것이다.

## 현재까지 닫힌 것

- `producer -> replicaNodes` candidate set은 이미 구현에 반영됨
- broken producer 이후 single-replica fallback은 실검증으로 확인됨
- broken producer + broken first replica 이후 second-replica fallback도 실검증으로 확인됨
- recorded replica order를 다시 관찰할 수 있는 최소 helper cut도 준비됨

즉 이제 남은 가장 작은 질문은 multi-replica가 가능한가가 아니라, 현재 implementation semantics를 어디까지 읽을 것인가다.

## 이번에 고정하는 다음 구현 질문

다음 직접 implementation question은 아래와 같이 고정한다.

- 현재 구현은 `producer -> recorded replica order`를 실제 remote candidate iteration 의미로 가진다

이 문장은 아직 broader policy promise가 아니다.
현재 단계에서는 “현재 구현을 이렇게 읽고, 다음 execution cut도 이 질문을 확인하는 방향으로 둔다”는 의미다.

## 이번 단계에서 열지 않는 것

이번 implementation entry에서는 아래 항목을 계속 보류한다.

- retry / recovery policy
- health/freshness-aware ranking
- actual fetch endpoint observability field 확장
- broader multi-replica policy commitment

## 다음 직접 후속 단계

이 entry 이후의 다음 직접 스프린트는 아래와 같다.

- `P1 - Post-O2 Execution Cut`

다음 cut의 목표는 recorded replica order가 실제로 의미를 가지는지 더 직접적으로 관찰할 최소 helper 또는 validation cut를 고정하는 것이다.

## 한 줄 결론

`O2`는 `recorded replica order semantics`를 다음 직접 implementation topic으로 고정하는 entry 스프린트다.
