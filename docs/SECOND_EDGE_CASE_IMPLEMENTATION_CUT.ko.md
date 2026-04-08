# SECOND_EDGE_CASE_IMPLEMENTATION_CUT

## 목적

이 문서는 `Sprint D9 - Second Edge Case Implementation Cut`에서 넣은 가장 작은 구현/검증 보정을 기록한다.

## 이번 cut의 범위

이번 스프린트에서는 새 control plane이나 새 state model을 추가하지 않았다.

대신 `Sprint D8`에서 선택한 두 번째 edge case:

- `catalog record missing + local artifact exists`

를 실제로 재현할 수 있도록 전용 validation helper script를 추가했다.

추가 파일:

- [run-edge-case-catalog-miss.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-edge-case-catalog-miss.sh)

## 왜 이 정도가 가장 작은 cut인가

이 질문의 핵심은 local artifact copy는 유지한 채, catalog truth만 사라지게 만드는 것이다.

기존 helper나 happy-path script를 크게 바꾸면:

- 첫 번째 edge-case 절차와 섞이기 쉽고
- Sprint 1 정상 검증 흐름까지 흔들릴 수 있다.

그래서 이번에도 별도 helper를 두는 편이 더 작고 안전하다.

## helper가 하는 일

1. fresh artifact를 producer node에 생성
2. catalog에서 `producerNode`를 읽어 producer truth를 한 번 확인
3. `artifact-catalog`를 재시작해 emptyDir-backed catalog state를 비움
4. local artifact copy는 그대로 둔 채 same-node에서 `/artifacts/{id}` GET 수행
5. parent / drop-catalog / consumer 로그를 그대로 남김

즉 이번 helper는 fresh artifact를 만든 뒤 catalog state만 비우고, local artifact copy는 그대로 남겨 두는 가장 좁은 재현 절차다.

지원 모드:

- 기본: `same-node`
- 옵션: `--cross-node`

## 이번 cut에서 의도적으로 하지 않은 것

- agent behavior 변경
- catalog delete API 추가
- catalog state machine 확장
- orphan cleanup logic 추가
- replica-aware fetch policy 추가

이번 cut의 목적은 semantics를 확장하는 것이 아니라, **선택된 두 번째 edge case를 재현 가능한 형태로 만드는 것**이다.

## 다음 스프린트로 넘기는 포인트

이제 다음 `D10`에서는 이 helper를 실제로 실행해서 아래를 확인하면 된다.

- catalog record가 사라진 상태에서 local artifact가 실제로 재사용되는지
- 아니면 lookup/control-layer failure로 드러나는지
- local metadata에는 어떤 `state`, `source`, `lastError`가 남는지

## 결론 한 줄

`Sprint D9`의 구현 cut은 **local copy는 유지하고 catalog truth만 제거하는 전용 helper를 추가해 두 번째 edge case를 실험 가능하게 만든 것**이다.
