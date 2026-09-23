# Registers the monitoring stack with ArgoCD and drives it from there. The
# workstation applies exactly one thing, the Application resource; every
# actual deployment (Prometheus, Alertmanager, Grafana, the exporters) is
# done by ArgoCD's own controller, continuously reconciling manifests/ from
# git. This assumes ArgoCD is already installed on the cluster.

SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

NAMESPACE        ?= monitoring
ARGOCD_NAMESPACE ?= argocd
ARGOCD_APP       ?= monitoring

# Timestamped, append-only trace of every run. Override to keep one operation
# on its own:
#   make app LOG_FILE=.logs/app-2026-09-23.log
LOG_FILE ?= .logs/pipeline.log

PIPELINE := scripts/pipeline

# Read by the scripts rather than passed as arguments: they all need the same
# handful of values, and threading them through every call site adds noise
# without adding clarity.
export NAMESPACE ARGOCD_NAMESPACE ARGOCD_APP LOG_FILE

include makefiles/argocd.mk
include makefiles/common.mk
