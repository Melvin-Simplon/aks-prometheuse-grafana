# The ArgoCD side: registering the Application and driving it once it exists.
# There is no per-component target here on purpose. With selfHeal enabled,
# anything applied by hand outside of git would just be reverted by ArgoCD on
# its next reconcile, so there is exactly one way to change what is deployed:
# change manifests/ and let ArgoCD pick it up.

##@ Deploy

.PHONY: app
app: ## Register/update the ArgoCD Application (the only apply this Makefile ever does)
	@$(PIPELINE)/deploy.sh --path "argocd/application.yaml" --namespace "$(ARGOCD_NAMESPACE)" --label "ArgoCD Application"

##@ Inspect

.PHONY: sync
sync: ## Force an immediate sync instead of waiting for ArgoCD's polling interval
	@argocd app sync $(ARGOCD_APP)

.PHONY: diff
diff: ## Show what differs between git and the live cluster
	@argocd app diff $(ARGOCD_APP) || true
