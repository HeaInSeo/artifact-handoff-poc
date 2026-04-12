# dragonfly-with

## 1. Research Question

Can `artifact-handoff-poc` realistically fork Dragonfly and apply it as part of this project, and if so, where should that boundary be drawn?

## 2. Key Summary

As of April 12, 2026, the practical answer is:

- **yes, conditionally**, if Dragonfly is treated as a replaceable distribution backend and not as the place where this project's DAG handoff semantics are implemented
- **no, for a deep fork**, if the plan is to push catalog semantics, workflow policy, placement logic, and artifact handoff control directly into Dragonfly internals

The useful fit is at the **distribution layer**:

- `dfcache import/export/stat`
- `dfdaemon` node-local runtime
- Manager Open API for preheat and task operations

The poor fit is at the **workflow/control layer**:

- artifact catalog authority
- producer/replica semantics for DAG handoff
- scheduling intent for same-node reuse
- orphan/cleanup policy specific to this repository

So the realistic extension path is:

1. keep `artifact-handoff-poc` control-plane semantics outside Dragonfly
2. use Dragonfly as an optional backend adapter for artifact transport and cache reuse
3. avoid a deep fork unless the required change cannot be expressed at the adapter boundary

## 3. What Resembles Our Project

- Dragonfly is explicitly a P2P distribution and acceleration system for files, images, OCI artifacts, and similar payloads.
- It already runs on Kubernetes and already assumes node-local daemon behavior through `dfdaemon`.
- It already exposes a usable file-oriented interface through `dfcache import/export/stat`.
- It already exposes a control surface through Manager Open API jobs such as preheat/task operations.

These are the parts that overlap with our problem framing:

- producer-side data already exists somewhere
- data can be reused peer-to-peer instead of always going back to a central source
- node-local and cross-node delivery can be separated from higher-level workflow semantics

## 4. What Differs From Our Project

- Dragonfly is not a DAG artifact handoff project. It is a general distribution system.
- Dragonfly optimizes delivery and acceleration; this repository optimizes **location-aware handoff decisions**.
- Dragonfly's core model does not replace our catalog fields such as `producerNode`, `producerAddress`, `replicaNodes`, or handoff-specific failure semantics.
- Dragonfly can tell us a lot about distribution and cache reuse, but not which child task should consume which parent artifact under this repository's workflow meaning.

This difference matters because a deep fork would force Dragonfly to carry semantics that are not native to its design center.

## 5. What To Borrow

- `dfcache import/export/stat` as a file-level artifact transport surface
- `dfdaemon` as a node-local runtime/transport endpoint
- Manager Open API for optional preheat and task control
- the separation between distribution layer and higher-level orchestration
- the idea that data movement should be delegated to a specialized backend instead of being reimplemented in every workflow project

## 6. What Not To Borrow

- Dragonfly scheduler/manager internals as the place to encode workflow-specific artifact policy
- deep modifications to peer-selection or scheduling internals just to express current PoC semantics
- Dragonfly's broader product scope as a substitute for this repository's catalog/control plane
- plugin-first optimism without proving that the extension point is stable enough for our needs

## 7. Fork-Fit Judgment

### Recommended fit

The safest fork/application shape is:

- fork only if packaging, thin adapter code, or narrow operational integration requires it
- keep the fork shallow
- keep this repository's catalog, placement intent, and handoff semantics outside Dragonfly

This means the product contract should look roughly like:

- `Put artifact into distributable backend`
- `Ensure artifact on node`
- `Stat artifact availability`
- `Warm artifact set`
- `Evict artifact`

Dragonfly can back these operations, but the contract must remain owned by `artifact-handoff-poc`.

### Not recommended fit

The risky fork/application shape is:

- pushing our catalog authority into Dragonfly manager
- pushing DAG semantics into scheduler internals
- relying on internal peer-selection details as if they were our workflow policy
- treating Dragonfly as if it were the system of record for artifact handoff decisions

That path creates an upgrade-coupled hybrid product that is hard to maintain.

## 8. Current Upstream Signals That Matter

As of April 12, 2026:

- the official documentation pages we checked are published under `v2.4.0`
- the GitHub repository main page shows the latest release as `v2.4.4-rc.0` on **April 10, 2026**
- the stable release listing visible on GitHub search results showed `v2.3.4` on **November 7, 2025**

This suggests the project is actively moving, and that documentation/version surfaces are not perfectly aligned at all times.

That is another reason to avoid a deep fork.

## 9. Immediate Points For This Repository

- Dragonfly should be evaluated as a **distribution backend candidate**, not as the new home of our control plane.
- The first concrete research/implementation question is whether our `producerNode` / `replicaNodes` semantics can stay external while Dragonfly handles actual payload movement.
- The second question is whether `dfcache` import/export and `dfdaemon` UDS patterns are sufficient for Kubernetes job-side consumption.
- The third question is whether a shallow adapter gives enough value that a fork is unnecessary.

## 10. Next Candidate Research Questions

- which exact adapter contract should sit between our catalog and Dragonfly
- whether `producer-first` and `replica fallback` should stay fully product-owned even when Dragonfly is used underneath
- whether Dragonfly task/query surfaces are enough for observability without making Dragonfly the source of truth

## References

- Dragonfly repository: <https://github.com/dragonflyoss/dragonfly>
- Dragonfly docs: <https://d7y.io/docs/>
- Dfcache reference: <https://d7y.io/docs/reference/commands/client/dfcache/>
- Dfdaemon reference: <https://d7y.io/docs/reference/configuration/client/dfdaemon/>
- Preheat Open API: <https://d7y.io/docs/advanced-guides/open-api/preheat/>
- Task Open API: <https://d7y.io/docs/advanced-guides/open-api/task/>
