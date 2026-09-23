# Everything not tied to one component: checks, orchestration, teardown, help.

##@ Setup

.PHONY: doctor
doctor: ## Check every prerequisite and report what is missing
	@$(PIPELINE)/doctor.sh

##@ Deploy

# Sequential through recursive make rather than a prerequisite list: make is
# free to reorder prerequisites. Prometheus and Alertmanager go first so
# Grafana's dashboards have data as soon as it starts, instead of a few
# minutes of "no data" while they catch up.
.PHONY: deploy
deploy: ## Sync every component now: prometheus, alertmanager, exporters, grafana
	@$(MAKE) prometheus
	@$(MAKE) alertmanager
	@$(MAKE) exporters
	@$(MAKE) grafana

##@ Inspect

.PHONY: status
status: ## Show every Application's sync/health status, the pods and services
	@$(PIPELINE)/status.sh

.PHONY: logs
logs: ## Follow the logs of one component: make logs COMPONENT=prometheus
	@$(PIPELINE)/logs.sh --component "$(COMPONENT)"

##@ Teardown

.PHONY: destroy
destroy: ## Delete the grafana and alertmanager Applications and everything they deployed
	@$(PIPELINE)/destroy.sh

##@ Help

.PHONY: lint
lint: ## Run shellcheck over the scripts
	@shellcheck -x $(PIPELINE)/*.sh && echo "shellcheck: clean"

.PHONY: help
help: ## Print this help
	@$(PIPELINE)/help.sh
