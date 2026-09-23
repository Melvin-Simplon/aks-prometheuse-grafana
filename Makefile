# Drives the monitoring stack through ArgoCD. Every per-component target
# forces an immediate sync of that component's Application instead of
# waiting for ArgoCD's next automated reconcile. This assumes both ArgoCD
# and every Application it manages already exist on the cluster.

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

include makefiles/component.mk
include makefiles/prometheus.mk
include makefiles/alertmanager.mk
include makefiles/grafana.mk
include makefiles/exporters.mk
include makefiles/common.mk
