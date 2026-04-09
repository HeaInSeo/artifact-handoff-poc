# POST_J1_VALIDATION_ENTRY

## 목적

이 문서는 `Sprint K1 - Post-J1 Validation Entry`에서 `J1` helper 이후 어떤 multi-replica validation question으로 먼저 들어갈지 고정한다.

`J1`의 역할은 producer + first replica + second replica 상태를 반복 가능하게 준비하는 것이었다.
따라서 `K1`의 역할은 그 준비 상태를 바탕으로 **가장 작은 first validation question**을 하나 고르는 것이다.

## 선택한 first validation question

이번에 고정한 첫 질문은 아래다.

- `producer`와 `first replica`를 순서대로 사용할 수 없게 만들었을 때
- consumer가 `second replica`까지 fallback 해서 성공하는가

짧게 말하면:

- `producer broken`
- `first replica unavailable`
- `second replica present`
- then `GET /artifacts/{id}` should still succeed

## 왜 이 질문을 먼저 고르는가

- current source-selection semantics는 현재 `producer -> replicaNodes` 순서다.
- single-replica fallback은 이미 `F9`에서 확인했다.
- multi-replica에서 가장 작은 다음 질문은 ordering을 완전히 재설계하는 것이 아니라, **candidate iteration이 second replica까지 실제로 이어지는가**를 보는 것이다.

즉 이번 질문은:

- multi-replica ordering policy 전체를 닫지 않고
- 현재 cut가 second replica까지 실제 path를 열었는지 먼저 확인하는 질문이다.

## 이번에 의도적으로 하지 않은 것

- multi-replica preference policy 설계
- replica freshness 비교
- richer observability field 추가
- retry / recovery policy 결합

이 스프린트는 validation entry selection 스프린트다.

## K2 최소 완료 기준

다음 `K2 - Multi-Replica First Validation`의 최소 완료 기준은 아래로 고정한다.

1. [run-multi-replica-prep.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-multi-replica-prep.sh)로 two-replica 상태 준비
2. top-level `producerAddress`를 broken endpoint로 변경
3. first replica를 임시로 사용할 수 없게 만들어 first replica hop도 실패하게 만들기
4. third consumer 또는 별도 consumer에서 artifact GET 수행
5. `200` 응답 또는 equivalent success 확인
6. consumer local metadata와 catalog snapshot을 같이 기록

## 다음 직접 연결점

이 문서 이후 직접 다음 스프린트는 `K2 - Multi-Replica First Validation`이다.
