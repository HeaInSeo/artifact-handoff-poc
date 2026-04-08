# nearby-opensource-map

## 1. Research Question

If there is no open-source project that matches `artifact-handoff-poc` exactly, which combination of nearby projects provides the most useful reference frame?

## 2. Key Summary

There is no single closest match. The nearest reference frame is a combination:

- distribution layer: Dragonfly, Kraken
- placement and scheduling: Volcano
- locality and cache: Alluxio, JuiceFS
- metadata and lineage: Datashim, Pachyderm
- node-local daemon pattern: kube-fledged, NodeLocal DNSCache

The key is to combine insights from these systems without misreading `artifact-handoff-poc` as a reduced copy of any one of them.

## 3. How It Resembles Our Project

- Dragonfly and Kraken provide peer-based distribution and source-offload thinking.
- Volcano provides a batch workload and placement perspective.
- Alluxio and JuiceFS provide data-locality and near-local-access thinking.
- Datashim and Pachyderm provide dataset pointer, metadata, and lineage thinking.
- kube-fledged and NodeLocal DNSCache provide a DaemonSet-style node-local agent/cache pattern.

## 4. How It Differs From Our Project

- Dragonfly and Kraken are generic distribution systems, not DAG artifact handoff meaning layers.
- Volcano is a scheduler, but it does not provide an artifact metadata catalog.
- Alluxio and JuiceFS are data access or cache layers, not handoff decision layers.
- Datashim and Pachyderm are stronger on dataset and lineage concerns, but they can be much heavier than the current sprint needs.
- kube-fledged and NodeLocal DNSCache are close in node-local daemon shape, but they do not provide artifact catalog semantics.

## 5. What To Borrow

- from Dragonfly and Kraken: peer/source/fallback thinking
- from Volcano: thinking that connects placement hints to placement primitives
- from Alluxio and JuiceFS: using node-local paths to improve locality
- from Datashim and Pachyderm: treating metadata pointers and lineage as a separate control plane
- from kube-fledged and NodeLocal DNSCache: one agent per node as a DaemonSet pattern

## 6. What Not To Borrow

- the full large-scale distribution control plane from Dragonfly or Kraken
- introducing a custom scheduler immediately from Volcano ideas
- the full central-storage-plus-cache architecture of Alluxio or JuiceFS
- Pachyderm-level full data versioning and pipeline system
- pulling Datashim's full Dataset CRD model directly into the current sprint

## 7. Points That Connect Directly To The Current Sprint

- The most direct combination for the current sprint is `Dragonfly-like problem framing + Kubernetes placement primitives + a node-local agent pattern`.
- The metadata model can borrow inspiration from Datashim and Pachyderm while staying at a minimal pointer level.
- The storage layer should stay narrow for now with `hostPath`-based validation instead of growing into a broader cache system.
- The closest overall reference mix at this stage is "Dragonfly's problem framing, Volcano's placement lens, and a NodeLocal DNSCache-style node-local DaemonSet pattern."

## 8. Candidate Points For The Next Sprint

- make the Datashim/Pachyderm comparison more precise in `catalog-metadata-model`
- make kube-fledged and NodeLocal DNSCache patterns more concrete in `node-local-agent-patterns`
- compare our storage scope against Alluxio/JuiceFS locality handling in `hostpath-vs-localpv`

## References

- Dragonfly: <https://d7y.io/>
- Kraken: <https://github.com/uber/kraken>
- Volcano: <https://volcano.sh/en/docs/v1-12-0/unified_scheduling/>
- Alluxio on Kubernetes: <https://documentation.alluxio.io/os-en/kubernetes/running-alluxio-on-kubernetes>
- JuiceFS cache: <https://juicefs.com/docs/csi/guide/cache/>
- Datashim: <https://datashim.io/>
- Pachyderm basic concepts: <https://docs.pachyderm.io/products/mldm/latest/learn/basic-concepts/>
- kube-fledged: <https://github.com/senthilrch/kube-fledged>
- NodeLocal DNSCache: <https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/>
