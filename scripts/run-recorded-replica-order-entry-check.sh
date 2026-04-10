#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${ROOT_DIR}/../multipass-k8s-lab/kubeconfig}"
NAMESPACE="${NAMESPACE:-artifact-handoff}"
ARTIFACT_ID="${ARTIFACT_ID:-recorded-replica-order-entry-check}"

export KUBECONFIG="${KUBECONFIG_PATH}"
export NAMESPACE
export ARTIFACT_ID

echo "== step 1: run recorded replica-order probe =="
ARTIFACT_ID="${ARTIFACT_ID}" bash "${ROOT_DIR}/scripts/run-recorded-replica-order-probe.sh"

echo
echo "== step 2: print expected ordered remote candidate interpretation =="
python3 - <<'PY'
import json
import os
import subprocess

namespace = os.environ["NAMESPACE"]
artifact_id = os.environ["ARTIFACT_ID"]

raw = subprocess.check_output(
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
record = json.loads(raw.decode("utf-8"))

candidates = []
producer_address = record.get("producerAddress", "")
if producer_address:
    candidates.append(
        {
            "index": 0,
            "kind": "producer",
            "node": record.get("producerNode", ""),
            "address": producer_address,
        }
    )

for idx, replica in enumerate(record.get("replicaNodes", []), start=len(candidates)):
    candidates.append(
        {
            "index": idx,
            "kind": "replica",
            "node": replica.get("node", ""),
            "address": replica.get("address", ""),
            "state": replica.get("state", ""),
        }
    )

print(
    json.dumps(
        {
            "artifactId": artifact_id,
            "reading": "producer -> recorded replica order",
            "expectedRemoteCandidateOrder": candidates,
        },
        indent=2,
        sort_keys=True,
    )
)
PY
