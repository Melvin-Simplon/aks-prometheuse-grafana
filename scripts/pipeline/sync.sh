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

if ! kubectl get application "${app}" -n "${ARGOCD_NAMESPACE:-argocd}" > /dev/null 2>&1; then
    die "${app}: ArgoCD Application not found, run 'make root' first"
fi

if output="$(argocd app sync "${app}" 2>&1)"; then
    log_changed "${app}: synced"
else
    printf '%s\n' "${output}" >&2
    die "${app}: sync failed"
fi

print_recap "${app}"
recap_exit_code
