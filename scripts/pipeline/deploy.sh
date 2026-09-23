#!/usr/bin/env bash
# Applies one manifest and reports ok/changed from kubectl's own output. In
# this repo it is only ever called on the ArgoCD root Application: ArgoCD
# applies everything else on its own from there.
#
# Runs standalone, outside of make:
#   scripts/pipeline/deploy.sh --path argocd/root.yaml --namespace argocd --label "root Application"

set -euo pipefail

ORIGINAL_ARGS="$*"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/pipeline/lib.sh
source "${HERE}/lib.sh"

require_cmd kubectl "See https://kubernetes.io/docs/tasks/tools/"

PATH_ARG='' LABEL='' NAMESPACE_ARG="${NAMESPACE:-monitoring}"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --path) PATH_ARG="$2"; shift 2 ;;
        --label) LABEL="$2"; shift 2 ;;
        --namespace) NAMESPACE_ARG="$2"; shift 2 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[[ -n "${PATH_ARG}" ]] || die "usage: deploy.sh --path FILE [--label NAME] [--namespace NS]"
[[ -n "${LABEL}" ]] || LABEL="${PATH_ARG}"

task "${LABEL}"

output=""
if ! output="$(kubectl apply -f "${PATH_ARG}" -n "${NAMESPACE_ARG}" 2>&1)"; then
    report_failed "${LABEL}" "kubectl apply failed"
    hint "${output}"
    recap "${LABEL}"
    exit 1
fi

while IFS= read -r line; do
    [[ -z "${line}" ]] && continue
    case "${line}" in
        *" unchanged") report_ok "${LABEL}" "${line}" ;;
        *" created" | *" configured") report_changed "${LABEL}" "${line}" ;;
        *) report_skipped "${LABEL}" "${line}" ;;
    esac
done <<< "${output}"

recap "${LABEL}"
