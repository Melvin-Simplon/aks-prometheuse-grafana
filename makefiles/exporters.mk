# The two exporters. Kept separate targets because they sync independently,
# plus one target to sync both.

##@ Deploy

.PHONY: node-exporter
node-exporter: ## Sync node-exporter now instead of waiting for ArgoCD's next reconcile
	@$(call sync,node-exporter)

.PHONY: kube-state-metrics
kube-state-metrics: ## Sync kube-state-metrics now instead of waiting for ArgoCD's next reconcile
	@$(call sync,kube-state-metrics)

.PHONY: exporters
exporters: ## Sync both exporters
	@$(MAKE) node-exporter
	@$(MAKE) kube-state-metrics
