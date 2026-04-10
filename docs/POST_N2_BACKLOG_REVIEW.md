# POST_N2_BACKLOG_REVIEW

## Purpose

This document records `Sprint O1 - Post-N2 Backlog Review` and narrows the remaining implementation backlog after `N1` and `N2` into the smallest next question.

## What This Review Fixes

- `M2` already opened multi-replica ordering semantics as an implementation question.
- `N1` already added the first execution helper for replaying recorded replica order.
- `N2` already aligned the completion/progress documents to the same next-question set.

So the next direct implementation question should now be narrowed to:
`does recorded replica order have real meaning as current implementation semantics?`

## Review Result

The remaining implementation backlog should now be read in this order:

1. `O2 - Post-O1 Implementation Entry`
2. `P1 - Post-O2 Execution Cut`
3. Then `retry / recovery policy`

## Why This Ordering Fits

### 1. There is still no live evidence for ordering semantics itself

- there is already second-replica fallback evidence
- but the meaning of the recorded replica order itself is still not directly closed

### 2. Retry/recovery is still the larger question

- timeout/backoff
- repeated failure handling
- recovery semantics

These should remain after ordering semantics is narrowed one more time.

### 3. Broader policy expansion is still premature

- freshness scoring
- health-aware ranking
- richer observability

all remain later refinement topics.

## One-Line Conclusion

`O1` narrows the next direct implementation question further toward recorded replica-order semantics.
