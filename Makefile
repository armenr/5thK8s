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
	$(MAKE) install-cert-manager
	$(MAKE) v-sync
	$(MAKE) v-manifests
	$(MAKE) argo-workflows-install
	$(MAKE) argocd-install

bootstrap-argocd:
	$(MAKE) install-argocd
	$(MAKE) install-argocd-appsets

remove-argocd:
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		bootstrap/cluster-resources/argocd \
		| kubectl -n argocd delete -f -;
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		bootstrap/cluster-resources/argocd-applicationset \
		| kubectl -n argocd delete -f -;
	kubectl delete namespace argocd

install-argocd:
	kubectl create namespace argocd;
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		bootstrap/cluster-resources/argocd \
		| kubectl -n argocd apply -f -; \
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		bootstrap/cluster-resources/argocd-applicationset \
		| kubectl -n argocd apply -f -;

install-cluster-resources:
	kubectl create -n argocd -f bootstrap/apps/appset-cluster-resources.yaml;

# bootstrap-argocd:

# 	kubectl -n argocd create secret generic \
# 		autopilot-secret \
# 		--from-literal git_username=$GITHUB_USER \
# 		--from-literal git-token=$GIT_TOKEN
# 	kustomize build \
# 		dependencies/argo-cd \
# 		> bootstrap/argo-cd/argo-cd.base.yaml
# 	kustomize build --enable-helm \
# 		dependencies/argocd-applicationset \
# 		> bootstrap/argo-cd/argocd-applicationsets.base.yaml
# 	kustomize build \
# 		bootstrap/argo-cd \
# 		| kubectl apply -n argocd -f -

# destroy all the things
destroy-cluster:
	k3d cluster delete local-$(USER)
