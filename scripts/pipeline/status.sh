#!/usr/bin/env bash
# Shows the ArgoCD Application's sync/health status, then what it manages:
# pods, services, and the Grafana external IP once assigned.

set -euo pipefail
NAMESPACE="${NAMESPACE:-monitoring}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
ARGOCD_APP="${ARGOCD_APP:-monitoring}"

echo "ArgoCD Application:"
kubectl get application "${ARGOCD_APP}" -n "${ARGOCD_NAMESPACE}" \
    -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status \
    2> /dev/null || echo "  not registered yet, run 'make app'"
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
