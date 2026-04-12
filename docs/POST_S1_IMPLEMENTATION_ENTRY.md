# POST_S1_IMPLEMENTATION_ENTRY

## Purpose

This note fixes the direct implementation entry for `Sprint S2 - Post-S1 Implementation Entry` after the narrowed question from `S1`.

## What This Entry Fixes

The next direct implementation topic is fixed as follows:

- the current implementation reads the catalog record as a **consumer perspective-aware remote candidate order**
- more specifically, this means `producer -> recorded replica order`, while excluding the current node's own address and duplicate addresses as in the current `fetch_candidates()` behavior

So the point at this stage is not to design a broader ordering policy.
It is to fix how the already-implemented source-selection logic should be read from the consumer side before the next cut.

## Why Fix The Entry Here

- up through `Q2` and `R1`, the `producer -> recorded replica order` reading was made replayable from catalog output
- but the actual fetch-candidate iteration is more accurately read only when the current consumer address is excluded
- so the smallest next step is not to broaden policy, but to fix this perspective-aware reading as the next direct implementation entry

## What Still Remains Out Of Scope

- broader multi-replica policy commitment
- health/freshness-aware ranking
- actual fetch-endpoint observability field expansion
- retry / recovery policy

## Next Direct Flow

The next direct flow after this entry is:

- `T1 - Post-S2 Execution Cut`
- then a completion refresh or backlog review

So `T1` should add the smallest replayable helper cut that shows the perspective-aware reading fixed here.

## One-Line Conclusion

`S2` fixes the next direct implementation entry as reading the current implementation through `consumer perspective-aware producer -> recorded replica order` semantics.
