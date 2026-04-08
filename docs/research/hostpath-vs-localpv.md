# hostpath-vs-localpv

## 1. Research Question

Why is `hostPath` still a reasonable node-local artifact storage choice for the current sprint, and when does `local PersistentVolume` become worth comparing?

## 2. Key Summary

For the current sprint, `hostPath` is the right choice because it is the fastest and most direct way to prove "this artifact exists on this node at this path."

But the Kubernetes documentation also makes clear that `hostPath` is mainly for single-node testing and is not the general multi-node answer. By contrast, `local` PVs bring node-local storage into the Kubernetes resource model more cleanly through node affinity.

So the current conclusion is:

- now: use `hostPath` to validate whether location-aware handoff works at all
- next comparison step: evaluate how `local PV` changes portability, scheduling alignment, and operational boundaries

## 3. How It Resembles Our Project

- Alluxio values local worker storage and local or short-circuit access.
- JuiceFS documents that `hostPath` cache is simple but comes with locality trade-offs when Pods move.
- Kubernetes `local` PVs make node binding explicit through node affinity.
- This repository also wants control flow to reflect the fact that an artifact lives on a specific node-local path.

## 4. How It Differs From Our Project

- Alluxio and JuiceFS are broader data access and cache systems.
- This repository prioritizes artifact handoff validation over general cache architecture.
- The `hostPath` vs `local PV` question should be evaluated by how it changes location-aware handoff semantics, not as a generic storage product comparison.

## 5. What To Borrow

- in the current sprint, the simplicity and directness of `hostPath`
- in the next stage, the `nodeAffinity` and Kubernetes-native storage alignment of `local PV`
- the idea that locality should be evaluated together across storage and placement

## 6. What Not To Borrow

- expanding storage abstraction too much in the current sprint
- delaying the current validation just because `hostPath` has known limits
- locking the longer-term direction to `hostPath` alone

## 7. Points That Connect Directly To The Current Sprint

- `hostPath` gives the most direct link between the parent node's local path and metadata such as `localPath`
- it is the fastest way to validate same-node reuse
- it also makes it straightforward to use the producer node's local file as the source for cross-node fetch
- result notes should still record these limits clearly:
  - portability limits
  - operational cleanup and permission burden
  - weaker alignment with Kubernetes-native storage abstraction

## 8. Candidate Points For The Next Sprint

- run a comparison experiment that shows how metadata and placement differ under `local PV`
- document failure, cleanup, and eviction differences between `hostPath` and `local PV`
- evaluate how storage choice affects the catalog model

## References

- Kubernetes persistent volumes: <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>
- Alluxio on Kubernetes: <https://documentation.alluxio.io/os-en/kubernetes/running-alluxio-on-kubernetes>
- JuiceFS CSI cache: <https://juicefs.com/docs/csi/guide/cache/>
