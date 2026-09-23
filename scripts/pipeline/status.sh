#!/usr/bin/env bash
# Where every ArgoCD Application stands, and what it manages: pods, services,
# and the Grafana external IP once assigned.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/pipeline/lib.sh
source "${HERE}/lib.sh"

require_cmd kubectl "See https://kubernetes.io/docs/tasks/tools/"

NAMESPACE="${NAMESPACE:-monitoring}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

show_applications() {
    task "argocd : sync and health of every Application"

    local line name sync health
    while IFS= read -r line; do
        [[ -z "${line}" ]] && continue
        name="${line%% *}"
        sync="$(awk '{print $2}' <<< "${line}")"
        health="$(awk '{print $3}' <<< "${line}")"
        if [[ "${sync}" == "Synced" && "${health}" == "Healthy" ]]; then
            report_ok "${name}" "${sync}, ${health}"
        else
            report_changed "${name}" "${sync}, ${health}"
        fi
    done < <(kubectl get applications -n "${ARGOCD_NAMESPACE}" --no-headers \
        -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status 2> /dev/null || true)
}

show_workloads() {
    task "kubernetes : pods and services in ${NAMESPACE}"
    kubectl get pods -n "${NAMESPACE}" -o wide 2>&1 | while IFS= read -r line; do hint "${line}"; done
    kubectl get svc -n "${NAMESPACE}" 2>&1 | while IFS= read -r line; do hint "${line}"; done
}

show_grafana_url() {
    task "grafana : external address"

    local ip
    ip="$(kubectl get svc grafana -n "${NAMESPACE}" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2> /dev/null || true)"
    if [[ -n "${ip}" ]]; then
        report_ok "grafana" "http://${ip}"
    else
        report_skipped "grafana" "LoadBalancer IP not assigned yet"
    fi
}

main() {
    show_applications
    show_workloads
    show_grafana_url
    recap "status"
}

main "$@"
