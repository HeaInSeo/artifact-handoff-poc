# SECOND_EDGE_CASE_SELECTION

## 목적

이 문서는 `Sprint D8 - Second Edge Case Selection` 결과를 고정하기 위한 메모다.

`Sprint D7`까지 첫 번째 edge case인 `catalog record exists + local artifact missing`는 다음처럼 닫혔다.

- same-node: self-loop failure
- cross-node: peer-fetch recovery

이제 다음 질문으로 남아 있는 두 번째 edge case를 선택한다.

## 후보

현재 남아 있는 가장 작은 후보는 아래 하나다.

- `catalog record missing + local artifact exists`

## 선택 결과

다음 edge-case 질문으로 `catalog record missing + local artifact exists`를 선택한다.

즉 `Sprint D8`의 결론은:

- 첫 번째 edge-case 트랙은 `D7`에서 닫힘
- 두 번째 edge-case 트랙은 `catalog record missing + local artifact exists`로 시작

## 왜 이 질문을 지금 선택하는가

이 질문은 현재 authority 경계에서 남아 있는 가장 직접적인 반대편 상황이다.

- 첫 번째 edge case는 `catalog truth는 있지만 local copy가 없는 경우`였다.
- 두 번째 edge case는 `local copy는 있지만 catalog truth가 없는 경우`다.

따라서 두 질문은 서로 대칭적인 성격을 가진다.

또 이 질문은 현재 저장소의 핵심 문제와 직접 연결된다.

- `catalog`가 location-aware decision layer의 진입점이라면
- catalog record가 사라졌을 때 local artifact를 어떻게 해석할지
- same-node local reuse를 허용할지, 거부할지, orphan/local-leftover로 볼지

를 한 번은 명시적으로 확인해야 한다.

## 왜 더 큰 질문으로 가지 않는가

이번 단계에서는 아래로 바로 확장하지 않는다.

- catalog top-level failure reflection
- replica-aware fetch policy
- retry / recovery policy
- scheduler/controller integration

이 질문들은 모두 더 큰 의미론 확장을 요구한다.

반면 `catalog record missing + local artifact exists`는 현재 authority boundary를 한 단계 더 확인하는 가장 작은 후속 질문이다.

## 현재 가설

현재 단계에서의 작업 가설은 다음과 같다.

- local artifact가 남아 있어도 catalog record가 없으면
- 현재 구현은 그 artifact를 authoritative handoff 대상으로 보지 않을 가능성이 높다
- 따라서 local-only reuse보다는 lookup/control-layer failure 쪽으로 드러날 가능성이 높다

이 가설은 아직 검증된 사실이 아니다.
다음 스프린트에서 실제 helper 또는 절차를 통해 확인해야 한다.

## 다음 스프린트의 최소 완료 기준

다음 `D9`에서 필요한 최소 완료 기준은 아래다.

1. fresh artifact id 1개 생성
2. local artifact copy는 유지
3. catalog record만 의도적으로 제거하거나 lookup 불가 상태로 만들기
4. same-node 또는 가장 단순한 path 하나를 먼저 실행
5. HTTP 응답, local metadata, interpretation을 기록

## 이번 스프린트의 결론

`Sprint D8`의 결론은 간단하다.

- 두 번째 edge case는 `catalog record missing + local artifact exists`
- 다음 단계는 이 질문을 재현 가능한 최소 helper/절차로 바꾸는 것
- 아직 semantics를 확장하지 않고, authority boundary validation 범위 안에서 다룬다
