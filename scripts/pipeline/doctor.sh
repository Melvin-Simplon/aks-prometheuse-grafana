#!/usr/bin/env bash
# Reports every prerequisite the other targets depend on.
#
# The only script here that keeps going after a problem: knowing all of what is
# missing in one pass is the point. Read only, so nothing is ever reported as
# changed. Exit status is 0 when nothing failed and nothing was unreachable.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/pipeline/lib.sh
source "${HERE}/lib.sh"

NAMESPACE="${NAMESPACE:-monitoring}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
APPS=(prometheus alertmanager grafana node-exporter kube-state-metrics)

check_kubectl() {
    task "kubectl : installed and pointed at a live cluster"

    if ! have kubectl; then
        report_failed "workstation" "kubectl is not installed"
        return
    fi
    report_ok "workstation" "kubectl is installed"

    if kubectl cluster-info > /dev/null 2>&1; then
        report_ok "$(kubectl config current-context 2> /dev/null || echo unknown)" "cluster reachable"
    else
        report_unreachable "workstation" "cluster is not reachable"
        hint "check your kubeconfig"
    fi
}

check_argocd() {
    task "argocd : installed, and every Application registered"

    if kubectl get namespace "${ARGOCD_NAMESPACE}" > /dev/null 2>&1; then
        report_ok "${ARGOCD_NAMESPACE}" "namespace exists"
    else
        report_failed "${ARGOCD_NAMESPACE}" "namespace does not exist, install ArgoCD first"
        return
    fi

    if kubectl get application root -n "${ARGOCD_NAMESPACE}" > /dev/null 2>&1; then
        report_ok "root" "Application exists"
    else
        report_skipped "root" "Application does not exist yet"
        hint "make deploy"
    fi

    local app
    for app in "${APPS[@]}"; do
        if kubectl get application "${app}" -n "${ARGOCD_NAMESPACE}" > /dev/null 2>&1; then
            report_ok "${app}" "Application exists"
        else
            report_skipped "${app}" "Application does not exist yet, ArgoCD creates it once 'make deploy' has run"
        fi
    done
}

check_grafana_secret() {
    task "grafana : admin secret"

    if kubectl get secret grafana-admin -n "${NAMESPACE}" > /dev/null 2>&1; then
        report_ok "grafana-admin" "secret exists"
    else
        report_skipped "grafana-admin" "secret is missing, ArgoCD cannot create it, it is not in git"
        hint "see manifests/grafana/README.md"
    fi
}

check_shellcheck() {
    task "workstation : shellcheck"

    if have shellcheck; then
        report_ok "workstation" "shellcheck is installed"
    else
        report_skipped "workstation" "shellcheck is not installed, 'make lint' will fail"
    fi
}

main() {
    check_kubectl
    check_argocd
    check_grafana_secret
    check_shellcheck
    recap "doctor"
}

main "$@"
