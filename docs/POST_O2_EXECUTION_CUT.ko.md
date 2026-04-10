# POST_O2_EXECUTION_CUT

## 목적

이 문서는 `Sprint P1 - Post-O2 Execution Cut`에서
`recorded replica order semantics`를 더 직접적으로 관찰할 수 있게 만드는 최소 execution cut를 고정한다.

## 이번 cut에서 추가한 것

- [run-recorded-replica-order-probe.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-recorded-replica-order-probe.sh)

이 helper는 기존 [run-replica-order-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-replica-order-check.sh) 위에 얇게 올라가는 probe cut다.

실제로 하는 일은 아래와 같다.

1. 기존 ordered fallback check를 그대로 실행
2. catalog record에서 `producerAddress`와 `replicaNodes`의 recorded order를 다시 읽음
3. producer node local metadata를 다시 읽음
4. 위 세 정보를 한 번에 읽을 수 있는 요약 JSON을 출력

## 왜 이 cut가 가장 작은가

- ordering policy 자체를 바꾸지 않는다
- 새로운 replica ranking 규칙을 넣지 않는다
- actual fetch endpoint field를 metadata에 추가하지 않는다
- retry/recovery를 열지 않는다

즉 이번 cut는 다음 validation이나 후속 판단에서
“현재 catalog가 기록한 replica 순서”와
“현재 producer-side metadata 결과”를 더 짧게 같이 읽게 만드는 데만 집중한다.

## 이번에 고정하는 범위

- 다음 후속 스프린트는 completion/progress refresh로 둔다
- 그 이후 backlog review에서 recorded replica order question을 다시 더 좁힌다
- broader multi-replica policy commitment는 아직 열지 않는다

## 한 줄 결론

`P1`은 recorded replica-order semantics를 더 직접적으로 관찰할 수 있게 만드는 최소 probe helper를 추가한 execution cut 스프린트다.
