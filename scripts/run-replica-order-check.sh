#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${ROOT_DIR}/../multipass-k8s-lab/kubeconfig}"
NAMESPACE="${NAMESPACE:-artifact-handoff}"
ARTIFACT_ID="${ARTIFACT_ID:-replica-order-demo}"
BROKEN_PRODUCER_ADDRESS="${BROKEN_PRODUCER_ADDRESS:-http://10.255.255.1:8080}"
BROKEN_FIRST_REPLICA_ADDRESS="${BROKEN_FIRST_REPLICA_ADDRESS:-http://10.255.255.2:8080}"

export KUBECONFIG="${KUBECONFIG_PATH}"
export NAMESPACE
export ARTIFACT_ID
export BROKEN_PRODUCER_ADDRESS
export BROKEN_FIRST_REPLICA_ADDRESS

echo "== step 1: prepare producer + first replica + second replica =="
ARTIFACT_ID="${ARTIFACT_ID}" bash "${ROOT_DIR}/scripts/run-multi-replica-prep.sh"

echo
echo "== step 2: capture catalog order =="
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
    "artifactId": artifact_id,
    "producerNode": record.get("producerNode", ""),
    "producerAddress": record.get("producerAddress", ""),
    "replicaNodes": record.get("replicaNodes", []),
}
print(json.dumps(summary, indent=2, sort_keys=True))
if len(summary["replicaNodes"]) < 2:
    raise SystemExit("need at least two replicaNodes")
PY

echo
echo "== step 3: rewrite producer and first replica addresses to broken endpoints =="
python3 - <<'PY'
import json
import os
import subprocess
import tempfile

namespace = os.environ["NAMESPACE"]
artifact_id = os.environ["ARTIFACT_ID"]
broken_producer = os.environ["BROKEN_PRODUCER_ADDRESS"]
broken_first_replica = os.environ["BROKEN_FIRST_REPLICA_ADDRESS"]
catalog_pod = subprocess.check_output(
    [
        "kubectl",
        "-n",
        namespace,
        "get",
        "pods",
        "-l",
        "app=artifact-catalog",
        "-o",
        "jsonpath={.items[0].metadata.name}",
    ]
).decode("utf-8").strip()
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
record["producerAddress"] = broken_producer
replicas = record.get("replicaNodes", [])
if len(replicas) < 2:
    raise SystemExit("need at least two replicas before rewriting addresses")
replicas[0]["address"] = broken_first_replica
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
            "import urllib.request; "
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
    "producerAddress": broken_producer,
    "firstReplicaAddress": broken_first_replica,
    "secondReplicaAddress": replicas[1].get("address", ""),
    "replicaNodes": replicas,
}, indent=2, sort_keys=True))
PY

echo
echo "== step 4: choose producer node consumer and clear local copy =="
producer_info="$(
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
producer = record.get("producerNode", "")
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
producer_pod = ""
for line in pod_lines:
    parts = line.split()
    if len(parts) == 2 and parts[1] == producer:
        producer_pod = parts[0]
        break
if not producer_pod:
    raise SystemExit(f"failed to resolve producer pod for node {producer}")
print(json.dumps({"producerNode": producer, "producerPod": producer_pod}, indent=2, sort_keys=True))
PY
)"
echo "${producer_info}"

producer_pod="$(printf '%s\n' "${producer_info}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["producerPod"])')"
kubectl -n "${NAMESPACE}" exec "${producer_pod}" -- rm -rf "/var/lib/artifact-handoff/${ARTIFACT_ID}"

echo
echo "== step 5: producer-node request after ordered candidate rewrite =="
set +e
kubectl -n "${NAMESPACE}" exec "${producer_pod}" -- sh -ceu "
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
echo "== step 6: producer-node local metadata after fallback =="
kubectl -n "${NAMESPACE}" exec "${producer_pod}" -- cat "/var/lib/artifact-handoff/${ARTIFACT_ID}/metadata.json"

echo
echo "== summary =="
echo "producer_pod=${producer_pod}"
echo "request_rc=${request_rc}"
