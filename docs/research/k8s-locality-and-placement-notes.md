# k8s-locality-and-placement-notes

## 1. Research Question

Which Kubernetes locality and placement primitives are the best fit for turning `artifact location awareness` into an actual handoff decision in the current sprint?

## 2. Key Summary

The current sprint can stay on basic Kubernetes primitives:

- most direct placement controls: `nodeName`, `nodeSelector`, `nodeAffinity`
- simplest node-local storage for validation: `hostPath`
- later comparison candidate: `local PersistentVolume`

Volcano is useful as a placement and batch-scheduling reference, but it is not something this sprint needs to adopt directly. Alluxio and JuiceFS go further on locality and cache design, but they do not replace the current sprint's main question: "do we know where the artifact is, and do we use that to drive handoff?"

## 3. How It Resembles Our Project

- Volcano treats placement as an important concern for batch and AI workloads.
- Alluxio values local worker storage and local or short-circuit access.
- JuiceFS explicitly documents locality trade-offs around hostPath-based local cache and pod migration.
- Kubernetes itself already exposes locality-aware building blocks through `nodeAffinity` and local volumes.

## 4. How It Differs From Our Project

- Volcano is a batch scheduler, not an artifact location catalog.
- Alluxio and JuiceFS focus more on data access performance and cache efficiency than on the handoff semantics this repository is validating.
- `artifact-handoff-poc` validates a control layer that learns location metadata first and then connects that to placement and fetch behavior.
- Placement primitives are tools; the meaning layer still belongs to the catalog and decision flow.

## 5. What To Borrow

- use `nodeName`, `nodeSelector`, and `nodeAffinity` to validate same-node placement explicitly
- use `hostPath` to prove node-local artifact presence quickly
- later, when comparing `local PV`, use its `nodeAffinity` implications as part of the storage discussion
- validate on top of existing Kubernetes primitives before considering deeper scheduler changes

## 6. What Not To Borrow

- adopting Volcano in the current sprint
- adopting a broad Alluxio/JuiceFS-style central-storage-plus-cache layer in the current sprint
- prioritizing storage/cache optimization ahead of handoff semantics
- assuming placement optimization can replace the metadata and decision layer

## 7. Points That Connect Directly To The Current Sprint

- the best current flow is to record `producerNode` in the catalog, then let child manifests or scripts try same-node placement from that metadata
- when same-node placement is unavailable, the next path should be cross-node peer fetch
- `hostPath` is the fastest validation path, but its portability and operational limits should be documented clearly in result notes
- at this stage, the key question is not advanced scheduling but whether metadata actually changes placement and fetch decisions

## 8. Candidate Points For The Next Sprint

- write a focused `hostPath` vs `local PV` comparison note
- evaluate how placement hints might be expressed more declaratively
- document when scheduler or controller integration becomes justified

## References

- Volcano unified scheduling: <https://volcano.sh/en/docs/v1-12-0/unified_scheduling/>
- Alluxio on Kubernetes: <https://documentation.alluxio.io/os-en/kubernetes/running-alluxio-on-kubernetes>
- JuiceFS CSI cache: <https://juicefs.com/docs/csi/guide/cache/>
- Kubernetes NodeLocal DNSCache: <https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/>
