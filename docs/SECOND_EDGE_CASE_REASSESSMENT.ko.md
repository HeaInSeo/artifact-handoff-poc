# SECOND_EDGE_CASE_REASSESSMENT

## 목적

이 문서는 `Sprint D11 - Second Edge Case Reassessment` 결과를 고정하기 위한 메모다.

재평가 대상 질문:

- `catalog record missing + local artifact exists`

기준 evidence:

- [SECOND_EDGE_CASE_TRUTH_TIGHTENING.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/SECOND_EDGE_CASE_TRUTH_TIGHTENING.ko.md)

## 현재까지 확인된 사실

`Sprint D10`에서 same-node 기준으로 아래가 실제로 확인됐다.

- catalog lookup은 `404 Not Found`
- same-node 공개 `/artifacts/{id}` 응답은 `200`
- 응답 source는 `local`
- local metadata는 `state=available-local`, `source=local-put` 유지

즉 현재 구현에서는 same-node local hit가 catalog absence보다 앞선다.

## 이번 재평가의 결론

이번 스프린트의 결론은 아래와 같다.

- same-node 관점에서는 두 번째 edge case의 current behavior가 충분히 고정됐다
- 따라서 `D10`이 same-node truth를 닫는 스프린트였다는 해석은 맞다
- 하지만 두 번째 edge case 전체를 완전히 닫았다고 보기는 아직 이르다
- 이유는 cross-node 관점이 아직 비어 있기 때문이다

따라서 verdict는:

- `same-node closed`
- `overall edge-case family still partially open`

## 왜 여기서 바로 종료하지 않는가

이 edge case는 단순 local reuse 질문이 아니라 authority boundary 질문이다.

same-node에서는 local hit가 catalog absence를 가릴 수 있다는 사실이 확인됐다.
하지만 cross-node에서는 질문이 달라진다.

- consumer node에는 local copy가 없고
- catalog에도 producer truth가 없을 때
- 현재 구현은 어떤 실패로 드러나는가
- existing local metadata 또는 leftover replica가 있으면 결과가 달라지는가

즉 cross-node까지 확인해야 `catalog absence`가 node 위치에 따라 어떤 의미를 갖는지 더 완전하게 설명할 수 있다.

## 왜 지금 당장 더 큰 확장으로 가지 않는가

이번 재평가에서도 아래는 여전히 보류한다.

- catalog top-level failure reflection
- orphan cleanup policy
- replica-aware fetch policy
- retry / recovery semantics

이들은 모두 현재 질문보다 더 큰 의미론 확장을 연다.

지금 필요한 다음 단계는 더 작다.

- `catalog record missing + local artifact exists`를 cross-node에서 한 번 실제로 보는 것

## 다음 스프린트 판단

다음은 `Sprint D12 - Second Edge Cross-Node Check`로 가는 것이 맞다.

최소 완료 기준:

1. fresh artifact id 1개 생성
2. producer node local artifact는 유지
3. catalog state는 비움
4. non-producer node에서 `/artifacts/{id}` 호출
5. HTTP 응답, local metadata, interpretation 기록

## 결론 한 줄

`Sprint D11`의 결론은 **두 번째 edge case는 same-node truth는 닫혔지만, edge-case family 전체는 cross-node 확인 전까지는 완전히 닫지 않는다**는 것이다.
