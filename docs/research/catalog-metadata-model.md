# catalog-metadata-model

## 1. Research Question

What is the minimum catalog and metadata model that `artifact-handoff-poc` should carry in the current sprint, and where should it stop?

## 2. Key Summary

In the current sprint, the catalog should not become a heavy data-management system. It should stay a minimal `location-aware decision layer`.

Its core jobs are:

1. record where an artifact was produced
2. provide enough information to decide whether same-node reuse is possible
3. provide enough information to decide which producer or peer should serve a cross-node fetch

So the current sprint only needs a minimal pointer-style metadata model. Datashim and Pachyderm are useful references for pointer, metadata, and lineage thinking, but adopting their weight directly would exceed the current validation scope.

## 3. How It Resembles Our Project

- Datashim treats a Dataset as a pointer to an existing data source.
- Pachyderm tracks relationships between data and pipeline execution through repos, commits, and lineage.
- Both systems separate payload data from the metadata or control plane that refers to it.
- That separation matters here as well: artifact bytes and artifact location metadata should stay distinct.

## 4. How It Differs From Our Project

- Datashim includes dataset access orchestration through PVCs and ConfigMaps, while this repository focuses on artifact handoff semantics.
- Pachyderm is a much larger data platform with versioning, lineage, and pipeline concepts.
- In the current sprint, it matters more to know `producerNode` and `localPath` than to introduce dataset abstractions or a lineage graph.
- At this stage, the catalog is a small metadata registry, not a full data-management system.

## 5. What To Borrow

- the separation between artifact payload and artifact metadata
- a pointer-style record centered on identity and location
- at least a minimal notion of "who produced this artifact"
- a state field that can support handoff decisions

## 6. What Not To Borrow

- Datashim's full Dataset CRD model
- Pachyderm's full repo/commit/branch/versioning model
- introducing a lineage graph or pipeline graph in the current sprint
- turning the metadata store into a durable HA system now

## 7. Points That Connect Directly To The Current Sprint

The minimum field set for this sprint is roughly:

- `artifactId`
- `digest`
- `producerNode`
- `producerAddress`
- `localPath`
- `state`
- `replicaNodes`, or an equivalent field that records fetch results

State does not need to be complex yet. A minimal state set could be:

- `produced`
- `available-local`
- `replicated`
- `fetch-failed`

Important distinctions:

- `producerNode` and `producerAddress` are not the same thing.
- `producerNode` is tied to placement decisions.
- `producerAddress` is tied to executing peer fetch.
- `localPath` is not incidental metadata; it is a core clue for node-local reuse.
- `digest` is mandatory because it anchors payload integrity validation.

Fields that can stay optional for now:

- artifact size
- creation time
- parent job ID or workflow step ID
- consumer history
- richer error codes

These may become useful later, but they are not required for the current minimum validation.

Failure semantics note:

- `fetch-failed` is enough as a minimal state label for the current phase, but interpreting `lastError` still needs a separate failure taxonomy.
- In particular, `peer fetch http 409: digest mismatch` and `peer digest mismatch` may both look like integrity failure, but the former is producer-side rejection and the latter is consumer-side verification failure.
- That distinction is documented separately in [peer-fetch-failure-paths.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/peer-fetch-failure-paths.md).
- The reason catalog top-level failure reflection is still deferred is documented separately in [catalog-failure-semantics-decision.md](/opt/go/src/github.com/HeaInSeo/artifact-handoff-poc/docs/research/catalog-failure-semantics-decision.md).

## 8. Candidate Points For The Next Sprint

- define state transitions more rigorously
- decide how to distinguish `replicaNodes` from cache-hit history
- decide when to introduce lineage-lite fields such as parent task ID or child task ID
- write down when a durable backing store becomes justified

## References

- Datashim: <https://datashim.io/>
- Pachyderm basic concepts: <https://docs.pachyderm.com/products/mldm/latest/learn/basic-concepts/>
