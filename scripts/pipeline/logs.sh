#!/usr/bin/env bash
# Follows the logs of one component by its "app" label.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/pipeline/lib.sh
source "${HERE}/lib.sh"

require_cmd kubectl "See https://kubernetes.io/docs/tasks/tools/"

COMPONENT=''
while [[ $# -gt 0 ]]; do
    case "$1" in
        --component) COMPONENT="$2"; shift 2 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[[ -n "${COMPONENT}" ]] || die "usage: make logs COMPONENT=<name>, e.g. COMPONENT=prometheus"

log_info "following ${COMPONENT} (Ctrl-C to stop)"
kubectl logs -f -n "${NAMESPACE:-monitoring}" -l "app=${COMPONENT}"
