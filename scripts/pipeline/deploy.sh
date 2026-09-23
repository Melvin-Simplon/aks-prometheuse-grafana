#!/usr/bin/env bash
# Applies one manifest and reports ok/changed from kubectl's own output. In
# this repo it is only ever called on the ArgoCD root Application: ArgoCD
# applies everything else on its own from there.
#
# Runs standalone, outside of make:
#   scripts/pipeline/deploy.sh --path argocd/root.yaml --namespace argocd --label "root Application"

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/pipeline/lib.sh
source "${SCRIPT_DIR}/lib.sh"

path="" label="" namespace="${NAMESPACE:-monitoring}"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --path) path="$2"; shift 2 ;;
        --label) label="$2"; shift 2 ;;
        --namespace) namespace="$2"; shift 2 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[[ -n "${path}" ]] || die "--path is required"
[[ -n "${label}" ]] || label="${path}"

if ! output="$(kubectl apply -f "${path}" -n "${namespace}" 2>&1)"; then
    printf '%s\n' "${output}" >&2
    die "${label}: kubectl apply failed"
fi

while IFS= read -r line; do
    [[ -z "${line}" ]] && continue
    case "${line}" in
        *" unchanged") log_ok "${line}" ;;
        *" created" | *" configured") log_changed "${line}" ;;
        *) log_skip "${line}" ;;
    esac
done <<< "${output}"

print_recap "${label}"
recap_exit_code
