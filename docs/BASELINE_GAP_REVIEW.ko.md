# BASELINE_GAP_REVIEW

## 1. 문서 목적

이 문서는 현재 구현이 `PROJECT_BASELINE`, `README`, `SPRINT1_SCOPE`, research notes와 얼마나 정합적인지 점검한 결과를 정리한다.

범위:

- `app/agent/agent.py`
- `app/catalog/catalog.py`
- `manifests/base/*`
- `scripts/*.sh`

이 문서는 코드 수정 문서가 아니라, 다음 구현 스프린트 전에 기준선과 현재 상태의 차이를 고정하는 갭 리뷰 문서다.

## 2. 전체 판단 요약

현재 구현은 Sprint 1의 **최소 same-node / cross-node validation PoC**로서는 대체로 성립한다. 특히 아래는 실제로 맞아 있다.

- node당 하나의 DaemonSet agent
- 단일 catalog
- `hostPath` 기반 node-local storage
- digest 검증
- same-node local hit
- cross-node peer fetch
- second-hit local cache 재사용 경로

하지만 현재 구현은 문서에서 강조한 `metadata-driven location-aware decision layer`를 아직 완전하게 보여 주지는 못한다. 다만 최근 보정으로 **parent 완료 후 catalog에서 `producerNode`를 읽어 child placement에 반영하는 흐름**은 들어갔다.

즉 현재 구현은 아래처럼 보는 것이 정확하다.

- 이미 존재하는 artifact를 기준으로 fetch source를 고르는 최소 PoC
- child placement가 catalog metadata를 일부 참조하는 단계까지는 왔지만, 여전히 스크립트 주도 시나리오 성격이 강함

## 3. 기준선과 잘 맞는 부분

### 3.1 저장소 경계는 잘 지켜지고 있다

- `scripts/check-lab.sh`는 형제 저장소 `multipass-k8s-lab`의 kubeconfig와 status 스크립트를 참조하지만, provisioning이나 bootstrap 로직을 가져오지 않는다.
- `scripts/deploy.sh`도 이 저장소 안에서 PoC 리소스만 배포한다.
- 현재 코드베이스 안에는 Multipass lifecycle, kubeadm bootstrap, host preparation logic가 들어오지 않았다.

판단:
- 저장소 경계는 baseline과 정합적이다.

### 3.2 node-local agent 패턴은 baseline과 잘 맞는다

- agent는 DaemonSet으로 배포된다.
- `hostNetwork: true`, `hostPort: 8080`, `hostPath: /var/lib/artifact-handoff`를 사용한다.
- 각 node에서 local artifact lookup과 peer serve를 수행한다.

판단:
- `node-local-agent-patterns` research note와 현재 구조는 잘 맞는다.

### 3.3 same-node / cross-node 최소 시나리오는 실제 흐름과 맞는다

- parent job이 특정 node에 artifact를 PUT한다.
- same-node child는 같은 node에서 local source를 기대한다.
- cross-node child는 다른 node에서 `peer-fetch` source를 기대한다.
- `--second-hit` 시 두 번째 child는 local source를 기대한다.

판단:
- Sprint 1 성공 기준 자체는 실제 스크립트 흐름으로 구현되어 있다.

### 3.4 digest 검증은 최소 수준으로 구현되어 있다

- PUT 시 declared digest와 actual digest 불일치를 거부한다.
- local read 시 digest mismatch가 나면 로컬 artifact 디렉터리를 삭제한다.
- peer fetch 후에도 expected digest와 actual digest를 대조한다.

판단:
- 무결성 검증은 현재 스프린트 범위에서 충분히 들어가 있다.

## 4. 기준선과 어긋나거나 약한 부분

### 4.1 placement는 이전보다 metadata-driven에 가까워졌지만, 여전히 script-driven 성격이 강하다

현재 문서 기준선은 다음을 강조한다.

- artifact 위치를 기록한다.
- 그 위치를 기준으로 same-node placement를 유도한다.

현재 스크립트는 parent 완료 후 catalog metadata를 읽어 child placement에 반영한다.

실제 구현:

- `scripts/run-same-node.sh`는 parent 완료 후 catalog에서 `producerNode`를 읽고 child를 그 node에 붙인다.
- `scripts/run-cross-node.sh`는 parent 완료 후 catalog에서 `producerNode`를 읽고, 그 node와 다른 node를 골라 child를 붙인다.

즉 placement는 이전보다 "artifact 위치를 보고 결정"에 가까워졌지만, 여전히 shell script가 실험 시나리오를 구성하는 구조다.

판단:
- 큰 갭이긴 하지만 이전보다 줄었다.
- 현재 구현은 validation scenario로 충분하고, metadata가 placement 입력에 실제로 쓰이기 시작했다.
- 다만 scheduler/controller나 richer policy 없이 shell script가 시나리오를 구성하므로, 완전한 decision layer라고 보긴 아직 이르다.

### 4.2 catalog는 위치 registry이지만 decision layer로는 아직 얇다

현재 catalog는:

- `PUT /artifacts/{id}`로 record 저장
- `GET /artifacts/{id}`로 record 조회
- `POST /artifacts/{id}/replicas`로 replica 기록

이 정도만 수행한다.

현재 없는 것:

- state 전이 검증
- 필드 validation
- placement hint 계산
- fetch source 선택 정책
- stale replica 정리

판단:
- baseline에서 말한 "핵심 제어 지점"의 최소 registry 역할은 한다.
- 하지만 아직 decision layer의 계산이나 정책은 거의 agent/script 쪽에 흩어져 있다.

### 4.3 metadata 모델 명칭과 상태 모델은 개선됐지만 아직 한 레이어로 완전히 정리되진 않았다

catalog record는 문서상으로는 `producerNode`, `producerAddress`, `localPath`, `state`, `replicaNodes`를 가진다고 되어 있고 실제로도 거의 그렇게 저장한다.

하지만 세부적으로 보면:

- agent의 로컬 metadata는 이제 `producerNode`, `producerAddress`, `localNode`, `localAddress`, `state`를 가진다.
- catalog top-level state는 현재 `produced`만 허용한다.
- replica entry는 `replicated`를 사용한다.
- `fetch-failed` 같은 오류 상태는 아직 catalog나 local metadata에 반영되지 않는다.

판단:
- naming 정합성은 이전보다 좋아졌다.
- state는 더 이상 `"ready"` placeholder는 아니지만, 아직 transition model까지 정리된 것은 아니다.

### 4.4 peer fetch는 producer 중심으로만 고정돼 있고 replica를 활용하지 않는다

현재 cross-node fetch 경로는 catalog를 조회한 뒤 `producerAddress`만 사용한다.

즉:

- `replicaNodes`는 기록되지만 fetch source 선택에는 사용되지 않는다.
- producer가 죽거나 접근 불가할 때 replica fallback 경로가 없다.
- `register_replica`는 이후 fetch optimization과 연결되지 않는다.

판단:
- 현재 스프린트 범위에서는 허용 가능하다.
- 하지만 README/research 문맥에서 보면 `replicaNodes`는 아직 기록만 하고 의미론은 약하다.

### 4.5 node-local agent와 catalog의 역할 구분은 조금 더 선명해졌지만, API 경계 문서화는 여전히 보강이 필요하다

현재 agent는 한 프로세스 안에서 다음을 다 한다.

- local storage 쓰기
- local digest 검증
- catalog 등록
- catalog 조회
- remote peer fetch 수행
- replica 등록

PoC로는 합리적이지만, 아래 경계는 아직 문서/코드에서 명시적이지 않다.

- catalog가 authoritative location source인지
- local metadata와 catalog record 중 어느 쪽이 우선인지
- local artifact는 있는데 catalog record가 없으면 어떻게 볼지
- catalog는 있는데 local artifact가 없는 경우 state를 어떻게 볼지

판단:
- 현재 구조는 작고 설명 가능하다.
- 현재 규칙을 좁게 정리하면, producer origin과 placement 판단의 기준은 catalog이고 local metadata는 node-local copy의 관찰값이다.
- 다만 이 규칙이 README/결과 문서까지 충분히 반영된 것은 아니어서 추가 보강이 필요하다.

### 4.6 테스트 자산이 사실상 없다

- `test/` 디렉터리는 비어 있다.
- 현재 검증은 shell script 기반 수동 시나리오에 의존한다.

판단:
- Sprint 1에서는 허용되지만, 결과 재현성과 실패 경로 커버리지는 약하다.

## 5. 파일별 관찰 메모

### `app/agent/agent.py`

좋은 점:

- digest mismatch를 PUT, local read, peer fetch 경로에서 모두 다룬다.
- local-first, remote-fallback 흐름이 명확하다.
- catalog 등록과 replica 등록이 최소 수준으로 들어가 있다.

갭:

- local metadata naming은 많이 정리됐지만, catalog top-level state와 local state의 역할 차이를 계속 문서로 설명해야 한다.
- fetch source 선택이 `producerAddress` 하나에 고정된다.
- state 모델은 개선됐지만 아직 failure transition이 없다.

### `app/catalog/catalog.py`

좋은 점:

- 매우 작은 in-memory + JSON snapshot 구조로 Sprint 1 범위에 맞다.
- `replicaNodes` 누적 업데이트가 가능하다.

갭:

- payload validation이 거의 없다.
- state transition, authority, stale handling이 없다.
- metadata registry 이상의 decision logic은 없다.

### `scripts/run-same-node.sh`

좋은 점:

- same-node hit 검증이 명확하다.
- local source가 아니면 실패하도록 검증한다.

갭:

- child placement가 catalog를 읽은 결과가 아니라 처음 정한 `node_a`에 의존한다.

### `scripts/run-cross-node.sh`

좋은 점:

- peer fetch와 second-hit local cache를 둘 다 검증한다.

갭:

- child를 `node_b`에 미리 고정하므로 placement decision이 metadata-driven 이라고 보긴 어렵다.
- fetch source 최적화는 producer-only다.

### `manifests/base/*`

좋은 점:

- DaemonSet + Deployment + namespace 구성이 Sprint 1에 적합하다.
- ConfigMap으로 코드 주입하는 방식도 PoC에는 충분히 단순하다.

갭:

- 운영성보다 단순성을 우선한 구조라, 이 자체는 괜찮지만 README에서 production-like 뉘앙스를 주면 과장될 수 있다.

## 6. 현재 결론

현재 구현은 아래 질문에는 "예"라고 답할 수 있다.

- same-node reuse가 가능한가?
- cross-node peer fetch가 가능한가?
- digest 검증이 최소 수준으로 강제되는가?
- node-local agent + central catalog 구조가 최소 형태로 성립하는가?

하지만 아래 질문에는 아직 부분적으로만 답할 수 있다.

- artifact 위치를 기준으로 child placement를 동적으로 유도하는가?
- metadata/state 모델이 handoff decision layer로 충분히 정리되어 있는가?
- replica metadata가 실제 fetch 전략에 반영되는가?

즉 현재 PoC는 **location-aware handoff의 최소 실행 경로**를 보여 주고, **metadata-driven placement 입력**도 일부 갖추기 시작했다. 다만 decision layer의 정책성과 state transition은 아직 약하다.

## 7. 다음 구현 스프린트 후보

우선순위 1:

- failure state와 authority 규칙을 결과/README 문서까지 반영

우선순위 2:

- catalog/local metadata state transition 최소 보강

우선순위 3:

- replicaNodes를 단순 기록이 아니라 fetch 후보로 다루는지 검토

우선순위 4:

- failure path 메모와 결과 문서 보강

## 8. 권장 다음 스프린트

`Sprint B2 - Metadata-Driven Placement Tightening`

목표:

- 현재 script-driven placement를 최소한 일부라도 metadata-driven flow에 가깝게 보정한다.

범위 예시:

- parent 완료 후 catalog 조회
- same-node child가 `producerNode`를 읽어 nodeSelector 생성
- cross-node script도 "producer node와 다른 node 선택" 판단을 catalog metadata와 연결
- state/naming 최소 보정

이 스프린트는 여전히 좁게 유지해야 한다.  
full scheduler/controller integration이나 고급 placement policy로 바로 확장하면 현재 프로젝트 단계에 비해 과하다.
