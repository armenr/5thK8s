# Bootstrap

This dependency bootstraps our argo-cd deployment.

Whie it all seems a bit recursive and self-referencial, this is worthwile, because the cluster self-manages.

Yes. That's right. ArgoCD manages itself, once bootstrapped.

For example, to update ArgoCD, all we have to do is push a new manifest to `bootstrap/argo-cd/argo-cd.base.yaml` and watch the magic happen.

## Bootstrapping
UPDATE ME

THEN, simply visit: http://kubernetes.docker.internal/argocd/

username: admin
password: BLEEGASTAN123
