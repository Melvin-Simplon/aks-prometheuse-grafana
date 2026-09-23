#!/usr/bin/env bash
# Follows the logs of one component by its "app" label.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/pipeline/lib.sh
source "${SCRIPT_DIR}/lib.sh"

component=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --component) component="$2"; shift 2 ;;
        *) die "unknown argument: $1" ;;
    esac
done

[[ -n "${component}" ]] || die "usage: make logs COMPONENT=<name>, e.g. COMPONENT=prometheus"

kubectl logs -f -n "${NAMESPACE:-monitoring}" -l "app=${component}"
