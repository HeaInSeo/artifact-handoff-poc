# dragonfly-with-update-01

## 1. Research Question

If this project applies Dragonfly through a fork or adapter, can it remain compatible with upstream Dragonfly updates over time?

## 2. Key Summary

The answer is:

- **yes, with a shallow integration strategy**
- **probably no, with a deep fork strategy**

Upstream alignment is realistic only if we keep our custom logic outside Dragonfly's moving internals.

The main reason is that Dragonfly is active and evolving:

- the repository main page showed `v2.4.4-rc.0` on **April 10, 2026**
- the documentation surface we checked is published under `v2.4.0`
- the release surface and repository surface already show that “current Dragonfly” is not a frozen target

So the right question is not “can we fork once and stay done?”
The right question is “can we make our custom layer small enough that upstream changes are absorbable?”

## 3. Main Upstream-Compatibility Risks

### A. Release drift risk

Docs, main branch, and release lines do not always move in lockstep.

Implication:

- if our project depends on internal code paths rather than stable operator-facing surfaces, each upstream bump can become a re-analysis task

### B. Internal-architecture coupling risk

The public repository layout exposes multiple major components:

- `manager`
- `scheduler`
- `client`
- `pkg`

If we customize across those boundaries, we are no longer “using Dragonfly.”
We are effectively maintaining a distribution product derived from Dragonfly.

### C. Extension-surface maturity risk

Dragonfly does have plugin-related docs, but they do not read like a stable long-term product extension model.

Current signals:

- the `next` in-tree plugin page is still effectively TODO/WIP
- older plugin-builder docs exist, but they still require rebuilding the images that use the plugin

Implication:

- plugin support reduces some friction, but it is not strong enough to justify assuming “safe deep customization”

### D. Operational-surface drift risk

Even if we avoid internal modifications, our integration still depends on:

- `dfcache`
- `dfdaemon`
- Manager Open API
- Helm/Kubernetes deployment shape

These are safer than internal hooks, but still need version tracking and compatibility checks.

## 4. Recommended Compatibility Strategy

### Strategy 1. Keep a product-owned contract above Dragonfly

Our project should define and own the interface, for example:

- `Put`
- `EnsureOnNode`
- `Stat`
- `Warm`
- `Evict`

Dragonfly should implement that contract through an adapter.

This means:

- upstream Dragonfly updates affect the adapter first
- they do not directly redefine our catalog or workflow semantics

### Strategy 2. Prefer shallow fork over deep fork

If a fork is needed, keep it limited to:

- packaging
- deployment defaults
- thin glue code
- narrow operational wrappers

Avoid placing custom logic in:

- scheduler peer-selection internals
- manager data model internals
- source-of-truth semantics for artifact handoff

### Strategy 3. Pin and test against a version matrix

Do not follow “latest” implicitly.

Maintain an explicit matrix such as:

- current tested stable version
- next candidate version
- blocking changes observed

That matrix should be checked whenever:

- docs version changes
- a new stable release appears
- RCs introduce relevant transport/control changes

### Strategy 4. Treat docs/release mismatch as a normal planning input

This project should explicitly accept that:

- docs may highlight one version line
- repo main may already advertise a newer RC
- some extension docs may lag or remain incomplete

That should not be treated as a blocker by itself.
It should be treated as a signal to keep our integration boundary narrow.

## 5. Go / No-Go Heuristic

### Go

Proceed with Dragonfly-backed experimentation if all of the following remain true:

- our custom semantics stay in this repository
- Dragonfly is used mainly for payload transport/cache distribution
- the adapter can survive version bumps with bounded work
- we do not need undocumented or immature extension points for core behavior

### No-Go

Do not choose a Dragonfly fork as the main path if one or more of the following become true:

- we need to patch scheduler/manager internals for core product semantics
- we need plugin behavior that current docs do not describe as stable
- we cannot keep our catalog as the source of truth
- each upstream bump requires re-reading large internal code paths before we can move forward

## 6. Current Judgment For `artifact-handoff-poc`

The best current judgment is:

- **use Dragonfly as a backend candidate**
- **do not redesign this repository as a Dragonfly forked product**
- **treat forking as a packaging/integration tactic, not as the architecture**

In other words:

- Dragonfly can sit under the project
- Dragonfly should not become the project

## 7. Immediate Next Research/Implementation Questions

- what exact adapter contract should this repository own before any Dragonfly spike begins
- which minimum Dragonfly-backed experiment proves real value beyond the current hand-rolled peer-fetch path
- how should version pinning and upgrade rehearsal be documented for future spikes

## References

- Dragonfly repository: <https://github.com/dragonflyoss/dragonfly>
- Dragonfly releases: <https://github.com/dragonflyoss/dragonfly/releases>
- Dfcache reference: <https://d7y.io/docs/reference/commands/client/dfcache/>
- Dfdaemon reference: <https://d7y.io/docs/reference/configuration/client/dfdaemon/>
- Preheat Open API: <https://d7y.io/docs/advanced-guides/open-api/preheat/>
- Plugin builder docs: <https://d7y.io/docs/v2.0.8/contribute/development-guide/plugin-builder/>
- In-tree plugin docs: <https://d7y.io/docs/next/development-guide/plugins/in-tree-plugin/>
