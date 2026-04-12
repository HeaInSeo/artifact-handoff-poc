#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${ROOT_DIR}/../multipass-k8s-lab/kubeconfig}"
NAMESPACE="${NAMESPACE:-artifact-handoff}"
ARTIFACT_ID="${ARTIFACT_ID:-recorded-replica-order-perspective-check}"

export KUBECONFIG="${KUBECONFIG_PATH}"
export NAMESPACE
export ARTIFACT_ID

echo "== step 1: run recorded replica-order entry check =="
ARTIFACT_ID="${ARTIFACT_ID}" bash "${ROOT_DIR}/scripts/run-recorded-replica-order-entry-check.sh"

echo
echo "== step 2: print perspective-aware remote candidate order =="
python3 - <<'PY'
import json
import os
import subprocess


def kubectl(*args):
    return subprocess.check_output(["kubectl", "-n", namespace, *args]).decode("utf-8")


namespace = os.environ["NAMESPACE"]
artifact_id = os.environ["ARTIFACT_ID"]

record = json.loads(
    kubectl(
        "exec",
        "deploy/artifact-catalog",
        "--",
        "wget",
        "-qO-",
        f"http://127.0.0.1:8090/artifacts/{artifact_id}",
    )
)

pod_names = (
    kubectl(
        "get",
        "pods",
        "-l",
        "app=artifact-agent",
        "-o",
        "jsonpath={range .items[*]}{.metadata.name}{'\\n'}{end}",
    )
    .strip()
    .splitlines()
)

perspectives = []
for pod in pod_names:
    env_line = kubectl(
        "exec",
        pod,
        "--",
        "sh",
        "-c",
        "printf '%s %s\\n' \"$NODE_NAME\" \"$NODE_IP\"",
    ).strip()
    node_name, node_ip = env_line.split()
    current_address = f"http://{node_ip}:8080"

    seen = set()
    candidates = []

    producer_address = record.get("producerAddress", "")
    producer_node = record.get("producerNode", "")
    if producer_address and producer_address != current_address:
        candidates.append(
            {
                "index": 0,
                "kind": "producer",
                "node": producer_node,
                "address": producer_address,
            }
        )
        seen.add(producer_address)

    for replica in record.get("replicaNodes", []):
        address = replica.get("address", "")
        if not address or address == current_address or address in seen:
            continue
        candidates.append(
            {
                "index": len(candidates),
                "kind": "replica",
                "node": replica.get("node", ""),
                "address": address,
                "state": replica.get("state", ""),
            }
        )
        seen.add(address)

    perspectives.append(
        {
            "pod": pod,
            "node": node_name,
            "currentAddress": current_address,
            "remoteCandidates": candidates,
        }
    )

print(
    json.dumps(
        {
            "artifactId": artifact_id,
            "reading": "perspective-aware producer -> recorded replica order",
            "perspectives": perspectives,
        },
        indent=2,
        sort_keys=True,
    )
)
PY
