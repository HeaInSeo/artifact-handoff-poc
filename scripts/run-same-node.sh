#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${ROOT_DIR}/../multipass-k8s-lab/kubeconfig}"
NAMESPACE="${NAMESPACE:-artifact-handoff}"
ARTIFACT_ID="${ARTIFACT_ID:-demo-artifact}"

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
  echo "failed to resolve node A" >&2
  exit 1
fi

artifact_digest="$(python3 - <<'PY'
import hashlib
payload = b"artifact-handoff sprint1 sample payload\n"
print(hashlib.sha256(payload).hexdigest())
PY
)"

kubectl delete job -n "${NAMESPACE}" parent-same-node --ignore-not-found >/dev/null
kubectl delete job -n "${NAMESPACE}" child-same-node --ignore-not-found >/dev/null

cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: parent-same-node
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
          envFrom: []
          volumeMounts: []
          resources: {}
          imagePullPolicy: IfNotPresent
          stdin: false
          tty: false
          workingDir: /
          securityContext: {}
          terminationMessagePolicy: File
          terminationMessagePath: /dev/termination-log
          env:
            - name: ARTIFACT_ID
              value: ${ARTIFACT_ID}
            - name: ARTIFACT_DIGEST
              value: ${artifact_digest}
            - name: HOST_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.hostIP
  backoffLimit: 0
EOF

kubectl wait -n "${NAMESPACE}" --for=condition=complete job/parent-same-node --timeout=180s

producer_node="$(
python3 - <<'PY'
import json
import os
import subprocess
import sys

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

if [[ -z "${producer_node}" ]]; then
  echo "failed to resolve producer node from catalog" >&2
  exit 1
fi

cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: child-same-node
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
                  timeout=10,
              ) as resp:
                  payload = resp.read()
                  source = resp.headers.get("X-Artifact-Source", "")
              digest = hashlib.sha256(payload).hexdigest()
              print(payload.decode("utf-8").strip())
              print(f"source={source}")
              print(f"digest={digest}")
              if digest != os.environ["ARTIFACT_DIGEST"]:
                  raise SystemExit("digest mismatch")
              if source != "local":
                  raise SystemExit(f"expected local source, got {source}")
              PY
  backoffLimit: 0
EOF

kubectl wait -n "${NAMESPACE}" --for=condition=complete job/child-same-node --timeout=180s

echo "== parent log =="
kubectl logs -n "${NAMESPACE}" job/parent-same-node
echo
echo "== child log =="
kubectl logs -n "${NAMESPACE}" job/child-same-node
