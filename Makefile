# One command turns a bare ArgoCD install into the whole monitoring stack:
# 'make deploy' registers the app-of-apps root, and ArgoCD's own automated
# sync (prune + selfHeal, already set on every Application under
# argocd/apps/) takes it from there. Pushing to main is the actual deploy
# mechanism; nothing here re-applies manifests by hand or on a schedule,
# that is exactly what ArgoCD already does on its own.

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

# Read by the scripts rather than passed as arguments: they all need the same
# handful of values, and threading them through every call site adds noise
# without adding clarity.
export NAMESPACE ARGOCD_NAMESPACE LOG_FILE

include makefiles/common.mk
