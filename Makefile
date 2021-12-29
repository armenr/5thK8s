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
	./repo.functions kapp_deploy_helm argocd argo-cd --create-namespace
	./repo.functions kapp_deploy_helm argo argo-workflows --create-namespace

# destroy all the things
destroy-cluster:
	k3d cluster delete local-$(USER)
