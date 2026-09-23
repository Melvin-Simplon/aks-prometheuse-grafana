# What every component shares: forcing an immediate ArgoCD sync of its
# Application instead of waiting for the next automated reconcile. Each
# component fragment calls this instead of spelling out the argocd CLI
# invocation, so this is the only place that knows its shape.
#
#   $(1) ArgoCD Application name, matches a file under argocd/apps/

sync = $(PIPELINE)/sync.sh --app "$(1)"
