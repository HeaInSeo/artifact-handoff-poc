# FAILURE_MATRIX

## 목적

이 문서는 현재까지 `artifact-handoff-poc`에서 실제로 검증한 failure scenario를 한 장 표로 모아 보는 참고 문서다.

이 문서는 새로운 semantics를 정의하지 않는다. 용어 기준은 [peer-fetch-failure-paths.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.ko.md)를 따른다.
failure semantics 메모로 바로 이동하려면 [peer-fetch-failure-paths.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.ko.md)를 함께 본다.

## Failure Matrix

| Scenario | Artifact ID | 감지 위치 | `source` | `lastError` | 판정 | 핵심 해석 | Evidence |
|---|---|---|---|---|---|---|---|
| producer points to self | `fail-self-20260408b` | consumer peer-fetch path | `peer-fetch` | `artifact missing locally and producer points to self` | pass | self-loop 성격의 잘못된 producer metadata가 local failure metadata에 남음 | [RESULTS.ko.md#scenario-a-producer-points-to-self](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/RESULTS.ko.md), [VALIDATION_HISTORY.ko.md#7-failure-scenario-validation](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/VALIDATION_HISTORY.ko.md) |
| peer fetch exception | `fail-peer-exc-20260408` | consumer peer-fetch path | `peer-fetch` | `<urlopen error [Errno 111] Connection refused>` | pass | transport 예외도 `fetch-failed` local metadata로 남음 | [RESULTS.ko.md#scenario-b-peer-fetch-exception](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/RESULTS.ko.md), [VALIDATION_HISTORY.ko.md#7-failure-scenario-validation](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/VALIDATION_HISTORY.ko.md) |
| local digest mismatch | `fail-internal-local-digest-20260408` | local verify path on producer/current node | `local-verify` | `local digest mismatch` | pass | local corruption이 peer fallback에 묻히지 않고 local verify failure로 유지됨 | [RESULTS.ko.md#scenario-c-local-digest-mismatch](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/RESULTS.ko.md), [VALIDATION_HISTORY.ko.md#9-local-digest-mismatch-validation](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/VALIDATION_HISTORY.ko.md) |
| peer digest mismatch | `fail-peer-digest-direct-20260408` | consumer-side `peer_fetch()` branch probe | `peer-fetch` | `peer digest mismatch` | partial pass | live branch에서는 consumer-side verification failure recording이 동작하지만, 당시 end-to-end HTTP 경로에서는 producer-side gate가 더 앞에서 막았음 | [RESULTS.ko.md#scenario-d-peer-digest-mismatch](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/RESULTS.ko.md), [VALIDATION_HISTORY.ko.md#10-peer-digest-mismatch-validation](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/VALIDATION_HISTORY.ko.md) |
| peer fetch http `409`: digest mismatch | `fail-peer-digest-http-b10-20260408` | producer-side internal gate surfaced through public fetch path | `peer-fetch` | `peer fetch http 409: digest mismatch` | pass | end-to-end HTTP에서는 producer-side rejection이 먼저 일어나며, B10 이후에는 그 사실이 정확히 라벨링됨 | [RESULTS.ko.md#scenario-e-peer-digest-mismatch-after-attribution-tightening](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/RESULTS.ko.md), [VALIDATION_HISTORY.ko.md#11-peer-fetch-http-attribution-tightening](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/VALIDATION_HISTORY.ko.md) |

## 읽는 법

### `peer digest mismatch` 와 `peer fetch http 409: digest mismatch`

둘은 같은 말이 아니다.

- `peer digest mismatch`
  - consumer가 peer payload를 읽은 뒤 직접 mismatch를 판단한 경우
- `peer fetch http 409: digest mismatch`
  - producer-side internal gate가 expected digest 불일치를 먼저 거절한 경우

즉 둘 다 integrity failure지만, 감지 위치가 다르다.

### `catalog lookup failed` 가 표에서 빠진 이유

현재 표는 "대표적으로 실증된 failure scenario"를 한 장으로 묶는 데 초점을 둔다. `catalog lookup failed`는 taxonomy에는 포함되지만, 이번 매트릭스에서는 독립 scenario보다는 peer digest mismatch 검증 중 intermediate observation으로 다뤘다.

관련 내용은 다음 문서를 같이 보면 된다.

- [peer-fetch-failure-paths.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.ko.md)
- [RESULTS.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/RESULTS.ko.md)
- [VALIDATION_HISTORY.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/VALIDATION_HISTORY.ko.md)

## 현재 범위에서의 결론

- `fetch-failed` / `lastError` recording은 self-loop, transport exception, local digest mismatch, peer integrity failure 계열에서 모두 실제 흔적을 남긴다.
- 다만 peer integrity failure는 현재 구현상 두 층으로 나뉜다.
  - producer-side rejection
  - consumer-side verification failure
- 따라서 결과를 읽을 때는 failure 이름뿐 아니라 감지 위치와 `source`를 같이 봐야 한다.
- semantics 설명으로 다시 올라가려면 [peer-fetch-failure-paths.ko.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.ko.md)를 본다.
