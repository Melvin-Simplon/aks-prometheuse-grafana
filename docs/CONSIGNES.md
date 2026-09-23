# Consignes

## Summary

Deploy a Prometheus + Grafana + Alertmanager stack, along with exporters, on a Kubernetes cluster, without using an operator or a prebuilt Helm chart.

Then create or import a dashboard to visualize node status, and a second dashboard for pod status.

## Typical workflow

1. Gather the list of required Docker images
2. Write the YAML manifests
3. Deploy Prometheus
4. Deploy Alertmanager
5. Deploy Grafana
6. Deploy the exporters
7. Configure everything: connect Grafana to Prometheus, and Prometheus to Alertmanager
8. Build the dashboards

## Bonus

- An alert is configured when a pod crashes (for example, a Discord webhook)
- Everything is deployed using a GitOps tool (ArgoCD, Flux, etc.)
