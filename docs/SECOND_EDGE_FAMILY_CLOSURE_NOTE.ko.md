# SECOND_EDGE_FAMILY_CLOSURE_NOTE

## 목적

이 문서는 `Sprint D13 - Second Edge Family Closure Note`의 결론을 고정한다.

대상 edge-case family:

- `catalog record missing + local artifact exists`

기준 evidence:

- [SECOND_EDGE_CASE_TRUTH_TIGHTENING.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_CASE_TRUTH_TIGHTENING.ko.md)
- [SECOND_EDGE_CROSS_NODE_CHECK.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_CROSS_NODE_CHECK.ko.md)

## 현재까지 채워진 두 관점

same-node:

- catalog lookup은 `404`
- 공개 `/artifacts/{id}`는 `source=local`, `200`
- local metadata는 `available-local`

cross-node:

- consumer local hit는 없음
- catalog lookup은 `404`
- 공개 `/artifacts/{id}`는 `catalog lookup failed`, `404`
- consumer local metadata는 `fetch-failed`, `source=catalog-lookup`

즉 이 family는 이제 node 위치에 따라 갈리는 두 결과가 모두 evidence로 채워졌다.

## closure 판단

이번 스프린트의 결론은:

- 이 edge-case family는 **현재 Sprint 1 범위에서는 여기서 닫는 것이 맞다**

판단 이유:

1. same-node와 cross-node 두 관점이 모두 live evidence로 채워졌다.
2. 현재 구현이 실제로 무엇을 하는지 설명하는 데 필요한 최소 truth는 확보됐다.
3. 더 들어가면 질문이 `authority boundary validation`에서 `orphan semantics / cleanup policy` 쪽으로 커지기 시작한다.

따라서 현재 family closure verdict는:

- `closed for current validation scope`

## 무엇을 닫았고 무엇을 닫지 않았는가

닫힌 것:

- current implementation truth
- node position에 따라 결과가 갈린다는 점
- same-node local-first reuse vs cross-node catalog-lookup failure 구분

닫지 않은 것:

- orphan/local-leftover를 정책적으로 허용할지 여부
- orphan cleanup policy
- catalog top-level failure reflection
- replica-aware fetch policy

즉 이번 closure는 **현재 동작의 validation closure**이지, 정책 closure나 production semantics closure는 아니다.

## 왜 추가 후속 note를 만들지 않는가

이번 시점에서 orphan semantics note를 별도로 여는 것은 과하다.

그 질문은 다음과 같은 더 큰 확장을 연다.

- local leftover를 계속 재사용 가능한 artifact로 볼 것인가
- local copy와 catalog truth 사이 GC/cleanup 정책을 둘 것인가
- scheduler/controller 연계 시 이 상황을 어떻게 다룰 것인가

이 질문들은 모두 현재 Sprint 1 범위를 넘어선다.

## 최종 결론

두 번째 edge-case family는 현재 범위에서 아래처럼 고정한다.

- same-node: surviving local copy가 catalog absence를 가릴 수 있다
- cross-node: local hit가 없으면 catalog absence가 lookup failure로 드러난다

여기까지를 현재 validation scope의 closure로 본다.

## 결론 한 줄

`Sprint D13`의 결론은 **`catalog record missing + local artifact exists` family는 현재 Sprint 1 validation 범위에서는 닫고, orphan semantics나 cleanup policy는 후속 범위로 남긴다**는 것이다.
