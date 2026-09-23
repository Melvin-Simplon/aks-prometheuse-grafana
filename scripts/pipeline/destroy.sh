#!/usr/bin/env bash
# Deletes the root Application. The resources-finalizer on every Application
# (root and each component) makes this cascade all the way down: root deletes
# each component Application, and each of those deletes everything it
# deployed in turn.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/pipeline/lib.sh
source "${HERE}/lib.sh"

require_cmd kubectl "See https://kubernetes.io/docs/tasks/tools/"

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

cat >&2 << EOF

This deletes the root Application and, through it, every component it
manages: Prometheus, Alertmanager, Grafana, the exporters, and everything
they deployed in the ${NAMESPACE:-monitoring} namespace.

EOF

read -r -p "Type 'root' to confirm: " answer
if [[ "${answer}" != "root" ]]; then
    die "got '${answer}', expected 'root'. Nothing was touched."
fi

task "root"
if kubectl delete application root -n "${ARGOCD_NAMESPACE}" > /dev/null 2>&1; then
    report_changed "root" "Application deleted, cascading to every component and its resources"
else
    report_failed "root" "delete failed"
fi
recap "destroy"
