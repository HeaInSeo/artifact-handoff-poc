#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${ROOT_DIR}/../multipass-k8s-lab/kubeconfig}"
NAMESPACE="${NAMESPACE:-artifact-handoff}"
ARTIFACT_ID="${ARTIFACT_ID:-multi-replica-demo}"

export KUBECONFIG="${KUBECONFIG_PATH}"
export NAMESPACE
export ARTIFACT_ID

artifact_digest="$(python3 - <<'PY'
import hashlib
payload = b"artifact-handoff sprint1 sample payload\n"
print(hashlib.sha256(payload).hexdigest())
PY
)"

echo "== step 1: seed producer + first replica =="
ARTIFACT_ID="${ARTIFACT_ID}" bash "${ROOT_DIR}/scripts/run-cross-node.sh"

echo
echo "== step 2: resolve producer / first replica / second replica target =="
readarray -t replica_nodes < <(
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
print(record.get("producerNode", ""))
replicas = record.get("replicaNodes", [])
if replicas:
    print(replicas[0].get("node", ""))
PY
)

producer_node="${replica_nodes[0]:-}"
first_replica_node="${replica_nodes[1]:-}"

if [[ -z "${producer_node}" || -z "${first_replica_node}" ]]; then
  echo "failed to resolve producer or first replica node" >&2
  exit 1
fi

all_nodes="$(kubectl get nodes --no-headers -o custom-columns=NAME:.metadata.name)"
second_replica_node="$(
  printf '%s\n' "${all_nodes}" | awk -v a="${producer_node}" -v b="${first_replica_node}" '$1 != a && $1 != b {print $1}' | sed -n '1p'
)"

if [[ -z "${second_replica_node}" ]]; then
  echo "failed to resolve a third node for multi-replica prep" >&2
  exit 1
fi

echo "producer=${producer_node}"
echo "first_replica=${first_replica_node}"
echo "second_replica_target=${second_replica_node}"

kubectl delete job -n "${NAMESPACE}" third-replica-prep --ignore-not-found >/dev/null

cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: third-replica-prep
  namespace: ${NAMESPACE}
spec:
  template:
    spec:
      restartPolicy: Never
      tolerations:
        - key: node-role.kubernetes.io/control-plane
          operator: Exists
          effect: NoSchedule
      nodeSelector:
        kubernetes.io/hostname: ${second_replica_node}
      containers:
        - name: child
          image: python:3.12-alpine
          env:
            - name: ARTIFACT_ID
              value: ${ARTIFACT_ID}
            - name: ARTIFACT_DIGEST
              value: ${artifact_digest}
            - name: HOST_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.hostIP
          command:
            - sh
            - -ceu
            - |
              python - <<'PY'
              import hashlib
              import os
              import urllib.request
              with urllib.request.urlopen(
                  f"http://{os.environ['HOST_IP']}:8080/artifacts/{os.environ['ARTIFACT_ID']}",
                  timeout=20,
              ) as resp:
                  payload = resp.read()
                  source = resp.headers.get("X-Artifact-Source", "")
              digest = hashlib.sha256(payload).hexdigest()
              print(payload.decode("utf-8").strip())
              print(f"source={source}")
              print(f"digest={digest}")
              if digest != os.environ["ARTIFACT_DIGEST"]:
                  raise SystemExit("digest mismatch")
              if source not in {"peer-fetch", "local"}:
                  raise SystemExit(f"unexpected source {source}")
              PY
  backoffLimit: 0
EOF

kubectl wait -n "${NAMESPACE}" --for=condition=complete job/third-replica-prep --timeout=180s

echo
echo "== step 3: third replica log =="
kubectl logs -n "${NAMESPACE}" job/third-replica-prep

echo
echo "== step 4: catalog snapshot with multi-replica state =="
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
if len(summary["replicaNodes"]) < 2:
    raise SystemExit("replicaNodes still has fewer than two entries")
PY

echo
echo "== step 5: replica metadata summary =="
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
if len(replicas) < 2:
    raise SystemExit("need at least two replicas for multi-replica summary")

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
).decode("utf-8")
pods = {}
for line in pod_lines.splitlines():
    parts = line.split()
    if len(parts) == 2:
        pods[parts[1]] = parts[0]

summaries = []
for replica in replicas[:2]:
    node_name = replica.get("node", "")
    pod_name = pods.get(node_name, "")
    if not node_name or not pod_name:
        raise SystemExit(f"failed to resolve replica pod on node {node_name}")
    meta_raw = subprocess.check_output(
        [
            "kubectl",
            "-n",
            namespace,
            "exec",
            pod_name,
            "--",
            "cat",
            f"/var/lib/artifact-handoff/{artifact_id}/metadata.json",
        ]
    )
    metadata = json.loads(meta_raw.decode("utf-8"))
    summaries.append(
        {
            "replicaNode": node_name,
            "localNode": metadata.get("localNode", ""),
            "producerNode": metadata.get("producerNode", ""),
            "state": metadata.get("state", ""),
            "source": metadata.get("source", ""),
        }
    )

print(json.dumps(summaries, indent=2, sort_keys=True))
for summary in summaries:
    if summary["state"] != "replicated":
        raise SystemExit(f"expected replicated state on {summary['replicaNode']}, got {summary['state']}")
PY
