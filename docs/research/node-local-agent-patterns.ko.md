# node-local-agent-patterns

## 1. 조사 질문

왜 `artifact-handoff-poc`는 node마다 agent를 두는 패턴을 우선 고려해야 하며, 그 패턴에서 현재 스프린트에 차용할 핵심은 무엇인가?

## 2. 핵심 요약

현재 스프린트에서 node-local agent는 가장 직접적인 실험 구조다. 이유는 artifact의 실제 저장 위치와 가장 가까운 곳에서 다음을 수행할 수 있기 때문이다.

1. node-local artifact 존재 확인
2. same-node read/reuse 제공
3. remote peer 요청에 대한 fetch source 역할 수행
4. catalog와 node-local 상태 연결

NodeLocal DNSCache와 kube-fledged는 목적은 다르지만, "각 node에 하나의 DaemonSet 기반 서비스가 있고, node-local hit를 우선하며, 중앙 트래픽을 줄인다"는 패턴에서 참고 가치가 있다.

## 3. 우리 프로젝트와 닮은 점

- NodeLocal DNSCache는 각 node에 DNS caching agent를 둬서 local hit를 높이고 중앙 DNS 부담을 줄인다.
- kube-fledged는 node에 필요한 이미지를 미리 확보하거나 node-local image availability를 높이려는 문제의식을 가진다.
- 두 경우 모두 node마다 에이전트 또는 캐시 인스턴스를 두는 것이 핵심 패턴이다.
- `artifact-handoff-poc`도 artifact가 실제로 놓인 node에서 가장 먼저 재사용 가능해야 하므로 같은 형태가 자연스럽다.

## 4. 우리 프로젝트와 다른 점

- NodeLocal DNSCache는 name resolution cache이고 artifact metadata catalog가 아니다.
- kube-fledged는 image pre-pull/cache 쪽에 가깝고, workflow-aware artifact handoff는 아니다.
- 현재 저장소의 agent는 단순 캐시가 아니라 local artifact lookup, peer fetch source, catalog registration을 함께 맡는다.
- 즉 node-local pattern은 비슷하지만 의미론은 더 handoff 중심이다.

## 5. 차용할 것

- node마다 하나의 DaemonSet 인스턴스를 두는 패턴
- node-local hit를 우선하는 사고방식
- 중앙 서비스를 모든 data path의 필수 통과 지점으로 만들지 않는 패턴
- node-local service가 cluster-wide service와 협력하는 구조

## 6. 차용하지 않을 것

- DNS cache 의미론을 artifact handoff에 그대로 덧씌우는 것
- image prefetch나 image cache 문제를 artifact handoff와 동일시하는 것
- agent를 지나치게 무겁게 만들어 scheduler/controller 책임까지 넣는 것
- 모든 로직을 agent에 몰아 catalog 의미론을 약하게 만드는 것

## 7. 현재 스프린트에 바로 연결되는 포인트

- agent는 DaemonSet으로 node당 1개 배치하는 것이 현재 가장 단순하고 설명 가능한 구조다.
- same-node child는 먼저 local agent에 질의하고, 없으면 metadata를 바탕으로 remote peer fetch로 넘어가면 된다.
- catalog는 node-local agent를 대체하지 않고, "어디에 무엇이 있는가"를 알려 주는 control point 역할에 머무르는 것이 좋다.
- 중앙 catalog와 node-local agent의 역할을 분리해야 현재 저장소 정체성이 선명해진다.

## 8. 다음 스프린트 후보 포인트

- agent API를 local lookup / register / peer fetch 관점으로 더 명시화
- catalog와 agent 사이의 최소 state sync 규칙 정리
- agent authn/authz, TLS, rate limiting 같은 hardening 이슈는 언제 다룰지 별도 메모 작성

## 참고 기준

- NodeLocal DNSCache: <https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/>
- kube-fledged: <https://github.com/senthilrch/kube-fledged>
