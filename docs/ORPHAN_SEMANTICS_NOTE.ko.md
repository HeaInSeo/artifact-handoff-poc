# ORPHAN_SEMANTICS_NOTE

## 목적

이 문서는 `Sprint E2 - Orphan Semantics Note` 결과를 고정하기 위한 메모다.

질문:

- `catalog record missing + local artifact exists` 상황에서 관찰된 동작을 현재 validation 범위에서 어떻게 읽어야 하는가

특히 아래 두 관찰값을 어떻게 해석할지 정리한다.

- same-node: `source=local` 성공
- cross-node: `catalog lookup failed`

## 기준 evidence

이 note는 아래 실검증 결과를 기준으로 한다.

- [SECOND_EDGE_CASE_TRUTH_TIGHTENING.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_CASE_TRUTH_TIGHTENING.ko.md)
- [SECOND_EDGE_CROSS_NODE_CHECK.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_CROSS_NODE_CHECK.ko.md)
- [SECOND_EDGE_FAMILY_CLOSURE_NOTE.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_FAMILY_CLOSURE_NOTE.ko.md)

## 현재까지 관찰된 사실

### same-node

- catalog lookup은 `404`
- 하지만 surviving local copy와 local metadata가 있으면 공개 `/artifacts/{id}`는 `200`, `source=local`로 성공

### cross-node

- consumer node에는 local hit가 없음
- catalog lookup도 `404`
- 공개 `/artifacts/{id}`는 `catalog lookup failed`와 `fetch-failed` metadata로 종료

## 이번 note의 결론

현재 범위에서는 아래처럼 읽는다.

- same-node local-first reuse는 **현재 구현에서 허용된 observed behavior**로 본다
- 하지만 이것을 곧바로 **orphan를 정책적으로 허용한다**는 뜻으로 확장하지는 않는다

즉 판정은 다음과 같다.

- `current behavior truth`: yes
- `policy approval`: not yet

## 왜 이렇게 읽는가

### 1. 현재 구현은 local hit를 catalog lookup보다 먼저 본다

same-node evidence는 현재 public `/artifacts/...` 경로가 local hit를 먼저 확인한다는 점을 보여 준다.

따라서 catalog record가 사라졌더라도:

- local copy가 살아 있고
- local metadata가 유효하면
- 현재 구현은 그 artifact를 계속 재사용한다

이건 버그라고 단정하기보다, **현재 구현 truth**로 먼저 받아들이는 편이 맞다.

### 2. 하지만 이것을 orphan policy로 승격시키기에는 아직 이르다

다음 질문들은 아직 열려 있다.

- orphan/local-leftover를 의도적으로 유지할 것인가
- cleanup/GC가 있어야 하는가
- catalog와 local metadata 불일치를 얼마나 오래 허용할 것인가
- local-only reuse를 정책적으로 문서화할 것인가

이건 현재 Sprint 1 validation 범위보다 크다.

### 3. cross-node evidence가 same-node local reuse를 policy truth로 만들지 않는다

cross-node에서는 같은 family가 바로 `catalog lookup failed`로 드러난다.

즉 이 동작은 cluster-wide general rule이 아니라:

- local hit가 살아 있을 때만 보이는 current behavior

에 가깝다.

따라서 현재 단계에서는 orphan/local-leftover를 “허용된 운영 정책”으로 고정하기보다,
**node-position-dependent current behavior**로만 읽는 것이 더 정확하다.

## 이번 스프린트에서 고정한 경계

현재 note가 허용하는 해석:

- same-node surviving local copy는 catalog absence를 가릴 수 있다
- cross-node에서는 catalog absence가 lookup failure로 드러난다
- 이 차이는 current implementation truth다

현재 note가 아직 고정하지 않는 것:

- orphan/local-leftover retention policy
- cleanup/GC policy
- catalog-local divergence 허용 기간
- orphan artifact를 정상 기능으로 공식화하는지 여부

## 현재 운영 표현

따라서 문서 표현은 아래 수준이 맞다.

- `same-node local-first reuse can mask catalog absence`
- `this is an observed current behavior, not yet a broader orphan-retention policy`

## 결론 한 줄

`Sprint E2`의 결론은 **`catalog record missing + local artifact exists`에서 보이는 same-node local reuse는 현재 구현에서 관찰된 truth로 받아들이되, 아직 orphan/local-leftover를 정책적으로 허용한 것으로 해석하지는 않는다**는 것이다.
