# je prends des notes en gros

## ArgoCD

alors déjà l'installation d'argoCD sur le cluster se fait facilement, rapido comme ça :  
```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

```  
après il faut l'installer sur sa machine (ils disent depuis le [repo par exemple](https://github.com/argoproj/argo-cd/releases/tag/v3.5.3) ou avec brew)  
` argocd login --core` pour skip les configs, j'ai pas de cerveau, et hop là on en viens à créer les app avec argoCD comme ça :
```bash
argocd app create <nomdelapp> --repo <url/durepo> --path <chemindansleprojer> --dest-server https://kubernetes.default.svc --dest-namespace <leespacenom>
```  
enfin un truc qui ressemble à ça, ce qu'il y a dans --path c'est le dossier qui contiens les yml de l'app qu'on veut déployer, et le dest-server je sais pas à quoi ça correspond, faut se renseigner, dest-namespace c'est explicite quand même (le namespace de destination).  
donc nous le path ce sera un truc du genre manifests/grafana ou manifests/exporters/kube-state-metrics  
Ok et pour le dest-serv c'est le cluster sur lequel on deploie les app et `https://kubernetes.default.svc` ça correspond au cluster sur lequel notre argoCD est deployé, donc tout bon en laissant ça comme ça.

pour que les commandes argoCD fonctionnent faut pas oublier de changer le contexte de ns par defaut `kubectl config set-context --current --namespace argocd`  

une fois que l'app est crée on peut voir son status avec `argocd app get <nomdelapp>` si c'est pas ync on peut sync avec `argocd app sync <nomdelapp>`

pour avoir acces à l'UI web de argoCD on met le loadbalencer du service argoCD comme ça : `kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'`  
puis quand l'ip est dispo (on peut la voir comme ça : ` kubectl get svc argocd-server -n argocd -w`)  
on y accède avec https://<IP> on se connecte avec user: `admin`, et on peut trouver le mot de passe comme ça `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d` (le mot de passe est généré aléatoirement)

## l'appli, l'observabilité etc

donc deja mas images docker à la con là, on prends ces 3 là :

[prometheus](https://hub.docker.com/hardened-images/catalog/dhi/prometheus), [grafana](https://hub.docker.com/hardened-images/catalog/dhi/grafana) et [alertmanager](https://hub.docker.com/hardened-images/catalog/dhi/alertmanager)

plein de manifeste générés par j'sais pas quelle ia (claude code surement)