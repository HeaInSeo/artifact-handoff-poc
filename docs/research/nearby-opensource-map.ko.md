# nearby-opensource-map

## 1. 조사 질문

`artifact-handoff-poc`와 정확히 같은 프로젝트는 없을 때, 어떤 오픈소스 조합이 가장 가까운 참고 축을 제공하는가?

## 2. 핵심 요약

이 저장소와 가장 가까운 단일 오픈소스는 없다. 대신 아래 조합이 가장 가깝다.

- 분배 계층 참고: Dragonfly, Kraken
- 배치/스케줄링 참고: Volcano
- locality/cache 참고: Alluxio, JuiceFS
- metadata/lineage 참고: Datashim, Pachyderm
- node-local daemon pattern 참고: kube-fledged, NodeLocal DNSCache

핵심은 이들을 조합해 보되, `artifact-handoff-poc`를 그 중 어느 하나의 축소판으로 오해하지 않는 것이다.

## 3. 우리 프로젝트와 닮은 점

- Dragonfly, Kraken은 peer-based distribution과 source offload 관점을 제공한다.
- Volcano는 batch 워크로드와 placement/scheduling 관점을 제공한다.
- Alluxio, JuiceFS는 data locality와 near-local access 관점을 제공한다.
- Datashim, Pachyderm은 dataset pointer, metadata, lineage 관점을 제공한다.
- kube-fledged, NodeLocal DNSCache는 node-local agent/cache를 DaemonSet 패턴으로 운영하는 관점을 제공한다.

## 4. 우리 프로젝트와 다른 점

- Dragonfly/Kraken은 범용 분배 시스템이지 DAG artifact handoff 의미론 저장소가 아니다.
- Volcano는 스케줄러이지만 artifact metadata catalog를 제공하지 않는다.
- Alluxio/JuiceFS는 데이터 접근/캐시 계층이지 handoff decision layer가 아니다.
- Datashim/Pachyderm은 dataset/lineage에 강하지만 현재 스프린트 범위보다 훨씬 무거울 수 있다.
- kube-fledged/NodeLocal DNSCache는 node-local daemon pattern에는 가깝지만 artifact catalog 의미론은 없다.

## 5. 차용할 것

- Dragonfly/Kraken: peer/source/fallback 관점
- Volcano: placement hint를 placement primitive와 연결하는 사고방식
- Alluxio/JuiceFS: locality를 높이기 위한 node-local 경로 활용 관점
- Datashim/Pachyderm: metadata pointer와 lineage를 별도 제어면으로 보는 관점
- kube-fledged/NodeLocal DNSCache: node마다 에이전트를 두는 DaemonSet 패턴

## 6. 차용하지 않을 것

- Dragonfly/Kraken의 대규모 분배 제어면 전체
- Volcano의 독자 스케줄러 도입을 현재 스프린트에 바로 넣는 것
- Alluxio/JuiceFS의 중앙 저장소 + 범용 캐시 시스템 전체
- Pachyderm 수준의 전체 데이터 버전관리/파이프라인 시스템
- Datashim의 dataset CRD 전체를 현재 스프린트에 바로 끌어오는 것

## 7. 현재 스프린트에 바로 연결되는 포인트

- 현재 스프린트의 가장 직접적인 조합은 `Dragonfly + Kubernetes placement primitive + node-local agent pattern`이다.
- metadata 모델은 `Datashim/Pachyderm`에서 영감을 받되, 현재는 최소 pointer 수준으로 유지하는 것이 맞다.
- storage/cache 계층은 `Alluxio/JuiceFS`처럼 크게 가지 않고, 우선 `hostPath` 기반 최소 검증으로 좁히는 것이 맞다.
- 현재 단계에서 가장 가까운 레퍼런스 조합은 "Dragonfly의 문제의식 + Volcano가 보여 주는 placement 시야 + NodeLocal DNSCache식 node-local DaemonSet 패턴"이라고 볼 수 있다.

## 8. 다음 스프린트 후보 포인트

- `catalog-metadata-model` 문서에서 Datashim/Pachyderm와의 공통점과 차이를 더 정밀하게 정리
- `node-local-agent-patterns` 문서에서 kube-fledged와 NodeLocal DNSCache 패턴을 구체화
- `hostpath-vs-localpv` 문서에서 Alluxio/JuiceFS가 locality를 다루는 방식과 우리 실험 범위를 비교

## 참고 기준

- Dragonfly: <https://d7y.io/>
- Kraken: <https://github.com/uber/kraken>
- Volcano: <https://volcano.sh/en/docs/v1-12-0/unified_scheduling/>
- Alluxio on Kubernetes: <https://documentation.alluxio.io/os-en/kubernetes/running-alluxio-on-kubernetes>
- JuiceFS cache: <https://juicefs.com/docs/csi/guide/cache/>
- Datashim: <https://datashim.io/>
- Pachyderm basic concepts: <https://docs.pachyderm.io/products/mldm/latest/learn/basic-concepts/>
- kube-fledged: <https://github.com/senthilrch/kube-fledged>
- NodeLocal DNSCache: <https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/>
