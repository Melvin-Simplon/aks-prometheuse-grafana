#!/usr/bin/env bash
# Checks every prerequisite and reports all of them in one pass, instead of
# stopping at the first problem.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/pipeline/lib.sh
source "${SCRIPT_DIR}/lib.sh"

NAMESPACE="${NAMESPACE:-monitoring}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

if command -v kubectl > /dev/null 2>&1; then
    log_ok "kubectl is installed"
else
    log_fatal "kubectl is not installed"
fi

if command -v kubectl > /dev/null 2>&1 && kubectl cluster-info > /dev/null 2>&1; then
    ctx="$(kubectl config current-context 2> /dev/null || echo unknown)"
    log_ok "cluster reachable (context: ${ctx})"
else
    log_unreachable "cluster is not reachable, check your kubeconfig"
fi

if kubectl get namespace "${ARGOCD_NAMESPACE}" > /dev/null 2>&1; then
    log_ok "ArgoCD namespace ${ARGOCD_NAMESPACE} exists"
else
    log_fatal "ArgoCD namespace ${ARGOCD_NAMESPACE} does not exist, install ArgoCD first"
fi

if command -v argocd > /dev/null 2>&1; then
    log_ok "argocd CLI is installed"
else
    log_skip "argocd CLI is not installed, every 'make <component>' sync target will fail"
fi

for app in prometheus alertmanager grafana node-exporter kube-state-metrics; do
    if kubectl get application "${app}" -n "${ARGOCD_NAMESPACE}" > /dev/null 2>&1; then
        log_ok "${app} Application exists"
    else
        log_skip "${app} Application does not exist yet, 'make ${app}' will fail until it is registered in ArgoCD"
    fi
done

if kubectl get secret grafana-admin -n "${NAMESPACE}" > /dev/null 2>&1; then
    log_ok "grafana-admin secret exists"
else
    log_skip "grafana-admin secret is missing, see manifests/grafana/README.md (ArgoCD cannot create it, it is not in git)"
fi

if command -v shellcheck > /dev/null 2>&1; then
    log_ok "shellcheck is installed"
else
    log_skip "shellcheck is not installed, 'make lint' will fail"
fi

print_recap "doctor"
recap_exit_code
