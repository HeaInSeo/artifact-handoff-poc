# failure-taxonomy-scope-check

## 1. Research Question

Is the current failure taxonomy in `artifact-handoff-poc` growing beyond the Sprint 1 scope, or is it still staying at an appropriate level?

## 2. Key Summary

The current failure taxonomy is **still at an appropriate Sprint 1 level.**

Verdict: `keep narrow`

The taxonomy should stay only as large as needed to answer these questions:

- is the failure a control-plane lookup failure
- is it a peer-fetch transport failure
- is it producer-side rejection
- is it consumer-side verification failure
- is it local verification failure

So at this stage, it is more important to keep only the necessary axes clear than to introduce many more labels.

## 3. Taxonomy To Keep Now

At the Sprint 1 level, the core set should stay roughly this small:

1. `catalog lookup failed`
2. `peer fetch exception`
3. `peer fetch http 409: digest mismatch`
4. `peer digest mismatch`
5. `local digest mismatch`

These five are directly tied to the current validations and documents.

- `catalog lookup failed`
  - control-plane failure before peer fetch really starts
- `peer fetch exception`
  - peer-endpoint transport failure
- `peer fetch http 409: digest mismatch`
  - producer-side rejection
- `peer digest mismatch`
  - consumer-side verification failure
- `local digest mismatch`
  - same-node/local-copy verification failure

## 4. What Should Still Stay Deferred

The following should remain deferred at this stage.

### A. Global error-code taxonomy

- do not design a broad numeric or platform-wide code system now

### B. Finer split inside `catalog lookup failed`

- do not promote 404 / 5xx / timeout families into the main taxonomy now
- this decision is documented separately in [catalog-lookup-failure-split-note.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/catalog-lookup-failure-split-note.md)

### C. Catalog top-level failure state

- do not include cluster-wide failure truth in the taxonomy now
- this decision is documented separately in [catalog-failure-semantics-decision.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/catalog-failure-semantics-decision.md)

### D. Retry / recovery semantics

- do not add retriable vs non-retriable categories yet

### E. Replica-aware failure classes

- do not expand the taxonomy into detailed fetch-source-selection classes yet

## 5. Why The Current Size Is Right

### A. The evidence and docs are still organized around these five axes

The current RESULTS, VALIDATION_HISTORY, and FAILURE_MATRIX all read naturally through these five families.

If the taxonomy grows further now, the classification system will start to get ahead of the actual evidence.

### B. The repository is still fundamentally about location-aware handoff validation

The repository is still trying to validate:

- can location be recorded
- can same-node reuse be driven by that location
- when needed, can cross-node peer fetch work

The failure taxonomy should support those questions, not become a new topic of its own.

### C. Document navigation is already under control

After C5, C7, and C8, the current navigation among failure documents is already considered sufficient. Growing the taxonomy further would likely make the document set heavier again.

## 6. Conditions For Reconsidering Expansion

The taxonomy can be revisited if one or more of these conditions appear.

### A. The same failure class repeatedly blocks experiments

- when coarse-grained labels are no longer enough for practical debugging

### B. Retry / recovery policy is actually introduced

- when failure classes begin to drive execution policy directly

### C. Scheduler/controller integration is actually evaluated

- when failure classes begin to affect placement decisions directly

### D. Catalog durability/authority expands

- when catalog-side state semantics become materially more important

## 7. Immediate Sprint-Level Outcome

- keep the taxonomy at the current level
- do not add new failure classes now
- keep relying on the existing notes:
  - [peer-fetch-failure-paths.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.md)
  - [catalog-failure-semantics-decision.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/catalog-failure-semantics-decision.md)
  - [catalog-lookup-failure-split-note.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/catalog-lookup-failure-split-note.md)

## 8. Conclusion

The current failure taxonomy has not outgrown the Sprint 1 scope. So the conclusion of `Sprint C9` is:

- keep the taxonomy narrow
- focus on interpreting the existing classes consistently rather than inventing new ones
