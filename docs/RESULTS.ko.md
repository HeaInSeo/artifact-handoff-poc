# RESULTS

## 요약

이 문서는 Sprint 1에 대한 실제 검증 결과를 기록합니다.

## 환경

- 랩 저장소: `../multipass-k8s-lab`
- 기대 클러스터 형태: `1 control-plane + 2 workers`
- PoC 네임스페이스: `artifact-handoff`

## 관찰된 상태

- `2026-04-03`: `multipass-k8s-lab/scripts/k8s-tool.sh status` 초기 확인 시 `k8s-master-0`만 실행 중이었습니다.
- `2026-04-03`: `multipass-k8s-lab/scripts/k8s-tool.sh up`는 설정된 이미지 별칭 `rocky-8`을 Multipass가 해석하지 못해 3노드 bring-up 전에 실패했습니다.
- `2026-04-03`: 남아 있던 단일 노드 클러스터에서 부분 검증을 진행하기 위해 기존 `k8s-master-0` VM에서 kubeconfig를 직접 내보냈습니다.
- `2026-04-03`: 그 단일 노드 클러스터에 `artifact-handoff` 네임스페이스로 PoC 베이스라인을 성공적으로 배포했습니다.

## Same-Node Reuse

- 상태: 현재 사용 가능한 단일 노드 클러스터에서 통과
- Parent job `parent-same-node`가 `demo-artifact`를 등록
- Child job `child-same-node`가 성공적으로 완료
- 관찰된 child 출력:
  - payload: `artifact-handoff sprint1 sample payload`
  - source: `local`
  - digest: `d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1`
- 실행 후 catalog 내용:
  - `artifactId`: `demo-artifact`
  - `producerNode`: `k8s-master-0`
  - `producerAddress`: `http://10.87.127.29:8080`
  - `state`: `ready`
  - `replicaNodes`: `[]`

## Cross-Node Peer Fetch

- 상태: 랩 준비 상태에 의해 차단됨
- 실제 스크립트 결과: `need at least two schedulable nodes for cross-node validation`
- 필요한 다음 단계: 의도한 `1 control-plane + 2 workers` 클러스터가 먼저 올라오도록 `multipass-k8s-lab`의 이미지/베이스라인 bring-up을 수정해야 함

## Second-Hit Cache

- 상태: 실행하지 않음
- 이유: 두 번째 노드가 없어 cross-node fetch를 검증할 수 없었음

## 참고

- 이 저장소의 베이스라인과 스크립트는 `multipass-k8s-lab`이 준비한 랩 클러스터를 대상으로 동작하도록 설계되었습니다.
- `scripts/check-lab.sh`는 기본적으로 `MIN_NODES=3`을 사용하며, 의도한 랩 형태가 없으면 즉시 실패합니다.
- 남아 있던 단일 노드 클러스터에서 부분 디버깅을 진행할 때는 same-node 검증만 수행하기 위해 `MIN_NODES=1`을 사용했습니다.
- 실제 3노드 랩에서 same-node와 cross-node가 모두 성공하기 전까지는 전체 스프린트 수락 조건이 완전히 충족된 것은 아닙니다.
