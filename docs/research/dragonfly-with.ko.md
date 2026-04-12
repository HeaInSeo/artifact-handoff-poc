# dragonfly-with

## 1. 조사 질문

`artifact-handoff-poc`가 Dragonfly를 실제로 포크해서 이 프로젝트 일부로 적용할 수 있는가? 가능하다면 그 경계는 어디까지가 맞는가?

## 2. 핵심 요약

2026년 4월 12일 기준으로 현실적인 답은 아래와 같다.

- **조건부 가능**: Dragonfly를 교체 가능한 distribution backend로 보고, 이 프로젝트의 DAG handoff 의미론은 바깥에 둘 경우
- **깊은 포크는 비권장**: catalog 의미론, workflow policy, placement logic, artifact handoff control을 Dragonfly 내부에 밀어 넣으려는 경우

유효한 접점은 **distribution layer** 쪽이다.

- `dfcache import/export/stat`
- `dfdaemon` node-local runtime
- preheat/task 계열 Manager Open API

맞지 않는 접점은 **workflow/control layer** 쪽이다.

- artifact catalog authority
- DAG handoff용 producer/replica semantics
- same-node reuse를 위한 placement intent
- 이 저장소 고유의 orphan/cleanup policy

따라서 현실적인 확장 방향은 아래와 같다.

1. `artifact-handoff-poc`의 control-plane semantics는 Dragonfly 바깥에 둔다
2. Dragonfly는 artifact transport와 cache reuse를 담당하는 optional backend adapter로 쓴다
3. adapter boundary로 표현할 수 없는 요구가 생기기 전에는 deep fork를 피한다

## 3. 우리 프로젝트와 닮은 점

- Dragonfly는 파일, 이미지, OCI artifact 등 payload를 P2P로 분배/가속하는 시스템이다.
- Kubernetes 위에서 동작하고, `dfdaemon`을 통해 node-local daemon 패턴을 이미 가진다.
- `dfcache import/export/stat`로 파일 중심 인터페이스를 이미 제공한다.
- Manager Open API를 통해 preheat/task 계열 제어면을 이미 제공한다.

즉 아래 문제의식은 서로 맞닿아 있다.

- producer 측에 데이터가 이미 존재한다
- 항상 중앙 원본으로 가지 않고 peer-to-peer 재사용을 시도한다
- node-local / cross-node 전달을 상위 workflow semantics와 분리할 수 있다

## 4. 우리 프로젝트와 다른 점

- Dragonfly는 DAG artifact handoff 프로젝트가 아니라 범용 distribution 시스템이다.
- Dragonfly는 delivery/acceleration을 최적화하고, 이 저장소는 **location-aware handoff decision**을 최적화한다.
- Dragonfly의 기본 모델은 우리 catalog의 `producerNode`, `producerAddress`, `replicaNodes`, failure semantics를 대신하지 않는다.
- Dragonfly는 distribution과 cache reuse에 강하지만, 어떤 child task가 어떤 parent artifact를 어떻게 받아야 하는지까지 이 저장소 대신 결정해 주지는 않는다.

이 차이 때문에 deep fork는 Dragonfly에 원래 설계 중심이 아닌 의미론을 짊어지게 만든다.

## 5. 차용할 것

- 파일 수준 artifact transport 표면으로서 `dfcache import/export/stat`
- node-local runtime/transport endpoint로서 `dfdaemon`
- optional preheat/task control surface로서 Manager Open API
- distribution layer와 상위 orchestration을 분리하는 관점
- data movement를 workflow 프로젝트 내부에서 재구현하지 않고 전문 backend에 위임하는 관점

## 6. 차용하지 않을 것

- workflow-specific artifact policy를 담는 장소로서의 Dragonfly scheduler/manager internals
- 현재 PoC semantics를 표현하기 위해 peer-selection/scheduling internals를 깊게 수정하는 것
- Dragonfly의 더 넓은 제품 범위를 이 저장소의 catalog/control plane 대체물로 쓰는 것
- extension point 안정성을 검증하기 전에 plugin-first 접근으로 낙관하는 것

## 7. 포크 적합성 판단

### 권장되는 적합 형태

가장 안전한 포크/적용 형태는 아래와 같다.

- 패키징, 얇은 adapter 코드, 좁은 운영 통합이 필요할 때만 포크
- 포크는 얕게 유지
- 이 저장소의 catalog, placement intent, handoff semantics는 Dragonfly 바깥에 유지

즉 제품 계약은 대략 아래처럼 남아 있어야 한다.

- `Put artifact into distributable backend`
- `Ensure artifact on node`
- `Stat artifact availability`
- `Warm artifact set`
- `Evict artifact`

Dragonfly는 이 연산의 backend가 될 수 있지만, 계약의 소유권은 `artifact-handoff-poc`에 있어야 한다.

### 비권장 형태

위험한 포크/적용 형태는 아래와 같다.

- catalog authority를 Dragonfly manager 안으로 밀어 넣기
- DAG semantics를 scheduler internals 안으로 밀어 넣기
- internal peer-selection detail을 곧 workflow policy로 취급하기
- Dragonfly를 artifact handoff decision의 system of record처럼 다루기

이 경로는 업그레이드와 강하게 결합된 hybrid product를 만들 가능성이 높다.

## 8. 지금 업스트림에서 중요한 신호

2026년 4월 12일 기준으로 확인한 신호는 아래와 같다.

- 공식 문서에서 확인한 reference page는 `v2.4.0` 기준으로 게시돼 있다
- GitHub repository main page에는 최신 release가 **2026년 4월 10일 `v2.4.4-rc.0`**로 보인다
- GitHub release search 결과에서 확인한 최근 stable line은 **2025년 11월 7일 `v2.3.4`**였다

즉 프로젝트는 계속 움직이고 있고, 문서/릴리스/메인 브랜치 표면이 항상 완전히 같은 버전 감각으로 맞춰져 있지는 않다.

이 점 역시 deep fork를 피해야 하는 근거가 된다.

## 9. 현재 저장소에 바로 연결되는 포인트

- Dragonfly는 **distribution backend candidate**로 평가해야지, control plane의 새 집으로 보면 안 된다.
- 첫 번째 실제 질문은 `producerNode` / `replicaNodes` semantics를 외부에 둔 채 Dragonfly가 payload movement를 담당할 수 있는가이다.
- 두 번째 질문은 Kubernetes job 소비 측에서 `dfcache` import/export와 `dfdaemon` UDS 패턴이면 충분한가이다.
- 세 번째 질문은 얕은 adapter만으로도 충분히 가치가 있어서 fork 자체가 불필요한가이다.

## 10. 다음 조사 후보 질문

- 우리 catalog와 Dragonfly 사이에 들어갈 adapter contract를 정확히 어떻게 둘 것인가
- Dragonfly를 밑단에 쓰더라도 `producer-first`와 `replica fallback` semantics를 제품 소유로 남길 것인가
- Dragonfly task/query 표면만으로 observability를 충분히 확보할 수 있는가, 아니면 source of truth 오해가 생기는가

## 참고 기준

- Dragonfly repository: <https://github.com/dragonflyoss/dragonfly>
- Dragonfly docs: <https://d7y.io/docs/>
- Dfcache reference: <https://d7y.io/docs/reference/commands/client/dfcache/>
- Dfdaemon reference: <https://d7y.io/docs/reference/configuration/client/dfdaemon/>
- Preheat Open API: <https://d7y.io/docs/advanced-guides/open-api/preheat/>
- Task Open API: <https://d7y.io/docs/advanced-guides/open-api/task/>
