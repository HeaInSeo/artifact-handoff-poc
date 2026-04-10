# POST_R2_BACKLOG_REVIEW

## Purpose

This note narrows the remaining implementation backlog again after `R1` and `R2` into the smallest next question.

## What This Review Fixes

- The `producer -> recorded replica order` reading already has both a direct implementation entry and a replayable helper.
- So the smallest remaining question is no longer to broaden that reading, but to fix how narrowly that reading should be carried into the next implementation entry.
- The next direct core sprint is therefore set to `S2 - Post-S1 Implementation Entry`.

## Why This Is The Right Reading

- `Q2` already fixed the reading as the direct implementation entry.
- `R1` already added the ordered-candidate replay helper.
- `R2` already realigned completion/progress around that state.
- So this is now a backlog-narrowing step, not another helper-expansion step.

## What Still Remains Deferred

- broader multi-replica policy commitment
- health/freshness-aware ranking
- actual fetch-endpoint observability field expansion
- retry / recovery policy

## Next Direct Flow

1. `S2 - Post-S1 Implementation Entry`
2. `T1 - Post-S2 Execution Cut`
3. then the next completion refresh or backlog review
