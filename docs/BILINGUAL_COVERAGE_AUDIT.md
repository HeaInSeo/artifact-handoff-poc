# BILINGUAL_COVERAGE_AUDIT

## Purpose

This note records the outcome of `Sprint C1 - Bilingual Coverage Audit`.

The audit separates two questions:

- do the core documents actually exist as Korean/English file pairs
- even when the pair exists, are there visible cross-link or content-parity gaps

## Audit Scope

This audit covered core documentation in these two repositories:

- `artifact-handoff-poc`
- `multipass-k8s-lab`

Included:

- root README files
- core design, result, and progress documents under `docs/`
- core research documents under `docs/research/`
- explicit entry documents such as `profiles/README*`

Excluded:

- `AGENTS.md`
  - treated as a working-instructions file, not as a core bilingual project document
- vendored or tool-downloaded files such as `.terraform/`
  - not treated as repository documentation coverage targets

## Audit Summary

### 1. File-pair coverage

Verdict: `pass`

For core documents, both repositories now have Korean/English pairs in place.

Representative pairs confirmed:

- `artifact-handoff-poc`
  - `README.md` / `README.en.md`
  - `docs/PROJECT_BASELINE.ko.md` / `docs/PROJECT_BASELINE.md`
  - `docs/SPRINT1_SCOPE.ko.md` / `docs/SPRINT1_SCOPE.md`
  - `docs/RESULTS.ko.md` / `docs/RESULTS.md`
  - `docs/VALIDATION_HISTORY.ko.md` / `docs/VALIDATION_HISTORY.md`
  - `docs/SPRINT_PROGRESS.ko.md` / `docs/SPRINT_PROGRESS.md`
  - core pairs under `docs/research/*`
- `multipass-k8s-lab`
  - `README.md` / `README.en.md`
  - `docs/LAB_SCOPE.ko.md` / `docs/LAB_SCOPE.md`
  - `docs/ROADMAP.ko.md` / `docs/ROADMAP.md`
  - `docs/REFERENCE_FROM_MAC_K8S.ko.md` / `docs/REFERENCE_FROM_MAC_K8S.md`
  - `docs/TROUBLESHOOTING_HISTORY.ko.md` / `docs/TROUBLESHOOTING_HISTORY.md`
  - `profiles/README.ko.md` / `profiles/README.md`

### 2. Naming-convention exception

Verdict: `known exception`

The current document naming is intentionally split like this:

- most docs:
  - Korean uses `*.ko.md`
  - English uses `*.md`
- root README:
  - Korean uses `README.md`
  - English uses `README.en.md`

This remains the current repository convention and was not changed in this sprint.

### 3. Cross-link quality

Verdict: `partial issues found and fixed`

During the audit, a few English docs were still linking directly to Korean counterparts. Those were fixed in this sprint.

Fixed targets:

- `artifact-handoff-poc/docs/RESULTS.md`
- `artifact-handoff-poc/docs/VALIDATION_HISTORY.md`
- `artifact-handoff-poc/docs/TROUBLESHOOTING_NOTES.md`
- `multipass-k8s-lab/README.en.md`

### 4. Content-parity risk

Verdict: `remaining gap`

`artifact-handoff-poc/docs/TROUBLESHOOTING_NOTES.md` does exist as the English-side file, but its prose parity is still weak. Some Korean text remains, so “coverage complete” and “translation parity complete” are not the same thing.

So the conclusion of this sprint is:

- file-pair coverage: largely complete
- cross-link alignment: tightened in this sprint
- English content parity: still needs one small follow-up pass

## Per-Repository Verdict

| Repository | File-Pair Coverage | Cross-Link Quality | Content Parity |
|---|---|---|---|
| `artifact-handoff-poc` | pass | pass after fix | partial |
| `multipass-k8s-lab` | pass | pass after fix | acceptable |

## Immediate Fixes Applied In This Sprint

1. Cross-links that pointed from English docs to Korean docs were redirected to the English counterparts.
2. The bilingual coverage audit result was written down as a dedicated note.
3. The sprint progress board is updated to mark `C1` complete and to keep the remaining parity backlog visible.

## Small Follow-Up Items

- improve English parity in `artifact-handoff-poc/docs/TROUBLESHOOTING_NOTES.md`
- optionally do one more terminology consistency pass across Korean/English docs later

## Conclusion

As of `Sprint C1`, bilingual pair coverage for core documents is in place. The remaining work is now less about missing file pairs and more about smoothing out English content parity in a few existing paired documents.
