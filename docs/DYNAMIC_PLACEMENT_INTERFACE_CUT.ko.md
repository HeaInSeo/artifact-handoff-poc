# U2 - Dynamic Placement Interface Cut

## 1. 스프린트 질문

`U1`의 원격 실검증으로 아래 사실이 이미 고정됐다.

- `poc-dynplace-20260412-01-a` Job의 `nodeSelector`는 비어 있었다.
- `poc-dynplace-20260412-01-a` Job의 `affinity`도 비어 있었다.
- `poc-dynplace-20260412-01-b1` Job도 동일하게 `nodeSelector`, `affinity`가 비어 있었다.
- 그런데 실제 Pod들은 모두 `lab-worker-1`에 붙었다.
- 같은 시점의 PVC annotation `volume.kubernetes.io/selected-node`는 `lab-worker-1`였다.

즉 현재 same-node 결과는 explicit placement mutation이 아니라 storage binding side effect다.

이번 스프린트 질문은 하나다.

- 이 상태에서 parent-result-driven dynamic placement를 실제 구현하려면 어떤 최소 interface cut가 필요한가?

## 2. 이번에 근거로 사용한 실제 관찰

이번 문서는 추상 설계만으로 쓰지 않는다.
아래 관찰은 `100.123.80.48` 원격 멀티패스 K8s 랩에서 다시 확인한 실행 결과다.

재확인한 값:

- `kubectl get job poc-dynplace-20260412-01-a -o jsonpath='{.spec.template.spec.nodeSelector}'`
  - 결과: 빈 값
- `kubectl get job poc-dynplace-20260412-01-a -o jsonpath='{.spec.template.spec.affinity}'`
  - 결과: 빈 값
- `kubectl get job poc-dynplace-20260412-01-b1 -o jsonpath='{.spec.template.spec.nodeSelector}'`
  - 결과: 빈 값
- `kubectl get job poc-dynplace-20260412-01-b1 -o jsonpath='{.spec.template.spec.affinity}'`
  - 결과: 빈 값
- `kubectl get pods -o wide`
  - `a`, `b1`, `b2`, `b3`, `c` 모두 `lab-worker-1`
- `kubectl get pvc poc-shared-pvc -o jsonpath='{.metadata.annotations.volume\.kubernetes\.io/selected-node}'`
  - 결과: `lab-worker-1`

이 결과가 의미하는 것은 분명하다.

- runtime은 placement를 쓰지 않았다.
- storage가 Pod를 같은 노드로 모았다.

그래서 다음 단계는 “same-node가 나왔다”를 더 재확인하는 것이 아니라,
“누가 어떤 정보로 Job placement를 실제로 쓸 것인가”를 인터페이스로 고정하는 것이다.

## 3. 왜 `RunSpec` 직확장만으로는 부족한가

현재 `RunSpec`는 실행 payload에 가깝다.

- `ImageRef`
- `Command`
- `Env`
- `Labels`
- `Annotations`
- `Mounts`
- `Resources`

`producerNode`, `replicaNodes`, artifact binding, fallback policy는 성격이 다르다.
이들은 Kubernetes Job 실행 필드라기보다 상위 orchestration 의미론이다.

`spawner` 쪽 문서도 같은 방향을 시사한다.
[spawner/docs/SPAWNER_REINFORCEMENT_REVIEW.ko.md](/opt/go/src/github.com/HeaInSeo/spawner/docs/SPAWNER_REINFORCEMENT_REVIEW.ko.md:138)는 필드를 무작정 늘리기보다 아래처럼 나누는 편이 낫다고 적고 있다.

- `RunSpec`: 실행에 직접 필요한 것
- `RunMeta` 또는 `SubmitRequest`: 상위 orchestration/control 정보

이번 dynamic placement 질문도 같은 원칙으로 다뤄야 한다.

## 4. 이번 스프린트에서 고정하는 최소 구조

### A. `ArtifactBinding`

child가 어떤 artifact를 기준으로 placement를 결정해야 하는지 표현한다.

최소 필드:

- `ArtifactID`
- `ConsumeMode`
  - `same-node-preferred`
  - `remote-ok`
- `FallbackPolicy`
  - `same-node-only`
  - `same-node-then-remote`

### B. `PlacementIntent`

parent 결과를 보고 child가 어떤 방향으로 배치되기를 원하는지 표현한다.

최소 필드:

- `Mode`
  - `none`
  - `co-locate-with-producer`
  - `co-locate-with-recorded-replica`
- `Required`
- `SourceArtifactID`

이 단계는 아직 Kubernetes concrete field가 아니다.
즉 여기서 바로 `nodeSelector`를 들고 있지 않는다.

### C. `ResolvedPlacement`

실제 Job spec에 들어갈 concrete placement 결과다.

최소 필드:

- `NodeSelector map[string]string`
- `RequiredNodeAffinity`
- `PreferredNodeAffinity`
- `Reason`

이 구조는 `PlacementResolver`의 출력으로만 존재하는 것이 맞다.

## 5. 권장 실행 흐름

현재 흐름:

1. static `RunSpec` 생성
2. `SpawnerNode.RunE()`
3. `Driver.Prepare()`
4. `buildJob()`

권장 흐름:

1. parent 완료
2. artifact-handoff metadata 확정
3. child `ArtifactBinding` 확인
4. `PlacementResolver.Resolve(binding, metadata)` 실행
5. `ResolvedPlacement` 생성
6. submit 직전 `RunSpec + ResolvedPlacement`를 합쳐 Job 생성

즉 mutation 지점은 `buildJob()` 내부의 숨은 규칙이 아니라,
child 제출 직전의 명시적 단계여야 한다.

## 6. 이번에 버린 대안

### A. `RunSpec.NodeSelector` / `RunSpec.Affinity`를 바로 추가

장점:

- 구현이 가장 단순하다.

단점:

- product-owned artifact semantics와 Kubernetes concrete field가 섞인다.
- `poc`와 `spawner` 경계가 흐려진다.

이번 스프린트 판단:

- 임시 구현용으로는 가능
- 기본 구조로는 비권장

### B. `SpawnerNode` 안에 mutation hook를 숨기기

장점:

- 현재 코드 구조와 가깝다.

단점:

- mutation이 node runtime 안으로 숨어든다.
- catalog read / placement resolve / Job translation 경계가 다시 흐려진다.

이번 스프린트 판단:

- 실험용 보조안
- 기본 구조로는 비권장

## 7. 이번 cut의 핵심 판단

이번 스프린트에서 고정하는 최소안은 아래다.

```text
Pipeline Node
  -> RunSpec
  -> ArtifactBinding[]
  -> PlacementIntent

Parent completes
  -> producerNode / replicaNodes available

PlacementResolver
  -> emits ResolvedPlacement

Submit path
  -> merges RunSpec + ResolvedPlacement
  -> builds concrete Job spec
```

ownership은 다음처럼 나누는 것이 맞다.

- `artifact-handoff-poc`
  - `producerNode`, `replicaNodes`, ordering/fallback semantics
- `poc`
  - DAG readiness와 node-to-node orchestration
- `spawner`
  - concrete K8s Job translation and submission

## 8. 이번 스프린트에서 아직 하지 않은 것

- 실제 code patch
- 실제 `nodeSelector` 주입
- `affinity` 최종 형태 선택
- remote fallback 자동화
- retry / recovery policy

즉 이번 스프린트는 “어디에 넣을 것인가”를 고정했지, “이미 넣었다”를 주장하지 않는다.

## 9. 다음 직접 단계

다음은 `U3 - Parent-Result Placement Injection Validation`가 맞다.

완료 기준은 아래처럼 잡아야 한다.

1. child 제출 직전에 `producerNode`를 읽는다.
2. `ResolvedPlacement`가 실제로 만들어진다.
3. 생성된 Job spec에 `nodeSelector` 또는 `affinity`가 들어간다.
4. 원격 멀티패스 K8s VM에서 same-node 결과가 PVC side effect가 아니라 explicit placement mutation 때문임을 다시 확인한다.
