# Get Bootstrapped

## Pre-requisites

- k3d
- docker
- kustomize
- kubectl
- kubeseal
- helm (v3)

## Quick Start

```bash
export GIT_TOKEN=<YOUR AWSOME TOKEN>
export GITHUB_USER=<YOUR AWESOME USERNAME>

# spin up k3d cluster
# NOTE: See Makefile for shell commands...it's all really vanilla

make cluster

# bootstrap the core cluster stack
# NOTE: ALL you need to install, to bootstrap everything, is JUST ./lib/bootstrap/apps/autobootstrap-manifest.yaml
# After that, the cluster self-manages via ./argocd-app-sets//cluster-resources

make bootstrap-argocd

```

That's it. Everything else happens all on its own

- Make sure you have `kubernetes.docker.internal` in your `/etc/hosts`
- Make sure to add these to `/etc/hosts` as well:
  - `argocd.docker.internal`
  - `workflows.docker.internal`
  - `prometheus.docker.internal`
  - `grafana.docker.internal`
  - `alertmanager.docker.internal`

- ArgoCD: http://argocd.docker.internal/argocd

  - User:     admin
  - Password: BLEEGASTAN123

- Argo-Workflows: http://workflows.docker.internal

  - workflows has no authentication (for now)

- Argo Rollouts: (for now, use port forwarding for argo-rollouts) -> port forward -> open in http://localhost:3100/rollouts

- Traefik dashboard: `kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" -n kube-system --output=name) -n kube-system 9000:9000`
