#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${ROOT_DIR}/../multipass-k8s-lab/kubeconfig}"

export KUBECONFIG="${KUBECONFIG_PATH}"

kubectl delete namespace artifact-handoff --ignore-not-found --wait=true
