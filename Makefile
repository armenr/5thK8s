# Recitals
.ONESHELL: kapp-deploy-helm

.PHONY : \
    argo-bootstrap \
    argo-deprovision \
    cluster \
    destroy \
    install-cert-manager \
    install-sealed-secrets \
    sealed-secrets-generator-aws \
    v-manifests \
	v-sync

# Vars
CHDIR_SHELL := $(SHELL)
AWS_ACCESS_KEY_ID := $(aws configure get default.aws_access_key_id)
AWS_SECRET_ACCESS_KEY := $(aws configure get default.aws_secret_access_key)
CLUSTER_ID := $(whoami)
EXISTING_NAMESPACES := $(shell kubectl get ns --show-labels | sed 1,1d | cut -d ' ' -f1)

define chdir
	$(eval _D=$(firstword $(1) $(@D)))
	$(info $(MAKE): cd $(_D)) $(eval SHELL = cd $(_D); $(CHDIR_SHELL))
endef

cluster:
	k3d cluster create local-$(USER) --config ./assets/k3d_local.yaml

bootstrap-argocd:
	kubectl create namespace argocd
	kustomize build \
		--enable-helm \
		dependencies/argo-cd \
		> dependencies/bootstrap/argo-cd/argo-cd.base.yaml
	kustomize build \
		--enable-helm dependencies/argocd-applicationset \
		> dependencies/bootstrap/argo-cd/argocd-applicationsets.base.yaml
	kustomize build \
		dependencies/bootstrap/argo-cd \
		| kubectl apply -n argocd -f -
	kubectl -n argocd create secret generic autopilot-secret --from-literal git_username=$GITHUB_USER --from-literal git-token=$GIT_TOKEN

# destroy all the things
destroy-cluster:
	k3d cluster delete local-$(USER)
