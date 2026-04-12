# POST_S2_EXECUTION_CUT

## Purpose

This note fixes the smallest replayable helper cut for `Sprint T1 - Post-S2 Execution Cut` after the perspective-aware ordering question fixed in `S2`.

## What This Cut Adds

- [run-recorded-replica-order-perspective-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-recorded-replica-order-perspective-check.sh)

This helper first runs the existing [run-recorded-replica-order-entry-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-recorded-replica-order-entry-check.sh), then rereads the same catalog record from each agent pod's point of view.

In practice it does the following:

1. runs the existing recorded replica-order entry check
2. rereads the catalog record
3. computes the current address for each agent pod from `NODE_IP`
4. recalculates `remoteCandidates` using the same rules as the current `fetch_candidates()`

So this helper does not add a broader ordering policy.
It focuses on replaying the current implementation's remote candidate order from the consumer perspective.

## Why This Is The Smallest Cut

- it does not change `peer_fetch()` logic
- it does not add a replica ranking rule
- it does not add observability fields
- it does not open retry/recovery work

This cut only adds a thin wrapper helper that makes the current semantics replayable with the consumer perspective included.

## Scope Fixed Here

- the next follow-up sprint is `T2 - Post-T1 Completion Refresh`
- broader multi-replica policy commitment remains deferred
- health/freshness-aware ranking also remains deferred

## One-Line Conclusion

`T1` adds the minimum execution cut that replays the current implementation's `consumer perspective-aware producer -> recorded replica order` reading as helper output.
