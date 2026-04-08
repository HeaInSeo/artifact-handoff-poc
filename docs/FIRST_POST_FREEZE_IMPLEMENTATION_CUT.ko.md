# FIRST_POST_FREEZE_IMPLEMENTATION_CUT

## 목적

이 문서는 `Sprint D4 - First Post-Freeze Implementation Cut`에서 넣은 가장 작은 구현/검증 보정을 기록한다.

## 이번 cut의 범위

이번 스프린트에서는 새 control plane을 추가하지 않았다.

대신 `D3`에서 고른 edge case:

- `catalog record exists + local artifact missing`

를 실제로 재현할 수 있도록 전용 validation helper script를 추가했다.

추가 파일:

- [run-edge-case-local-miss.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-edge-case-local-miss.sh)

## 왜 이 정도가 가장 작은 cut인가

기존 `run-same-node.sh`, `run-cross-node.sh`를 크게 바꾸면 Sprint 1 정상 경로 검증 스크립트까지 흔들리게 된다.

이번 질문은 정상 경로가 아니라 edge case 검증이므로, 별도 helper를 두는 편이 더 안전하고 범위도 작다.

## helper가 하는 일

1. fresh artifact를 producer node에 생성
2. catalog에서 `producerNode`를 읽어 producer truth를 확인
3. 선택한 consumer node의 hostPath artifact 디렉터리만 제거
4. 해당 node에서 `/artifacts/{id}` GET 수행
5. HTTP 결과와 로그를 그대로 남김

지원 모드:

- 기본: `same-node`
- 옵션: `--cross-node`

즉 같은 helper로:

- producer self-loop/local miss 상황
- peer-fetch fallback 상황

둘 다 재현 준비를 할 수 있다.

## 이번 cut에서 의도적으로 하지 않은 것

- agent behavior 변경
- catalog state model 변경
- replica-aware fetch policy 추가
- retry / recovery logic 추가

이번 cut의 목적은 새 semantics를 만들기보다, **선택된 edge case를 실험 가능한 형태로 만드는 것**이다.

## 다음 스프린트로 넘기는 포인트

이제 다음 스프린트에서는 이 helper를 실제로 실행해서:

- same-node/local miss가 self-loop failure로 남는지
- cross-node 모드에서 peer fetch로 회복되는지
- local metadata에 어떤 `lastError`가 남는지

를 evidence로 확인하면 된다.

## 결론 한 줄

`Sprint D4`의 구현 cut은 **선택된 edge case를 별도 helper script로 재현 가능하게 만든 것**이다.
