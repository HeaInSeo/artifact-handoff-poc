# NEXT_VALIDATION_QUESTION_SELECTION

## Purpose

This note records the result of `Sprint D3 - Next Validation Question Selection`.

The questions are:

- which of the two edge cases from `D2` should be chosen first as the next live validation question
- why that question is the smallest sensible next step at the current stage

## Candidate Questions

There were two candidates:

1. `catalog record missing + local artifact exists`
2. `catalog record exists + local artifact missing`

## Selection Result

Verdict: `pick catalog record exists + local artifact missing first`

The next validation sprint should first focus on:

**how the current implementation interprets the case where the catalog record still exists but the local artifact is missing on the current node**

## Why This Question Comes First

### 1. It exposes the authority boundary more directly

This question shows, in one place:

- whether catalog truth still remains
- what a local miss means
- how the same-node/local path diverges from the peer-fetch path
- what gets recorded when the producer points to self

So it gives the most direct observation of the role difference between the `catalog` and `local metadata`.

### 2. It aligns more naturally with the current implementation paths

The current implementation already has:

- local miss behavior
- peer-fetch fallback
- self-loop failure when the producer points to self

So current behavior can be observed without inventing a new structure.

### 3. It carries less orphan/leftover interpretation overhead than the other candidate

`catalog record missing + local artifact exists` is still important, but it quickly opens extra questions such as:

- is the copy orphaned
- is it just leftover local state
- should local-only reuse ever be allowed

That can drift toward storage-hygiene interpretation rather than staying focused on the authority boundary.

By contrast, `catalog record exists + local artifact missing` stays closer to the control-layer question.

## Validation Question Fixed By This Sprint

The next validation sprint question is fixed as follows.

### Question

Under `catalog record exists + local artifact missing`:

- how does the same-node/local path behave
- how does the cross-node/peer path behave
- what `lastError` is recorded in the producer self-loop case

### Minimum Completion Criteria

The next sprint only needs to verify:

1. one fresh artifact id
2. keep the catalog record
3. intentionally remove or empty only the local artifact on one node
4. confirm the HTTP response and local metadata snapshot
5. record both current behavior and intended interpretation in the results docs

## Candidate Not Chosen This Time

`catalog record missing + local artifact exists` is not discarded.

It remains the next candidate when:

- orphan/local-leftover interpretation needs to be fixed
- storage hygiene or local-only copy semantics need to be clarified further

## D3 Conclusion

The smallest useful next validation question is to test the case where **catalog truth remains but the local copy is absent**.

That keeps the focus on the control-layer authority boundary without reopening the failure-doc track.

## One-Line Conclusion

As of `Sprint D3`, the next validation sprint should first verify the **`catalog record exists + local artifact missing` edge case**.
