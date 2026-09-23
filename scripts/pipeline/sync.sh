#!/usr/bin/env bash
# Forces an immediate ArgoCD sync of one Application, instead of waiting for
# its next automated reconcile.
#
# Runs standalone, outside of make:
#   scripts/pipeline/sync.sh --app prometheus

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/pipeline/lib.sh
source "${SCRIPT_DIR}/lib.sh"

app=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --app) app="$2"; shift 2 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[[ -n "${app}" ]] || die "--app is required"

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

if ! kubectl get application "${app}" -n "${ARGOCD_NAMESPACE}" > /dev/null 2>&1; then
    die "${app}: ArgoCD Application not found in namespace ${ARGOCD_NAMESPACE}"
fi

# `argocd --core` talks to Kubernetes directly instead of the ArgoCD API
# server, but it looks up argocd-cm in the kubeconfig context's current
# namespace rather than accepting one as a flag. Switch to it for this one
# call only, and always restore whatever was there before, even on failure.
previous_ns="$(kubectl config view --minify -o jsonpath='{..namespace}' 2> /dev/null || true)"
restore_ns() { kubectl config set-context --current --namespace="${previous_ns}" > /dev/null 2>&1 || true; }
trap restore_ns EXIT

kubectl config set-context --current --namespace="${ARGOCD_NAMESPACE}" > /dev/null

if output="$(argocd app sync "${app}" --core 2>&1)"; then
    log_changed "${app}: synced"
else
    printf '%s\n' "${output}" >&2
    die "${app}: sync failed"
fi

print_recap "${app}"
recap_exit_code
