# NEXT_VALIDATION_QUESTION_SELECTION

## 목적

이 문서는 `Sprint D3 - Next Validation Question Selection` 결과를 고정하기 위한 메모다.

질문은 다음과 같다.

- `D2`에서 추린 두 edge case 중 어떤 것을 다음 실검증 질문으로 먼저 잡을 것인가
- 왜 그 질문이 현재 단계에서 가장 작은 다음 단계인가

## 후보 질문

현재 후보는 두 가지였다.

1. `catalog record missing + local artifact exists`
2. `catalog record exists + local artifact missing`

## 선택 결과

판정: `pick catalog record exists + local artifact missing first`

다음 validation sprint에서 먼저 다룰 질문은 아래다.

**catalog record는 남아 있지만 현재 node의 local artifact는 없는 상황을 현재 구현이 어떻게 해석하고 있는가?**

## 왜 이 질문을 먼저 고르는가

### 1. authority 경계를 더 직접적으로 드러낸다

이 질문은 다음을 한 번에 보여 준다.

- catalog truth는 아직 남아 있는가
- local miss는 어떤 의미인가
- same-node/local path와 peer fetch path가 어떻게 갈라지는가
- producer self-loop일 때 무엇이 실패로 기록되는가

즉 `catalog`와 `local metadata`의 역할 차이를 가장 직접적으로 관찰할 수 있다.

### 2. 현재 구현 경로와 더 자연스럽게 맞물린다

현재 구현은 이미 다음 동작을 가지고 있다.

- local miss
- peer fetch fallback
- producer가 self를 가리키면 self-loop failure

즉 새 구조를 만들지 않고도 current behavior를 비교적 자연스럽게 관찰할 수 있다.

### 3. 다른 후보보다 orphan/leftover 해석 부담이 적다

`catalog record missing + local artifact exists`는 중요한 질문이지만, 해석에 아래가 같이 따라온다.

- orphaned copy인가
- leftover인가
- local-only reuse를 허용할 것인가

이건 현재 단계에서 authority boundary보다 storage hygiene 해석으로 번질 가능성이 있다.

반면 `catalog record exists + local artifact missing`는 control-layer 경계에 더 곧게 연결된다.

## 이번 선택으로 고정한 validation 질문

다음 validation sprint의 질문은 아래처럼 고정한다.

### 질문

`catalog record exists + local artifact missing` 상황에서:

- same-node/local path는 어떻게 동작하는가
- cross-node/peer path는 어떻게 동작하는가
- producer self-loop 상황은 어떤 `lastError`로 남는가

### 최소 완료 기준

다음 스프린트에서는 아래 정도를 확인하면 충분하다.

1. fresh artifact id 1개 사용
2. catalog record 유지
3. 특정 node의 local artifact만 의도적으로 제거 또는 비우기
4. HTTP 응답과 local metadata snapshot 확인
5. 결과 문서에 current behavior와 intended interpretation 같이 기록

## 이번에 선택하지 않은 후보

`catalog record missing + local artifact exists`는 버린 것이 아니다.

이 질문은 아래와 같이 다음 순번 후보로 남긴다.

- orphaned/local leftover 해석을 고정해야 할 때
- storage hygiene나 local-only copy semantics를 더 명확히 봐야 할 때

## D3 결론

현재 가장 작은 다음 validation 질문은 **catalog truth는 남아 있지만 local copy는 비어 있는 상황**을 실검증하는 것이다.

이 질문은 failure docs를 더 키우지 않으면서도, control-layer authority 경계를 실제 동작과 연결해 확인할 수 있다.

## 결론 한 줄

`Sprint D3` 기준 다음 validation sprint는 **`catalog record exists + local artifact missing` edge case**를 먼저 검증하는 것이 맞다.
