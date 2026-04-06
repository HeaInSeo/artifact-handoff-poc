# RESULTS

## Summary

This file captures actual validation results for Sprint 1.

## Environment

- Lab repo: `../multipass-k8s-lab`
- Expected cluster shape: `1 control-plane + 2 workers`
- PoC namespace: `artifact-handoff`

## Observed Status

- `2026-04-03`: initial check from `multipass-k8s-lab/scripts/k8s-tool.sh status` showed only `k8s-master-0` running.
- `2026-04-03`: `multipass-k8s-lab/scripts/k8s-tool.sh up` failed before 3-node bring-up because Multipass could not resolve the configured image alias `rocky-8`.
- `2026-04-03`: kubeconfig was exported directly from the existing `k8s-master-0` VM to allow partial validation on the remaining single-node cluster.
- `2026-04-03`: PoC baseline deployed successfully to namespace `artifact-handoff` on that single-node cluster.
- `2026-04-04`: after the lab baseline was switched to Ubuntu 24.04 and the worker join/runtime issues were resolved, the intended `1 control-plane + 2 workers` cluster became available again.
- `2026-04-04`: cross-node validation succeeded on the recovered 3-node lab.

## Same-Node Reuse

- Status: passed on the currently available single-node cluster
- Parent job `parent-same-node` registered artifact `demo-artifact`
- Child job `child-same-node` completed successfully
- Observed child output:
  - payload: `artifact-handoff sprint1 sample payload`
  - source: `local`
  - digest: `d7e0b5a63f2caaf5c4a184958550d2d14209d093be1c0aa9301af65e17aea0b1`
- Catalog contents after the run:
  - `artifactId`: `demo-artifact`
  - `producerNode`: `k8s-master-0`
  - `producerAddress`: `http://10.87.127.29:8080`
  - `state`: `ready`
  - `replicaNodes`: `[]`

## Cross-Node Peer Fetch

- `2026-04-03` status: blocked by lab readiness
- `2026-04-03` script result: `need at least two schedulable nodes for cross-node validation`
- `2026-04-04` status: passed after lab recovery
- Successful scenario:
  - parent on `lab-worker-0`
  - child on `lab-worker-1`
  - child output `source=peer-fetch`
  - digest matched
  - catalog recorded producer and replica node information

## Second-Hit Cache

- Status: not captured in the final notes
- Earlier status on `2026-04-03`: not run because cross-node fetch could not be validated without a second node

## Notes

- The repository baseline and scripts are intended to run against a lab cluster prepared by `multipass-k8s-lab`.
- `scripts/check-lab.sh` defaults to `MIN_NODES=3` and fails fast when the intended lab shape is missing.
- For partial debugging on the leftover single-node cluster, `MIN_NODES=1` was used to deploy and run same-node validation only.
- The earlier blocked state in this file reflects the `2026-04-03` checkpoint rather than the final recovered lab state.
- The later recovery and successful cross-node validation are summarized in [TROUBLESHOOTING_NOTES.md](TROUBLESHOOTING_NOTES.md) and [VALIDATION_HISTORY.ko.md](VALIDATION_HISTORY.ko.md).
