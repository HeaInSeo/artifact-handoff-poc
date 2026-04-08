# FAILURE_DOCS_ENTRY_AUDIT

## Purpose

This short note records the outcome of `Sprint C8 - Failure Docs Entry Audit`.

The audit covers entry paths among these failure-related documents:

- `README*`
- `RESULTS*`
- `VALIDATION_HISTORY*`
- `FAILURE_MATRIX*`
- `docs/research/peer-fetch-failure-paths*`
- `docs/research/catalog-failure-semantics-decision*`
- `docs/research/catalog-lookup-failure-split-note*`

It asks two questions:

1. are the current links too thin, making the documents hard to find
2. or are they becoming too dense, causing unnecessary cross-reference noise

## Audit Summary

Verdict: `balanced enough`

The current entry paths among failure-related documents are **sufficient for the current scope, and no further expansion is needed right now.**

## What Was Checked

### 1. Repository entry points

- `README.md` / `README.en.md`
  - link to the failure semantics note
  - link to the failure matrix
  - link to sprint progress

Judgment:

- the repository entry already exposes the right first-level paths
- exposing decision notes directly from README would likely make the entry document too heavy

### 2. Results and history documents

- `RESULTS*`
  - terminology note links to the failure semantics note
  - terminology note links to the failure matrix
- `VALIDATION_HISTORY*`
  - same structure: semantics note + matrix

Judgment:

- a reader of results/history can already answer both of the immediate questions:
  - how should these terms be interpreted
  - where is the one-page scenario summary
- that is enough for now

### 3. Matrix and research note

- `FAILURE_MATRIX*`
  - direct link back to the semantics note
- `peer-fetch-failure-paths*`
  - direct link back to the matrix

Judgment:

- after C7, the round trip between the matrix and the semantics note is short enough

### 4. Decision-note documents

- `catalog-failure-semantics-decision*`
- `catalog-lookup-failure-split-note*`

Judgment:

- these are supporting decision notes, not first-level entry documents
- the current choice not to expose them directly from README, RESULTS, or VALIDATION_HISTORY is the right one
- readers can still reach them through the research layer when needed

## What Should Stay As-Is

1. README should expose only the first-level entry points: semantics note, matrix, and progress
2. RESULTS / VALIDATION_HISTORY should expose only the semantics note and matrix from their terminology note blocks
3. the matrix and the semantics note should remain directly linked to each other
4. decision notes should remain discoverable through the research layer rather than promoted into README

## What Should Not Be Added Now

- direct README link to `catalog-failure-semantics-decision`
- direct README link to `catalog-lookup-failure-split-note`
- direct RESULTS / VALIDATION_HISTORY links to those decision notes
- duplicate second- or third-level link chains across all failure docs

## Conclusion

The current failure-doc navigation is **neither too thin nor too dense**.

So the conclusion of `Sprint C8` is:

- stop expanding links for now
- revisit only if the document set grows further or the navigation cost becomes high again
