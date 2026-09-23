##@ Deploy

.PHONY: alertmanager
alertmanager: ## Sync Alertmanager now instead of waiting for ArgoCD's next reconcile
	@$(call sync,alertmanager)
