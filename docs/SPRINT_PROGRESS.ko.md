# SPRINT_PROGRESS

## 목적

이 문서는 `artifact-handoff-poc`의 스프린트 진행 상황을 한 곳에서 추적하기 위한 운영 문서다.

역할:

- 지금까지 어떤 스프린트가 끝났는지 빠르게 확인
- 무엇이 backlog로 남아 있는지 확인
- 다음에 어떤 작은 스프린트를 이어서 할지 판단

이 문서는 설계 본문이 아니라 **진행 상태판**이다. 따라서 스프린트가 끝날 때마다 갱신한다.

## 현재 요약

- 완료 스프린트: `B1` ~ `B16`, `C1`, `C2`, `C3`, `C4`, `C5`, `C6`, `C7`, `C8`, `C9`, `C10`, `C11`, `C12`, `D1`, `D2`, `D3`, `D4`, `D5`, `D6`, `D7`, `D8`, `D9`, `D10`
- 진행률:
  - failure-doc 정리 트랙 `C1~C12` 기준: `12/12` 완료, `100%`
  - post-freeze transition 트랙 `D1~D3` 기준: `3/3` 완료, `100%`
  - first edge-case completion 트랙 `D4~D7` 기준: `4/4` 완료, `100%`
  - second edge-case kickoff 트랙 `D8~D9` 기준: `2/2` 완료, `100%`
  - second edge-case truth 트랙 `D10~D11` 기준: `1/2` 완료, `50%`
  - 현재 문서화된 스프린트 전체 `B1~B16` + `C1~C12` + `D1~D11` 기준: `38/39` 완료, 약 `97%`
  - 이 수치는 문서/검증 정리 로드맵 기준이며, 향후 구현 확장 전체를 뜻하지는 않음
- 현재 상태:
  - Sprint 1 baseline validation과 failure semantics 정리는 상당 부분 완료
  - README / baseline / scope / results / validation history / research note 간 문서 진입 경로도 대부분 정리
  - `Sprint C1`에서 핵심 문서의 한/영 파일 쌍 coverage는 pass로 확인
  - `Sprint C2`에서 현재까지 실증한 failure를 한 장 표로 정리해 관찰 범위를 빠르게 확인할 수 있게 함
  - `Sprint C3`에서 catalog top-level failure reflection을 왜 아직 보류하는지 decision note로 고정
  - `Sprint C4`에서 `TROUBLESHOOTING_NOTES.md` 영문 parity를 한글 문서 수준에 맞춰 보강
  - `Sprint C5`에서 README / RESULTS / VALIDATION_HISTORY에 failure matrix 진입 hook를 추가
  - `Sprint C6`에서 `catalog lookup failed` 세분화는 아직 보류하는 것이 맞다는 판단을 note로 고정
  - `Sprint C7`에서 failure matrix와 failure semantics research note 사이 왕복 경로를 짧게 정리
  - `Sprint C8`에서 failure docs navigation은 현재 수준이면 충분하다는 감사 결론을 고정
  - `Sprint C9`에서 current failure taxonomy는 Sprint 1 범위 안에서 아직 충분히 좁게 유지되고 있다는 판단을 고정
  - `Sprint C10`에서 failure docs navigation은 현재 수준에서 멈추는 것이 맞다는 freeze 결론을 고정
  - `Sprint C11`에서 research README에 별도 failure note index를 추가하지 않는 것이 맞다는 결론을 고정
  - `Sprint C12`에서 현재 Sprint 1 범위의 failure docs 정리 트랙을 여기서 마감 정리하는 summary를 추가
  - 따라서 현재 failure-doc 정리 트랙은 Sprint 1 범위 기준으로 한 차례 닫힌 상태로 본다
  - `Sprint D1`에서 다음 연결점은 failure docs 확장이 아니라 control-layer 갭 재점검이라는 판단을 고정
  - `Sprint D2`에서 catalog/local metadata authority 경계의 남은 최소 갭 두 가지를 좁게 정리
  - `Sprint D3`에서 다음 실검증 질문으로 `catalog record exists + local artifact missing` edge case를 우선 선택
  - `Sprint D4`에서 선택된 edge case를 재현하는 전용 helper script를 추가
  - `Sprint D5`에서 same-node `catalog record exists + local artifact missing`를 실검증하고 current behavior를 결과 문서에 반영
  - `Sprint D6`에서 같은 edge case를 cross-node recovery까지 이어서 보는 것이 다음 최소 단계라는 판단을 고정
  - `Sprint D7`에서 cross-node `catalog record exists + local artifact missing`가 실제로 `peer-fetch` recovery로 이어지는지 확인
  - `Sprint D8`에서 두 번째 edge case를 `catalog record missing + local artifact exists`로 선택하고 다음 helper cut 기준을 고정
  - `Sprint D9`에서 `catalog record missing + local artifact exists`를 재현하는 전용 helper를 추가
  - `Sprint D10`에서 same-node `catalog record missing + local artifact exists`가 `catalog 404`와 동시에 `source=local` 성공으로 드러나는지 실검증

## 완료 스프린트 표

| Sprint | 상태 | 핵심 결과 |
|---|---|---|
| B1 | 완료 | baseline 대비 구현 갭 리뷰 문서화 |
| B2 | 완료 | `producerNode`를 child placement 입력으로 연결 |
| B3 | 완료 | metadata naming/state 정리, catalog validation 강화 |
| B4 | 완료 | README / RESULTS 표현을 현재 구현 수준에 맞게 정리 |
| B5 | 완료 | `multipass-k8s-lab` 실환경 same-node / cross-node / second-hit 재검증 |
| B6 | 완료 | `fetch-failed` / `lastError` failure metadata 기록 강화 |
| B7 | 완료 | self-loop, peer fetch exception 실검증 및 evidence 반영 |
| B8 | 완료 | `local digest mismatch` 실검증, 공개 경로 보정 |
| B9 | 완료 | `peer digest mismatch` live branch 검증, HTTP 한계 확인 |
| B10 | 완료 | peer-side HTTP error attribution 정밀화 |
| B11 | 완료 | failure semantics research note 정리 |
| B12 | 완료 | RESULTS / VALIDATION_HISTORY와 taxonomy cross-link 정리 |
| B13 | 완료 | README에 failure semantics entry hook 추가 |
| B14 | 완료 | PROJECT_BASELINE에 failure semantics hook 추가 |
| B15 | 완료 | SPRINT1_SCOPE에 failure hook 및 scope 정합성 보정 |
| B16 | 완료 | bilingual doc policy note 고정 |
| C1 | 완료 | 핵심 문서 한/영 coverage 감사 및 cross-link 보정 |
| C2 | 완료 | 실증된 failure scenario를 한 장 matrix로 정리 |
| C3 | 완료 | catalog failure semantics defer 판단을 decision note로 고정 |
| C4 | 완료 | TROUBLESHOOTING_NOTES 영문 parity 보강 |
| C5 | 완료 | README / RESULTS / VALIDATION_HISTORY에 failure matrix 진입 hook 추가 |
| C6 | 완료 | `catalog lookup failed` 세분화 defer 판단을 note로 고정 |
| C7 | 완료 | failure matrix와 research note 사이 직접 hook 추가 |
| C8 | 완료 | failure docs entry path가 현재 수준이면 충분하다는 감사 결론 고정 |
| C9 | 완료 | failure taxonomy가 Sprint 1 범위 안에 머문다는 scope check 결론 고정 |
| C10 | 완료 | failure docs navigation을 현재 수준에서 freeze하는 결론 고정 |
| C11 | 완료 | research README에 별도 failure note index를 추가하지 않는 결론 고정 |
| C12 | 완료 | current Sprint 1 failure-doc scope를 여기서 마감 정리하는 summary 추가 |
| D1 | 완료 | post-freeze 이후 다음 연결점은 catalog/local metadata control-layer 갭 재점검이라는 판단 고정 |
| D2 | 완료 | catalog/local metadata authority 경계의 최소 edge-case 갭 목록 정리 |
| D3 | 완료 | 다음 validation 질문으로 `catalog record exists + local artifact missing` edge case를 우선 선택 |
| D4 | 완료 | 선택된 edge case를 재현하는 전용 validation helper script 추가 |
| D5 | 완료 | same-node `catalog record exists + local artifact missing` evidence와 해석 고정 |
| D6 | 완료 | 같은 edge case의 다음 질문은 cross-node recovery check라는 재판단 고정 |
| D7 | 완료 | cross-node `catalog record exists + local artifact missing` evidence와 recovery 해석 고정 |
| D8 | 완료 | 두 번째 edge case를 `catalog record missing + local artifact exists`로 선택 |
| D9 | 완료 | 두 번째 edge case를 재현하는 전용 helper와 cut 문서 추가 |
| D10 | 완료 | same-node `catalog record missing + local artifact exists` evidence와 해석 고정 |

## 현재 backlog

| 영역 | 항목 | 우선순위 | 현재 판단 |
|---|---|---|---|
| 구현 | catalog top-level failure reflection | 중간 | 아직 local metadata 중심 |
| 구현 | replica-aware fetch policy | 낮음 | 현재 범위 밖 유지 |
| 구현 | retry / recovery policy | 낮음 | 현재 범위 밖 유지 |
| 구현 | scheduler/controller 통합 평가 | 낮음 | 아직 script-assisted validation 단계 |
| 운영 | 새 문서 추가 시 bilingual pair 유지 | 높음 | 정책 고정 완료, 계속 실행 필요 |

## 추천 다음 3개 스프린트

### Sprint D8 - Second Edge Case Selection

목표:

- 남아 있는 `catalog record missing + local artifact exists` edge case를 다음 질문으로 바로 가져갈지 재판단

완료 기준:

- 다음 edge case 우선순위를 한 문서로 고정

### Sprint D9 - Second Edge Case Implementation Cut

목표:

- `catalog record missing + local artifact exists`를 재현할 최소 helper 또는 절차를 추가

완료 기준:

- 두 번째 edge case를 실제로 검증할 준비가 됨

### Sprint D10 - Second Edge Case Truth Tightening

목표:

- 선택된 두 번째 edge case를 실제로 재현하고 current behavior를 evidence로 고정

완료 기준:

- HTTP 응답, local metadata, interpretation이 RESULTS / VALIDATION_HISTORY에 반영됨

### Sprint D11 - Second Edge Case Reassessment

목표:

- `D10` 결과를 기준으로 두 번째 edge case의 해석이 충분히 닫혔는지 재판단

완료 기준:

- 다음 질문 또는 종료 판단이 한 문서로 고정됨

### Sprint D12 - Second Edge Cross-Node Check

목표:

- 필요하면 두 번째 edge case를 cross-node 관점에서도 실제로 확인

완료 기준:

- cross-node에서도 catalog absence가 어떤 의미를 갖는지 evidence 또는 defer 판단이 고정됨

## 업데이트 규칙

이후 스프린트가 끝날 때마다 아래를 같이 갱신한다.

1. `현재 요약`
2. `완료 스프린트 표`
3. `현재 backlog`
4. `추천 다음 3개 스프린트`

즉, 이 문서는 일회성 메모가 아니라 **스프린트 진행 기록판**으로 유지한다.
