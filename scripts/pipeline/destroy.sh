#!/usr/bin/env bash
# Deletes the root Application, after an explicit confirmation. The
# resources-finalizer on every Application (root and each component) makes
# this cascade all the way down: root deletes each component Application,
# and each of those deletes everything it deployed in turn.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/pipeline/lib.sh
source "${SCRIPT_DIR}/lib.sh"

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

read -r -p "Delete the root Application and everything it deployed? [y/N] " reply
case "${reply}" in
    y | Y) ;;
    *)
        log_skip "destroy cancelled"
        exit 0
        ;;
esac

kubectl delete application root -n "${ARGOCD_NAMESPACE}"
log_changed "root Application deleted, cascading to every component and its resources"
