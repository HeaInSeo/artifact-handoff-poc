#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${ROOT_DIR}/../multipass-k8s-lab/kubeconfig}"
NAMESPACE="${NAMESPACE:-artifact-handoff}"
ARTIFACT_ID="${ARTIFACT_ID:-demo-artifact}"
SECOND_HIT=0

if [[ "${1:-}" == "--second-hit" ]]; then
  SECOND_HIT=1
fi

export KUBECONFIG="${KUBECONFIG_PATH}"

preferred_nodes="$(kubectl get nodes --no-headers -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints | awk '$2 !~ /NoSchedule/ {print $1}')"
all_nodes="$(kubectl get nodes --no-headers -o custom-columns=NAME:.metadata.name)"
node_a="${NODE_A:-$(printf '%s\n' "${preferred_nodes}" | sed -n '1p')}"
node_b="${NODE_B:-$(printf '%s\n' "${preferred_nodes}" | sed -n '2p')}"
if [[ -z "${node_a}" ]]; then
  node_a="$(printf '%s\n' "${all_nodes}" | sed -n '1p')"
fi
if [[ -z "${node_b}" ]]; then
  node_b="$(printf '%s\n' "${all_nodes}" | sed -n '2p')"
fi
if [[ -z "${node_a}" || -z "${node_b}" ]]; then
  echo "need at least two schedulable nodes for cross-node validation" >&2
  exit 1
fi

artifact_digest="$(python3 - <<'PY'
import hashlib
payload = b"artifact-handoff sprint1 sample payload\n"
print(hashlib.sha256(payload).hexdigest())
PY
)"

kubectl delete job -n "${NAMESPACE}" parent-cross-node --ignore-not-found >/dev/null
kubectl delete job -n "${NAMESPACE}" child-cross-node --ignore-not-found >/dev/null
kubectl delete job -n "${NAMESPACE}" child-cross-node-second --ignore-not-found >/dev/null

cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: parent-cross-node
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

kubectl wait -n "${NAMESPACE}" --for=condition=complete job/parent-cross-node --timeout=180s

cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: child-cross-node
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
        kubernetes.io/hostname: ${node_b}
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
              if source != "peer-fetch":
                  raise SystemExit(f"expected peer-fetch source, got {source}")
              PY
  backoffLimit: 0
EOF

kubectl wait -n "${NAMESPACE}" --for=condition=complete job/child-cross-node --timeout=180s

echo "== parent log =="
kubectl logs -n "${NAMESPACE}" job/parent-cross-node
echo
echo "== child log =="
kubectl logs -n "${NAMESPACE}" job/child-cross-node

if [[ "${SECOND_HIT}" == "1" ]]; then
  cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: child-cross-node-second
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
        kubernetes.io/hostname: ${node_b}
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
              if source != "local":
                  raise SystemExit(f"expected local source, got {source}")
              PY
  backoffLimit: 0
EOF
  kubectl wait -n "${NAMESPACE}" --for=condition=complete job/child-cross-node-second --timeout=180s
  echo
  echo "== second hit log =="
  kubectl logs -n "${NAMESPACE}" job/child-cross-node-second
fi
