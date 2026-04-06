# SPRINT1_SCOPE

## 목적

Sprint 1의 목적은 작은 Kubernetes VM 랩에서 artifact handoff의 최소 구조가 성립하는지를 증명하는 것입니다.

목표는 프로덕션 시스템이 아닙니다. 목표는 다음을 보여 주는 작지만 실제적인 베이스라인입니다.

1. parent가 node A에서 artifact를 생성한다.
2. node A의 same-node child가 이를 로컬에서 재사용한다.
3. node B의 cross-node child가 node A의 peer agent로부터 이를 가져온다.
4. digest 검증과 최소 메타데이터가 강제된다.

## 책임 분리

- `multipass-k8s-lab`은 랩 인프라 저장소입니다.
- `artifact-handoff-poc`은 실험 저장소입니다.
- 이 PoC 저장소는 VM 라이프사이클, kubeadm 부트스트랩, 호스트 설정을 담당하지 않습니다.

## 포함 범위

- 노드당 하나의 DaemonSet 기반 node agent
- 최소 중앙 catalog 하나
- hostPath 기반 node-local artifact 저장소
- HTTP 기반 artifact put, get, peer fetch
- same-node 및 cross-node 검증 스크립트
- 스프린트 결과 기록

## 제외 범위

- 내구성 있는 artifact 영속화
- 세밀한 garbage collection
- 프로덕션 보안 태세
- CRD/operator control plane
- Cilium 강제 의존성
- 고성능 벤치마킹

## 최소 데이터 모델

각 artifact 레코드는 다음 필드를 추적합니다.

- `artifactId`
- `digest`
- `producerNode`
- `producerAddress`
- `localPath`
- `state`
- `replicaNodes`

## 성공 기준

- same-node child가 원격 fetch 없이 성공한다.
- cross-node child가 peer fetch 이후 성공한다.
- 요청 시 node B에서 두 번째 실행이 로컬 캐시로 성공할 수 있다.
- digest 불일치는 거부된다.
- 전체 흐름이 `multipass-k8s-lab` 위에서 재현 가능하다.

## 비목표

이번 스프린트는 다음 질문에 답하려는 것이 아닙니다.

- 장기 스토리지 전략
- catalog HA
- 라이프사이클 정책의 완성도
- operator API 형태
- 특정 네트워크 스택 최적화

## 산출물

- 실행 가능한 베이스라인 매니페스트
- 배포 및 정리 스크립트
- same-node 및 cross-node 점검용 시나리오 스크립트
- 관찰된 제약 조건을 담은 스프린트 결과 메모
