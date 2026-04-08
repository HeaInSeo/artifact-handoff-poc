#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${ROOT_DIR}/../multipass-k8s-lab/kubeconfig}"
NAMESPACE="${NAMESPACE:-artifact-handoff}"
ARTIFACT_ID="${ARTIFACT_ID:-replica-aware-demo}"

export KUBECONFIG="${KUBECONFIG_PATH}"
export NAMESPACE
export ARTIFACT_ID

echo "== step 1: seed producer + first replica =="
ARTIFACT_ID="${ARTIFACT_ID}" bash "${ROOT_DIR}/scripts/run-cross-node.sh"

echo
echo "== step 2: catalog snapshot =="
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
summary = {
    "artifactId": record.get("artifactId", artifact_id),
    "producerNode": record.get("producerNode", ""),
    "producerAddress": record.get("producerAddress", ""),
    "replicaNodes": record.get("replicaNodes", []),
}
print(json.dumps(summary, indent=2, sort_keys=True))
if not summary["replicaNodes"]:
    raise SystemExit("replicaNodes is still empty after cross-node seed")
PY

echo
echo "== step 3: first replica metadata =="
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
replicas = record.get("replicaNodes", [])
if not replicas:
    raise SystemExit("replicaNodes is empty")
replica = replicas[0]
node_name = replica.get("node", "")
if not node_name:
    raise SystemExit("replica node missing from catalog")

pod = subprocess.check_output(
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
).decode("utf-8")

replica_pod = ""
for line in pod.splitlines():
    parts = line.split()
    if len(parts) == 2 and parts[1] == node_name:
        replica_pod = parts[0]
        break
if not replica_pod:
    raise SystemExit(f"failed to resolve artifact-agent pod on replica node {node_name}")

meta_raw = subprocess.check_output(
    [
        "kubectl",
        "-n",
        namespace,
        "exec",
        replica_pod,
        "--",
        "cat",
        f"/var/lib/artifact-handoff/{artifact_id}/metadata.json",
    ]
)
metadata = json.loads(meta_raw.decode("utf-8"))
summary = {
    "replicaNode": node_name,
    "localNode": metadata.get("localNode", ""),
    "producerNode": metadata.get("producerNode", ""),
    "state": metadata.get("state", ""),
    "source": metadata.get("source", ""),
}
print(json.dumps(summary, indent=2, sort_keys=True))
if summary["state"] != "replicated":
    raise SystemExit(f"expected replicated state on replica node, got {summary['state']}")
PY
