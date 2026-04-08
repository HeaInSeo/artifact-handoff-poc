# BILINGUAL_COVERAGE_AUDIT

## 목적

이 문서는 `Sprint C1 - Bilingual Coverage Audit` 결과를 고정하기 위한 감사 메모다.

목표는 다음 두 가지를 분리해서 확인하는 것이다.

- 핵심 문서의 한글/영문 파일 쌍이 실제로 존재하는가
- 파일 쌍이 있더라도 링크나 내용 parity에 눈에 띄는 문제가 남아 있는가

## 감사 범위

이번 감사는 아래 두 저장소의 핵심 문서를 대상으로 했다.

- `artifact-handoff-poc`
- `multipass-k8s-lab`

포함 기준:

- 루트 README
- `docs/` 아래 핵심 설계/결과/진행 문서
- `docs/research/` 아래 핵심 조사 문서
- `profiles/README*` 같은 명시적 사용자 진입 문서

제외 기준:

- `AGENTS.md`
  - 작업 지침 문서로 보고 bilingual 핵심 문서 범위에서 제외
- `.terraform/` 같이 외부 도구가 내려받은 vendor 성격 문서
  - 저장소 문서 coverage 대상으로 보지 않음

## 감사 결과 요약

### 1. 파일 쌍 coverage

판정: `pass`

핵심 문서 기준으로는 두 저장소 모두 한글/영문 파일 쌍이 정리되어 있다.

확인된 대표 문서:

- `artifact-handoff-poc`
  - `README.md` / `README.en.md`
  - `docs/PROJECT_BASELINE.ko.md` / `docs/PROJECT_BASELINE.md`
  - `docs/SPRINT1_SCOPE.ko.md` / `docs/SPRINT1_SCOPE.md`
  - `docs/RESULTS.ko.md` / `docs/RESULTS.md`
  - `docs/VALIDATION_HISTORY.ko.md` / `docs/VALIDATION_HISTORY.md`
  - `docs/SPRINT_PROGRESS.ko.md` / `docs/SPRINT_PROGRESS.md`
  - `docs/research/*` 핵심 문서 쌍
- `multipass-k8s-lab`
  - `README.md` / `README.en.md`
  - `docs/LAB_SCOPE.ko.md` / `docs/LAB_SCOPE.md`
  - `docs/ROADMAP.ko.md` / `docs/ROADMAP.md`
  - `docs/REFERENCE_FROM_MAC_K8S.ko.md` / `docs/REFERENCE_FROM_MAC_K8S.md`
  - `docs/TROUBLESHOOTING_HISTORY.ko.md` / `docs/TROUBLESHOOTING_HISTORY.md`
  - `profiles/README.ko.md` / `profiles/README.md`

### 2. naming convention 예외

판정: `known exception`

현재 문서 naming은 아래처럼 운영된다.

- 대부분의 docs 문서:
  - 한글 `*.ko.md`
  - 영문 `*.md`
- 루트 README:
  - 한글 `README.md`
  - 영문 `README.en.md`

이 차이는 현재 저장소 관례로 보고 이번 스프린트에서는 변경하지 않았다.

### 3. cross-link 품질

판정: `partial issues found and fixed`

감사 중 아래 문제를 확인했고 이번 스프린트에서 바로 수정했다.

- 영문 결과/히스토리 문서가 한글 문서로 직접 연결되던 링크
- `multipass-k8s-lab` 영문 README가 한글 troubleshooting history만 가리키던 링크

수정 대상:

- `artifact-handoff-poc/docs/RESULTS.md`
- `artifact-handoff-poc/docs/VALIDATION_HISTORY.md`
- `artifact-handoff-poc/docs/TROUBLESHOOTING_NOTES.md`
- `multipass-k8s-lab/README.en.md`

### 4. content parity 리스크

판정: `remaining gap`

`artifact-handoff-poc/docs/TROUBLESHOOTING_NOTES.md`는 파일 쌍 자체는 존재하지만, 현재 영문 문서로서의 내용 parity가 약하다. 일부 문장이 여전히 한글로 남아 있어 “coverage complete”와 “translation parity complete”는 같은 말이 아님을 이번 감사에서 분리해 기록한다.

즉 이번 스프린트 결론은 다음과 같다.

- 파일 쌍 coverage: 대체로 완료
- 링크 정합성: 이번 스프린트에서 보정
- 영문 내용 parity: 일부 후속 정리 필요

## 저장소별 판정

| 저장소 | 파일 쌍 coverage | 링크 정합성 | 내용 parity |
|---|---|---|---|
| `artifact-handoff-poc` | pass | pass after fix | partial |
| `multipass-k8s-lab` | pass | pass after fix | acceptable |

## 이번 스프린트에서 바로 수정한 내용

1. 영문 문서가 한글 문서로 연결되던 cross-link를 영문 대응 문서로 바꿨다.
2. bilingual coverage 감사 결과를 별도 문서로 남겼다.
3. 스프린트 진행판에 `C1` 완료 상태와 남은 parity backlog를 반영한다.

## 남은 작은 후속 항목

- `artifact-handoff-poc/docs/TROUBLESHOOTING_NOTES.md` 영문 parity 보강
- 필요하면 이후 스프린트에서 한/영 문서 간 용어 level consistency를 한 번 더 점검

## 결론

`Sprint C1` 기준으로 핵심 문서의 bilingual pair coverage는 충족했다. 이번 스프린트 이후 남은 일은 “문서 쌍이 없는 문제”보다 “영문 대응 문서의 내용 parity를 더 매끄럽게 다듬는 문제”에 가깝다.
