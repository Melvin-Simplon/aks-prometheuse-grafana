# One command turns a bare ArgoCD install into the whole monitoring stack:
# 'make deploy' registers the app-of-apps root, and ArgoCD's own automated
# sync (prune + selfHeal, already set on every Application under
# argocd/apps/) takes it from there. Pushing to main is the actual deploy
# mechanism; nothing here re-applies manifests by hand or on a schedule,
# that is exactly what ArgoCD already does on its own. This Makefile only
# bootstraps it once and gives visibility into what it is doing.

SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

NAMESPACE        ?= monitoring
ARGOCD_NAMESPACE ?= argocd

# Timestamped, append-only trace of every run. Override to keep one operation
# on its own:
#   make deploy LOG_FILE=.logs/deploy-2026-09-23.log
LOG_FILE ?= .logs/pipeline.log

PIPELINE := scripts/pipeline

export NAMESPACE ARGOCD_NAMESPACE LOG_FILE

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
