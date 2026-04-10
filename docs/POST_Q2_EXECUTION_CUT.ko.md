# POST_Q2_EXECUTION_CUT

## 목적

이 문서는 `Sprint R1 - Post-Q2 Execution Cut`에서
`Q2`에서 고정한 `producer -> recorded replica order` reading을 더 직접 재현할 수 있게 만드는 최소 execution cut를 고정한다.

## 이번 cut에서 추가한 것

- [run-recorded-replica-order-entry-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-recorded-replica-order-entry-check.sh)

이 helper는 기존 [run-recorded-replica-order-probe.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-recorded-replica-order-probe.sh) 위에 얇게 올라가는 wrapper cut다.

실제로 하는 일은 아래와 같다.

1. 기존 recorded replica-order probe를 그대로 실행
2. catalog record를 다시 읽음
3. `producer -> recorded replica order` reading 기준의 expected remote candidate order를 JSON으로 출력

즉 이 helper는 current implementation reading을 문서 설명이 아니라, 다시 실행 가능한 해석 출력으로 보여 주는 데 집중한다.

## 왜 이 cut가 가장 작은가

- ordering policy를 바꾸지 않는다
- replica ranking rule을 추가하지 않는다
- actual fetch endpoint field를 추가하지 않는다
- retry/recovery를 열지 않는다

이번 cut는 현재 reading을 더 직접 읽게 만드는 wrapper helper까지만 담당한다.

## 이번에 고정하는 범위

- 다음 후속 스프린트는 `R2 - Post-R1 Completion Refresh`
- 그 다음 backlog review에서 이 reading 이후 남은 구현 질문을 다시 좁힌다
- broader multi-replica policy commitment는 계속 보류한다

## 한 줄 결론

`R1`은 `producer -> recorded replica order` reading을 재실행 가능한 출력으로 보여 주는 최소 wrapper helper cut를 추가한 스프린트다.
