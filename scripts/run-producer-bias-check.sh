#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${ROOT_DIR}/../multipass-k8s-lab/kubeconfig}"
NAMESPACE="${NAMESPACE:-artifact-handoff}"
ARTIFACT_ID="${ARTIFACT_ID:-producer-bias-demo}"
BROKEN_PRODUCER_ADDRESS="${BROKEN_PRODUCER_ADDRESS:-http://10.255.255.1:8080}"

export KUBECONFIG="${KUBECONFIG_PATH}"
export NAMESPACE
export ARTIFACT_ID
export BROKEN_PRODUCER_ADDRESS

CATALOG_POD="$(kubectl -n "${NAMESPACE}" get pods -l app=artifact-catalog -o jsonpath='{.items[0].metadata.name}')"
export CATALOG_POD

echo "== step 1: seed producer + first replica =="
ARTIFACT_ID="${ARTIFACT_ID}" bash "${ROOT_DIR}/scripts/run-replica-aware-prep.sh"

echo
echo "== step 2: choose third node consumer =="
consumer_info="$(
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
producer = record.get("producerNode", "")
replicas = record.get("replicaNodes", [])
replica = replicas[0]["node"] if replicas else ""
node_lines = subprocess.check_output(
    [
        "kubectl",
        "get",
        "nodes",
        "--no-headers",
        "-o",
        "custom-columns=NAME:.metadata.name",
    ]
).decode("utf-8").splitlines()
third = ""
for node in node_lines:
    node = node.strip()
    if node and node != producer and node != replica:
        third = node
        break
if not third:
    raise SystemExit("failed to resolve a third node distinct from producer and first replica")
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
consumer_pod = ""
for line in pod_lines:
    parts = line.split()
    if len(parts) == 2 and parts[1] == third:
        consumer_pod = parts[0]
        break
if not consumer_pod:
    raise SystemExit(f"failed to resolve artifact-agent pod on third node {third}")
print(json.dumps({
    "producerNode": producer,
    "replicaNode": replica,
    "consumerNode": third,
    "consumerPod": consumer_pod,
}, indent=2, sort_keys=True))
PY
)"
echo "${consumer_info}"

consumer_pod="$(printf '%s\n' "${consumer_info}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["consumerPod"])')"
consumer_node="$(printf '%s\n' "${consumer_info}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["consumerNode"])')"

echo
echo "== step 3: rewrite producerAddress to broken endpoint =="
python3 - <<'PY'
import json
import os
import subprocess
import tempfile

namespace = os.environ["NAMESPACE"]
artifact_id = os.environ["ARTIFACT_ID"]
broken = os.environ["BROKEN_PRODUCER_ADDRESS"]
catalog_pod = os.environ["CATALOG_POD"]
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
record["producerAddress"] = broken
with tempfile.NamedTemporaryFile("w", delete=False, encoding="utf-8") as fh:
    json.dump(record, fh)
    temp_path = fh.name
subprocess.check_call(
    [
        "kubectl",
        "-n",
        namespace,
        "cp",
        temp_path,
        f"{catalog_pod}:/tmp/catalog-record.json",
    ]
)
subprocess.check_call(
    [
        "kubectl",
        "-n",
        namespace,
        "exec",
        "deploy/artifact-catalog",
        "--",
        "python",
        "-c",
        (
            "import json, urllib.request; "
            "data=open('/tmp/catalog-record.json','rb').read(); "
            "req=urllib.request.Request("
            f"'http://127.0.0.1:8090/artifacts/{artifact_id}',"
            "data=data,method='PUT',headers={'Content-Type':'application/json'}"
            "); "
            "urllib.request.urlopen(req, timeout=10).read()"
        ),
    ]
)
print(json.dumps({
    "artifactId": artifact_id,
    "producerAddress": broken,
    "replicaNodes": record.get("replicaNodes", []),
}, indent=2, sort_keys=True))
PY

echo
echo "== step 4: third-node request =="
set +e
kubectl -n "${NAMESPACE}" exec "${consumer_pod}" -- sh -ceu "
  python - <<'PY'
import sys
import urllib.error
import urllib.request

url = 'http://127.0.0.1:8080/artifacts/${ARTIFACT_ID}'
try:
    with urllib.request.urlopen(url, timeout=20) as resp:
        body = resp.read().decode('utf-8', errors='replace')
        print(f'status={resp.status}')
        print(f'source={resp.headers.get(\"X-Artifact-Source\", \"\")}')
        print(body)
except urllib.error.HTTPError as exc:
    print(f'status={exc.code}')
    print(exc.read().decode('utf-8', errors='replace'))
    sys.exit(1)
PY
"
request_rc=$?
set -e

echo
echo "== step 5: consumer local metadata =="
kubectl -n "${NAMESPACE}" exec "${consumer_pod}" -- cat "/var/lib/artifact-handoff/${ARTIFACT_ID}/metadata.json"

echo
echo "== summary =="
echo "consumer_node=${consumer_node}"
echo "consumer_pod=${consumer_pod}"
echo "request_rc=${request_rc}"
