# PROJECT_BASELINE

## 1. 왜 이 저장소가 필요한가

이 저장소는 Kubernetes 기반 DAG 실행 환경에서 부모 노드가 생성한 artifact를 자식 노드에게 넘길 때, 중앙 저장소/PV/PVC 중심 접근 대신 **artifact의 위치를 먼저 인식하고 그 위치를 활용하는 방식**이 가능한지 검증하기 위해 존재한다.

핵심 질문:
- 부모 artifact의 위치를 Kubernetes 환경에서 기록할 수 있는가?
- 자식을 같은 노드에 배치하여 same-node reuse를 유도할 수 있는가?
- 같은 노드 배치가 어려울 때, 생산 노드에서 cross-node peer fetch를 수행할 수 있는가?
- 이 전체 흐름이 3-node Kubernetes VM lab 같은 범위를 좁힌 환경에서 최소 형태로 성립하는가?

즉 이 저장소는 "데이터를 어디로 복사할까"보다, "데이터가 지금 어디에 있는가, 그리고 그 위치를 handoff 결정에 활용할 수 있는가"를 더 본질적인 문제로 본다.

---

## 2. 프로젝트의 출발점

이 저장소는 Dragonfly 같은 peer-based distribution 시스템의 문제의식에서 영감을 받았다.

하지만 목적은 다음과 같다.

- Dragonfly 자체를 재현하지 않는다.
- 범용 P2P 플랫폼을 만들지 않는다.
- Dragonfly류의 locality-aware reuse / peer-based distribution 문제의식을 Kubernetes DAG artifact handoff 문제에 좁혀 적용한다.

핵심 아이디어:
- 중앙 원본/중앙 저장소만 바라보지 않는다.
- 이미 특정 노드에 존재하는 데이터의 위치를 활용한다.
- same-node hit를 우선하고, 필요하면 peer fetch로 확장한다.

참고 기준 링크:
- Dragonfly official site: https://d7y.io/
- Dragonfly GitHub: https://github.com/dragonflyoss/dragonfly
- Dragonfly docs: https://d7y.io/docs/
- Dragonfly blog: https://d7y.io/blog/

---

## 3. 저장소 경계

### multipass-k8s-lab
- VM 기반 Kubernetes 랩 환경 준비
- Multipass VM lifecycle
- kubeadm bootstrap
- kubeconfig export
- 재사용 가능한 3-node lab infrastructure

### artifact-handoff-poc
- 위 랩 위에서 node-local artifact handoff를 실제로 구현하고 검증
- 최소 catalog / agent / manifests / experiment scripts / result docs 포함
- same-node reuse와 cross-node peer fetch를 포함한 location-aware artifact handoff 아이디어를 단계적으로 검증

경계 원칙:
- `artifact-handoff-poc` 안에 Multipass provisioning, kubeadm bootstrap, host preparation logic를 넣지 않는다.
- `multipass-k8s-lab`과 `artifact-handoff-poc`의 책임 경계를 흐리지 않는다.
- 랩 환경 문제와 handoff 의미론 문제를 한 저장소에서 동시에 풀려고 하지 않는다.

---

## 4. Kubernetes 기반 해결 아이디어에 대한 기본 관점

이 프로젝트는 Kubernetes가 이미 제공하는 primitive 위에서 실험할 수 있다고 본다.

### 배치 관련
- `nodeSelector`
- `nodeAffinity`
- `nodeName`

### node-local artifact 저장 관련
- 초기 실험: `hostPath`
- 이후 비교 후보: `local PersistentVolume` 등

### cross-node handoff 관련
- producer node 기준 peer fetch
- same-node 재사용이 어려울 때 fallback 경로로 사용

### metadata / catalog 관련
핵심 제어 지점으로 다음을 본다.

- artifactId
- digest
- producerNode
- producerAddress
- localPath
- state

중요한 점:
- Kubernetes는 배치/스토리지/네트워킹 primitive를 제공한다.
- 하지만 artifact 위치를 기록하고, 그 위치를 기준으로 재사용 또는 fetch를 결정하는 의미론은 이 저장소가 직접 설계/구현해야 한다.
- Cilium 같은 eBPF 기반 CNI/네트워크 최적화 기술은 향후 cross-node 전송 경로를 더 좋게 만들 수 있는 후보일 수 있다.
- 하지만 Cilium은 artifact 위치 기록이나 DAG handoff 의미론 자체를 대신하지 않는다.

failure semantics 메모: [docs/research/peer-fetch-failure-paths.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.ko.md)

---

## 5. 저장소 성격

이 저장소는 단순한 앱 저장소가 아니다.

다음 세 가지를 모두 포함하는 **research-backed validation repository**로 다룬다.

1. 자료 조사
2. 실험 구현
3. 결과 정리

즉, 구현만 하는 저장소로 해석하지 않는다.  
관련 개념을 조사하고, 그 조사 결과가 문서와 구현에 반영되어야 한다.

---

## 6. README 원칙

`README.md`와 `README.en.md`는 설계 전체를 담는 문서가 아니라 저장소의 입구 문서다.

README는 먼저 아래 질문에 답해야 한다.

- 이 저장소는 왜 존재하는가?
- `multipass-k8s-lab`과 어떤 관계인가?
- 어떤 문제를 검증하려는가?
- 왜 PV/PVC 중심 접근 대신 location-aware handoff를 보려 하는가?
- 어떤 실험을 어떻게 실행하는가?
- 현재 스프린트 범위는 어디까지인가?

구현 세부사항, 내부 구성요소 상세, 긴 설계 배경은 `docs/` 아래 문서로 내린다.

## 6.1 문서 이중 언어 원칙

이 저장소의 핵심 문서는 가능하면 한글과 영문을 분리된 두 파일로 유지한다.

원칙:

- 한글 문서는 `.ko.md`
- 영문 문서는 `.md`
- 둘을 한 파일 안에서 혼합하지 않는다.
- 새 핵심 문서를 추가하면 가능한 한 같은 턴에 대응 영문/한글 문서도 같이 만든다.

이 원칙의 목적은 번역 품질을 완벽하게 맞추는 것보다, 저장소 입구 문서, baseline, scope, results, validation history, research note가 두 언어로 모두 추적 가능하도록 유지하는 것이다.

---

## 7. 작업 방식의 기본 원칙

이 저장소의 작업은 세세한 micro-step 위주가 아니라 **스프린트 방식**으로 진행한다.

원칙:
- 작업 전에 먼저 스프린트 단위 계획을 제안한다.
- 한 번의 작업 턴에서는 의미 있는 하나의 스프린트를 완성하는 식으로 진행한다.
- 스프린트 범위는 작게 유지하되, 산출물은 스프린트 단위로 완성한다.

각 스프린트마다 반드시 명시할 것:
1. 스프린트 이름
2. 스프린트 목표
3. 이번 스프린트에서 다룰 범위
4. 이번 스프린트에서 다루지 않을 범위
5. 완료 기준
6. 핵심 리스크
7. 예상 산출물 파일 목록
8. 다음 스프린트로 넘길 항목

---

## 8. 현재 상태 인식

이미 다음 방향은 반영되기 시작한 상태로 본다.

- README는 입구 문서 역할로 조정되기 시작했다.
- `docs/PROJECT_BASELINE*.md` 문서로 저장소 정체성과 경계가 고정되기 시작했다.
- `docs/research/README*.md` 문서로 조사 문서의 중요성이 명시되기 시작했다.

하지만 아직 남은 과제가 있다.

- 실제 research note 문서들은 아직 비어 있거나 초기 상태일 수 있다.
- 기존 `manifests/`, `scripts/`, `app/` 구현이 baseline과 완전히 정합적인지는 아직 별도 점검이 필요하다.
- 따라서 현재는 코드 변경보다 조사/정리/정합성 판단이 더 먼저일 수 있다.

---

## 9. 현재 추천 스프린트

### 추천 Sprint A: Research Baseline Fill
목표:
- 비어 있는 `docs/research/` 계열을 실제 조사 문서로 채우고, 오픈소스/기술 비교 기준선을 만든다.

범위:
- Dragonfly / Kraken / Volcano / Alluxio / JuiceFS / Datashim / Pachyderm / kube-fledged / NodeLocal DNSCache 조사
- nearby-opensource-map
- dragonfly-vs-artifact-handoff-poc
- k8s-locality-and-placement-notes
- node-local-agent-patterns
- catalog-metadata-model 초안

완료 기준:
- 조사 문서 세트가 실제 내용으로 채워진다.
- 차용할 것 / 차용하지 않을 것이 명시된다.
- 현재 스프린트에 바로 적용 가능한 아이디어와 아직 이른 아이디어가 구분된다.

핵심 리스크:
- 너무 넓게 조사해서 문서가 피상적으로 끝날 수 있다.
- 너무 깊게 들어가서 현재 프로젝트와 연결되지 않는 분석으로 흐를 수 있다.

### 추천 Sprint B: Baseline-to-Implementation Gap Review
목표:
- 현재 `app/`, `manifests/`, `scripts/`가 `PROJECT_BASELINE`과 얼마나 맞는지 점검한다.

범위:
- agent/catalog 구조
- metadata 모델
- run-same-node / run-cross-node 흐름
- manifests/base 구조
- docs/SPRINT1_SCOPE와 baseline 표현 정합성

완료 기준:
- 갭 분석 문서 1개 이상 작성
- 구현과 기준선의 일치/불일치가 구분된다.
- 다음 구현 보정 스프린트 후보가 도출된다.

핵심 리스크:
- 기준선 문서와 실제 코드 흐름을 제대로 연결하지 못하면 추상적인 감상 수준으로 끝날 수 있다.

현재 기준으로는 Sprint A를 먼저 수행하고, 그 다음 Sprint B로 넘어가는 방향을 우선 제안한다.
