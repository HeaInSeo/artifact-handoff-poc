# POST_ORPHAN_POLICY_BOUNDARY_CHECK

## 목적

이 문서는 `Sprint E4 - Post-Orphan Policy Boundary Check` 결과를 고정하기 위한 메모다.

질문:

- 두 번째 edge-case family를 닫고
- `catalog top-level failure reflection` 재검토까지 끝난 시점에서
- 남은 policy boundary를 더 확장하는 것이 맞는가

중요한 현재 상태:

- `E3`까지는 실제로 정리되었다.
- `E2 - Orphan Semantics Note`는 아직 별도 문서로 닫히지 않았다.

따라서 이번 스프린트의 목적은 orphan semantics 자체를 대신 정리하는 것이 아니라,
**남은 policy boundary를 더 넓힐지, 아니면 여기서 멈추고 `E2`만 남길지**를 판단하는 것이다.

## 현재까지 이미 고정된 것

현재 문서와 실검증으로 아래는 이미 고정되었다.

- `catalog record exists + local artifact missing`
  - same-node: self-loop failure
  - cross-node: peer-fetch recovery
- `catalog record missing + local artifact exists`
  - same-node: `source=local` 성공
  - cross-node: `catalog lookup failed`
- `catalog top-level failure reflection`
  - 현재 단계에서는 계속 defer

즉 현재 구현 truth와 authority boundary의 큰 틀은 이미 충분히 드러난 상태다.

## 이번 policy boundary check의 결론

결론은 아래다.

- **더 넓은 policy boundary 확장은 지금 하지 않는다**
- **남은 작은 정책 해석 질문은 `E2 - Orphan Semantics Note` 하나로 제한한다**

판정:

- `broader policy expansion`: defer 유지
- `remaining narrow note`: keep only `E2`

## 왜 여기서 멈추는 것이 맞는가

### 1. 남은 큰 질문들은 현재 validation 범위를 넘어간다

아직 남아 있는 후보:

- orphan/local-leftover를 policy적으로 허용할지
- cleanup/GC를 둘지
- catalog에 orphan/failure를 반영할지
- replica-aware 또는 recovery policy를 둘지

이 질문들은 모두 현재 Sprint 1 validation 범위보다 크다.

### 2. current behavior truth는 이미 충분히 확보됐다

현재는 이미 아래가 evidence로 남아 있다.

- same-node local-first reuse가 catalog absence를 가릴 수 있음
- cross-node에서는 catalog absence가 lookup failure로 드러남
- catalog truth와 local availability는 같은 의미가 아님

즉 지금 필요한 것은 policy 확장이 아니라,
이 observed truth를 어떻게 읽을지 좁게 정리하는 일이다.

### 3. 남은 해석 질문은 orphan semantics note 하나로 충분하다

이 시점에서 더 필요한 것은:

- orphan/local-leftover를 **허용된 current behavior**로만 볼지
- 아니면 **정책 미정 상태의 관찰값**으로만 둘지

를 짧게 고정하는 것이다.

이 질문은 `E2` 하나로 다룰 수 있고,
그 이상을 지금 열면 범위가 다시 커진다.

## 이번 스프린트에서 고정한 운영 규칙

- `E2`를 쓰기 전까지 broader policy discussion은 확장하지 않는다
- `catalog top-level failure reflection`은 계속 보류한다
- orphan cleanup / GC / controller integration은 계속 범위 밖으로 둔다
- 다음 작은 문서 질문은 `E2 - Orphan Semantics Note`로 한정한다

## 지금 닫힌 것과 아직 안 닫힌 것

이미 닫힌 것:

- edge-case family 두 개의 current behavior truth
- catalog/local metadata authority boundary의 현재 구현 수준 해석
- catalog top-level failure reflection을 지금 넣지 않는다는 판단

아직 안 닫힌 것:

- orphan/local-leftover semantics의 policy wording

## 결론 한 줄

`Sprint E4`의 결론은 **policy boundary를 더 확장하지 말고, 남은 좁은 질문은 `E2 - Orphan Semantics Note` 하나로 제한한 뒤 그 이후에는 현재 범위에서 멈추는 것이 맞다**는 것이다.
