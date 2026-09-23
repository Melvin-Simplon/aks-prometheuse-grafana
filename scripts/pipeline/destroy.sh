#!/usr/bin/env bash
# Deletes the Grafana and Alertmanager Applications, after an explicit
# confirmation. Does not touch prometheus, node-exporter, kube-state-metrics
# or root: those were registered outside of this Makefile and are shared
# with other people working on the same cluster.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/pipeline/lib.sh
source "${SCRIPT_DIR}/lib.sh"

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

read -r -p "Delete the grafana and alertmanager Applications and everything they deployed? [y/N] " reply
case "${reply}" in
    y | Y) ;;
    *)
        log_skip "destroy cancelled"
        exit 0
        ;;
esac

for app in grafana alertmanager; do
    kubectl delete application "${app}" -n "${ARGOCD_NAMESPACE}"
    log_changed "${app}: Application deleted, cascading to its managed resources"
done
