# dragonfly-vs-artifact-handoff-poc

## 1. 조사 질문

Dragonfly의 어떤 개념이 `artifact-handoff-poc`에 실제로 도움이 되며, 어떤 부분은 현재 프로젝트 범위와 맞지 않는가?

## 2. 핵심 요약

Dragonfly는 대규모 파일/이미지 분배를 위한 peer-based distribution 시스템이다. `dfdaemon` peer, scheduler, seed peer 같은 구조를 통해 중앙 원본 부하를 줄이고 peer 간 전송을 조직한다.

`artifact-handoff-poc`는 Dragonfly와 같은 분배 효율 문제의식을 일부 공유하지만, 중심은 대규모 범용 분배가 아니라 `artifact location awareness`다. 즉 먼저 부모 artifact가 어느 노드에 있는지 알고, 그 정보를 기준으로 same-node reuse 또는 cross-node peer fetch를 결정하는 것이 핵심이다.

따라서 Dragonfly에서 차용할 것은 peer fetch와 fallback 사고방식이지, Dragonfly 전체 제어면이나 범용 분배 플랫폼 구조가 아니다.

## 3. 우리 프로젝트와 닮은 점

- 중앙 원본 또는 중앙 저장소 부하를 줄이려는 문제의식이 있다.
- 이미 어떤 노드가 데이터를 가지고 있다면 그 노드를 활용하려는 관점이 있다.
- peer 간 전송을 fallback 또는 확장 경로로 본다.
- producer/source/peer 역할 구분이 artifact handoff 설계에도 도움이 된다.

## 4. 우리 프로젝트와 다른 점

- Dragonfly는 범용 P2P 분배 시스템이고, 이 저장소는 Kubernetes DAG artifact handoff 검증 저장소다.
- Dragonfly의 핵심은 효율적인 대규모 다운로드 스케줄링이고, 이 저장소의 핵심은 artifact 위치 기록과 위치 기반 결정이다.
- Dragonfly는 scheduler가 parent peer를 선택하는 구조가 중심이지만, 현재 스프린트는 최소 catalog metadata와 명시적 노드 배치로 충분하다.
- Dragonfly는 컨테이너 이미지, 파일 분배, 프록시/미러 같은 넓은 사용처를 겨냥하지만, 이 저장소는 부모 산출물을 자식 워크로드에 넘기는 좁은 handoff 문제를 본다.

## 5. 차용할 것

- peer-based fallback 관점
- producer node를 우선 활용하는 사고방식
- same-node hit를 우선하고, 안 되면 peer fetch로 가는 단계적 흐름
- transfer 주체와 metadata 판단 주체를 분리하는 관점
- digest 기반 무결성 확인의 중요성

## 6. 차용하지 않을 것

- Dragonfly 전체 scheduler/manager/control-plane 구조
- 범용 supernode 또는 seed peer 중심 분배 시스템 설계
- 대규모 조각 단위 스케줄링과 최적 parent peer 선택 로직
- 범용 이미지 배포/레지스트리 미러링 문제를 그대로 가져오는 것

## 7. 현재 스프린트에 바로 연결되는 포인트

- catalog가 `producerNode`, `producerAddress`, `localPath`, `digest`, `state`를 기록해야 한다는 근거가 된다.
- same-node reuse 실패 시 cross-node peer fetch를 필수 fallback으로 두는 판단 근거가 된다.
- producer artifact를 중앙 저장소로 먼저 밀어 넣지 않고, producer node를 first-class source로 취급하는 방향을 지지한다.
- 현재 단계에서는 scheduler 최적화보다 "어디에 무엇이 있는지 먼저 안다"가 더 중요하다는 점을 분명히 해 준다.

## 8. 다음 스프린트 후보 포인트

- peer fetch 실패 시 back-to-source 또는 재시도 정책을 어디까지 둘지 정리
- producer peer 외에 replica node를 metadata에 어떻게 반영할지 검토
- 장기적으로 placement hint 또는 controller 연계 시 Dragonfly류 parent selection 아이디어를 얼마나 단순화해 가져올지 검토

## 참고 기준

- Dragonfly official site: <https://d7y.io/>
- Dragonfly GitHub: <https://github.com/dragonflyoss/dragonfly>
- Scheduler: <https://d7y.io/docs/operations/deployment/applications/scheduler/>
- Dfdaemon: <https://d7y.io/docs/v2.1.0/concepts/terminology/dfdaemon>
