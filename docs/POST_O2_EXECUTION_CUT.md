# POST_O2_EXECUTION_CUT

## Purpose

This note fixes the minimum execution cut added in `Sprint P1 - Post-O2 Execution Cut` so that `recorded replica order semantics` can be observed more directly.

## What This Cut Adds

- [run-recorded-replica-order-probe.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-recorded-replica-order-probe.sh)

This helper is a thin probe layer on top of the existing [run-replica-order-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-replica-order-check.sh).

It does the following:

1. runs the existing ordered-fallback check as-is
2. re-reads the catalog record for `producerAddress` and the recorded `replicaNodes` order
3. re-reads the producer-node local metadata
4. prints one summary JSON that makes those three views easier to read together

## Why This Is The Smallest Cut

- it does not change the ordering policy itself
- it does not add a new replica-ranking rule
- it does not add an actual fetch-endpoint field to metadata
- it does not open retry/recovery

So this cut stays focused on making the current recorded replica order and the current producer-side metadata outcome easier to read together during the next validation and follow-up judgment.

## Scope Fixed Here

- the next follow-up sprint stays a completion/progress refresh
- the backlog review after that will narrow the recorded replica-order question further
- broader multi-replica policy commitment is still deferred

## One-Line Conclusion

`P1` is the execution-cut sprint that adds the minimum probe helper for reading recorded replica-order semantics more directly.
