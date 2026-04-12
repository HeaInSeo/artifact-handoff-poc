# Dynamic DAG Placement Validation

## 1. 조사 질문

- 현재 `/opt/go/src/github.com/HeaInSeo/poc`의 DAG 실행 경로가 부모 결과를 읽고 자식 Job의 placement를 동적으로 바꾸는가?

여기서 동적 placement는 단순히 Pod가 우연히 같은 노드에 붙는 것을 뜻하지 않는다. 아래 세 단계를 포함해야 한다.

1. parent 완료 후 artifact/location metadata가 생긴다.
2. child 제출 직전에 runtime/controller가 그 metadata를 읽는다.
3. child Job spec에 `nodeSelector` 또는 `affinity` 같은 placement hint를 동적으로 주입한다.

## 2. 핵심 요약

- 현재 `poc` 경로는 **동적 parent-result-driven placement를 구현하지 않는다**.
- 원격 멀티패스 K8s VM 실검증에서 생성된 Job의 `nodeSelector`와 `affinity`는 비어 있었다.
- observed same-node는 runtime이 parent artifact 위치를 읽어 자식을 재배치한 결과가 아니라, `local-path` PVC의 `selected-node=lab-worker-1` 때문에 나온 storage binding side effect였다.

즉 현재 `poc`는 `when to run`은 해결하지만, `where to run based on parent result`는 아직 해결하지 않는다.

## 3. 로컬 코드 기준 근거

### 3.1 `poc-pipeline`은 정적 `RunSpec`을 DAG node에 연결한다

[cmd/poc-pipeline/main.go](/opt/go/src/github.com/HeaInSeo/poc/cmd/poc-pipeline/main.go:126)~[cmd/poc-pipeline/main.go](/opt/go/src/github.com/HeaInSeo/poc/cmd/poc-pipeline/main.go:144)에서 각 node는 미리 만들어진 `api.RunSpec`을 그대로 `adapter.SpawnerNode`에 넣는다.

- `poc-a` → `specA(...)`
- `poc-b1/b2/b3` → `specWorker(...)`
- `poc-c` → `specCollect(...)`

parent 결과를 읽어 child spec을 다시 계산하는 단계가 없다.

### 3.2 `SpawnerNode`는 static `Spec`을 그대로 `Prepare`에 넘긴다

[pkg/adapter/spawner_node.go](/opt/go/src/github.com/HeaInSeo/poc/pkg/adapter/spawner_node.go:23)~[pkg/adapter/spawner_node.go](/opt/go/src/github.com/HeaInSeo/poc/pkg/adapter/spawner_node.go:41)에서 `RunE()`는 `s.Spec`를 그대로 `Driver.Prepare()`에 넘긴다.

즉 DAG readiness는 `dag-go`가 결정하지만, placement를 다시 쓰는 훅은 여기 없다.

### 3.3 `RunSpec`에는 placement 필드가 없다

[spawner/pkg/api/types.go](/opt/go/src/github.com/HeaInSeo/spawner/pkg/api/types.go:96)~[spawner/pkg/api/types.go](/opt/go/src/github.com/HeaInSeo/spawner/pkg/api/types.go:107)의 `RunSpec`에는 `nodeSelector`, `affinity`, `nodeName`, `placementHint`, `artifactLocationRef` 같은 필드가 없다.

### 3.4 `buildJob()`도 Pod placement를 채우지 않는다

[spawner/cmd/imp/k8s_driver.go](/opt/go/src/github.com/HeaInSeo/spawner/cmd/imp/k8s_driver.go:157)~[spawner/cmd/imp/k8s_driver.go](/opt/go/src/github.com/HeaInSeo/spawner/cmd/imp/k8s_driver.go:205)의 `buildJob()`는 PodSpec에 `RestartPolicy`, `Containers`, `Volumes` 정도만 넣고 `nodeSelector`나 `affinity`는 채우지 않는다.

### 3.5 `poc` 테스트도 같은 한계를 적고 있다

[pkg/integration/kueue_observe_test.go](/opt/go/src/github.com/HeaInSeo/poc/pkg/integration/kueue_observe_test.go:204)~[pkg/integration/kueue_observe_test.go](/opt/go/src/github.com/HeaInSeo/poc/pkg/integration/kueue_observe_test.go:207)에는 nodeSelector를 Job spec에 넣으려면 `api.RunSpec` 또는 `buildJob` 확장이 필요하다고 직접 적혀 있다.

## 4. 원격 멀티패스 K8s VM 실검증

### 4.1 환경

- 원격 호스트: `100.123.80.48`
- 사용자: `seoy`
- Kubernetes lab: `multipass-k8s-lab`
- 노드:
  - `lab-master-0`
  - `lab-worker-0`
  - `lab-worker-1`
- kubeconfig: `/opt/go/src/github.com/HeaInSeo/multipass-k8s-lab/kubeconfig`

원격 호스트에 아래 저장소를 clone했다.

- `pipeline-lite-poc` → `/opt/go/src/github.com/HeaInSeo/poc`
- `spawner` → `/opt/go/src/github.com/HeaInSeo/spawner`
- `dag-go` → `/opt/go/src/github.com/HeaInSeo/dag-go`

추가로 원격 클러스터에 아래를 준비했다.

- Kueue `v0.16.4`
- `deploy/kueue/queues.yaml`
- `poc-shared-pvc`
  - `storageClassName: local-path`
  - `ReadWriteOnce`

### 4.2 실행

원격에서 아래를 실행했다.

```bash
cd /opt/go/src/github.com/HeaInSeo/poc
KUBECONFIG=/opt/go/src/github.com/HeaInSeo/multipass-k8s-lab/kubeconfig \
  /usr/local/go/bin/go run ./cmd/poc-pipeline --run-id dynplace-20260412-01
```

실행은 정상 완료됐다.

- `poc-a`
- `poc-b1`
- `poc-b2`
- `poc-b3`
- `poc-c`

모두 `Complete`

### 4.3 Job spec의 placement 필드 확인

실제 원격 클러스터에서 아래를 확인했다.

```bash
kubectl get job poc-dynplace-20260412-01-a  -o jsonpath='{.spec.template.spec.nodeSelector}'
kubectl get job poc-dynplace-20260412-01-a  -o jsonpath='{.spec.template.spec.affinity}'
kubectl get job poc-dynplace-20260412-01-b1 -o jsonpath='{.spec.template.spec.nodeSelector}'
kubectl get job poc-dynplace-20260412-01-b1 -o jsonpath='{.spec.template.spec.affinity}'
```

결과:

- `nodeSelector`: 빈 값
- `affinity`: 빈 값

즉 현재 `poc-pipeline`이 생성한 Job에는 parent 결과 기반 placement injection이 없다.

### 4.4 실제 Pod는 모두 `lab-worker-1`에 붙었다

원격 `kubectl get pods -o wide` 결과:

- `poc-dynplace-20260412-01-a-*` → `lab-worker-1`
- `poc-dynplace-20260412-01-b1-*` → `lab-worker-1`
- `poc-dynplace-20260412-01-b2-*` → `lab-worker-1`
- `poc-dynplace-20260412-01-b3-*` → `lab-worker-1`
- `poc-dynplace-20260412-01-c-*` → `lab-worker-1`

겉으로 보면 same-node pipeline처럼 보인다. 하지만 이것만으로 dynamic placement가 검증된 것은 아니다.

### 4.5 실제 same-node 원인은 PVC의 selected-node였다

원격 `kubectl describe pvc poc-shared-pvc -n default` 결과 핵심:

- `StorageClass: local-path`
- `Access Modes: RWO`
- annotation:
  - `volume.kubernetes.io/selected-node: lab-worker-1`

즉 first consumer 이후 local-path provisioner가 PVC를 `lab-worker-1`로 binding했고, 이후 동일 PVC를 쓰는 Pod들이 storage 제약 때문에 같은 노드에 모인 것이다.

이건 다음과 다르다.

- parent artifact 위치를 읽고
- child Job spec에
- `nodeSelector=producerNode`
같은 힌트를 넣는 것

## 5. 이번 검증으로 확정된 것

1. 현재 `poc`는 DAG dependency/readiness는 동작한다.
2. 현재 `poc`는 Kueue + Job 제출 + shared PVC 경로로 정상 실행된다.
3. 현재 `poc`는 parent-result-driven dynamic placement는 구현하지 않는다.
4. 현재 same-node 결과는 controller/runtime의 artifact-aware placement가 아니라 storage binding side effect일 수 있다.

따라서 지금 단계에서 "Kubernetes가 동적으로 parent/child locality를 자동으로 해결해 준다"라고 읽으면 안 된다.

더 정확한 표현은 이렇다.

- Kubernetes는 placement primitive와 storage constraint를 제공한다.
- 하지만 parent artifact metadata를 읽고 child placement를 동적으로 바꾸는 의미론은 아직 product/runtime 쪽에서 직접 구현해야 한다.

## 6. 우리 프로젝트와 어떻게 연결되는가

`artifact-handoff-poc`는 이미 `producerNode` 같은 metadata를 기록하고, script가 그 metadata를 읽어 same-node / cross-node를 실험할 수 있음을 검증했다.

이번 `poc` 실검증은 그 다음 층을 분리해 준다.

- DAG readiness가 있다고 해서 placement까지 동적으로 해결되는 것은 아니다.
- same-node가 보인다고 해서 artifact-aware placement 구현의 증거는 아니다.

즉 두 저장소를 함께 보면 다음이 분명해진다.

- `artifact-handoff-poc`: location-aware 의미론의 최소 truth
- `poc`: DAG runtime / Kueue / Job orchestration baseline
- 아직 비어 있는 층: parent-result-driven placement controller/adapter

## 7. 다음 스프린트 후보

1. `U2 - Dynamic Placement Interface Cut`
   - `RunSpec` 또는 그 상위 abstraction에 placement hint를 어떻게 표현할지 결정

2. `U3 - Parent-Result Placement Injection Validation`
   - parent 완료 후 child 제출 직전에 `producerNode`를 읽어 child Job spec에 `nodeSelector` 또는 `affinity`를 주입하고, 원격 멀티패스 K8s VM에서 다시 검증

현재 우선순위는 `U2`가 맞다.
