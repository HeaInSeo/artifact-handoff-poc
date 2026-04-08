# FAILURE_DOCS_NAVIGATION_FREEZE

## Purpose

This note records the conclusion of `Sprint C10 - Failure Docs Navigation Freeze`.

The question is simple:

- should the current navigation among failure-related documents keep expanding
- or is the current level already enough

## Conclusion

Verdict: `freeze at current level`

The current failure-doc navigation is already sufficient. So the right default is to **stop expanding links further unless a concrete need appears.**

## Why Stop Here

### 1. The first-level entry points already exist

The README already exposes:

- the failure semantics note
- the failure matrix
- sprint progress

So the repository entry already provides the necessary first navigation paths.

### 2. Results documents already provide the needed secondary paths

RESULTS and VALIDATION_HISTORY already provide:

- a terminology-note link to the semantics note
- a terminology-note link to the failure matrix

That already solves the two immediate reading needs:

- where to interpret the terms
- where to revisit the representative scenarios in one page

### 3. The matrix and the research note are already directly connected

After C7, both of these are already true:

- matrix -> semantics note
- semantics note -> matrix

So the main navigation objective is already achieved.

### 4. More links would likely add noise faster than value

If more direct links are added to documents such as:

- `catalog-failure-semantics-decision`
- `catalog-lookup-failure-split-note`
- future failure notes

the document set will likely become heavier faster than it becomes more useful.

At the current stage, those decision notes belong in the research layer rather than being promoted into README or results documents.

## Rules To Keep

1. README should keep only first-level entry points.
2. RESULTS / VALIDATION_HISTORY should directly expose only the semantics note and the matrix.
3. The matrix and the semantics note should remain directly linked to each other.
4. Decision notes should stay discoverable from the research layer only.

## Conditions For Reopening This Decision

This freeze can be revisited if one or more of these happens.

### A. The number of failure notes grows enough to raise real navigation cost

### B. Users repeatedly report that a specific note is hard to find

### C. README / results / history no longer provide a clear enough path to the next needed document

## Operating Rule

The current operating rule should be:

- do not add new failure links by default
- if a new note is added, keep it inside the research layer first
- only promote it into README or results documents if the need becomes repeated and concrete

## One-Line Conclusion

As of `Sprint C10`, the right move is to **freeze failure-doc navigation at the current level.**
