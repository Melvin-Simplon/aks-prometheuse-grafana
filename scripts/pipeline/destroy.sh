#!/usr/bin/env bash
# Deletes the ArgoCD Application, after an explicit confirmation. The
# resources-finalizer on the Application makes this cascade: everything it
# deployed (Prometheus, Alertmanager, Grafana, the exporters, the namespace)
# is deleted along with it.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/pipeline/lib.sh
source "${SCRIPT_DIR}/lib.sh"

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
ARGOCD_APP="${ARGOCD_APP:-monitoring}"

read -r -p "Delete Application '${ARGOCD_APP}' and everything it deployed? [y/N] " reply
case "${reply}" in
    y | Y) ;;
    *)
        log_skip "destroy cancelled"
        exit 0
        ;;
esac

kubectl delete application "${ARGOCD_APP}" -n "${ARGOCD_NAMESPACE}"
log_changed "ArgoCD Application ${ARGOCD_APP} deleted, cascading to its managed resources"
