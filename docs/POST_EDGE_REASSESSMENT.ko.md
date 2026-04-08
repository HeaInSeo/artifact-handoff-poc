# POST_EDGE_REASSESSMENT

## 목적

이 문서는 `Sprint D6 - Post-Edge Reassessment` 결과를 고정하기 위한 메모다.

질문은 다음과 같다.

- `D5`에서 same-node edge case evidence를 확인한 뒤, 다음 작은 질문은 무엇인가
- 지금 바로 다른 edge case로 넘어갈지, 아니면 같은 edge case를 cross-node 관점까지 먼저 닫을지

## 핵심 요약

판정: `finish the same edge case in cross-node view first`

현재 가장 작은 다음 단계는:

- `catalog record exists + local artifact missing`

를 **cross-node 관점까지 이어서 확인하는 것**이다.

즉 다음 우선순위는 `catalog record missing + local artifact exists`로 바로 넘어가는 것이 아니라, 이미 선택하고 일부 검증한 같은 edge case를 한 단계 더 완성하는 쪽이 맞다.

## 왜 cross-node recovery check가 다음 순서인가

### 1. 같은 질문을 반쪽만 닫은 상태다

`D5`에서는 same-node path만 확인했다.

즉 현재까지 아는 것은:

- catalog truth는 유지된다
- same-node local artifact가 없으면 self-loop failure가 난다

하지만 아직 모르는 것은:

- 다른 node에서는 같은 상황이 peer fetch recovery로 이어지는가

같은 질문 안에서 이 한 칸이 비어 있으므로, 먼저 메우는 편이 맞다.

### 2. authority 경계를 더 완전하게 보여 준다

same-node evidence만 있으면 “local artifact가 없으면 실패한다”는 쪽이 더 강하게 보인다.

cross-node recovery까지 확인되면:

- catalog truth는 남아 있다
- same-node local availability는 없다
- 하지만 non-producer node에서는 peer fetch로 recovery할 수 있다

라는 더 완전한 authority/control-layer picture가 나온다.

### 3. 다른 edge case보다 현재 맥락 전환 비용이 적다

`catalog record missing + local artifact exists`는 여전히 중요한 질문이지만, 그 순간부터는 orphan/local-leftover 해석이 다시 중심이 된다.

반면 지금은:

- 같은 helper를 재사용할 수 있고
- 같은 artifact semantics를 유지할 수 있고
- 같은 결과 문서 섹션을 확장할 수 있다

즉 범위 전환 비용이 더 낮다.

## 이번 스프린트에서 고정한 다음 질문

다음 validation sprint의 질문은 아래로 고정한다.

### 질문

`catalog record exists + local artifact missing` cross-node case에서:

- consumer node는 peer fetch recovery로 성공하는가
- 응답 `source`는 `peer-fetch`인가
- consumer local metadata는 어떤 state/source로 남는가
- catalog는 producer truth를 그대로 유지하는가

### 최소 완료 기준

1. fresh artifact id 1개 사용
2. producer node local artifact는 제거하지 않음
3. consumer node local artifact만 비운 상태에서 GET 수행
4. HTTP 성공 여부, `source`, local metadata snapshot 수집
5. 결과 문서에 same-node와 cross-node 차이를 나란히 기록

## 이번에 아직 선택하지 않은 질문

`catalog record missing + local artifact exists`는 버린 것이 아니다.

다만 이 질문은 다음 조건에서 다시 여는 것이 맞다.

- cross-node recovery check까지 끝난 뒤
- orphaned/local-leftover semantics를 별도 질문으로 좁힐 준비가 됐을 때

## D6 결론

현재는 새 질문으로 넘어가기보다, 이미 선택한 edge case를 cross-node까지 닫는 것이 가장 작은 다음 단계다.

## 결론 한 줄

`Sprint D6` 기준으로 다음 스프린트는 **`catalog record exists + local artifact missing`의 cross-node recovery check**가 맞다.
