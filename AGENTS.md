# AGENTS.md

## 목적

이 저장소는 Kubernetes 기반 DAG 실행 환경에서 부모 노드가 생성한 artifact를 자식 노드에게 넘길 때, 중앙 저장소/PV/PVC 중심 접근 대신 **artifact 위치를 먼저 인식하고 그 위치를 활용하는 방식**이 가능한지 검증하는 PoC 저장소다.

핵심 개념:
- data location awareness
- locality-aware handoff
- same-node reuse + cross-node fallback

이 저장소는 단순 file transfer 앱이 아니라, **Kubernetes DAG artifact handoff를 위한 location-aware validation repo**로 다룬다.

---

## 저장소 경계

### multipass-k8s-lab
- VM 기반 Kubernetes 랩 환경 준비
- Multipass VM lifecycle
- kubeadm bootstrap
- kubeconfig export

### artifact-handoff-poc
- 위 랩 위에서 node-local artifact handoff를 구현/검증
- 최소 catalog / agent / manifests / experiment scripts / result docs 포함

경계 원칙:
- `artifact-handoff-poc` 안에 Multipass provisioning, kubeadm bootstrap, host preparation logic를 넣지 않는다.
- `multipass-k8s-lab`과 `artifact-handoff-poc`의 책임 경계를 흐리지 않는다.

---

## 먼저 읽을 문서

작업 전에 아래 문서를 먼저 읽고 기준선을 고정한다.

- `docs/PROJECT_BASELINE.ko.md`
- `docs/PROJECT_BASELINE.md`
- `docs/research/README.ko.md`
- `docs/research/README.md`

---

## README 원칙

`README.md`와 `README.en.md`는 저장소의 입구 문서다.

README는 먼저 아래 질문에 답해야 한다.

- 이 저장소는 왜 존재하는가?
- `multipass-k8s-lab`과 어떤 관계인가?
- 어떤 문제를 검증하려는가?
- 왜 PV/PVC 중심 접근 대신 location-aware handoff를 보려 하는가?
- 어떤 실험을 어떻게 실행하는가?
- 현재 스프린트 범위는 어디까지인가?

구현 세부사항, 긴 설계 배경, 조사 내용은 `docs/` 아래 문서로 내린다.

---

## 작업 원칙

- 이 프로젝트를 범용 P2P 플랫폼처럼 오해하지 않는다.
- 이 프로젝트를 단순 storage cache 프로젝트처럼 오해하지 않는다.
- 이 프로젝트를 full workflow engine처럼 오해하지 않는다.
- 구현뿐 아니라 자료 조사와 문서 정리도 핵심 산출물로 다룬다.
- 코드 변경보다 조사/정리/정합성 판단이 먼저일 수 있다.
- 큰 작업은 micro-step보다 **스프린트 단위**로 계획하고 수행한다.

---

## 스프린트 방식

작업 전에는 먼저 아래를 제안한다.

1. 스프린트 이름
2. 스프린트 목표
3. 이번 스프린트에서 다룰 범위
4. 다루지 않을 범위
5. 완료 기준
6. 핵심 리스크
7. 예상 산출물 파일 목록
8. 다음 스프린트로 넘길 항목

한 번의 작업 턴에서는 의미 있는 하나의 스프린트를 완성하는 식으로 진행한다.

---

## 결과 보고 형식

작업 후에는 아래 형식으로 정리한다.

1. 이번에 수행한 스프린트 이름
2. 스프린트 목표와 완료 기준
3. 변경 파일 목록
4. 조사/판단한 핵심 근거
5. 이번 산출물이 프로젝트 목표와 어떻게 연결되는지
6. 남은 리스크 / 열려 있는 질문
7. 다음 스프린트 제안