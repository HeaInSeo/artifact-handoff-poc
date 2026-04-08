# POST_EDGE_REASSESSMENT

## Purpose

This note records the result of `Sprint D6 - Post-Edge Reassessment`.

The questions are:

- after confirming the same-node edge-case evidence in `D5`, what is the next smallest question
- should the work move immediately to a different edge case, or should the same edge case be completed in the cross-node view first

## Core Summary

Verdict: `finish the same edge case in cross-node view first`

The smallest next step is to continue with:

- `catalog record exists + local artifact missing`

and complete it in the **cross-node view** first.

So the next priority is not to jump directly into `catalog record missing + local artifact exists`, but to complete the edge case that has already been selected and partially validated.

## Why Cross-Node Recovery Comes Next

### 1. The current question is only half closed

`D5` confirmed only the same-node path.

So what is known now is:

- catalog truth remains
- if the same-node local artifact is gone, a self-loop failure appears

But what is still unknown is:

- whether the same situation recovers through peer fetch from another node

That missing cell belongs to the same question, so it should be filled first.

### 2. It completes the authority-boundary picture

With only the same-node evidence, the dominant conclusion is “if the local artifact is gone, the path fails.”

If cross-node recovery is also confirmed, the picture becomes more complete:

- catalog truth still remains
- same-node local availability is gone
- but a non-producer node can still recover through peer fetch

That gives a clearer control-layer/authority interpretation.

### 3. It costs less context-switch than the other edge case

`catalog record missing + local artifact exists` is still important, but it shifts the focus back toward orphan/local-leftover interpretation.

By contrast, the current step can:

- reuse the same helper
- keep the same artifact semantics
- extend the same results section

So it has a lower context-switch cost.

## Next Question Fixed By This Sprint

The next validation sprint question is fixed as follows.

### Question

Under the cross-node `catalog record exists + local artifact missing` case:

- does the consumer recover through peer fetch
- is the response `source` equal to `peer-fetch`
- what state/source remain in consumer local metadata
- does the catalog keep producer truth unchanged

### Minimum Completion Criteria

1. one fresh artifact id
2. do not remove the producer-node local artifact
3. clear only the consumer-node local artifact before GET
4. collect HTTP success, `source`, and local metadata snapshot
5. record same-node vs cross-node behavior side by side in the results docs

## Question Not Chosen Yet

`catalog record missing + local artifact exists` is not discarded.

It should be reopened when:

- the cross-node recovery check is finished
- the orphan/local-leftover semantics are ready to be isolated as their own question

## D6 Conclusion

At this point, it is better to finish the already selected edge case in the cross-node view than to open a new question immediately.

## One-Line Conclusion

As of `Sprint D6`, the next sprint should validate the **cross-node recovery case of `catalog record exists + local artifact missing`**.
