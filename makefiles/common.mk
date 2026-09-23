# Everything the Makefile does: bootstrap, checks, teardown, help. One
# fragment is enough for now, there is no per-component logic left to split
# out, ArgoCD already handles every component on its own once the root is
# registered.

##@ Setup

.PHONY: doctor
doctor: ## Check every prerequisite and report what is missing
	@$(PIPELINE)/doctor.sh

##@ Deploy

.PHONY: deploy
deploy: ## Register the app-of-apps root; ArgoCD deploys and keeps in sync everything under argocd/apps/ from there
	@$(PIPELINE)/deploy.sh --path "argocd/root.yaml" --namespace "$(ARGOCD_NAMESPACE)" --label "root Application"

##@ Inspect

.PHONY: status
status: ## Show every Application's sync/health status, the pods and services
	@$(PIPELINE)/status.sh

.PHONY: logs
logs: ## Follow the logs of one component: make logs COMPONENT=prometheus
	@$(PIPELINE)/logs.sh --component "$(COMPONENT)"

##@ Teardown

.PHONY: destroy
destroy: ## Delete the root Application, cascading to every component and everything it deployed
	@$(PIPELINE)/destroy.sh

##@ Help

.PHONY: lint
lint: ## Run shellcheck over the scripts
	@shellcheck -x $(PIPELINE)/*.sh && echo "shellcheck: clean"

.PHONY: help
help: ## Print this help
	@$(PIPELINE)/help.sh
