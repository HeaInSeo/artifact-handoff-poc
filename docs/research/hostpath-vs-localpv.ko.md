# hostpath-vs-localpv

## 1. 조사 질문

현재 스프린트에서 node-local artifact 저장소로 `hostPath`를 쓰는 판단은 왜 타당하며, 언제 `local PersistentVolume` 비교가 필요해지는가?

## 2. 핵심 요약

현재 스프린트에서는 `hostPath`가 맞다. 이유는 가장 빠르고 직접적으로 "이 artifact는 이 node의 이 경로에 있다"를 증명할 수 있기 때문이다.

하지만 Kubernetes 공식 문서도 `hostPath`는 single-node testing 성격이 강하고 multi-node 일반 해법으로 권장되지 않는다고 분명히 적고 있다. 반면 `local` PV는 node affinity와 함께 node-local storage를 Kubernetes 자원 모델 안으로 더 잘 끌어온다.

따라서 현재 스프린트의 결론은 다음이다.

- 지금: `hostPath`로 빠르게 location-aware handoff 성립 여부 검증
- 다음 비교 단계: `local PV`가 portability, scheduling alignment, 운영 경계 측면에서 어떤 차이를 만드는지 평가

## 3. 우리 프로젝트와 닮은 점

- Alluxio는 worker local storage에서 local access와 short-circuit path를 중시한다.
- JuiceFS는 `hostPath` 기반 cache가 간단하지만 Pod 이동 시 locality trade-off가 있음을 분명히 설명한다.
- Kubernetes `local` PV는 node affinity를 통해 "이 storage는 이 node에 묶여 있다"를 명시한다.
- 이 저장소도 결국 "artifact가 특정 node-local 경로에 있다"는 사실을 제어 흐름에 반영하려고 한다.

## 4. 우리 프로젝트와 다른 점

- Alluxio/JuiceFS는 더 넓은 데이터 접근/캐시 시스템이다.
- 현재 저장소는 caching generality보다 artifact handoff validation이 우선이다.
- `hostPath`와 `local PV` 비교도 스토리지 제품 비교가 아니라, location-aware handoff 의미론에 어떤 차이를 만드는가를 기준으로 봐야 한다.

## 5. 차용할 것

- 현재 스프린트에서는 `hostPath`의 단순성과 직접성
- 다음 단계에서는 `local PV`의 `nodeAffinity`와 Kubernetes-native storage 모델 정합성
- locality를 storage 계층만의 문제가 아니라 placement와 함께 봐야 한다는 관점

## 6. 차용하지 않을 것

- 현재 스프린트에서 storage abstraction을 과도하게 늘리는 것
- hostPath 한계 때문에 현재 검증 자체를 늦추는 것
- 반대로 hostPath만으로 장기 방향을 고정하는 것

## 7. 현재 스프린트에 바로 연결되는 포인트

- `hostPath`는 parent node의 로컬 경로와 metadata의 `localPath`를 가장 직접적으로 연결해 준다.
- same-node reuse 검증에는 `hostPath`가 가장 빠르다.
- cross-node fetch에서도 producer node의 실제 로컬 파일을 source로 삼기 쉽다.
- 다만 결과 문서에는 반드시 다음 제약을 남겨야 한다.
  - portability 제약
  - 운영상 정리/권한 관리 부담
  - Kubernetes-native storage abstraction과의 거리

## 8. 다음 스프린트 후보 포인트

- `local PV`를 쓴 경우 metadata와 placement가 어떻게 달라지는지 비교 실험
- `hostPath`와 `local PV`에서 failure/cleanup/eviction 차이를 정리
- storage 선택이 catalog 모델에 미치는 영향 검토

## 참고 기준

- Kubernetes persistent volumes: <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>
- Alluxio on Kubernetes: <https://documentation.alluxio.io/os-en/kubernetes/running-alluxio-on-kubernetes>
- JuiceFS CSI cache: <https://juicefs.com/docs/csi/guide/cache/>
