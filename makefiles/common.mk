# Everything not tied to ArgoCD itself: checks, teardown, help.

##@ Setup

.PHONY: doctor
doctor: ## Check every prerequisite and report what is missing
	@$(PIPELINE)/doctor.sh

##@ Inspect

.PHONY: status
status: ## Show the Application's sync/health status, the pods and services it manages
	@$(PIPELINE)/status.sh

.PHONY: logs
logs: ## Follow the logs of one component: make logs COMPONENT=prometheus
	@$(PIPELINE)/logs.sh --component "$(COMPONENT)"

##@ Teardown

.PHONY: destroy
destroy: ## Delete the Application, and everything it deployed with it (asks for confirmation)
	@$(PIPELINE)/destroy.sh

##@ Help

.PHONY: lint
lint: ## Run shellcheck over the scripts
	@shellcheck -x $(PIPELINE)/*.sh && echo "shellcheck: clean"

.PHONY: help
help: ## Print this help
	@$(PIPELINE)/help.sh
