# FAILURE_DOCS_NAVIGATION_FREEZE

## 목적

이 문서는 `Sprint C10 - Failure Docs Navigation Freeze` 결론을 고정하기 위한 메모다.

질문은 단순하다.

- 현재 failure-related 문서들의 navigation을 더 확장해야 하는가
- 아니면 현재 수준에서 멈추는 것이 맞는가

## 결론

판정: `freeze at current level`

현재 수준의 failure docs navigation은 이미 충분하다. 따라서 **추가 링크 확장을 기본 동작으로 두지 않고, 현재 수준에서 멈추는 것이 맞다.**

## 왜 지금 멈추는가

### 1. 첫 진입점은 이미 확보됐다

현재 README에는 아래가 이미 있다.

- failure semantics note
- failure matrix
- sprint progress

즉 저장소 입구에서 필요한 첫 탐색 경로는 이미 제공된다.

### 2. 결과 문서에서도 필요한 보조 경로가 있다

현재 RESULTS / VALIDATION_HISTORY에는 아래가 있다.

- terminology note에서 semantics note 링크
- terminology note에서 failure matrix 링크

따라서 결과를 읽는 사용자는 “이 용어를 어디서 해석할까”와 “대표 scenario를 한 장 표로 다시 볼 수 있는가”를 이미 해결할 수 있다.

### 3. matrix와 research note도 이미 왕복 가능하다

C7 이후 현재는:

- matrix -> semantics note
- semantics note -> matrix

가 직접 연결되어 있다.

즉 navigation 보강의 핵심 목적은 이미 달성됐다.

### 4. 이제 더 늘리면 noise가 커질 가능성이 높다

추가로 다음까지 직접 연결하기 시작하면 문서군이 빠르게 무거워진다.

- catalog-failure-semantics-decision
- catalog-lookup-failure-split-note
- future failure notes

현재 단계에서는 이런 decision note를 README/results까지 끌어올리는 것보다, research 계층 안에 두는 편이 더 맞다.

## 현재 유지 규칙

1. README는 first-level entry만 유지한다.
2. RESULTS / VALIDATION_HISTORY는 semantics note와 matrix만 직접 연결한다.
3. matrix와 semantics note는 서로 직접 왕복 가능하게 유지한다.
4. decision note는 research 계층 안에서만 접근하게 둔다.

## 예외적으로 다시 열 수 있는 조건

아래 중 하나가 생기면 navigation freeze를 해제할 수 있다.

### A. failure note 수가 더 늘어 탐색 비용이 실제로 커질 때

### B. 사용자가 반복적으로 특정 note를 찾기 어렵다는 피드백을 줄 때

### C. README / results / history만 보고는 다음 문서로 가기 어렵다는 구조적 문제가 생길 때

## 운영 판단

현재 기준 운영 원칙은 다음과 같다.

- 새 failure link는 기본적으로 추가하지 않는다.
- 새 note가 생겨도 먼저 research 계층 안에서만 연결한다.
- README나 RESULTS로 끌어올릴 필요가 반복적으로 확인될 때만 예외로 승격한다.

## 결론 한 줄

`Sprint C10` 기준으로 failure docs navigation은 **이 수준에서 멈추는 것이 맞다.**
