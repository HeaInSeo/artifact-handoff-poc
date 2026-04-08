# FAILURE_NOTE_INDEX_REVIEW

## Purpose

This note records the decision from `Sprint C11 - Failure Note Index Review`.

The question is:

- should `docs/research/README*` gain a dedicated index for failure-related notes
- or should the current structure stay as it is

## Conclusion

Verdict: `no dedicated failure-note index for now`

At the current stage, the right move is to **not** add a dedicated failure-note index to `docs/research/README*`.

## Why Not Add It Now

### 1. The first-level and second-level entry points already exist

The current document set already provides:

- README -> failure semantics note
- README -> failure matrix
- RESULTS / VALIDATION_HISTORY -> semantics note
- RESULTS / VALIDATION_HISTORY -> failure matrix

So the primary and secondary discovery paths are already in place.

### 2. The research README should not become too heavy

`docs/research/README*` is an entry document for research themes and recommended notes.

If a dedicated failure-note index is added there:

- the research README can start to look like a failure-note hub
- the decision-note hierarchy gets promoted again toward the front

That would be heavier than needed at the current stage.

### 3. It should stay aligned with the freeze decision

`Sprint C8` and `Sprint C10` already fixed these conclusions:

- the current failure-doc navigation is balanced enough
- the current level should now be frozen

Adding a separate failure-note index would work against that conclusion.

## Structure To Keep

1. README provides the first-level entry points.
2. RESULTS / VALIDATION_HISTORY provide second-level entry through the semantics note and the matrix.
3. Research-layer decision notes remain discoverable from within the research layer.

## Conditions For Reopening This Decision

This can be revisited if one or more of these happens.

### A. The number of failure notes grows enough to create a real discovery cost inside the research folder

### B. Users repeatedly report that a specific failure note is hard to find

### C. README / RESULTS / matrix no longer provide a clear enough path into the research-note hierarchy

## One-Line Conclusion

As of `Sprint C11`, the right move is to **avoid adding a dedicated failure-note index to the research README.**
