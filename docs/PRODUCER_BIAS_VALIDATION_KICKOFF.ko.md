# PRODUCER_BIAS_VALIDATION_KICKOFF

## 목적

이 문서는 `Sprint F7 - Producer-Bias Validation Kickoff`의 첫 live evidence를 고정하기 위한 메모다.

질문:

- `replicaNodes`가 실제로 catalog에 기록되고 first replica도 준비된 상태에서,
- non-producer third node consumer는 replica를 source 후보로 보지 않고 여전히 `producerAddress`만 따라가는가?

## 기준 문서

- [REPLICA_AWARE_FIRST_VALIDATION.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_FIRST_VALIDATION.ko.md)
- [REPLICA_AWARE_DECISION_NOTE.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_AWARE_DECISION_NOTE.ko.md)
- [run-producer-bias-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-producer-bias-check.sh)

## 실행 방식

1. worker0에서 parent artifact 생성
2. worker1에서 first replica 생성
3. catalog record의 `replicaNodes` populated 확인
4. catalog top-level `producerAddress`만 의도적으로 깨진 endpoint로 변경
5. producer도 first replica도 아닌 third node(`lab-master-0`)에서 `/artifacts/{id}` 호출

## 실제 확인한 점

- artifact id: `producer-bias-20260408c`
- producer node: `lab-worker-0`
- first replica node: `lab-worker-1`
- third consumer node: `lab-master-0`
- catalog는 여전히 아래를 유지했다.
  - `producerNode=lab-worker-0`
  - `replicaNodes[0].node=lab-worker-1`
  - `replicaNodes[0].state=replicated`
- 하지만 third-node consumer 응답은:
  - `status=404`
  - `error=<urlopen error timed out>`
- consumer local metadata는 아래처럼 남았다.
  - `source=peer-fetch`
  - `state=fetch-failed`
  - `producerAddress=http://10.255.255.1:8080`
  - `lastError=<urlopen error timed out>`

## 해석

- 현재 구현은 third-node consumer에서 local hit가 없으면 peer-fetch로 들어간다.
- 하지만 peer-fetch는 `replicaNodes`를 source 후보로 보지 않고, 여전히 top-level `producerAddress`만 사용한다.
- 그래서 first replica가 살아 있어도 broken producer endpoint만 따라가다가 실패한다.

## 이번 스프린트의 결론

- `producer-only bias`: pass
- `replica-aware source selection`: still not implemented

## 다음 연결점

이제 다음 질문은 더 이상 “bias가 있는가”가 아니라,

- `replicaNodes`를 actual source selection에 연결하는 가장 작은 cut를 어떻게 둘 것인가

로 좁혀진다.
