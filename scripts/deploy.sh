#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${ROOT_DIR}/../multipass-k8s-lab/kubeconfig}"

export KUBECONFIG="${KUBECONFIG_PATH}"

"${ROOT_DIR}/scripts/check-lab.sh"

kubectl apply -f "${ROOT_DIR}/manifests/base/namespace.yaml"
kubectl -n artifact-handoff create configmap agent-code \
  --from-file=agent.py="${ROOT_DIR}/app/agent/agent.py" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl -n artifact-handoff create configmap catalog-code \
  --from-file=catalog.py="${ROOT_DIR}/app/catalog/catalog.py" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -k "${ROOT_DIR}/manifests/base"
kubectl rollout status -n artifact-handoff deploy/artifact-catalog --timeout=120s
kubectl rollout status -n artifact-handoff ds/artifact-agent --timeout=180s

echo
kubectl get pods -n artifact-handoff -o wide
