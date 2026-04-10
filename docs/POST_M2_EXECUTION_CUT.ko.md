# POST_M2_EXECUTION_CUT

## 목적

이 문서는 `Sprint N1 - Post-M2 Execution Cut`에서
multi-replica ordering semantics를 다음 단계에서 바로 실험할 수 있게 만드는 최소 execution cut를 고정한다.

## 이번 cut에서 추가한 것

- [run-replica-order-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-replica-order-check.sh)

이 helper는 아래를 한 번에 준비한다.

1. producer + first replica + second replica 상태 준비
2. catalog의 recorded replica order 출력
3. `producerAddress`와 first replica address를 broken endpoint로 치환
4. producer node local copy 삭제
5. producer node 요청을 다시 발생시켜 ordered candidate iteration을 관찰

## 왜 이 cut가 가장 작은가

- ordering policy 자체를 아직 바꾸지 않는다.
- health scoring이나 freshness scoring도 넣지 않는다.
- actual fetch endpoint field도 추가하지 않는다.

즉 이번 cut는
현재 code path가 `producer -> first replica -> second replica`
순으로 이어질 수 있는지를 반복 가능하게 만드는 helper에만 집중한다.

## 이번에 고정하는 범위

- 다음 live validation은 recorded replica order가 실제 candidate iteration 의미를 가지는지 확인하는 데 둔다.
- broader multi-replica policy 설계는 아직 열지 않는다.
- retry/recovery는 이번 스프린트에서도 건드리지 않는다.

## 한 줄 결론

`N1`은 multi-replica ordering semantics를 위한 첫 execution helper를 추가한 스프린트다.
