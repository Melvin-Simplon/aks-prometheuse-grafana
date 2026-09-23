#!/usr/bin/env bash
# Shows every ArgoCD Application's sync/health status, then what they
# manage: pods, services, and the Grafana external IP once assigned.

set -euo pipefail
NAMESPACE="${NAMESPACE:-monitoring}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

echo "ArgoCD Applications:"
kubectl get applications -n "${ARGOCD_NAMESPACE}" \
    -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status \
    2> /dev/null || echo "  none registered yet, run 'make root'"
echo
echo "Pods:"
kubectl get pods -n "${NAMESPACE}" -o wide
echo
echo "Services:"
kubectl get svc -n "${NAMESPACE}"
echo

grafana_ip=""
grafana_ip="$(kubectl get svc grafana -n "${NAMESPACE}" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2> /dev/null || true)"
if [[ -n "${grafana_ip}" ]]; then
    echo "Grafana: http://${grafana_ip}"
else
    echo "Grafana: LoadBalancer IP not assigned yet"
fi
