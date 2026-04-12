# SPRINT_PROGRESS

## 목적

이 문서는 `artifact-handoff-poc`의 스프린트 진행 상황을 한 곳에서 추적하기 위한 운영 문서다.

역할:

- 지금까지 어떤 스프린트가 끝났는지 빠르게 확인
- 무엇이 backlog로 남아 있는지 확인
- 다음에 어떤 작은 스프린트를 이어서 할지 판단

이 문서는 설계 본문이 아니라 **진행 상태판**이다. 따라서 스프린트가 끝날 때마다 갱신한다.

현재 완료 범위와 남은 스프린트를 한 번에 보려면 [PROJECT_COMPLETION_VIEW.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PROJECT_COMPLETION_VIEW.ko.md)를 같이 본다.
전체 backlog를 포함한 보수적 6주 병렬 일정은 [PARALLEL_6W_DELIVERY_PLAN.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PARALLEL_6W_DELIVERY_PLAN.ko.md)에서 관리한다.

## 현재 요약

- 완료 스프린트: `B1` ~ `B16`, `C1`, `C2`, `C3`, `C4`, `C5`, `C6`, `C7`, `C8`, `C9`, `C10`, `C11`, `C12`, `D1`, `D2`, `D3`, `D4`, `D5`, `D6`, `D7`, `D8`, `D9`, `D10`, `D11`, `D12`, `D13`, `E1`, `E2`, `E3`, `E4`, `E5`, `F1`, `F2`, `F3`, `F4`, `F5`, `F6`, `F7`, `F8`, `F9`, `G1`, `G2`, `H1`, `H2`, `H3`, `I1`, `I2`, `I3`, `J1`, `J2`, `K1`, `K2`, `L1`, `L2`, `M1`, `M2`, `N1`, `N2`, `O1`, `O2`, `P1`, `P2`, `Q1`, `Q2`, `R1`, `R2`, `S1`, `S2`, `T1`, `T2`, `T3`
- 진행률:
  - failure-doc 정리 트랙 `C1~C12` 기준: `12/12` 완료, `100%`
  - post-freeze transition 트랙 `D1~D3` 기준: `3/3` 완료, `100%`
  - first edge-case completion 트랙 `D4~D7` 기준: `4/4` 완료, `100%`
  - second edge-case kickoff 트랙 `D8~D9` 기준: `2/2` 완료, `100%`
  - second edge-case truth 트랙 `D10~D11` 기준: `2/2` 완료, `100%`
  - second edge-case cross-node follow-up 트랙 `D12~D13` 기준: `2/2` 완료, `100%`
  - post-second-edge planning 트랙 `E1~E4` 기준: `4/4` 완료, `100%`
  - post-E2 freeze track `E5` 기준: `1/1` 완료, `100%`
  - next execution planning 트랙 `F1~F3` 기준: `3/3` 완료, `100%`
  - replica-aware first validation 트랙 `F4~F5` 기준: `2/2` 완료, `100%`
  - replica-aware decision 트랙 `F6` 기준: `1/1` 완료, `100%`
  - producer-bias validation 트랙 `F7` 기준: `1/1` 완료, `100%`
  - replica source-selection minimal cut 트랙 `F8` 기준: `1/1` 완료, `100%`
  - replica-aware validation 트랙 `F9` 기준: `1/1` 완료, `100%`
  - post-replica-aware review 트랙 `G1~G2` 기준: `2/2` 완료, `100%`
  - current post-replica-aware follow-up 트랙 `H1~H3` 기준: `3/3` 완료, `100%`
  - next post-H3 reset track `I1~I2` 기준: `2/2` 완료, `100%`
  - next implementation selection track `I3` 기준: `1/1` 완료, `100%`
  - next execution cut track `J1` 기준: `1/1` 완료, `100%`
  - post-I3 refresh track `J2` 기준: `1/1` 완료, `100%`
  - post-J1 validation entry track `K1` 기준: `1/1` 완료, `100%`
  - multi-replica first validation track `K2` 기준: `1/1` 완료, `100%`
  - post-K2 backlog review track `L1` 기준: `1/1` 완료, `100%`
  - post-K2 completion refresh track `L2` 기준: `1/1` 완료, `100%`
  - post-L2 implementation reset track `M1` 기준: `1/1` 완료, `100%`
  - multi-replica ordering entry track `M2` 기준: `1/1` 완료, `100%`
  - post-M2 execution cut track `N1` 기준: `1/1` 완료, `100%`
  - post-M2 completion refresh track `N2` 기준: `1/1` 완료, `100%`
  - post-N2 backlog review track `O1` 기준: `1/1` 완료, `100%`
  - post-O1 implementation entry track `O2` 기준: `1/1` 완료, `100%`
  - post-O2 execution cut track `P1` 기준: `1/1` 완료, `100%`
  - post-P1 completion refresh track `P2` 기준: `1/1` 완료, `100%`
  - post-P2 backlog review track `Q1` 기준: `1/1` 완료, `100%`
  - post-Q1 implementation entry track `Q2` 기준: `1/1` 완료, `100%`
  - post-Q2 execution cut track `R1` 기준: `1/1` 완료, `100%`
  - post-R1 completion refresh track `R2` 기준: `1/1` 완료, `100%`
  - post-R2 backlog review track `S1` 기준: `1/1` 완료, `100%`
  - post-S1 implementation entry track `S2` 기준: `1/1` 완료, `100%`
  - post-S2 execution cut track `T1` 기준: `1/1` 완료, `100%`
  - post-T1 completion refresh track `T2` 기준: `1/1` 완료, `100%`
  - post-T2 backlog review track `T3` 기준: `1/1` 완료, `100%`
  - 현재 문서화된 스프린트 전체 `B1~B16` + `C1~C12` + `D1~D13` + `E1~E5` + `F1~T3` 기준: `86/86` 완료, `100%`
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
  - `Sprint D11`에서 두 번째 edge case는 same-node truth는 닫혔지만 cross-node view 전까지는 전체 family를 완전히 닫지 않는다는 재판단을 고정
  - `Sprint D12`에서 cross-node `catalog record missing + local artifact exists`는 `catalog lookup failed`와 `fetch-failed` metadata로 드러난다는 사실을 실검증
  - `Sprint D13`에서 두 번째 edge-case family는 현재 Sprint 1 validation 범위에서는 여기서 닫고, orphan semantics는 후속 범위로 남긴다는 closure 판단을 고정
  - `Sprint E1`에서 다음 우선순위는 orphan/local-leftover semantics note이고, catalog top-level failure reflection은 그 다음 순서라는 gap review 판단을 고정
  - `Sprint E2`에서 same-node local-first reuse는 current behavior truth로 받아들이되, orphan/local-leftover를 정책적으로 허용한 것으로는 아직 해석하지 않는다는 note를 고정
  - `Sprint E3`에서 두 번째 edge-case family 결과를 반영해도 catalog top-level failure reflection은 계속 defer가 맞다는 재검토 결론을 고정
  - `Sprint E4`에서 broader policy boundary는 더 확장하지 않고, 남은 좁은 정책 질문은 `E2 - Orphan Semantics Note` 하나로 제한하는 것이 맞다는 판단을 고정
  - `Sprint E5`에서 현재 Sprint 1 범위의 policy/document cleanup은 여기서 freeze하고, 다음부터는 다음 validation/implementation 질문 선택으로 넘어가는 것이 맞다는 판단을 고정
  - `Sprint F1`에서 다음 실제 질문은 `replicaNodes`를 fetch source selection에 의미 있게 연결할 수 있는지 검토하는 가장 작은 replica-aware fetch 질문으로 고정
  - `Sprint F2`에서 구현 backlog를 다시 순서화하고, `replica-aware fetch`를 1순위, `catalog top-level failure reflection`을 2순위로 고정
  - `Sprint F3`에서 replica-aware fetch를 위한 가장 작은 실행 cut로, first replica와 `replicaNodes` 준비 상태를 반복 가능하게 만드는 전용 helper를 추가
  - `Sprint F4`에서 live 검증으로 `replicaNodes`와 replica metadata가 실제로 준비되는 것은 확인했지만, actual fetch source selection은 여전히 `producerAddress` 중심이라는 첫 evidence를 고정
  - `Sprint F5`에서 replica-aware 후속 순서를 `validation first, cut second`로 고정하고, 다음 판단 메모를 `F6 - Replica-Aware Decision Note`로 좁힘
  - `Sprint F6`에서 다음 즉시 실행은 producer-bias validation을 먼저 두고, 최소 replica source-selection cut는 그 다음으로 미루는 것이 맞다는 decision을 고정
  - `Sprint F7`에서 first replica와 `replicaNodes`가 살아 있어도 third-node consumer는 broken `producerAddress`만 따라가다 실패한다는 live evidence를 확보
  - `Sprint F8`에서 `peer_fetch()`의 remote candidate set을 `producerAddress` 하나에서 `producer + replicaNodes`로 확장하는 최소 cut를 추가
  - `Sprint F9`에서 broken producer 상황에서도 third-node consumer가 replica fallback으로 `200 source=peer-fetch`를 받는다는 live evidence를 확보
  - `Sprint G1`에서 replica-aware 첫 사이클 이후 남은 최소 갭은 actual fetch endpoint observability와 ordering semantics라는 점을 고정
  - `Sprint G2`에서 다음 후속 순서를 completion refresh, observability, ordering semantics 순으로 다시 정렬
  - `Sprint H1`에서 completion overview와 progress board가 replica-aware 첫 사이클 이후 동일한 남은 질문 세트를 가리키도록 다시 정리
  - `Sprint H2`에서 actual fetch endpoint observability는 현재 metadata model 확장보다는 refinement 주제로 보고 defer 유지가 맞다는 판단을 고정
  - `Sprint H3`에서 producer-first ordering은 현재 구현 truth로 보되, 더 넓은 policy commitment로는 아직 읽지 않는다는 판단을 고정
  - `Sprint I1`에서 replica-aware 첫 사이클 이후 다음 실제 implementation backlog는 multi-replica policy 우선, retry/recovery 그 다음으로 재설정
  - `Sprint I2`에서 completion overview와 progress board가 backlog reset 이후 직접 남은 질문을 `I3`, `J1` 기준으로 다시 가리키도록 정리
  - `Sprint I3`에서 next real implementation question은 retry/recovery가 아니라 multi-replica policy로 고정
  - `Sprint J1`에서 producer + first replica + second replica 상태를 반복 가능하게 만드는 multi-replica 전용 helper cut를 추가
  - `Sprint J2`에서 `J1` 이후 직접 남은 질문은 `K1 - Post-J1 Validation Entry`, 그 다음 실검증은 `K2 - Multi-Replica First Validation`이라는 구조로 completion view와 progress board를 다시 맞춤
  - `Sprint K1`에서 first multi-replica validation question을 `producer broken + first replica unavailable + second replica fallback success` 시나리오로 고정
  - `Sprint K2`에서 broken producer와 broken first replica 뒤에도 second replica fallback이 실제로 `status=200 source=peer-fetch`로 이어진다는 first live evidence를 확보
  - `Sprint L1`에서 `K2` 이후 최소 남은 갭을 multi-replica ordering semantics, observability refinement, retry/recovery로 다시 좁히고, 다음 직접 흐름을 `L2 -> M1 -> ordering semantics`로 고정
  - `Sprint L2`에서 completion view와 progress board가 `M1 -> M2`를 같은 다음 질문 세트로 가리키도록 다시 정렬
  - `Sprint M1`에서 `L2` 이후 남은 실제 implementation backlog를 다시 묶고 다음 직접 implementation 질문을 multi-replica ordering semantics로 고정
  - `Sprint M2`에서 multi-replica ordering semantics를 `producer -> recorded replica order`라는 현재 implementation question으로 여는 entry를 고정
  - `Sprint N1`에서 recorded replica order를 실제로 재현하고 다시 검증할 수 있는 첫 execution helper cut를 추가
  - `Sprint N2`에서 completion view와 progress board가 `O1 -> O2`를 같은 다음 질문 세트로 가리키도록 다시 정렬
  - `Sprint O1`에서 ordering helper 이후 남은 구현 backlog를 다시 좁히고, 다음 직접 구현 질문을 recorded replica order semantics 쪽으로 재고정
  - `Sprint O2`에서 다음 직접 implementation topic을 `recorded replica order semantics`로 고정하고, broader policy commitment는 아직 보류한 채 `P1` execution cut로 넘기는 entry를 추가
  - `Sprint P1`에서 recorded replica-order semantics를 더 직접 읽을 수 있게 catalog recorded order와 producer-side metadata를 같이 출력하는 최소 probe helper cut를 추가
  - `Sprint P2`에서 completion view와 progress board를 `Q1 -> Q2` 흐름으로 다시 정렬
  - `Sprint Q1`에서 recorded replica-order question을 broader policy가 아니라 current implementation reading 수준으로 다시 좁히는 backlog review를 고정
  - `Sprint Q2`에서 `producer -> recorded replica order` reading을 다음 직접 implementation entry로 고정
  - `Sprint R1`에서 그 reading을 ordered remote candidate output으로 재실행할 수 있는 최소 wrapper helper cut를 추가
  - `Sprint R2`에서 `Q2`, `R1` 이후 completion view와 progress board를 같은 남은 질문 세트로 다시 정렬
  - `Sprint S1`에서 `R1`, `R2` 이후 남은 구현 backlog를 다시 좁혀 다음 직접 질문을 `S2`로 고정
  - `Sprint S2`에서 다음 직접 implementation entry를 `consumer perspective-aware producer -> recorded replica order` reading으로 고정
  - `Sprint T1`에서 각 agent pod 관점의 remote candidate order를 재실행하는 최소 perspective helper cut를 추가
  - `Sprint T2`에서 `S2`, `T1` 이후 남은 질문 세트를 `T3 -> U1` 흐름으로 다시 정렬
  - `Sprint T3`에서 perspective-aware reading 이후 남은 refinement question을 다시 작은 entry 범위로 넘기기 위해 backlog를 재축소
  - 별도 research extension으로 Dragonfly 포크 적용 가능성과 업스트림 업데이트 정합성 유지 가능성을 `docs/research/dragonfly-with*` 계열 문서로 확장하기 시작
  - remote lab(`100.123.80.48`)에서 Dragonfly Helm install과 `dfcache` export 실검증을 바탕으로 `dragonfly-adapter-contract` 연구 문서를 추가
  - 전체 backlog 완료 일정은 별도 [PARALLEL_6W_DELIVERY_PLAN.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PARALLEL_6W_DELIVERY_PLAN.ko.md)에 `6주 / 4개 병렬 트랙` 기준으로 고정

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
| D11 | 완료 | 두 번째 edge case는 same-node는 닫혔지만 overall family는 cross-node 전까지 부분 open이라는 재판단 고정 |
| D12 | 완료 | cross-node `catalog record missing + local artifact exists` evidence와 failure 해석 고정 |
| D13 | 완료 | 두 번째 edge-case family를 current validation scope에서 closure 처리 |
| E1 | 완료 | post-second-edge 이후 다음 우선순위를 orphan semantics note로 고정 |
| E2 | 완료 | same-node local reuse는 current behavior truth이지만 orphan policy approval은 아니라는 note 고정 |
| E3 | 완료 | catalog top-level failure reflection은 edge-case 결과 이후에도 defer 유지라는 재검토 결론 고정 |
| E4 | 완료 | broader policy boundary는 확장하지 않고 `E2`만 남기는 것이 맞다는 판단 고정 |
| E5 | 완료 | 현재 policy/document cleanup scope를 여기서 freeze하고 다음 질문 선택 단계로 전환 |
| F1 | 완료 | 다음 실제 질문을 `replica-aware fetch`의 가장 작은 형태로 선택 |
| F2 | 완료 | 구현 backlog를 `replica-aware fetch` 우선 순서로 재정렬 |
| F3 | 완료 | replica-aware fetch 준비 상태를 만드는 최소 execution cut 추가 |
| F4 | 완료 | replica-ready 상태는 live로 확인했지만 actual fetch는 아직 producer-biased라는 첫 evidence 고정 |
| F5 | 완료 | replica-aware 후속 순서를 validation first, cut second 로 고정 |
| F6 | 완료 | 다음 즉시 실행을 producer-bias validation으로 고정하고 최소 cut는 그 다음으로 미룸 |
| F7 | 완료 | third-node consumer가 replica 대신 broken producerAddress만 따라가 실패한다는 live evidence 확보 |
| F8 | 완료 | `peer_fetch()` remote candidate set을 producer + replicaNodes 로 넓히는 최소 cut 추가 |
| F9 | 완료 | broken producer 이후 third-node consumer가 replica fallback으로 성공한다는 live evidence 확보 |
| G1 | 완료 | replica-aware 첫 사이클 이후 남은 최소 갭을 observability와 ordering semantics로 좁혀 고정 |
| G2 | 완료 | post-replica-aware 이후 다음 후속 순서를 completion refresh, observability, ordering semantics로 재정렬 |
| H1 | 완료 | completion overview와 progress board를 replica-aware 이후 상태에 맞게 다시 정리 |
| H2 | 완료 | actual fetch endpoint observability는 현재는 refinement 주제로 보고 defer 유지 판단 고정 |
| H3 | 완료 | producer-first ordering을 current implementation truth로 고정하되 broader policy commitment로는 아직 보지 않음 |
| I1 | 완료 | replica-aware 이후 실제 implementation backlog를 multi-replica policy 우선으로 재설정 |
| I2 | 완료 | backlog reset 이후 completion view와 progress board의 남은 질문 세트를 다시 정리 |
| I3 | 완료 | 다음 실제 implementation 질문을 multi-replica policy로 고정 |
| J1 | 완료 | producer + first replica + second replica 상태를 준비하는 최소 execution cut 추가 |
| J2 | 완료 | `J1` 이후 남은 직접 질문 세트를 `K1`, `K2` 기준으로 다시 정렬 |
| K1 | 완료 | first multi-replica validation question을 second-replica fallback 시나리오로 고정 |
| K2 | 완료 | broken producer + broken first replica 뒤 second replica fallback success를 live로 확인 |
| L1 | 완료 | K2 이후 최소 남은 갭과 후속 순서를 다시 좁혀 고정 |
| L2 | 완료 | K2 이후 completion view와 progress board를 같은 다음 질문 세트로 정렬 |
| M1 | 완료 | L2 이후 다음 실제 implementation backlog를 multi-replica ordering semantics 중심으로 재설정 |
| M2 | 완료 | multi-replica ordering semantics를 `producer -> recorded replica order` 기준의 implementation question으로 여는 entry를 고정 |
| N1 | 완료 | recorded replica order 재현을 위한 첫 execution helper cut 추가 |
| N2 | 완료 | `M2`, `N1` 이후 completion view와 progress board를 같은 다음 질문 세트로 다시 정렬 |
| O1 | 완료 | ordering helper 이후 남은 구현 backlog를 recorded replica order semantics 중심으로 다시 좁힘 |
| O2 | 완료 | recorded replica order semantics를 다음 직접 implementation topic으로 고정하는 entry 추가 |
| P1 | 완료 | recorded replica-order semantics를 더 직접 읽기 위한 최소 probe helper cut 추가 |
| P2 | 완료 | `Q1 -> Q2` 흐름으로 completion/progress를 다시 정렬 |
| Q1 | 완료 | recorded replica-order question을 current implementation reading 수준으로 다시 좁히는 backlog review 고정 |
| Q2 | 완료 | `producer -> recorded replica order` reading을 다음 직접 implementation entry로 고정 |
| R1 | 완료 | `producer -> recorded replica order` reading을 재실행 가능한 ordered-candidate output으로 만드는 최소 wrapper helper cut 추가 |
| R2 | 완료 | `Q2`, `R1` 이후 completion/progress를 같은 남은 질문 세트로 다시 정렬 |
| S1 | 완료 | `R1`, `R2` 이후 남은 구현 backlog를 다시 좁혀 다음 직접 질문을 `S2`로 고정 |
| S2 | 완료 | 다음 직접 implementation entry를 `consumer perspective-aware producer -> recorded replica order` reading으로 고정 |
| T1 | 완료 | 각 agent pod 관점의 remote candidate order를 재실행하는 최소 perspective helper cut 추가 |
| T2 | 완료 | `S2`, `T1` 이후 남은 질문 세트를 `T3 -> U1` 흐름으로 다시 정렬 |
| T3 | 완료 | perspective-aware reading 이후 남은 refinement question을 다시 작은 entry 범위로 넘기기 위해 backlog 재축소 |

## 현재 backlog

| 영역 | 항목 | 우선순위 | 현재 판단 |
|---|---|---|---|
| 구현 | multi-replica ordering semantics | 중간 | perspective-aware reading review까지 닫혔고, 다음은 `U1`에서 entry scope 재고정 |
| 조사 | Dragonfly fork-fit / upstream alignment | 높음 | shallow adapter 가능성은 높고, deep fork는 비권장이라는 연구 축을 열었음 |
| 조사 | Dragonfly adapter contract | 높음 | remote lab 실검증을 바탕으로 product-owned contract 초안을 추가 |
| 구현 | catalog top-level failure reflection | 중간 | 여전히 defer 유지 |
| 구현 | retry / recovery policy | 낮음 | multi-replica ordering 다음 후속 질문 |
| 구현 | scheduler/controller 통합 평가 | 낮음 | 아직 script-assisted validation 단계 |
| 운영 | 새 문서 추가 시 bilingual pair 유지 | 높음 | 정책 고정 완료, 계속 실행 필요 |

## 6주 병렬 운영 기준

- 전체 backlog 완료 기준 보수 일정: `6주`
- 병렬 트랙:
  - validation
  - implementation
  - policy/decision
  - docs/release
- 상세 일정표: [PARALLEL_6W_DELIVERY_PLAN.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/PARALLEL_6W_DELIVERY_PLAN.ko.md)

## 추천 다음 3개 스프린트

### U1 - Post-T3 Implementation Entry

목표:

- `T3`에서 좁힌 다음 구현 질문을 다시 direct implementation entry로 고정

완료 기준:

- 다음 implementation entry note가 한 문서로 고정됨

### U2 - Post-U1 Execution Cut

목표:

- `U1`에서 고정한 다음 구현 질문을 위한 최소 execution cut를 정의

완료 기준:

- helper 또는 최소 cut note가 한 문서로 고정됨

### U3 - Post-U2 Completion Refresh

목표:

- `U1`, `U2` 이후 completion view와 progress board를 같은 남은 질문 세트로 다시 정렬

완료 기준:

- completion/progress refresh note가 한 문서로 고정됨

## 업데이트 규칙

이후 스프린트가 끝날 때마다 아래를 같이 갱신한다.

1. `현재 요약`
2. `완료 스프린트 표`
3. `현재 backlog`
4. `추천 다음 3개 스프린트`

즉, 이 문서는 일회성 메모가 아니라 **스프린트 진행 기록판**으로 유지한다.
