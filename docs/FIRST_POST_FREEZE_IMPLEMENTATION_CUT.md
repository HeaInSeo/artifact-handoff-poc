# FIRST_POST_FREEZE_IMPLEMENTATION_CUT

## Purpose

This note records the smallest implementation/validation adjustment introduced in `Sprint D4 - First Post-Freeze Implementation Cut`.

## Scope Of This Cut

This sprint does not add a new control plane.

Instead, it adds a dedicated validation helper for the edge case selected in `D3`:

- `catalog record exists + local artifact missing`

Added file:

- [run-edge-case-local-miss.sh](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/scripts/run-edge-case-local-miss.sh)

## Why This Is The Smallest Reasonable Cut

Heavily modifying `run-same-node.sh` or `run-cross-node.sh` would risk disturbing the existing Sprint 1 happy-path validation scripts.

This sprint is about an edge-case validation path, not a happy-path rewrite, so a separate helper is the narrower and safer choice.

## What The Helper Does

1. create a fresh artifact on a producer node
2. read `producerNode` back from the catalog
3. remove only the hostPath artifact directory on the selected consumer node
4. run `/artifacts/{id}` GET from that node
5. leave the HTTP result and logs visible for collection

Supported modes:

- default: `same-node`
- option: `--cross-node`

So the same helper can prepare both:

- producer self-loop/local-miss behavior
- peer-fetch fallback behavior

## What This Cut Intentionally Does Not Do

- change agent behavior
- change the catalog state model
- add replica-aware fetch policy
- add retry / recovery logic

The purpose of this cut is not to invent new semantics, but to **make the selected edge case reproducible**.

## What It Hands Off To The Next Sprint

The next sprint can now run this helper and confirm:

- whether same-node local miss is recorded as self-loop failure
- whether cross-node mode recovers through peer fetch
- what `lastError` is written into local metadata

## One-Line Conclusion

The `Sprint D4` implementation cut is **a dedicated helper script that makes the selected edge case reproducible without broadening the scope**.
