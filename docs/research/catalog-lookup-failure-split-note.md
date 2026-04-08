# catalog-lookup-failure-split-note

## 1. Research Question

At the current stage of `artifact-handoff-poc`, should `catalog lookup failed` be split into finer buckets such as 404, 5xx, or timeout?

## 2. Key Summary

At the current stage, the right decision is to **keep `catalog lookup failed` unsplit for now.**

Verdict: `defer`

Reasons:

1. in the validated failure set so far, `catalog lookup failed` has been closer to an intermediate observation than to a headline scenario
2. the current repository question is still about location-aware handoff and local forensic trail, not about detailed catalog failure taxonomy
3. introducing 404/5xx/timeout buckets would make the taxonomy more precise, but the practical gain at the current stage would still be limited

So for now, it is more important to keep the larger failure families clearly separated than to split `catalog lookup failed` further.

## 3. Current Decision

The current interpretation is:

- `catalog lookup failed`
  - a coarse-grained control-plane lookup failure before peer fetch really starts

That label already does enough for the current phase:

- it tells us peer fetch did not truly begin yet
- it is recorded in local metadata together with `source=catalog-lookup`
- it distinguishes control-plane lookup failure from data-plane failure

## 4. Why Not Split It Yet

### A. The evidence is still too thin

The strongest observed `catalog lookup failed` case so far came mainly from the B9 attribution gap.

In other words, the project has not yet accumulated repeated, separate evidence for:

- a standalone catalog 404 family
- a standalone catalog 5xx family
- a standalone catalog timeout family

If the taxonomy is expanded before the evidence grows, the document structure gets ahead of the actual validation story.

### B. The current questions are still at a higher level

The more important questions in the current results are:

- did the failure happen at the catalog stage or at the peer-fetch stage
- was it producer-side rejection or consumer-side verification failure
- was it local corruption or cross-node fetch failure

Compared with those, a 404/5xx split is still secondary.

### C. It tends to pull implementation and docs outward

Once `catalog lookup failed` is split, at least one or more of these usually follow:

- changing agent-side error mapping
- updating wording in results/history docs
- expanding the failure matrix taxonomy
- discussing retriable vs non-retriable behavior

At the current stage, that expansion cost is larger than the immediate value.

## 5. Rules To Keep For Now

For now, keep the rules like this:

1. keep `catalog lookup failed` as a coarse-grained control-plane lookup failure
2. the key point is that the failure happened before peer fetch really started
3. prioritize `source=catalog-lookup` and `fetch-failed` over finer sub-buckets

## 6. Conditions For Reconsidering The Split

The split can be revisited if one or more of these conditions appear.

### A. Catalog failure starts blocking experiments repeatedly

- when distinguishing 404 from 5xx becomes practically useful in debugging

### B. Catalog backend or durability work becomes real

- when the catalog stops being just a small in-memory registry

### C. Retry / recovery policy is introduced

- when 404 and transient 5xx need to be handled differently

### D. Controller/scheduler integration is being evaluated

- when lookup-failure classes begin to influence placement decisions directly

## 7. Immediate Sprint-Level Outcome

- splitting `catalog lookup failed` is currently `defer`
- no implementation change is needed
- the failure matrix and failure taxonomy stay at the current level

## 8. Candidate Next Steps

- tighten the cross-links between the failure matrix and the research note
- revisit the split later only if repeated catalog-failure evidence grows
