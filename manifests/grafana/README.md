# Grafana

Before applying this deployment, create the admin password secret (never commit it):

```bash
kubectl create secret generic grafana-admin \
  --namespace monitoring \
  --from-literal=admin-password='<your-password>'
```

Without this secret, the pod fails to start (`CreateContainerConfigError`), by design: no default password shipped in the manifests.
