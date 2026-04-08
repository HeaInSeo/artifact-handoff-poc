# FAILURE_DOCS_ENTRY_AUDIT

## 목적

이 문서는 `Sprint C8 - Failure Docs Entry Audit` 결과를 고정하기 위한 짧은 감사 메모다.

대상은 아래 failure 관련 문서들의 진입 경로다.

- `README*`
- `RESULTS*`
- `VALIDATION_HISTORY*`
- `FAILURE_MATRIX*`
- `docs/research/peer-fetch-failure-paths*`
- `docs/research/catalog-failure-semantics-decision*`
- `docs/research/catalog-lookup-failure-split-note*`

핵심 질문은 다음 두 가지다.

1. 지금 링크 구성이 너무 얇아서 문서를 찾기 어려운가
2. 반대로 너무 촘촘해서 문서가 과하게 서로를 반복 참조하는가

## 감사 요약

판정: `balanced enough`

현재 failure 관련 문서 진입 경로는 **작업 목적 대비 충분하고, 추가 확장은 당장 필요하지 않다.**

## 확인한 구성

### 1. 저장소 입구

- `README.md` / `README.en.md`
  - failure semantics note 링크 있음
  - failure matrix 링크 있음
  - sprint progress 링크 있음

판단:

- 입구 문서에서 필요한 첫 진입점은 이미 제공된다.
- 여기서 decision note까지 더 직접 노출하면 README가 과해질 가능성이 높다.

### 2. 결과/히스토리 문서

- `RESULTS*`
  - terminology note에서 failure semantics note 링크 제공
  - terminology note에서 failure matrix 링크 제공
- `VALIDATION_HISTORY*`
  - 같은 구조로 semantics note + matrix 링크 제공

판단:

- 결과와 history를 읽는 사용자는 “이 용어를 어떻게 읽는가”와 “대표 scenario를 한 장 표로 다시 볼 수 있는가”를 바로 해결할 수 있다.
- 이 수준이면 충분하다.

### 3. matrix와 research note

- `FAILURE_MATRIX*`
  - semantics note로 바로 가는 링크 있음
- `peer-fetch-failure-paths*`
  - matrix로 바로 가는 링크 있음

판단:

- C7까지의 보강으로 matrix와 semantics note 사이 왕복 경로는 충분히 짧아졌다.

### 4. decision note 문서들

- `catalog-failure-semantics-decision*`
- `catalog-lookup-failure-split-note*`

판단:

- 이 두 문서는 “세부 판단을 고정하는 보조 note” 성격이다.
- README, RESULTS, VALIDATION_HISTORY에서 직접 연결하지 않는 현재 구성이 맞다.
- 필요한 독자는 semantics note나 metadata model 문서를 통해 충분히 도달할 수 있다.

## 현재 수준에서 유지할 것

1. README는 입구 문서로서 semantics note + matrix + progress까지만 직접 노출한다.
2. RESULTS / VALIDATION_HISTORY는 terminology note 아래에서 semantics note와 matrix만 직접 연결한다.
3. matrix와 semantics note는 서로 직접 왕복 가능하게 유지한다.
4. decision note는 research 계층 안에서 접근하게 두고, README까지 끌어올리지 않는다.

## 지금 추가하지 않을 것

- README에 `catalog-failure-semantics-decision` 직접 링크 추가
- README에 `catalog-lookup-failure-split-note` 직접 링크 추가
- RESULTS / VALIDATION_HISTORY에서 decision note까지 직접 링크 추가
- failure docs 사이에 2중, 3중 반복 링크 추가

## 결론

현재 failure docs navigation은 **과하지도 부족하지도 않은 수준**이다.

따라서 `Sprint C8` 기준 결론은 다음과 같다.

- 추가 링크 확장은 지금은 멈춘다.
- 이후 문서가 더 늘어나거나 실제 사용 중 탐색 비용이 다시 커질 때만 재검토한다.
