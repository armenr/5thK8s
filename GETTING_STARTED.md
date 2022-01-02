```
k3d cluster create --config assets/k3d_local.yaml

kubectl create namespace argocd

kustomize build --load-restrictor LoadRestrictionsNone --enable-helm bootstrap/argo-cd | kubectl apply -n argocd -f -

cd bootstrap && kubectl create -f autopilot-bootstrap.yaml

# If `create` gives you shit, use `kubectl apply` instead

#Additional requirement (you need a Github username + Github TOKEN to exported into your ENV)

export GIT_TOKEN=
export GITHUB_USER=

# create github private repo access secrets configmap
kubectl -n argocd create secret generic autopilot-secret --from-literal git_username=$GITHUB_USER --from-literal git-token=$GIT_TOKEN

```

That's it. Everything else happens all on its own

- Make sure you have kubernetes.docker.internal in your /etc/hosts

- ArgoCD: http://kubernetes.docker.internal/argocd

- user - admin, password - BLEEGASTAN123

- Argo-Workflows: http://kubernetes.docker.internal/workflows

- workflows has no authentication (for now)
- Argo Rollouts: (for now, use port forwarding for argo-rollouts) -> port forward -> open in http://localhost:3100/rollouts

- Traefik dashboard: `kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" -n kube-system --output=name) -n kube-system 9000:9000`
