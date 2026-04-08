# CATALOG_LOCAL_METADATA_GAP_REVIEW

## 목적

이 문서는 `Sprint D2 - Catalog And Local Metadata Gap Review` 결과를 고정하기 위한 메모다.

질문은 다음과 같다.

- 현재 `catalog`와 `local metadata` 사이 authority 경계에서 어떤 작은 갭이 남아 있는가
- 다음 구현 스프린트로 넘길 최소 갭은 무엇인가

## 핵심 요약

판정: `authority boundary is mostly clear, but a few narrow gaps remain`

현재 기준선은 이미 어느 정도 정리되어 있다.

- `catalog`
  - producer origin
  - placement 판단의 기준
- `local metadata`
  - node-local copy 존재
  - verification 결과
  - fetch failure forensic trail

하지만 이 경계가 **모든 코드 경로와 결과 문서에서 동일한 밀도로 드러나는 것은 아직 아니다.**

따라서 다음 구현 스프린트는 authority 모델을 새로 키우는 것이 아니라, 아래 남은 작은 갭을 하나씩 줄이는 방향이 맞다.

## 현재 authority 경계 정리

### catalog가 authoritative source인 것

- `producerNode`
- `producerAddress`
- top-level producer record 존재 여부
- child placement 입력의 기준점

### local metadata가 authoritative source가 아닌 것

- producer origin 판정
- cluster-wide location truth
- placement 판단

### local metadata가 관찰값으로 유효한 것

- 현재 node에 로컬 copy가 있는가
- 그 copy가 `available-local` 또는 `replicated` 상태인가
- 현재 node에서 fetch failure가 났는가
- `lastError`가 무엇인가

## 남아 있는 최소 갭 목록

### 1. catalog record 부재 vs local artifact 존재 상황의 의미가 문서상 완전히 고정돼 있지 않다

현재는 대체로 다음처럼 읽는 것이 맞다.

- local artifact만 있고 catalog record가 없으면:
  - cluster-wide handoff 기준으로는 authoritative하지 않다
  - 단지 node-local leftover 또는 orphaned copy일 가능성이 있다

하지만 이 판단이 README/results 수준까지 직접 고정돼 있지는 않다.

판단:
- 구현 변경 없이도 문서 보강 또는 작은 validation note로 명확히 할 수 있는 갭이다.

### 2. catalog record는 있는데 local artifact가 없는 경우의 해석이 경로별로 조금 다르다

현재는 이 경우:

- same-node/local 경로에서는 local miss가 나고
- cross-node 시도에서는 peer fetch로 이어질 수 있다
- producer 자기 자신이면 self-loop failure가 된다

즉 실제 동작은 설명 가능하지만, “catalog truth는 남아 있고 local copy만 비어 있는 상황”의 semantics가 한 장 문서로 정리돼 있지는 않다.

판단:
- 다음 validation question 후보로 적합하다.

### 3. top-level catalog state와 local state의 역할 차이가 코드/문서에서 반복적으로 다시 설명돼야 한다

현재는:

- catalog top-level state: `produced`
- local metadata state: `available-local`, `replicated`, `fetch-failed`

이 구분이 이미 맞는 방향이지만, 문서마다 다시 설명이 필요하다.

판단:
- 큰 구현 갭이라기보다, 다음 구현 또는 validation 스프린트에서 혼동이 줄도록 한 곳에 더 명확히 고정할 필요가 있다.

### 4. replica metadata는 기록되지만 authority 모델에서 아직 약하다

현재 `replicaNodes`는 기록된다.

하지만 아직:

- placement 기준으로도 직접 쓰이지 않고
- fetch source 선택에도 쓰이지 않고
- authority hierarchy에서도 producer record보다 약한 참고 정보에 머문다

판단:
- 현재 범위에서는 허용 가능하다.
- 다만 “replica metadata는 현재 authoritative source가 아니라 observation/history에 가깝다”는 점을 더 명확히 적을 필요가 있다.

## 다음 구현 스프린트로 넘길 최소 갭

우선순위는 아래처럼 잡는 것이 맞다.

### A. 문서/validation 우선 갭

- `catalog record missing + local artifact exists` 상황의 해석 고정
- `catalog record exists + local artifact missing` 상황의 해석 고정

이 둘은 authority 경계를 실제로 가장 잘 드러내는 edge case다.

### B. 작은 코드/검증 후보

- 위 두 상황 중 하나를 실제 validation scenario로 재현
- current behavior를 결과 문서와 맞춰 확인

### C. 지금 당장 하지 않을 것

- catalog top-level failure reflection
- replica-aware fetch policy
- retry / recovery policy
- broader state machine 확장

## D2 결론

현재 authority 경계 자체는 방향이 맞다.

다음 단계에서 필요한 것은:

1. 새 모델 확장
2. 새 taxonomy 추가

가 아니라,

1. 경계 edge case 해석 고정
2. 그 해석을 작은 validation으로 확인

이다.

## 결론 한 줄

`Sprint D2` 기준으로 다음 구현/검증 후보는 **catalog와 local metadata 경계의 edge case 두 가지를 좁게 확인하는 것**이다.
