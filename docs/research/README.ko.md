# Research README

## 목적

`docs/research/`는 구현의 부속물이 아니라, 이 저장소의 핵심 산출물 중 하나인 **자료 조사 결과**를 정리하는 공간이다.

이 저장소는 구현만 하는 프로젝트가 아니라:

1. 자료 조사
2. 실험 구현
3. 결과 정리

를 함께 수행하는 research-backed validation repository다.

따라서 조사 결과는 대화에서만 소비하지 않고, 가능한 한 문서로 남겨 이후 README, baseline, manifests, scripts, app 설계와 연결되도록 한다.

## 문서 이중 언어 원칙

`docs/research/` 아래의 핵심 조사 문서는 가능하면 한글/영문을 분리된 두 파일로 유지한다.

원칙:

- 한글 문서는 `.ko.md`
- 영문 문서는 `.md`
- 한 파일 안에서 두 언어를 같이 쓰지 않는다.
- 새 조사 문서를 만들면 가능한 한 대응 문서도 같은 턴에 함께 만든다.

즉 조사 문서는 "한글만 임시로 쓰고 나중에 정리"하는 방식보다, 처음부터 문서 쌍으로 관리하는 편을 기본으로 본다.

## 조사 원칙

이 프로젝트와 **완전히 동일한** 오픈소스를 찾는 것이 목적은 아니다.
대신 비슷한 문제의식을 가진 오픈소스들을 축별로 조사하고, **차용할 것 / 차용하지 않을 것**을 구분한다.

조사 시 다음 정체성을 유지한다.

- 이 프로젝트를 범용 P2P 플랫폼처럼 오해하지 않는다.
- 이 프로젝트를 단순 storage cache 프로젝트처럼 오해하지 않는다.
- 이 프로젝트를 full workflow engine처럼 오해하지 않는다.
- 이 프로젝트는 **Kubernetes DAG artifact handoff를 위한 location-aware validation repo**라는 정체성을 유지해야 한다.

## 조사 축

### A. peer-based distribution / 분배 계층

대상:

- Dragonfly
- Kraken

조사 포인트:

- peer-based distribution
- 중앙 원본/레지스트리 부하 감소
- producer/peer/source 개념
- scheduler / parent peer 선택 같은 아이디어
- 분배 계층과 workflow-aware handoff의 차이

### B. Kubernetes-native batch scheduling / 배치 계층

대상:

- Volcano

조사 포인트:

- batch / elastic workload scheduling
- genomics / bioinformatics workload 적합성
- placement / scheduling hint 관점
- 향후 artifact-aware placement 실험과의 연결성

### C. data locality / cache / data access 계층

대상:

- Alluxio
- JuiceFS

조사 포인트:

- local cache / near-local access
- Kubernetes에서 data locality를 높이는 방식
- 중앙 저장소 + local cache 모델
- node-local hit / cache sharing 개념

### D. dataset / metadata / lineage 계층

대상:

- Datashim
- Pachyderm

조사 포인트:

- Dataset / metadata / pointer 모델
- data lineage / versioning / pipeline awareness
- artifact metadata catalog와 연결 가능한 개념
- data-centric workflow 사고방식

### E. node-local agent/cache pattern

대상:

- kube-fledged
- NodeLocal DNSCache

조사 포인트:

- node마다 agent/cache를 두는 패턴
- DaemonSet 기반 node-local service pattern
- same-node hit 우선 / 중앙 트래픽 감소 패턴

## 권장 조사 문서

가능하면 아래 문서를 만들거나 갱신한다.

- `docs/research/nearby-opensource-map.ko.md`
- `docs/research/nearby-opensource-map.md`
- `docs/research/dragonfly-vs-artifact-handoff-poc.ko.md`
- `docs/research/dragonfly-vs-artifact-handoff-poc.md`
- `docs/research/k8s-locality-and-placement-notes.ko.md`
- `docs/research/k8s-locality-and-placement-notes.md`
- `docs/research/node-local-agent-patterns.ko.md`
- `docs/research/node-local-agent-patterns.md`
- `docs/research/catalog-metadata-model.ko.md`
- `docs/research/catalog-metadata-model.md`

필요하면 이후 아래 계열도 추가할 수 있다.

- `docs/research/hostpath-vs-localpv.ko.md`
- `docs/research/peer-fetch-failure-paths.ko.md`
- `docs/research/cilium-fit-gap.ko.md`
- `docs/research/dragonfly-with.ko.md`
- `docs/research/dragonfly-with-update-01.ko.md`
- `docs/research/dragonfly-adapter-contract.ko.md`
- `docs/research/dynamic-dag-placement-validation.ko.md`

## 각 조사 문서의 공통 구조

각 조사 문서는 가능하면 아래 구조를 따른다.

1. 조사 질문
2. 핵심 요약
3. 우리 프로젝트와 닮은 점
4. 우리 프로젝트와 다른 점
5. 차용할 것
6. 차용하지 않을 것
7. 현재 스프린트에 바로 연결되는 포인트
8. 다음 스프린트 후보 포인트

## 조사 후 특히 정리해야 할 결론

조사 후에는 아래 질문에 답할 수 있어야 한다.

- artifact-handoff-poc와 가장 가까운 오픈소스 조합은 무엇인가?
- peer-based distribution 관점에서 가장 참고할 대상은 무엇인가?
- Kubernetes 배치/스케줄링 관점에서 가장 참고할 대상은 무엇인가?
- metadata/catalog 관점에서 가장 참고할 대상은 무엇인가?
- node-local daemon pattern 관점에서 가장 참고할 대상은 무엇인가?
- 어떤 프로젝트는 비슷해 보이지만 실제로는 다른 문제를 푸는가?
- 현재 스프린트에서 바로 참고할 개념은 무엇이고, 아직 너무 이른 개념은 무엇인가?

## 현재 우선 조사 순서

현재 기준으로는 아래 순서를 우선 제안한다.

1. `dragonfly-vs-artifact-handoff-poc`
2. `nearby-opensource-map`
3. `k8s-locality-and-placement-notes`
4. `catalog-metadata-model`
5. `node-local-agent-patterns`

이 순서는 고정이 아니라 시작점이다.
현재 스프린트 목표와 리스크에 따라 조정할 수 있다.
