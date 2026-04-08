# k8s-locality-and-placement-notes

## 1. 조사 질문

현재 스프린트 범위에서 Kubernetes의 어떤 locality/placement primitive가 `artifact location awareness`를 실제 handoff 결정으로 연결하는 데 가장 적합한가?

## 2. 핵심 요약

현재 스프린트에서는 Kubernetes 기본 primitive만으로도 충분하다.

- 가장 직접적인 배치 수단: `nodeName`, `nodeSelector`, `nodeAffinity`
- 가장 단순한 node-local 저장 수단: `hostPath`
- 이후 비교 후보: `local PersistentVolume`

Volcano는 batch scheduling과 placement 관점에서 참고할 가치가 있지만, 지금 당장 도입할 시스템은 아니다. Alluxio와 JuiceFS는 locality와 cache를 더 풍부하게 다루지만, 현재 스프린트의 핵심 질문인 "artifact 위치를 알고 handoff 결정에 쓰는가"를 직접 대신하지는 않는다.

## 3. 우리 프로젝트와 닮은 점

- Volcano는 batch/AI 워크로드에서 placement를 중요하게 다룬다.
- Alluxio는 worker local storage와 short-circuit/local access를 중요하게 본다.
- JuiceFS는 hostPath 기반 local cache와 Pod 이동 시 locality trade-off를 명시적으로 다룬다.
- Kubernetes 자체도 `nodeAffinity`와 local volume을 통해 locality-aware 배치와 저장을 일부 표현할 수 있다.

## 4. 우리 프로젝트와 다른 점

- Volcano는 배치 스케줄러이지 artifact 위치 catalog는 아니다.
- Alluxio/JuiceFS는 데이터 접근 성능과 캐시 효율에 무게가 크고, 현재 저장소의 handoff 의미론과는 다르다.
- `artifact-handoff-poc`는 먼저 location metadata를 알고, 그 결과를 배치와 fetch에 연결하는 제어층을 검증한다.
- 즉 placement primitive는 수단이고, 의미론은 catalog/decision layer에 있다.

## 5. 차용할 것

- 현재 스프린트에서는 `nodeName`, `nodeSelector`, `nodeAffinity`로 same-node placement를 명시적으로 검증
- `hostPath`로 node-local artifact 존재를 빠르게 증명
- 이후 `local PV` 비교 시 `nodeAffinity`가 storage와 placement를 어떻게 결합하는지 참고
- placement는 scheduler 전체 교체보다 기존 Kubernetes primitive 조합으로 먼저 검증

## 6. 차용하지 않을 것

- 현재 스프린트에 Volcano 도입
- 현재 스프린트에 Alluxio/JuiceFS 같은 중앙 저장소 + 범용 캐시 계층 도입
- storage/cache 최적화 문제를 handoff 의미론보다 앞세우는 것
- placement 최적화가 metadata/location 결정층을 대체한다고 보는 것

## 7. 현재 스프린트에 바로 연결되는 포인트

- parent가 만든 `producerNode`를 catalog에 기록하고, child manifest 또는 스크립트가 이를 이용해 same-node placement를 시도하는 흐름이 현재 최적 경로다.
- same-node placement 실패 또는 불가 시에는 cross-node peer fetch로 넘어가는 2단 구조가 자연스럽다.
- `hostPath`는 가장 빠른 초기 검증 수단이지만, 결과 문서에는 portability와 운영 제약을 분명히 적어야 한다.
- 지금 단계에서 중요한 것은 고급 스케줄링이 아니라 "metadata가 placement/fetch 결정을 실제로 바꾸는가"다.

## 8. 다음 스프린트 후보 포인트

- `hostPath`와 `local PV` 비교 메모 작성
- placement hint를 선언적으로 줄 수 있는 방법 검토
- scheduler/controller 연계가 필요해지는 시점을 별도 문서로 정리

## 참고 기준

- Volcano unified scheduling: <https://volcano.sh/en/docs/v1-12-0/unified_scheduling/>
- Alluxio on Kubernetes: <https://documentation.alluxio.io/os-en/kubernetes/running-alluxio-on-kubernetes>
- JuiceFS CSI cache: <https://juicefs.com/docs/csi/guide/cache/>
- Kubernetes NodeLocal DNSCache: <https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/>
