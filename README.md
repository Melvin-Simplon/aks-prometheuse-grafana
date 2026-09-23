# aks-prometheuse-grafana

See [docs/CONSIGNES.md](docs/CONSIGNES.md) for the project instructions.

## Structure

- `manifests/` : raw Kubernetes YAML, per component (prometheus, alertmanager, grafana, exporters)
- `argocd/` : ArgoCD Application manifests, one per component, plus the app-of-apps root that registers them all
- `dashboards/` : Grafana dashboard JSON files
- `docs/` : project instructions and notes

## Deploy

Requires ArgoCD already installed on the cluster, and `kubectl` pointed at it.

1. Create the Grafana admin secret first, it is never committed to git (see [manifests/grafana/README.md](manifests/grafana/README.md))
2. `make deploy`, registers the app-of-apps root. From there, ArgoCD watches this repo and deploys, then keeps in sync, every component on its own (automated sync, self-heal, prune)

There is no "redeploy" command: once `make deploy` has run once, pushing to `main` is the deployment mechanism.

Useful commands:

```bash
make status   # sync/health of every component, pods, services
make logs COMPONENT=prometheus
make doctor   # checks prerequisites: cluster reachable, ArgoCD installed, secret present...
make destroy  # tears down everything make deploy registered
```

Run `make help` for the full list.
