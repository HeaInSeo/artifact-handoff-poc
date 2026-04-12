# U3 - Parent-Result Placement Injection Validation

## 1. 스프린트 질문

`U1`에서 현재 `poc` path는 dynamic placement를 하지 않는다는 부정 결과를 원격 랩에서 확인했고,
`U2`에서는 그 결과를 바탕으로 최소 interface cut를 `ArtifactBinding + PlacementIntent + ResolvedPlacement`로 고정했다.

이번 스프린트 질문은 하나다.

- parent 결과를 child Job placement mutation으로 실제로 연결했다고 말할 수 있는가?

이번 문서는 추상 설계가 아니라 실제 실행 결과를 근거로만 쓴다.

## 2. 이번에 반영한 실제 변경

이번 검증은 아래 두 저장소의 실제 변경을 포함한다.

- `spawner`
  - `RunSpec`에 `Placement`와 downward API 기반 `EnvFieldRefs`를 추가
  - K8s Job 생성 시 `Placement.NodeSelector`를 Pod spec에 반영
- `poc`
  - `SpawnerNode`에 submit 직전 `Mutate` hook 추가
  - child node(`b1`, `b2`, `b3`, `c`)는 parent `a`의 실제 Pod node를 조회해 `nodeSelector`를 동적으로 주입

이번 검증에 사용한 upstream 상태:

- `spawner` commit: `2f9930e`
- `poc` commit: `dd77eb6`

핵심은 “same-node가 나왔는가”가 아니라,
“child Job spec에 explicit placement mutation이 실제로 들어갔는가”다.

## 3. 원격 멀티패스 K8s 랩 실행 조건

실행 환경:

- host: `100.123.80.48`
- user: `seoy`
- cluster: `lab-master-0`, `lab-worker-0`, `lab-worker-1`
- kubeconfig: `/opt/go/src/github.com/HeaInSeo/multipass-k8s-lab/kubeconfig`

실행한 파이프라인:

- repo: `/opt/go/src/github.com/HeaInSeo/poc`
- command:

```bash
KUBECONFIG=/opt/go/src/github.com/HeaInSeo/multipass-k8s-lab/kubeconfig \
/usr/local/go/bin/go run ./cmd/poc-pipeline --run-id dynplace-20260412-04
```

이번 run은 원격 랩에서 실제로 성공 완료됐다.

## 4. 실제 관찰 결과

### A. parent Job에는 explicit placement mutation이 없다

실행 후 확인:

- `kubectl -n default get job poc-dynplace-20260412-04-a -o jsonpath='{.spec.template.spec.nodeSelector}'`
  - 결과: 빈 값

즉 parent `a`는 기존과 동일하게 명시적 placement 없이 제출됐다.

### B. child Job들에는 explicit placement mutation이 들어갔다

실행 후 확인:

- `kubectl -n default get job poc-dynplace-20260412-04-b1 -o jsonpath='{.spec.template.spec.nodeSelector}'`
  - 결과: `{"kubernetes.io/hostname":"lab-worker-1"}`
- `kubectl -n default get job poc-dynplace-20260412-04-b2 -o jsonpath='{.spec.template.spec.nodeSelector}'`
  - 결과: `{"kubernetes.io/hostname":"lab-worker-1"}`
- `kubectl -n default get job poc-dynplace-20260412-04-b3 -o jsonpath='{.spec.template.spec.nodeSelector}'`
  - 결과: `{"kubernetes.io/hostname":"lab-worker-1"}`
- `kubectl -n default get job poc-dynplace-20260412-04-c -o jsonpath='{.spec.template.spec.nodeSelector}'`
  - 결과: `{"kubernetes.io/hostname":"lab-worker-1"}`

즉 child 제출 직전 mutation이 실제 Job spec까지 연결됐다.

### C. child Job metadata에도 mutation 근거가 남았다

실행 후 확인:

- `kubectl -n default get job poc-dynplace-20260412-04-b1 -o jsonpath='{.metadata.annotations}'`
  - 결과:
    - `poc.seoy.io/placement-source=producer-pod-node`
    - `poc.seoy.io/producer-node=lab-worker-1`
- `kubectl -n default get job poc-dynplace-20260412-04-c -o jsonpath='{.metadata.annotations}'`
  - 결과:
    - `poc.seoy.io/placement-source=producer-pod-node`
    - `poc.seoy.io/producer-node=lab-worker-1`

즉 이번 run에서는 단순히 같은 노드에 붙은 것이 아니라,
“왜 그 placement가 생겼는지”를 Job metadata에서도 읽을 수 있다.

### D. 실제 Pod 배치 결과

`kubectl -n default get pods -o wide | grep dynplace-20260412-04` 결과:

- `a`: `lab-worker-1`
- `b1`: `lab-worker-1`
- `b2`: `lab-worker-1`
- `b3`: `lab-worker-1`
- `c`: `lab-worker-1`

그리고 같은 시점의 PVC annotation:

- `volume.kubernetes.io/selected-node=lab-worker-1`

즉 이번 run에서도 storage side effect는 계속 존재한다.
하지만 이번에는 child Job spec 자체에 explicit placement mutation이 같이 들어간 상태이므로,
`U1`과 달리 “same-node 결과가 오직 PVC side effect였다”고 읽을 수는 없다.

## 5. 이번 스프린트에서 고정되는 판단

이번 스프린트로 아래 판단은 고정할 수 있다.

1. 현재 `poc` path는 이제 child 제출 직전에 parent 결과를 읽어 explicit placement mutation을 만들 수 있다.
2. 그 mutation은 실제 K8s Job spec의 `nodeSelector`까지 전달된다.
3. 따라서 `parent result -> child placement mutation` 연결 자체는 원격 멀티패스 K8s 랩에서 실증됐다.

하지만 아래는 아직 닫히지 않았다.

1. 이번 run은 여전히 `producer-pod-node -> child nodeSelector`라는 가장 좁은 same-node path만 검증했다.
2. same-node 실패 시 cross-node fallback을 자동으로 연결하는지까지는 아직 검증하지 않았다.
3. controller/scheduler 계층이 이 판단을 product-owned way로 일반화했는지는 아직 열려 있다.

## 6. 이번 결과가 프로젝트 의미론에 주는 영향

이번 결과로 최소한 아래 구분은 더 이상 애매하지 않다.

- `U1`의 결론:
  - current path는 dynamic placement를 하지 않았다.
  - same-node는 storage binding side effect였다.
- `U3`의 결론:
  - child Job mutation은 실제로 추가됐다.
  - same-node 결과와 별개로 explicit placement intent가 Job spec에 존재한다.

즉 이제 다음 질문은 “동적으로 연결되느냐”가 아니라,
“그 동적 연결을 same-node preferred / remote fallback semantics까지 어떻게 확장하느냐”다.

## 7. 다음 직접 질문

다음 직접 질문은 `dynamic fallback` 쪽으로 넘어가는 것이 맞다.

최소 질문은 아래다.

- parent 결과로 same-node placement를 먼저 시도하되,
  그 노드가 불가하거나 artifact locality가 어긋날 때 remote fallback을 어떤 조건과 구조로 연결할 것인가?

즉 후속은 `U5 - Dynamic Fallback Validation Entry`처럼
explicit placement mutation 이후의 fallback semantics를 좁게 여는 것이 적절하다.
