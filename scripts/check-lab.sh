#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB_DIR="${LAB_DIR:-$(cd "${ROOT_DIR}/../multipass-k8s-lab" && pwd 2>/dev/null || true)}"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${LAB_DIR}/kubeconfig}"
MIN_NODES="${MIN_NODES:-3}"

if [[ -z "${LAB_DIR}" || ! -d "${LAB_DIR}" ]]; then
  echo "missing sibling repo: multipass-k8s-lab" >&2
  exit 1
fi

echo "== lab status from multipass-k8s-lab =="
(cd "${LAB_DIR}" && ./scripts/k8s-tool.sh status) || true

if [[ ! -f "${KUBECONFIG_PATH}" ]]; then
  echo "kubeconfig not found at ${KUBECONFIG_PATH}" >&2
  echo "prepare the cluster via multipass-k8s-lab before deploying this PoC" >&2
  exit 1
fi

export KUBECONFIG="${KUBECONFIG_PATH}"

echo
echo "== kubectl cluster access =="
kubectl cluster-info

echo
echo "== nodes =="
kubectl get nodes -o wide

node_count="$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')"
if [[ "${node_count}" -lt "${MIN_NODES}" ]]; then
  echo "expected at least ${MIN_NODES} nodes, got ${node_count}" >&2
  exit 1
fi

echo
echo "lab check passed with ${node_count} nodes"
