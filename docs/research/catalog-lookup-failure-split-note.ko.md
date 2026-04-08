# catalog-lookup-failure-split-note

## 1. 조사 질문

현재 단계의 `artifact-handoff-poc`에서 `catalog lookup failed`를 404, 5xx, timeout 같은 더 세부적인 bucket으로 나눠야 하는가?

## 2. 핵심 요약

현재 단계에서는 **`catalog lookup failed`를 더 세분화하지 않고 유지하는 것이 맞다.**

판정: `defer`

이유는 다음과 같다.

1. 현재까지 실증된 대표 failure에서 `catalog lookup failed`는 headline scenario라기보다 intermediate observation에 가깝다.
2. 현재 저장소의 핵심 질문은 catalog의 세부 failure taxonomy보다 location-aware handoff와 local forensic trail이 작동하는가에 있다.
3. 404/5xx/timeout 구분을 도입하면 error taxonomy는 더 정확해지지만, 현재 스프린트의 해석력 개선은 제한적이다.

즉 지금 단계에서는 `catalog lookup failed`를 더 쪼개는 것보다, 이미 있는 큰 failure 축을 분명히 구분하는 것이 더 중요하다.

## 3. 현재 판단

현재는 아래처럼 본다.

- `catalog lookup failed`
  - control-plane lookup 단계에서 peer fetch로 넘어가기 전에 실패했다는 coarse-grained signal

이 label이 현재 단계에서 해주는 일은 충분히 좁다.

- peer fetch가 아직 시작되지 않았음을 알려줌
- `source=catalog-lookup`와 함께 local metadata에 남음
- data-plane failure와 구분되는 control-plane failure라는 점을 보여줌

## 4. 왜 지금 더 나누지 않는가

### A. 현재 evidence가 충분히 쌓이지 않음

지금까지 강하게 관찰된 `catalog lookup failed`는 주로 B9 시점의 attribution gap에서 나온 것이다.

즉 현재는:

- 독립적인 catalog 404 family
- 독립적인 catalog 5xx family
- catalog timeout family

를 각각 반복 검증한 상태가 아니다.

이 상황에서 taxonomy만 먼저 늘리면 실제 evidence보다 문서 구조가 앞서가게 된다.

### B. 현재 해석 질문은 더 상위 레벨임

현재 문서와 결과에서 더 중요한 질문은 아래다.

- 이 failure가 catalog 단계인가, peer fetch 단계인가
- producer-side rejection인가, consumer-side verification failure인가
- local corruption인가, cross-node fetch failure인가

이 질문들에 비하면 404/5xx 구분은 아직 2차적이다.

### C. 구현/문서 경계 비용이 생김

`catalog lookup failed`를 세분화하려면 결국 아래 중 하나 이상이 뒤따르기 쉽다.

- agent error mapping 변경
- results/history 문구 업데이트
- failure matrix taxonomy 확장
- retriable/non-retriable 해석 논의

지금 단계에서는 이 확장 비용이 얻는 가치보다 크다.

## 5. 지금 유지할 규칙

현재 단계에서는 아래처럼 유지한다.

1. `catalog lookup failed`는 coarse-grained control-plane lookup failure로 유지한다.
2. peer fetch가 시작되기 전 실패라는 점이 더 중요하다.
3. 세부 원인 구분보다 `source=catalog-lookup`와 `fetch-failed` 기록을 우선 본다.

## 6. 다시 검토할 조건

아래 조건 중 하나가 생기면 세분화를 다시 검토할 수 있다.

### A. catalog failure가 반복적으로 실험을 막을 때

- 404와 5xx를 구분하지 않으면 실제 디버깅 가치가 떨어질 때

### B. catalog backend나 durability 논의가 본격화될 때

- catalog가 단순 in-memory registry를 넘어 더 강한 구성요소가 될 때

### C. retry / recovery policy를 도입할 때

- 404와 transient 5xx를 다르게 취급해야 할 이유가 생길 때

### D. controller/scheduler 연동을 평가할 때

- lookup failure class가 placement decision에 직접 영향을 주게 될 때

## 7. 현재 스프린트에 바로 연결되는 포인트

- `catalog lookup failed` 세분화는 현재 `defer`
- 구현 변경 없이 문서 판단만 고정
- failure matrix와 taxonomy는 현재 수준을 유지

## 8. 다음 스프린트 후보 포인트

- failure matrix와 research note 사이 cross-link 보강
- catalog lookup failure에 대한 실제 repeated evidence가 쌓였는지 나중에 다시 점검
