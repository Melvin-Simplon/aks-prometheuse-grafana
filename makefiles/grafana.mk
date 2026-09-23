# Needs the grafana-admin secret to exist first, see manifests/grafana/README.md,
# ArgoCD does not create it (it is not in git), so the pod refuses to start
# without it regardless of how the sync goes.

##@ Deploy

.PHONY: grafana
grafana: ## Sync Grafana now instead of waiting for ArgoCD's next reconcile
	@$(call sync,grafana)
