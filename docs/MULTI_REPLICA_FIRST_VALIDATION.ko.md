# MULTI_REPLICA_FIRST_VALIDATION

## 목적

이 문서는 `Sprint K2 - Multi-Replica First Validation`의 첫 live evidence를 고정한다.

## 질문

- `producer`가 깨져 있고
- `first replica`도 사용할 수 없고
- `second replica`는 살아 있을 때
- current source-selection path가 실제로 `second replica`까지 fallback 하는가

## 실행 요약

- artifact id: `multi-replica-k2-20260409`
- producer node: `lab-worker-0`
- first replica node: `lab-worker-1`
- second replica node: `lab-master-0`

실행 방식:

1. [run-multi-replica-prep.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-multi-replica-prep.sh)로 two-replica 상태 준비
2. catalog top-level `producerAddress`를 `http://10.255.255.1:8080`으로 변경
3. first replica address를 `http://10.255.255.2:8080`으로 변경
4. producer node의 local artifact를 삭제해 local hit를 막음
5. producer node에서 다시 `/artifacts/{id}` 호출

## 결과

- 요청 결과:
  - `status=200`
  - `source=peer-fetch`
- producer-node local metadata:
  - `state=replicated`
  - `source=peer-fetch`
  - `producerAddress=http://10.255.255.1:8080`

## 해석

- current source-selection path는 producer candidate와 first replica candidate가 모두 실패한 뒤에도 second replica candidate까지 이어질 수 있다.
- 따라서 multi-replica 상태가 actual live fetch path에서 처음으로 확인됐다.
- 이 스프린트는 broader multi-replica ordering policy 전체를 닫는 것이 아니라, second-replica fallback path가 실제로 존재한다는 첫 evidence를 남긴다.

## 다음 직접 연결점

이 문서 이후 직접 다음 스프린트는 `L1 - Post-K2 Backlog Review`다.
