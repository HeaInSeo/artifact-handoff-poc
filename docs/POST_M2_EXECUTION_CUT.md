# POST_M2_EXECUTION_CUT

## Purpose

This document records `Sprint N1 - Post-M2 Execution Cut` and fixes the smallest execution cut that makes the next multi-replica ordering step directly testable.

## What This Cut Adds

- [run-replica-order-check.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-replica-order-check.sh)

This helper prepares all of the following in one flow.

1. producer + first replica + second replica state
2. catalog output that shows the recorded replica order
3. a broken `producerAddress` and a broken first-replica address
4. deletion of the producer-node local copy
5. a fresh producer-node request to observe ordered candidate iteration

## Why This Is The Smallest Cut

- it does not change the ordering policy itself
- it does not add health scoring or freshness scoring
- it does not add a new actual-fetch-endpoint field

So this cut stays focused on making it repeatable to observe whether the current code path can proceed in the order
`producer -> first replica -> second replica`.

## Scope Fixed Here

- the next live validation should check whether recorded replica order has real candidate-iteration meaning
- broader multi-replica policy design still remains unopened
- retry/recovery stays out of scope in this sprint

## One-Line Conclusion

`N1` adds the first execution helper for the multi-replica ordering-semantics question.
