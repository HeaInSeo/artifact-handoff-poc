# dragonfly-with-update-01

## 1. 조사 질문

이 프로젝트가 Dragonfly를 포크하거나 adapter로 적용할 때, 시간이 지나도 업스트림 Dragonfly 업데이트와 정합성을 유지할 수 있는가?

## 2. 핵심 요약

답은 아래와 같다.

- **얕은 통합 전략이라면 가능**
- **깊은 포크 전략이라면 가능성이 낮음**

업스트림 정합성은 우리 custom logic를 Dragonfly의 계속 움직이는 internals 바깥에 둘 때만 현실적이다.

핵심 이유는 Dragonfly가 계속 변하는 프로젝트이기 때문이다.

- repository main page 기준 최신 release는 **2026년 4월 10일 `v2.4.4-rc.0`**
- 확인한 공식 문서 표면은 `v2.4.0`
- 즉 “현재 Dragonfly”는 고정된 타깃이 아니라 계속 움직이는 타깃이다

따라서 올바른 질문은 “한 번 포크하면 끝나는가?”가 아니다.
올바른 질문은 “우리 custom layer를 충분히 작게 만들어서 업스트림 변화를 흡수할 수 있는가?”다.

## 3. 업스트림 정합성의 주요 리스크

### A. release drift 리스크

문서, main branch, release line은 항상 같은 속도로 움직이지 않는다.

의미:

- 우리 프로젝트가 안정된 운영 표면이 아니라 internal code path에 기대면, 업스트림 버전이 바뀔 때마다 재분석 비용이 커진다

### B. 내부 아키텍처 결합 리스크

공개 repository layout에는 아래 주요 컴포넌트가 드러난다.

- `manager`
- `scheduler`
- `client`
- `pkg`

우리가 이 경계를 가로질러 custom logic를 넣기 시작하면, 그때부터는 Dragonfly를 “사용하는 것”이 아니라 Dragonfly 기반 distribution product를 “직접 유지하는 것”에 가까워진다.

### C. 확장 포인트 성숙도 리스크

Dragonfly에는 plugin 관련 문서가 있긴 하지만, 장기적으로 안정적인 product extension model처럼 읽히지는 않는다.

현재 확인한 신호:

- `next` in-tree plugin page는 사실상 TODO/WIP 상태다
- 예전 plugin-builder 문서는 존재하지만, 여전히 plugin을 쓰는 이미지를 다시 빌드해야 한다

의미:

- plugin은 일부 마찰을 줄일 수 있지만, “안전한 deep customization이 가능하다”는 근거로 보기엔 아직 약하다

### D. 운영 표면 drift 리스크

internal modification을 피하더라도, 우리 통합은 여전히 아래에 의존한다.

- `dfcache`
- `dfdaemon`
- Manager Open API
- Helm/Kubernetes deployment shape

이 표면은 internals보다 안전하지만, 그래도 version tracking과 compatibility check는 계속 필요하다.

## 4. 권장 정합성 전략

### 전략 1. Dragonfly 위에 product-owned contract를 둔다

우리 프로젝트는 아래 같은 인터페이스를 직접 정의하고 소유해야 한다.

- `Put`
- `EnsureOnNode`
- `Stat`
- `Warm`
- `Evict`

Dragonfly는 이 계약을 구현하는 backend adapter가 된다.

이 구조의 의미는 아래와 같다.

- 업스트림 Dragonfly 업데이트는 먼저 adapter에 영향을 준다
- catalog나 workflow semantics 자체가 Dragonfly 업데이트에 의해 재정의되지는 않는다

### 전략 2. deep fork보다 shallow fork를 택한다

포크가 필요하더라도 아래 범위에 제한하는 것이 맞다.

- packaging
- deployment defaults
- thin glue code
- 좁은 operational wrapper

반대로 아래 쪽에 custom logic를 넣는 것은 피해야 한다.

- scheduler peer-selection internals
- manager data model internals
- artifact handoff의 source-of-truth semantics

### 전략 3. version matrix를 고정하고 검증한다

`latest`를 암묵적으로 따라가면 안 된다.

예를 들어 아래처럼 명시적 matrix를 운영해야 한다.

- 현재 검증된 stable version
- 다음 후보 version
- 확인된 blocking change

이 matrix는 아래 시점마다 다시 봐야 한다.

- docs version이 바뀔 때
- 새 stable release가 나올 때
- RC에서 transport/control 관련 의미 있는 변화가 보일 때

### 전략 4. docs/release mismatch를 정상 입력으로 본다

이 프로젝트는 아래 상황을 정상적인 planning input으로 받아들여야 한다.

- docs는 한 버전 라인을 강조할 수 있다
- repo main은 더 새로운 RC를 이미 가리킬 수 있다
- extension docs는 늦거나 불완전할 수 있다

이 사실 자체를 blocker로 볼 필요는 없다.
대신 integration boundary를 좁게 유지해야 한다는 신호로 읽는 것이 맞다.

## 5. Go / No-Go 판단 기준

### Go

아래 조건이 유지되면 Dragonfly-backed 실험을 진행할 수 있다.

- custom semantics는 이 저장소에 남아 있다
- Dragonfly는 주로 payload transport/cache distribution을 담당한다
- adapter가 버전 업 때도 bounded work로 유지 가능하다
- core behavior를 위해 undocumented 또는 미성숙 extension point에 의존하지 않는다

### No-Go

아래 중 하나라도 맞으면 Dragonfly fork를 주 경로로 삼지 않는 것이 낫다.

- core product semantics를 위해 scheduler/manager internals patch가 필요하다
- 현재 문서상 안정적으로 보이지 않는 plugin behavior가 필수다
- catalog를 source of truth로 유지할 수 없다
- 업스트림 버전이 바뀔 때마다 내부 코드 경로를 광범위하게 다시 읽어야 한다

## 6. `artifact-handoff-poc`에 대한 현재 판단

현재 가장 적절한 판단은 아래와 같다.

- **Dragonfly는 backend candidate로 사용**
- **이 저장소를 Dragonfly forked product로 재설계하지 않음**
- **포크는 architecture가 아니라 packaging/integration tactic으로 취급**

즉,

- Dragonfly는 프로젝트 밑단에 놓일 수 있다
- Dragonfly가 프로젝트 자체가 되어서는 안 된다

## 7. 다음 조사/구현 질문

- Dragonfly spike 전에 이 저장소가 먼저 소유해야 할 adapter contract는 정확히 무엇인가
- 현재 hand-rolled peer-fetch path보다 Dragonfly-backed path가 실제로 더 가치 있다는 것을 보여 줄 최소 실험은 무엇인가
- 이후 spike를 위해 version pinning과 upgrade rehearsal을 어떻게 문서화할 것인가

## 참고 기준

- Dragonfly repository: <https://github.com/dragonflyoss/dragonfly>
- Dragonfly releases: <https://github.com/dragonflyoss/dragonfly/releases>
- Dfcache reference: <https://d7y.io/docs/reference/commands/client/dfcache/>
- Dfdaemon reference: <https://d7y.io/docs/reference/configuration/client/dfdaemon/>
- Preheat Open API: <https://d7y.io/docs/advanced-guides/open-api/preheat/>
- Plugin builder docs: <https://d7y.io/docs/v2.0.8/contribute/development-guide/plugin-builder/>
- In-tree plugin docs: <https://d7y.io/docs/next/development-guide/plugins/in-tree-plugin/>
