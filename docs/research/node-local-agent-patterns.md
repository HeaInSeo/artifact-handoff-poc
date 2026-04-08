# node-local-agent-patterns

## 1. Research Question

Why should `artifact-handoff-poc` prefer a one-agent-per-node pattern first, and what are the main ideas to borrow from that pattern in the current sprint?

## 2. Key Summary

For the current sprint, a node-local agent is the most direct experiment shape because it stays closest to where the artifact actually lives. That makes it a natural place to handle:

1. node-local artifact presence checks
2. same-node read and reuse
3. serving as a source for remote peer fetch
4. linking node-local state back to the catalog

NodeLocal DNSCache and kube-fledged solve different problems, but they are still useful references for the shared pattern of "one DaemonSet-backed service per node, prioritizing node-local hits and reducing central traffic."

## 3. How It Resembles Our Project

- NodeLocal DNSCache places a caching agent on each node to increase local hits and reduce central DNS pressure.
- kube-fledged is concerned with making needed images available on nodes and improving node-local image availability.
- In both cases, the core pattern is one agent or cache instance per node.
- `artifact-handoff-poc` has a similar need because the first best reuse path is on the node that already stores the artifact.

## 4. How It Differs From Our Project

- NodeLocal DNSCache is a name-resolution cache, not an artifact metadata catalog.
- kube-fledged is closer to image pre-pull and cache behavior than to workflow-aware artifact handoff.
- The agent in this repository is not just a cache. It also supports local artifact lookup, peer fetch serving, and catalog registration.
- So the node-local pattern is similar, but the meaning layer is much more handoff-specific.

## 5. What To Borrow

- one DaemonSet instance per node
- a node-local hit-first mindset
- avoiding a design where every data-path operation must traverse the central service
- a split structure where node-local services collaborate with a cluster-wide control point

## 6. What Not To Borrow

- applying DNS-cache semantics directly to artifact handoff
- treating image prefetch or image cache concerns as the same problem as artifact handoff
- making the agent too heavy by folding scheduler/controller responsibilities into it
- pushing so much logic into the agent that the catalog loses its control-layer role

## 7. Points That Connect Directly To The Current Sprint

- the simplest current structure is one DaemonSet agent per node
- a same-node child should query the local agent first, then fall back to remote peer fetch if metadata says the artifact lives elsewhere
- the catalog should not replace the node-local agent; it should stay the control point that answers "where is the artifact?"
- separating central catalog responsibility from node-local agent responsibility keeps the repository's design intent clear

## 8. Candidate Points For The Next Sprint

- make the agent API more explicit around local lookup, registration, and peer fetch
- define the minimum state-sync contract between catalog and agents
- write a later note for hardening concerns such as authn/authz, TLS, and rate limiting

## References

- NodeLocal DNSCache: <https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/>
- kube-fledged: <https://github.com/senthilrch/kube-fledged>
