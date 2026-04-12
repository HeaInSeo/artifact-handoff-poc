# dragonfly-adapter-contract

## 1. 조사 질문

`artifact-handoff-poc`가 Dragonfly를 distribution backend로 사용할 경우, 어떤 adapter contract를 소유해야 하며 그 경계는 어디까지가 맞는가?

## 2. 핵심 요약

현재 기준으로 가장 안전한 방향은 아래와 같다.

- `artifact-handoff-poc`가 **product-owned adapter contract**를 직접 소유한다
- Dragonfly는 그 계약을 구현하는 **replaceable backend**로 붙는다
- catalog, placement intent, handoff semantics는 Dragonfly 바깥에 둔다

즉 이 프로젝트는 Dragonfly API를 그대로 product contract로 노출하면 안 된다.
대신 Dragonfly를 구현체 중 하나로 감싸는 얇은 adapter boundary를 먼저 고정하는 것이 맞다.

이번 판단은 문서 비교만이 아니라, **2026-04-12 원격 멀티패스 K8s 랩(`100.123.80.48`)에서 실제 Dragonfly 설치와 `dfcache` 검증**을 바탕으로 했다.

## 3. 이번에 직접 확인한 실증 근거

원격 랩 환경:

- 호스트: `100.123.80.48`
- 사용자: `seoy`
- 랩 베이스라인: `multipass-k8s-lab`
- 클러스터: 3-node kubeadm cluster
- Kubernetes nodes: `lab-master-0`, `lab-worker-0`, `lab-worker-1`
- Cilium: `1.19.1`

Dragonfly 설치 검증:

- Helm chart: `dragonfly/dragonfly`
- namespace: `dragonfly-system`
- 상태: `deployed`
- 핵심 컴포넌트 확인:
  - `dragonfly-manager`
  - `dragonfly-scheduler`
  - `dragonfly-client`
  - `dragonfly-seed-client`
  - `mysql`
  - `redis`

`dfcache` 검증:

- `dfcache import --help` / `dfcache export --help`를 직접 확인
- 현재 배포된 CLI 계약은 `--cid`가 아니라:
  - `dfcache import <PATH>`
  - `dfcache export -O <OUTPUT> <ID>`
- 동일 content 재-import 시:
  - `persistent cache task ... is Succeeded cannot upload`
  - 즉 content 기반 persistent cache task가 이미 존재하면 재업로드 대신 existing task를 재사용하는 쪽으로 읽힌다
- known task ID로 다른 client pod에서 `dfcache export` 수행 시:
  - `/tmp/dragonfly-demo.out`
  - 결과 payload: `hello-dragonfly`

따라서 최소 수준에서는 아래 사실을 실증했다.

1. Dragonfly는 현재 랩 위에 실제로 올라간다
2. `dfcache`는 로컬 파일 import / task ID 기반 export 계약을 가진다
3. 다른 client pod에서 동일 task ID를 export해 payload를 재사용할 수 있다

## 4. 왜 product-owned adapter contract가 필요한가

우리 프로젝트의 핵심 의미론은 아래에 있다.

- 어떤 artifact가 어떤 producer에서 만들어졌는가
- 어떤 child가 어떤 artifact를 소비해야 하는가
- same-node reuse를 먼저 시도할지
- replica fallback을 어떤 순서로 볼지
- orphan/local-leftover를 어떻게 해석할지

이 의미론은 Dragonfly 내부의 기본 모델이 아니다.

Dragonfly가 제공하는 것은 주로:

- payload distribution
- persistent cache task
- node-local daemon runtime
- optional preheat/task control API

따라서 product contract를 먼저 정의하지 않으면, Dragonfly의 CLI/API 표면이 곧 product semantics처럼 굳어질 위험이 있다.

## 5. 권장 Adapter Contract

현재 PoC와 Dragonfly를 연결할 때 권장하는 최소 contract는 아래와 같다.

### A. `Put`

의미:

- producer가 만든 artifact를 distribution backend에 올린다

입력 예시:

- `artifactId`
- `localPath`
- `digest`
- `ttl`
- `replicaHint`

Dragonfly 매핑:

- `dfcache import <PATH>`
- 필요 시 `--ttl`
- 필요 시 `--persistent-replica-count`
- task ID를 adapter 내부에서 기록

출력 예시:

- `backendTaskId`
- `backendType=dragonfly`
- `state=stored`

### B. `EnsureOnNode`

의미:

- 특정 node에서 artifact가 실제 사용 가능한 상태가 되도록 보장한다

입력 예시:

- `artifactId`
- `targetNode`
- `backendTaskId`
- `outputPath`

Dragonfly 매핑:

- target node의 `dfcache export -O <OUTPUT> <ID>`

출력 예시:

- `resolvedPath`
- `source=dragonfly-export`
- `state=available-local`

### C. `Stat`

의미:

- artifact/backend task 상태를 조회한다

입력 예시:

- `artifactId`
- `backendTaskId`

Dragonfly 매핑 후보:

- `dfcache stat`
- Manager task/job query

출력 예시:

- `exists`
- `backendState`
- `lastObservedAt`

### D. `Warm`

의미:

- fan-out 전에 artifact set을 미리 준비한다

Dragonfly 매핑 후보:

- Manager Open API preheat

주의:

- 현재 PoC의 최소 contract에서는 필수보다 optional capability에 가깝다

### E. `Evict`

의미:

- artifact/backend cache를 폐기하거나 정리한다

Dragonfly 매핑 후보:

- task cleanup / delete 계열
- local cache cleanup

주의:

- catalog source of truth를 깨지 않도록 제품 정책과 함께 묶어야 한다

## 6. 이 Contract에서 Dragonfly 바깥에 남겨야 하는 것

아래는 반드시 product-owned 영역으로 남겨야 한다.

- `artifactId`와 workflow lineage 의미
- `producerNode`, `producerAddress`, `replicaNodes`
- same-node 우선 정책
- replica fallback ordering semantics
- orphan / cleanup policy
- scheduler/controller integration semantics

즉 Dragonfly adapter는 “전송/캐시 backend”이지, “artifact handoff의 source of truth”가 아니다.

## 7. 이 Contract에서 Dragonfly 안으로 위임해도 되는 것

- payload upload/import
- task ID 계산 및 persistent cache creation
- node-local export
- cache replication hint
- preheat / warm-up
- transport-level retry 일부

다만 이 위임도 제품 계약을 통해 간접적으로만 이뤄져야 한다.

## 8. 현재 리스크와 주의점

### 1. CLI/API를 그대로 product contract로 오해하면 안 된다

이번 실검증에서도 `dfcache` CLI는 예상한 `--cid`가 아니라 `import <PATH>`, `export <ID>` 계약을 사용했다.

즉 Dragonfly 표면은 제품 고유 의미론보다 더 낮은 레벨의 transport contract다.

### 2. task ID와 `artifactId`를 같은 것으로 취급하면 안 된다

현재 확인한 task ID는 content 기반 persistent cache task에 가깝다.

우리 프로젝트의 `artifactId`는 DAG/workflow 의미를 가질 수 있으므로, 두 값을 동일시하면 안 된다.

권장:

- `artifactId`는 제품 소유
- `backendTaskId`는 adapter 소유

### 3. re-import semantics는 “idempotent reuse”로 읽어야 한다

동일 payload 재-import 시 existing task가 이미 `Succeeded`이면 재업로드를 막고 existing task를 재사용하는 동작을 보였다.

이건 `Put` 구현 시 아래처럼 해석하는 것이 맞다.

- duplicate content는 새 artifact semantic이 아니라 existing backend object 재사용일 수 있다

### 4. artifact-handoff-poc 원격 repo는 아직 없음

이번 검증 시점에 원격 호스트의 `/opt/go/src/github.com/HeaInSeo` 아래에는 `multipass-k8s-lab`만 있었다.

즉 현재는 lower-layer Dragonfly 검증만 끝난 상태이고, upper-layer PoC 통합은 다음 단계다.

## 9. 현재 권장 다음 단계

1. `U1` 또는 별도 research sprint에서 `artifact-handoff-poc`용 `DragonflyAdapter` 인터페이스 초안을 코드 수준으로 더 좁힌다
2. `backendTaskId`를 catalog에 어떻게 매핑할지 결정한다
3. remote lab에 `artifact-handoff-poc`도 올려서 hand-rolled peer-fetch와 Dragonfly-backed path를 같은 실험으로 비교한다
4. preheat / stat / evict는 second pass capability로 둔다

## 10. 한 줄 결론

Dragonfly adapter contract의 핵심은 **Dragonfly를 product semantics의 주체로 쓰지 않고, `Put / EnsureOnNode / Stat / Warm / Evict`를 구현하는 replaceable backend로만 쓰는 것**이다.
