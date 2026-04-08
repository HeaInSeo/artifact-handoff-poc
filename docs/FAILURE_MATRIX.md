# FAILURE_MATRIX

## Purpose

This document summarizes the failure scenarios that have already been validated in `artifact-handoff-poc` in one table.

It does not define new semantics. The terminology follows [peer-fetch-failure-paths.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.md).
To jump back to the semantics note directly, read [peer-fetch-failure-paths.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.md) alongside this matrix.

## Failure Matrix

| Scenario | Artifact ID | Detection Point | `source` | `lastError` | Verdict | Key Interpretation | Evidence |
|---|---|---|---|---|---|---|---|
| producer points to self | `fail-self-20260408b` | consumer peer-fetch path | `peer-fetch` | `artifact missing locally and producer points to self` | pass | malformed self-pointing producer metadata is preserved as local failure metadata | [RESULTS.md#scenario-a-producer-points-to-self](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/RESULTS.md), [VALIDATION_HISTORY.md#7-failure-scenario-validation](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/VALIDATION_HISTORY.md) |
| peer fetch exception | `fail-peer-exc-20260408` | consumer peer-fetch path | `peer-fetch` | `<urlopen error [Errno 111] Connection refused>` | pass | transport exceptions also leave `fetch-failed` local metadata behind | [RESULTS.md#scenario-b-peer-fetch-exception](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/RESULTS.md), [VALIDATION_HISTORY.md#7-failure-scenario-validation](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/VALIDATION_HISTORY.md) |
| local digest mismatch | `fail-internal-local-digest-20260408` | local verify path on the current/producer node | `local-verify` | `local digest mismatch` | pass | local corruption is preserved as a local-verify failure instead of being hidden by peer fallback | [RESULTS.md#scenario-c-local-digest-mismatch](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/RESULTS.md), [VALIDATION_HISTORY.md#9-local-digest-mismatch-validation](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/VALIDATION_HISTORY.md) |
| peer digest mismatch | `fail-peer-digest-direct-20260408` | consumer-side `peer_fetch()` branch probe | `peer-fetch` | `peer digest mismatch` | partial pass | consumer-side verification recording works in the live branch, but the end-to-end HTTP path was still gated earlier by the producer-side check at that point | [RESULTS.md#scenario-d-peer-digest-mismatch](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/RESULTS.md), [VALIDATION_HISTORY.md#10-peer-digest-mismatch-validation](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/VALIDATION_HISTORY.md) |
| peer fetch http `409`: digest mismatch | `fail-peer-digest-http-b10-20260408` | producer-side internal gate surfaced through the public fetch path | `peer-fetch` | `peer fetch http 409: digest mismatch` | pass | in the end-to-end HTTP path, producer-side rejection happens first, and after B10 that fact is now labeled accurately | [RESULTS.md#scenario-e-peer-digest-mismatch-after-attribution-tightening](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/RESULTS.md), [VALIDATION_HISTORY.md#11-peer-fetch-http-attribution-tightening](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/VALIDATION_HISTORY.md) |

## How To Read It

### `peer digest mismatch` vs `peer fetch http 409: digest mismatch`

These are not the same.

- `peer digest mismatch`
  - the consumer read peer bytes and concluded the mismatch itself
- `peer fetch http 409: digest mismatch`
  - the producer-side internal gate rejected the request first

So both are integrity failures, but they are detected at different points in the path.

### Why `catalog lookup failed` is not a main row here

This matrix focuses on the representative validated failure scenarios. `catalog lookup failed` remains part of the taxonomy, but in this matrix it is treated as an intermediate observation from the earlier peer-digest-mismatch investigation rather than as a standalone headline scenario.

For that distinction, read these together:

- [peer-fetch-failure-paths.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.md)
- [RESULTS.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/RESULTS.md)
- [VALIDATION_HISTORY.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/VALIDATION_HISTORY.md)

## Current-Scope Conclusion

- `fetch-failed` / `lastError` recording now leaves real traces for self-loop, transport exception, local digest mismatch, and peer integrity failure families.
- Peer integrity failures are still split into two layers in the current implementation:
  - producer-side rejection
  - consumer-side verification failure
- So the correct way to read the current results is to look at the failure name together with the detection point and `source`.
- For the semantics note behind those labels, go back to [peer-fetch-failure-paths.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.md).
