#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${ROOT_DIR}/../multipass-k8s-lab/kubeconfig}"
NAMESPACE="${NAMESPACE:-artifact-handoff}"
ARTIFACT_ID="${ARTIFACT_ID:-recorded-replica-order-probe}"

export KUBECONFIG="${KUBECONFIG_PATH}"
export NAMESPACE
export ARTIFACT_ID

echo "== step 1: run ordered replica fallback check =="
ARTIFACT_ID="${ARTIFACT_ID}" bash "${ROOT_DIR}/scripts/run-replica-order-check.sh"

echo
echo "== step 2: summarize recorded replica order and producer-side metadata =="
python3 - <<'PY'
import json
import os
import subprocess

namespace = os.environ["NAMESPACE"]
artifact_id = os.environ["ARTIFACT_ID"]

record_raw = subprocess.check_output(
    [
        "kubectl",
        "-n",
        namespace,
        "exec",
        "deploy/artifact-catalog",
        "--",
        "wget",
        "-qO-",
        f"http://127.0.0.1:8090/artifacts/{artifact_id}",
    ]
)
record = json.loads(record_raw.decode("utf-8"))
replicas = record.get("replicaNodes", [])

pod_lines = subprocess.check_output(
    [
        "kubectl",
        "-n",
        namespace,
        "get",
        "pods",
        "-l",
        "app=artifact-agent",
        "-o",
        "jsonpath={range .items[*]}{.metadata.name} {.spec.nodeName}{'\\n'}{end}",
    ]
).decode("utf-8").splitlines()

producer_node = record.get("producerNode", "")
producer_pod = ""
for line in pod_lines:
    parts = line.split()
    if len(parts) == 2 and parts[1] == producer_node:
        producer_pod = parts[0]
        break
if not producer_pod:
    raise SystemExit(f"failed to resolve producer pod for node {producer_node}")

metadata_raw = subprocess.check_output(
    [
        "kubectl",
        "-n",
        namespace,
        "exec",
        producer_pod,
        "--",
        "cat",
        f"/var/lib/artifact-handoff/{artifact_id}/metadata.json",
    ]
)
metadata = json.loads(metadata_raw.decode("utf-8"))

summary = {
    "artifactId": artifact_id,
    "producerNode": producer_node,
    "producerAddress": record.get("producerAddress", ""),
    "recordedReplicaOrder": [
        {
            "index": idx,
            "node": replica.get("node", ""),
            "address": replica.get("address", ""),
            "state": replica.get("state", ""),
        }
        for idx, replica in enumerate(replicas)
    ],
    "producerLocalMetadata": {
        "state": metadata.get("state", ""),
        "source": metadata.get("source", ""),
        "producerNode": metadata.get("producerNode", ""),
        "producerAddress": metadata.get("producerAddress", ""),
        "lastError": metadata.get("lastError", ""),
    },
}
print(json.dumps(summary, indent=2, sort_keys=True))
PY
