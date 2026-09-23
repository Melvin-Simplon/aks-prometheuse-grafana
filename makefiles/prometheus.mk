##@ Deploy

.PHONY: prometheus
prometheus: ## Sync Prometheus now instead of waiting for ArgoCD's next reconcile
	@$(call sync,prometheus)
