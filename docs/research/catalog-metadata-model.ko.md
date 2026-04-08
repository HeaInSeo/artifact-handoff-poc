# catalog-metadata-model

## 1. 조사 질문

`artifact-handoff-poc`의 catalog/metadata 계층은 현재 스프린트에서 어떤 최소 모델을 가져야 하며, 어떤 수준에서 멈춰야 하는가?

## 2. 핵심 요약

현재 스프린트의 catalog는 무거운 데이터 관리 시스템이 아니라 `location-aware decision layer`의 최소 제어 지점이어야 한다.

핵심 역할은 세 가지다.

1. artifact가 어디서 생성되었는지 기록
2. same-node reuse가 가능한지 판단할 근거 제공
3. same-node가 아니면 어느 producer/peer에서 fetch할지 판단할 근거 제공

따라서 현재 스프린트의 metadata는 최소 pointer 모델이면 충분하다. Datashim과 Pachyderm은 dataset pointer, lineage, versioning 관점에서 참고할 가치가 있지만, 지금 당장 그 수준의 데이터 모델을 들여오면 현재 검증 범위를 넘어선다.

## 3. 우리 프로젝트와 닮은 점

- Datashim은 Dataset CRD를 기존 데이터 소스에 대한 pointer로 본다.
- Pachyderm은 repo, commit, lineage를 통해 데이터와 파이프라인 관계를 추적한다.
- 두 시스템 모두 "데이터 자체"와 "그 데이터를 가리키는 metadata/control plane"을 구분한다.
- 이 구분은 `artifact-handoff-poc`에서도 중요하다. 현재 저장소도 artifact 바이트와 artifact 위치 metadata를 분리해서 봐야 한다.

## 4. 우리 프로젝트와 다른 점

- Datashim은 dataset access와 PVC/ConfigMap orchestration을 포함하지만, 현재 저장소는 artifact handoff 의미론 검증에 집중한다.
- Pachyderm은 versioning, lineage, pipeline system을 포함하는 훨씬 큰 데이터 플랫폼이다.
- 현재 스프린트에서는 dataset abstraction, lineage graph, branch/commit semantics보다 `producerNode`와 `localPath`를 먼저 아는 것이 중요하다.
- 즉 catalog는 지금 단계에서 "작은 metadata registry"이지 "완성형 data management system"이 아니다.

## 5. 차용할 것

- metadata를 artifact payload와 분리하는 관점
- dataset/pointer처럼 artifact record를 위치와 식별자 중심으로 다루는 관점
- lineage 전체는 아니더라도 "이 artifact를 누가 만들었는가"를 추적하려는 관점
- 상태 필드를 통해 handoff 판단에 필요한 최소 lifecycle을 표현하는 관점

## 6. 차용하지 않을 것

- Datashim의 Dataset CRD 전체
- Pachyderm의 full repo/commit/branch/versioning 모델
- 현재 스프린트에 lineage graph나 pipeline graph를 도입하는 것
- metadata 저장소를 durable HA system으로 확장하는 것

## 7. 현재 스프린트에 바로 연결되는 포인트

현재 스프린트의 최소 필드는 아래 정도면 충분하다.

- `artifactId`
- `digest`
- `producerNode`
- `producerAddress`
- `localPath`
- `state`
- `replicaNodes` 또는 그에 준하는 fetch 결과 기록 필드

현재 스프린트에서 state는 복잡할 필요가 없다. 예를 들면 아래 정도면 충분하다.

- `produced`
- `available-local`
- `replicated`
- `fetch-failed`

현재 구현 기준으로는 state를 한 레이어에 모두 통일하지 않는다.

- catalog record의 top-level `state`는 producer record에 대해 `produced`를 쓴다.
- local metadata는 현재 node에 artifact가 어떤 방식으로 존재하는지 나타내기 위해 `available-local` 또는 `replicated`를 쓴다.
- replica entry는 `replicated`를 쓴다.

중요한 점:

- `producerNode`와 `producerAddress`는 같은 정보가 아니다.
- `producerNode`는 placement 판단에, `producerAddress`는 peer fetch 수행에 직접 연결된다.
- `localPath`는 단순 부가 정보가 아니라 hostPath 또는 node-local storage 재사용 가능성의 핵심 단서다.
- `digest`는 payload 무결성 검증의 기준이므로 필수다.
- current authoritative location source는 catalog record다.
- local metadata는 node-local cache 또는 copy의 관찰값으로 보고, placement 판단이나 producer origin 판정은 catalog를 기준으로 삼는 편이 맞다.

현재 단계에서 optional로 둘 수 있는 항목:

- artifact size
- creation time
- parent job id / workflow step id
- consumer history
- richer error code

이들은 유용할 수 있지만, 현재 최소 검증에 필수는 아니다.

failure semantics 메모:

- `fetch-failed` 하나만 있어도 현재 단계의 state 표시는 가능하지만, `lastError` 해석은 별도 failure taxonomy를 같이 봐야 한다.
- 특히 `peer fetch http 409: digest mismatch`와 `peer digest mismatch`는 둘 다 integrity failure처럼 보이지만, 전자는 producer-side rejection이고 후자는 consumer-side verification failure다.
- 이 차이는 [peer-fetch-failure-paths.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.ko.md)에서 별도로 정리한다.
- catalog top-level failure reflection을 왜 아직 보류하는지는 [catalog-failure-semantics-decision.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/catalog-failure-semantics-decision.ko.md)에서 별도로 정리한다.

## 8. 다음 스프린트 후보 포인트

- state 전이를 더 엄밀히 정의하는 메모 추가
- `replicaNodes`와 cache hit history를 어떻게 구분할지 정리
- parent task id / child task id 같은 lineage-lite 필드를 언제 도입할지 검토
- durable backing store가 필요한 시점을 별도 문서로 정리

## 참고 기준

- Datashim: <https://datashim.io/>
- Pachyderm basic concepts: <https://docs.pachyderm.com/products/mldm/latest/learn/basic-concepts/>
