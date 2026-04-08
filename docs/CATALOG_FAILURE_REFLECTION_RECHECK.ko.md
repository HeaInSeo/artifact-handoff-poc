# CATALOG_FAILURE_REFLECTION_RECHECK

## 목적

이 문서는 `Sprint E3 - Catalog Failure Reflection Recheck` 결과를 고정하기 위한 메모다.

질문:

- 두 번째 edge-case family까지 닫힌 뒤에도 `catalog top-level failure reflection`을 계속 보류하는 것이 맞는가

참고 기준:

- [catalog-failure-semantics-decision.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/catalog-failure-semantics-decision.ko.md)
- [SECOND_EDGE_CASE_TRUTH_TIGHTENING.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_CASE_TRUTH_TIGHTENING.ko.md)
- [SECOND_EDGE_CROSS_NODE_CHECK.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_CROSS_NODE_CHECK.ko.md)

## 현재까지 추가로 확인된 사실

두 번째 edge-case family를 통해 아래가 더 분명해졌다.

same-node:

- catalog lookup은 `404`
- 하지만 surviving local copy가 있으면 공개 `/artifacts/{id}`는 `source=local`로 성공한다

cross-node:

- local hit가 없고
- catalog truth도 없으면
- 공개 `/artifacts/{id}`는 `catalog lookup failed`와 `fetch-failed` metadata로 종료된다

즉 consumer 관점 failure와 same-node local success가 같은 family 안에서도 node 위치에 따라 갈린다.

## 이번 재검토의 결론

결론은 이전과 같다.

- `catalog top-level failure reflection`은 **계속 defer가 맞다**

판정:

- `defer 유지`

## 왜 여전히 defer가 맞는가

### 1. 새 evidence가 catalog-level global failure state의 필요성을 강하게 만들지는 않았다

이번에 더 분명해진 것은:

- local hit가 catalog absence를 가릴 수 있다는 점
- non-producer node에서는 catalog absence가 lookup failure로 바로 드러난다는 점

이다.

하지만 이것은 어디까지나 **node-position-dependent observed behavior**를 더 잘 설명해 준 것이지,
catalog를 global failure truth로 키워야 한다는 근거는 아니다.

### 2. consumer-specific failure를 top-level truth로 승격시키면 authority 경계가 더 흐려진다

cross-node consumer는 `catalog lookup failed`를 본다.
same-node producer/local node는 동시에 `source=local` 성공을 볼 수 있다.

이 상황에서 catalog top-level state에 실패를 기록하기 시작하면 곧바로 아래 질문이 열린다.

- 어느 node 관찰값을 top-level truth로 채택할 것인가
- same-node success와 cross-node failure가 동시에 있으면 어떤 state가 대표 상태인가
- local leftover success가 있더라도 cluster-wide state를 failure로 둘 것인가

이 질문들은 현재 authority boundary를 단순화하기보다 복잡하게 만든다.

### 3. 현재 evidence는 local metadata + results/history 조합으로 이미 충분히 해석 가능하다

지금까지 실증한 경로는 다음 조합으로 읽을 수 있다.

- catalog:
  - producer origin
  - placement input
- local metadata:
  - current node local copy
  - `fetch-failed`
  - `lastError`
- results/history docs:
  - node-position-dependent interpretation

현재 Sprint 1 범위에서는 이 조합만으로도 “무슨 일이 일어났는가”를 추적하기에 충분하다.

## 이번 재검토에서 추가로 고정한 점

- same-node local success가 있다고 해서 catalog top-level state를 success로 재정의하지 않는다
- cross-node lookup failure가 있다고 해서 catalog top-level state를 failure로 승격하지 않는다
- catalog는 계속 producer origin / placement input registry로 남긴다
- failure forensic trail은 계속 local metadata와 결과 문서 쪽에 둔다

## 아직 남는 질문

- orphan/local-leftover semantics를 허용된 current behavior로만 볼지, 더 강한 policy 의미를 부여할지는 아직 별도 note가 필요하다
- multi-consumer aggregate failure 관찰이 정말 필요해지는 시점이 오면 catalog reflection을 다시 검토할 수 있다

## 결론 한 줄

`Sprint E3`의 결론은 **두 번째 edge-case family까지 반영해도 catalog top-level failure reflection은 계속 보류하는 것이 맞고, 현재는 local metadata + results/history 해석 구조를 유지한다**는 것이다.
