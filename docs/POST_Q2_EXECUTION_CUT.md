# POST_Q2_EXECUTION_CUT

## Purpose

This note fixes the minimum execution cut added in `Sprint R1 - Post-Q2 Execution Cut` so that the `producer -> recorded replica order` reading fixed in `Q2` can be replayed more directly.

## What This Cut Adds

- [run-recorded-replica-order-entry-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-recorded-replica-order-entry-check.sh)

This helper is a thin wrapper on top of the existing [run-recorded-replica-order-probe.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-recorded-replica-order-probe.sh).

It does the following:

1. runs the existing recorded replica-order probe as-is
2. re-reads the catalog record
3. prints the expected remote candidate order under the `producer -> recorded replica order` reading as JSON

So this helper stays focused on turning the current implementation reading into something replayable and inspectable, not just a text statement.

## Why This Is The Smallest Cut

- it does not change the ordering policy
- it does not add a new replica-ranking rule
- it does not add an actual fetch-endpoint field
- it does not open retry/recovery

This cut only adds the thinnest wrapper needed to replay the current reading more directly.

## Scope Fixed Here

- the next follow-up sprint is `R2 - Post-R1 Completion Refresh`
- the backlog review after that will narrow the remaining implementation questions again
- broader multi-replica policy commitment stays deferred

## One-Line Conclusion

`R1` is the sprint that adds the minimum wrapper helper for replaying the `producer -> recorded replica order` reading directly.
