# artifact-handoff-poc

한국어: [README.md](README.md)
English: [README.en.md](README.en.md)

`artifact-handoff-poc`은 Kubernetes 랩 클러스터 위에서 node-local artifact handoff를 검증하기 위한 범위를 좁힌 실험 저장소입니다.

이 저장소는 VM 생성이나 Kubernetes 부트스트랩을 담당하지 않습니다. `multipass-k8s-lab`이 랩 인프라 저장소이고, `artifact-handoff-poc`은 그 랩 위에 최소 artifact handoff 스택을 배포하는 실험 저장소입니다.

## 목표

Sprint 1은 한 가지 질문을 검증합니다.

3노드 K8s VM 랩에서 same-node 재사용과 cross-node peer fetch를 포함한 최소 node-local artifact handoff 흐름을 지원할 수 있는가?

## 저장소 경계

- `multipass-k8s-lab`은 VM 라이프사이클, kubeadm 부트스트랩, kubeconfig 내보내기, 재사용 가능한 랩 인프라를 담당합니다.
- `artifact-handoff-poc`은 PoC 구현, Kubernetes 매니페스트, 실험 스크립트, 결과 기록을 담당합니다.
- 이 저장소는 Multipass 프로비저닝, kubeadm 부트스트랩, 호스트 설정 로직을 구현하지 않습니다.

## Sprint 1 범위

포함 범위:

- 노드마다 하나의 `artifact-agent`를 DaemonSet으로 배치
- 최소 중앙 catalog 서비스 하나
- hostPath 기반 node-local artifact 저장소
- parent job이 node A에서 artifact 생성
- same-node child가 node A에서 이를 재사용
- node B의 cross-node child가 node A에서 peer transfer로 가져옴
- 최소 digest 검증과 메타데이터 추적

제외 범위:

- 내구성 있는 스토리지
- 프로덕션 하드닝
- 고급 GC
- CRD/operator 통합
- Cilium 전용 최적화
- 성능 벤치마킹

자세한 내용: [docs/SPRINT1_SCOPE.ko.md](docs/SPRINT1_SCOPE.ko.md)

## 구성

```text
.
├── app/
│   ├── agent/      # DaemonSet이 사용하는 Python HTTP agent
│   └── catalog/    # Deployment가 사용하는 Python HTTP catalog
├── docs/
├── manifests/
│   └── base/       # kustomize baseline
├── scripts/
└── test/
```

## 구성 요소

### artifact-agent

- `hostNetwork: true`로 동작하는 DaemonSet
- `/var/lib/artifact-handoff` 아래에 artifact 저장
- 로컬 조회와 peer fetch를 HTTP로 제공
- catalog에 메타데이터 등록
- 선언된 SHA-256 digest와 artifact 내용이 일치하는지 검증

### catalog

- 단일 Deployment
- 메모리 내 저장소와 `emptyDir` 위의 JSON 스냅샷에 최소 메타데이터 저장
- 추적 항목:
  - `artifactId`
  - `digest`
  - `producerNode`
  - `producerAddress`
  - `localPath`
  - `state`
  - `replicaNodes`

### 워크로드

- `run-same-node.sh`: parent on node A, child on node A
- `run-cross-node.sh`: parent on node A, child on node B

## 전제 조건

1. 형제 저장소로 `multipass-k8s-lab`이 존재해야 합니다.
2. 랩 클러스터는 이미 그 저장소를 통해 준비되어 있어야 합니다.
3. 호스트에 `kubectl`이 설치되어 있어야 합니다.
4. 호스트에 헬퍼 스크립트를 위한 `python3`가 있어야 합니다.

## 빠른 시작

```bash
./scripts/check-lab.sh
./scripts/deploy.sh
./scripts/run-same-node.sh
./scripts/run-cross-node.sh
```

선택적 캐시 재적중 확인:

```bash
./scripts/run-cross-node.sh --second-hit
```

정리:

```bash
./scripts/cleanup.sh
```

## 실행 순서

1. `multipass-k8s-lab`으로 랩 클러스터를 확인합니다.
2. PoC 네임스페이스, catalog, agent를 배포합니다.
3. same-node 재사용을 실행합니다.
4. cross-node peer fetch를 실행합니다.
5. 로그와 [docs/RESULTS.ko.md](docs/RESULTS.ko.md)를 검토합니다.

## 알려진 제한 사항

- catalog 데이터는 내구성이 없습니다.
- artifact 저장소는 hostPath를 직접 사용합니다.
- peer discovery는 주소 기반이며 의도적으로 단순합니다.
- agent 간 통신에 authn/authz 또는 TLS가 없습니다.
- 테스트 잡에서 명시적인 노드 고정을 하는 것 외에 별도 스케줄러 통합이 없습니다.

## 다음 단계

- 메모리 기반 catalog를 더 내구성 있는 저장소로 교체
- 정리 및 eviction 규칙 도입
- 메타데이터 상태 전이와 오류 상태 정형화
- scheduler 힌트나 controller 기반 배치 평가
- 더 풍부한 실패 경로 테스트 추가
