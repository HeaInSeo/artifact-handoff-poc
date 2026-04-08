# FAILURE_NOTE_INDEX_REVIEW

## 목적

이 문서는 `Sprint C11 - Failure Note Index Review` 판단을 고정하기 위한 메모다.

질문은 다음과 같다.

- `docs/research/README*` 수준에서 failure 관련 note index를 별도로 추가해야 하는가
- 아니면 현재 구조를 유지하는 것이 맞는가

## 결론

판정: `no dedicated failure-note index for now`

현재 단계에서는 `docs/research/README*`에 별도 failure note index를 추가하지 않는 편이 맞다.

## 왜 지금은 추가하지 않는가

### 1. 이미 첫 진입점과 두 번째 진입점이 있다

현재는 이미 다음 경로가 있다.

- README -> failure semantics note
- README -> failure matrix
- RESULTS / VALIDATION_HISTORY -> semantics note
- RESULTS / VALIDATION_HISTORY -> failure matrix

즉 failure 문서를 찾기 위한 첫 번째, 두 번째 진입 경로는 이미 충분하다.

### 2. research README를 너무 무겁게 만들 필요가 없다

`docs/research/README*`는 조사 축과 권장 조사 문서를 설명하는 입구 문서다.

여기에 별도 failure note index를 추가하면:

- research README가 failure note 전용 index처럼 보이기 쉬워지고
- decision note hierarchy를 다시 전면에 끌어올리게 된다

현재 단계에서는 그 정도 밀도가 필요하지 않다.

### 3. freeze 결론과도 맞아야 한다

이미 `Sprint C8`, `Sprint C10`에서 다음 결론을 고정했다.

- 현재 failure docs navigation은 balanced enough
- 현재 수준에서 freeze하는 것이 맞다

따라서 별도 failure note index를 새로 만드는 것은 이 결론과도 어긋난다.

## 지금 유지할 구조

1. README는 first-level entry를 제공한다.
2. RESULTS / VALIDATION_HISTORY는 semantics note와 matrix를 통해 second-level entry를 제공한다.
3. research note 내부의 decision note는 research 계층 안에서 찾게 둔다.

## 나중에 다시 열 수 있는 조건

아래 중 하나가 생기면 dedicated failure-note index를 다시 검토할 수 있다.

### A. failure note 수가 더 늘어나 research 폴더 안에서 탐색 비용이 분명히 커질 때

### B. 사용자가 반복적으로 특정 failure note를 찾기 어렵다는 피드백을 줄 때

### C. README / RESULTS / matrix만으로는 research note hierarchy를 따라가기 어려워질 때

## 결론 한 줄

`Sprint C11` 기준으로는 **research README에 별도 failure note index를 추가하지 않는 것이 맞다.**
