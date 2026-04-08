# dragonfly-vs-artifact-handoff-poc

## 1. Research Question

Which Dragonfly concepts are actually useful for `artifact-handoff-poc`, and which parts do not fit the current project scope?

## 2. Key Summary

Dragonfly is a peer-based distribution system built for large-scale file and image delivery. It uses concepts such as `dfdaemon`, scheduler, and seed peer to reduce load on the original source and organize peer-to-peer transfer.

`artifact-handoff-poc` shares part of that problem framing, but its center is not large-scale generic distribution. Its center is `artifact location awareness`: first identify where the parent artifact lives, then decide between same-node reuse and cross-node peer fetch.

So the repository should borrow Dragonfly's peer-fetch and fallback mindset, not Dragonfly's full control plane or generic distribution platform shape.

## 3. How It Resembles Our Project

- It tries to reduce pressure on a central source or repository.
- It values the fact that some node already has the data.
- It treats peer transfer as a fallback or expansion path.
- Its producer/source/peer distinction is useful for artifact handoff thinking.

## 4. How It Differs From Our Project

- Dragonfly is a general-purpose P2P distribution system, while this repository validates Kubernetes DAG artifact handoff.
- Dragonfly centers on efficient large-scale download scheduling, while this repository centers on recording artifact location and making location-aware decisions.
- Dragonfly relies on scheduler-driven parent-peer selection, while the current sprint can stay much simpler with minimal catalog metadata and explicit node placement.
- Dragonfly targets broad file and image distribution use cases; this repository targets a narrower parent-to-child artifact handoff problem.

## 5. What To Borrow

- the peer-based fallback mindset
- the idea of prioritizing the producer node
- a staged flow of same-node hit first, peer fetch second
- separating transfer execution from metadata-driven decision making
- the importance of digest-based integrity checks

## 6. What Not To Borrow

- Dragonfly's full scheduler/manager/control-plane structure
- a generic seed-peer or supernode distribution architecture
- fine-grained chunk scheduling and optimal parent-peer selection logic
- a generic image distribution or registry mirroring problem definition

## 7. Points That Connect Directly To The Current Sprint

- It supports why the catalog should record `producerNode`, `producerAddress`, `localPath`, `digest`, and `state`.
- It supports making cross-node peer fetch a required fallback when same-node reuse is unavailable.
- It supports treating the producer node as a first-class source instead of first pushing everything into a central repository.
- It clarifies that, at this stage, knowing where the data is matters more than advanced scheduling optimization.

## 8. Candidate Points For The Next Sprint

- define how far retry or back-to-source behavior should go when peer fetch fails
- evaluate how replica nodes should be reflected in metadata
- later, if placement hints or controller integration are explored, decide how much of Dragonfly-like parent selection should be simplified and borrowed

## References

- Dragonfly official site: <https://d7y.io/>
- Dragonfly GitHub: <https://github.com/dragonflyoss/dragonfly>
- Scheduler: <https://d7y.io/docs/operations/deployment/applications/scheduler/>
- Dfdaemon: <https://d7y.io/docs/v2.1.0/concepts/terminology/dfdaemon>
