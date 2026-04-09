# REPLICA_SOURCE_SELECTION_VALIDATION

## 목적

이 문서는 `Sprint F9 - Replica Source-Selection Validation`의 live evidence를 고정하기 위한 메모다.

질문:

- `Sprint F8`에서 `peer_fetch()`의 remote candidate set을 `producer + replicaNodes`로 넓힌 뒤,
- broken producer 상황에서 third-node consumer가 실제로 replica fallback으로 성공하는가?

## 기준 문서

- [REPLICA_SOURCE_SELECTION_MINIMAL_CUT.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/REPLICA_SOURCE_SELECTION_MINIMAL_CUT.ko.md)
- [PRODUCER_BIAS_VALIDATION_KICKOFF.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PRODUCER_BIAS_VALIDATION_KICKOFF.ko.md)
- [run-producer-bias-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-producer-bias-check.sh)

## 실행 방식

1. worker0에서 parent artifact 생성
2. worker1에서 first replica 생성
3. catalog에서 `replicaNodes` populated 확인
4. catalog top-level `producerAddress`만 broken endpoint로 변경
5. producer와 first replica가 아닌 third node(`lab-master-0`)에서 `/artifacts/{id}` 호출

## 실제 확인한 점

- artifact id: `replica-source-select-20260409`
- producer node: `lab-worker-0`
- first replica node: `lab-worker-1`
- third consumer node: `lab-master-0`
- producerAddress는 `http://10.255.255.1:8080`으로 의도적으로 깨져 있었다.
- 그 상태에서도 third-node consumer 결과는:
  - `status=200`
  - `source=peer-fetch`
- third-node local metadata는 아래처럼 남았다.
  - `state=replicated`
  - `source=peer-fetch`
  - `producerNode=lab-worker-0`
  - `producerAddress=http://10.255.255.1:8080`

## 해석

- 현재 cut 이후에는 producer candidate가 실패해도 replica candidate로 넘어갈 수 있다.
- 따라서 `replicaNodes`는 더 이상 단순 observation만이 아니라, 실제 source-selection path에 참여한다.
- 다만 local metadata의 `producerAddress`는 여전히 origin producer 기준으로 유지되므로, 실제 fetch endpoint와는 다를 수 있다.

## 이번 스프린트의 결론

- `replica fallback after producer failure`: pass
- `replica-aware source selection`: first live pass

## 다음 연결점

이제 다음 질문은:

- replica-aware 첫 구현/검증 흐름 이후 어떤 backlog를 다음으로 볼 것인가

로 이동한다.
