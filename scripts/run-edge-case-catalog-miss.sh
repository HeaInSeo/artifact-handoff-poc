#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${ROOT_DIR}/../multipass-k8s-lab/kubeconfig}"
NAMESPACE="${NAMESPACE:-artifact-handoff}"
ARTIFACT_ID="${ARTIFACT_ID:-edge-case-catalog-miss}"

export KUBECONFIG="${KUBECONFIG_PATH}"
export NAMESPACE
export ARTIFACT_ID

preferred_nodes="$(kubectl get nodes --no-headers -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints | awk '$2 !~ /NoSchedule/ {print $1}')"
all_nodes="$(kubectl get nodes --no-headers -o custom-columns=NAME:.metadata.name)"
node_a="${NODE_A:-$(printf '%s\n' "${preferred_nodes}" | sed -n '1p')}"
if [[ -z "${node_a}" ]]; then
  node_a="$(printf '%s\n' "${all_nodes}" | sed -n '1p')"
fi
if [[ -z "${node_a}" ]]; then
  echo "failed to resolve producer node" >&2
  exit 1
fi

artifact_digest="$(python3 - <<'PY'
import hashlib
payload = b"artifact-handoff sprint1 sample payload\n"
print(hashlib.sha256(payload).hexdigest())
PY
)"

kubectl delete job -n "${NAMESPACE}" edge2-parent --ignore-not-found >/dev/null
kubectl delete job -n "${NAMESPACE}" edge2-consumer --ignore-not-found >/dev/null

cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: edge2-parent
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
        kubernetes.io/hostname: ${node_a}
      containers:
        - name: parent
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
              import os
              import urllib.request
              payload = b"artifact-handoff sprint1 sample payload\n"
              req = urllib.request.Request(
                  f"http://{os.environ['HOST_IP']}:8080/artifacts/{os.environ['ARTIFACT_ID']}",
                  data=payload,
                  method="PUT",
                  headers={"X-Artifact-Digest": os.environ["ARTIFACT_DIGEST"]},
              )
              with urllib.request.urlopen(req, timeout=10) as resp:
                  print(resp.read().decode("utf-8"))
              PY
  backoffLimit: 0
EOF

kubectl wait -n "${NAMESPACE}" --for=condition=complete job/edge2-parent --timeout=180s

producer_node="$(
python3 - <<'PY'
import json
import os
import subprocess

namespace = os.environ["NAMESPACE"]
artifact_id = os.environ["ARTIFACT_ID"]
raw = subprocess.check_output(
    ["kubectl", "-n", namespace, "exec", "deploy/artifact-catalog", "--", "wget", "-qO-", f"http://127.0.0.1:8090/artifacts/{artifact_id}"],
)
record = json.loads(raw.decode("utf-8"))
producer_node = record.get("producerNode", "")
if not producer_node:
    raise SystemExit("producerNode missing from catalog record")
print(producer_node)
PY
)"

ARTIFACT_ID="${ARTIFACT_ID}" kubectl -n "${NAMESPACE}" exec deploy/artifact-catalog -- python3 -c '
import json
import os

path = "/data/catalog.json"
with open(path, "r", encoding="utf-8") as fh:
    records = json.load(fh)
records.pop(os.environ["ARTIFACT_ID"], None)
tmp = path + ".tmp"
with open(tmp, "w", encoding="utf-8") as fh:
    json.dump(records, fh, indent=2, sort_keys=True)
os.replace(tmp, path)
print("removed", os.environ["ARTIFACT_ID"])
'

cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: edge2-consumer
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
        kubernetes.io/hostname: ${producer_node}
      containers:
        - name: consumer
          image: python:3.12-alpine
          env:
            - name: ARTIFACT_ID
              value: ${ARTIFACT_ID}
            - name: HOST_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.hostIP
          command:
            - sh
            - -ceu
            - |
              python - <<'PY'
              import os
              import urllib.error
              import urllib.request

              url = f"http://{os.environ['HOST_IP']}:8080/artifacts/{os.environ['ARTIFACT_ID']}"
              try:
                  with urllib.request.urlopen(url, timeout=20) as resp:
                      body = resp.read().decode("utf-8", errors="replace")
                      print(f"status={resp.status}")
                      print(f"source={resp.headers.get('X-Artifact-Source', '')}")
                      print(body)
              except urllib.error.HTTPError as exc:
                  body = exc.read().decode("utf-8", errors="replace")
                  print(f"status={exc.code}")
                  print(body)
                  raise SystemExit(0)
              PY
  backoffLimit: 0
EOF

kubectl wait -n "${NAMESPACE}" --for=condition=complete job/edge2-consumer --timeout=180s

echo "producer_node=${producer_node}"
echo "consumer_node=${producer_node}"
echo
echo "== parent log =="
kubectl logs -n "${NAMESPACE}" job/edge2-parent
echo
echo "== drop-catalog log =="
echo "removed ${ARTIFACT_ID} from catalog.json"
echo
echo "== consumer log =="
kubectl logs -n "${NAMESPACE}" job/edge2-consumer
