# U10 - Remote-Capable Resolution Entry

## 1. Sprint Question

`U8` fixed that downgrade should be read in two stages:

- `required -> preferred`
- `preferred -> remote-capable resolution`

And `U9` fixed that `ObservePod()` / `ObserveWorkload()` should be read by a separate fallback-judgment layer.

The remaining direct question is this:

- What policy inputs should open the remote-capable resolution path after preferred locality?

This document adds no new implementation.
It fixes the remote-capable resolution entry from the metadata and validation truth that already exist in the repository.

## 2. What Remote-Capable Resolution Means Here

In this document, remote-capable resolution does not mean:

- “give up on same-node and allow any node”

It means something narrower:

- stop forcing the current same-node preference
- but stay within artifact-handoff semantics
- and move into a placement/consume path that can read remote fetch, replicas, and producer ordering

So this resolution step is not just relaxed scheduling.
It still includes artifact-aware target selection.

## 3. Policy Inputs That Already Exist In The Repository

The repository already contains several candidate inputs for remote-capable resolution.

### A. `producerNode`

- producer locality input
- the first input for the current same-node path

This is still the first locality reference even before remote resolution opens.

### B. `replicaNodes`

- the actual follow-up input for the remote candidate set
- already validated as part of the replica-aware fetch path

So once the remote path opens, this value defines not “some remote,” but the concrete remote candidate set.

### C. recorded replica order

- multi-replica validation already fixed
  `producer -> recorded replica order`
  and the consumer perspective-aware reading

So remote-capable resolution should not stop at “replicas exist.”
It should read the recorded-order semantics.

### D. consume semantics

`DYNAMIC_PLACEMENT_INTERFACE_CUT` already opened the following distinctions:

- `same-node-preferred`
- `remote-ok`
- `same-node-only`
- `same-node-then-remote`

So remote-capable resolution cannot be opened from location metadata alone.
It also needs artifact consume mode and fallback policy.

## 4. Misreadings This Sprint Rejects

### A. Is `replicaNodes` alone enough for remote-capable resolution?

No.

`replicaNodes` is only part of the candidate set.
Before that, the runtime still needs to know:

- whether the remote path is allowed by product semantics
- whether producer should still be read first
- whether recorded replica order should actually be honored

### B. Does remote-capable resolution only solve a scheduling problem?

No.

This step is broader than scheduling relaxation,
because the remote-capable path eventually has to decide:

- where the child should run
- which artifact source it should read

## 5. Minimum Resolution Input Set Fixed In This Sprint

The minimum input set fixed here is:

1. `ArtifactBinding` / consume mode
- whether the artifact is `same-node-only`
- `same-node-then-remote`
- or already `remote-ok`

2. producer-locality input
- `producerNode`
- and, when needed, current producer-side annotation / placement intent

3. remote-candidate input
- `replicaNodes`
- recorded replica order

4. current failure/judgment input
- `ObservePod()` result
- and, when needed, `ObserveWorkload()` result

So remote-capable resolution is the step that reads:

- failure signal
- locality metadata
- remote candidate metadata
- consume policy

together.

## 6. Exclusion Rules Fixed In This Sprint

The following are still not fixed as default inputs for remote-capable resolution.

1. simple “any available node”
- that is not artifact-aware resolution

2. source selection based only on application logs
- that mixes scheduling, placement, and artifact policy

3. broader freshness/health ranking
- still outside the current backlog slice

4. controller-wide global optimization
- still beyond the current narrow validation phase

## 7. Entry Judgments Fixed In This Sprint

This sprint fixes the following.

1. remote-capable resolution is not just scheduler relaxation; it is an artifact-aware policy step
2. the minimum inputs are `consume policy + producerNode + replicaNodes/recorded order + observable failure signal`
3. the remote path should not open as “any remote,” but by reading the current recorded producer/replica semantics

## 8. Next Direct Follow-Up

`U11 - Controller-Owned Placement Resolution Entry` is the right next step.

The input set for remote-capable resolution is now narrowed.
The next step is to fix whether this judgment should stay above the current node-level mutate/observer combination, or be raised into a product/controller-owned resolution step.
