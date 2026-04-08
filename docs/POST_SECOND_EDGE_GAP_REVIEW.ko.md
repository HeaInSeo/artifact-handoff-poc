# POST_SECOND_EDGE_GAP_REVIEW

## 목적

이 문서는 `Sprint E1 - Post-Second-Edge Gap Review` 결과를 고정하기 위한 메모다.

배경:

- 첫 번째 edge-case family는 `D7`에서 닫혔다.
- 두 번째 edge-case family는 `D13`에서 현재 Sprint 1 validation 범위 기준으로 닫혔다.

따라서 다음 질문은 edge-case family를 더 확장하는 것이 아니라, backlog에서 무엇을 가장 작은 다음 단계로 가져올지 다시 고르는 것이다.

## 현재 backlog 후보

현재 기준 backlog는 크게 아래로 요약된다.

1. `catalog top-level failure reflection`
2. orphan/local-leftover semantics
3. replica-aware fetch policy
4. retry / recovery policy
5. scheduler/controller integration evaluation

## 이번 재검토의 결론

다음 우선순위는 아래로 고정한다.

- `orphan/local-leftover semantics`를 먼저 문서 판단 note로 정리

즉 다음 질문은:

- `catalog record missing + local artifact exists`에서 관찰된 same-node local reuse를 현재 단계에서 어떻게 해석할 것인가

를 policy 수준이 아니라 **research/validation note 수준**에서 한 번 더 좁게 정리하는 것이다.

## 왜 이 질문이 다음으로 맞는가

이유는 세 가지다.

1. 방금 닫은 두 번째 edge-case family와 직접 이어진다.
2. 코드 확장 없이 문서 판단으로 먼저 범위를 고정할 수 있다.
3. `catalog top-level failure reflection`보다 현재 구현 truth와 더 가깝다.

특히 `catalog top-level failure reflection`은 다음을 같이 열어 버린다.

- global failure state semantics
- state transition ownership
- transient failure와 durable state 구분

반면 orphan/local-leftover semantics는 현재까지 이미 관찰된 사실:

- same-node local-first reuse
- cross-node catalog-lookup failure

를 어떻게 읽을지 정리하는 문제다.

## 이번 스프린트에서 고정한 우선순위

우선순위 1:

- `E2 - Orphan Semantics Note`

우선순위 2:

- `E3 - Catalog Failure Reflection Recheck`

우선순위 3:

- 그 이후에 가장 작은 validation 또는 구현 질문 1개 선택

## 지금 당장 하지 않을 것

다음 항목은 계속 보류한다.

- replica-aware fetch policy
- retry / recovery policy
- scheduler/controller integration

이들은 모두 현재 단계보다 큰 확장을 요구한다.

## 결론 한 줄

`Sprint E1`의 결론은 **다음 가장 작은 질문은 orphan/local-leftover semantics를 먼저 문서로 고정하는 것이고, catalog top-level failure reflection은 그 다음 순서로 둔다**는 것이다.
