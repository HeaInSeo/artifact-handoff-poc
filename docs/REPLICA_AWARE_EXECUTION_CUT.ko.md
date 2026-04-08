# REPLICA_AWARE_EXECUTION_CUT

## 목적

이 문서는 `Sprint F3 - Next Execution Cut` 결과를 고정하기 위한 메모다.

질문:

- `replica-aware fetch`를 바로 크게 구현하지 않고,
- `F4`에서 바로 검증 가능한 가장 작은 실행 cut는 무엇인가

## 이번 cut의 결론

이번 스프린트에서는 **전용 준비 helper를 추가하는 것**으로 범위를 제한한다.

추가한 helper:

- [run-replica-aware-prep.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-replica-aware-prep.sh)

이 helper는 다음 세 단계를 자동화한다.

1. 기존 cross-node flow를 한 번 실행해 first replica를 만든다
2. catalog에서 `replicaNodes`가 실제로 채워졌는지 확인한다
3. replica node local metadata가 `state=replicated`, `source=peer-fetch`인지 확인한다

## 왜 이 cut가 가장 작은가

### 1. agent/catalog 의미론을 아직 바꾸지 않는다

이번 cut는 `producerAddress` 중심 fetch path를 아직 바꾸지 않는다.

즉:

- replica를 실제 fetch source로 선택하는 구현은 아직 하지 않는다
- 먼저 `replicaNodes`가 검증 가능한 입력 상태로 준비되는지만 본다

### 2. `F4`의 live validation 준비로 바로 이어진다

이 helper를 쓰면 다음 스프린트에서 바로 아래 질문으로 들어갈 수 있다.

- producer-only bias를 가진 현재 구현에서
- replica-aware source selection을 시험하려면
- 어떤 producer/replica 준비 상태가 필요한가

### 3. 기존 happy-path와 edge-case 스크립트를 건드리지 않는다

기존 스크립트:

- [run-same-node.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-same-node.sh)
- [run-cross-node.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-cross-node.sh)
- [run-edge-case-local-miss.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-edge-case-local-miss.sh)
- [run-edge-case-catalog-miss.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-edge-case-catalog-miss.sh)

는 그대로 둔다.

## 이번 스프린트에서 아직 하지 않는 것

- replica-aware fetch source selection 구현
- producer down 시나리오 실검증
- `replicaNodes` 우선순위 정책 구현

## 이번 스프린트에서 확인한 것

- helper 스크립트 문법 검증: `bash -n` 통과

## 다음 스프린트 연결

다음 스프린트 `F4`에서는 이 helper로 준비된 상태를 바탕으로:

- replica-aware fetch 가설 1개를 정하고
- 실제로 producer-only path와 어떤 차이가 나는지
- 최소 evidence를 남기는 것이 맞다

## 결론 한 줄

`Sprint F3`의 결론은 **replica-aware fetch를 위한 가장 작은 실행 cut는 새 fetch policy 구현이 아니라, `replicaNodes`와 replica metadata가 실제로 준비된 상태를 반복 가능하게 만드는 전용 helper를 추가하는 것**이라는 점이다.
