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

- Status: blocked by lab readiness
- Actual script result: `need at least two schedulable nodes for cross-node validation`
- Required next step: fix `multipass-k8s-lab` image/baseline bring-up so the intended `1 control-plane + 2 workers` cluster exists first

## Second-Hit Cache

- Status: not run
- Reason: cross-node fetch could not be validated without a second node

## Notes

- The repository baseline and scripts are intended to run against a lab cluster prepared by `multipass-k8s-lab`.
- `scripts/check-lab.sh` defaults to `MIN_NODES=3` and fails fast when the intended lab shape is missing.
- For partial debugging on the leftover single-node cluster, `MIN_NODES=1` was used to deploy and run same-node validation only.
- Full sprint acceptance remains incomplete until same-node and cross-node both succeed on the actual 3-node lab.
