# POST_ORPHAN_POLICY_BOUNDARY_CHECK

## Purpose

This note fixes the result of `Sprint E4 - Post-Orphan Policy Boundary Check`.

Question:

- after closing the second edge-case family
- and after rechecking catalog top-level failure reflection
- should the remaining policy boundary be expanded any further

Important current state:

- `E3` has been documented.
- `E2 - Orphan Semantics Note` is still not closed as a separate note.

So this sprint does not try to replace the orphan-semantics note itself.
It only decides whether the policy boundary should expand further, or whether it should stop here and leave only `E2` open.

## What is already fixed

The current documents and live validation already fixed the following:

- `catalog record exists + local artifact missing`
  - same-node: self-loop failure
  - cross-node: peer-fetch recovery
- `catalog record missing + local artifact exists`
  - same-node: `source=local` success
  - cross-node: `catalog lookup failed`
- `catalog top-level failure reflection`
  - still deferred for the current stage

So the larger shape of the current implementation truth and authority boundary is already visible enough.

## Conclusion of this policy-boundary check

The conclusion is:

- **do not expand the broader policy boundary any further now**
- **limit the remaining narrow policy question to `E2 - Orphan Semantics Note`**

Verdict:

- `broader policy expansion`: keep deferred
- `remaining narrow note`: keep only `E2`

## Why stopping here is the right choice

### 1. The remaining larger questions are beyond the current validation scope

The remaining candidates include:

- whether orphan/local-leftover should be policy-approved
- whether cleanup/GC should exist
- whether orphan/failure should be reflected in the catalog
- whether replica-aware or recovery policy should be added

All of them are larger than the current Sprint 1 validation scope.

### 2. The current behavior truth is already sufficiently established

The evidence already shows:

- same-node local-first reuse can hide catalog absence
- cross-node access exposes catalog absence as lookup failure
- catalog truth and local availability do not mean the same thing

So the next need is not more policy expansion. It is a narrow interpretation note for the observed truth.

### 3. The remaining interpretation question fits in one orphan-semantics note

At this point the only remaining question is whether orphan/local-leftover should be read as:

- an allowed current behavior
- or only an observed behavior with policy still undecided

That question fits in `E2` alone.
Opening more than that now would widen the scope again.

## Operating rule fixed in this sprint

- do not expand broader policy discussion before `E2`
- keep `catalog top-level failure reflection` deferred
- keep orphan cleanup / GC / controller integration out of scope
- treat `E2 - Orphan Semantics Note` as the only next small policy document question

## What is closed and what is still open

Already closed:

- the current behavior truth of both edge-case families
- the current implementation-level interpretation of the catalog/local-metadata authority boundary
- the decision to avoid catalog top-level failure reflection for now

Still open:

- the policy wording for orphan/local-leftover semantics

## One-line conclusion

The conclusion of `Sprint E4` is that **the policy boundary should not be expanded further, and the only remaining narrow question should be limited to `E2 - Orphan Semantics Note`; after that, the current scope should stop here**.
