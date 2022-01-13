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
AWS_CREDS := $(echo -e "[default]\naws_access_key_id = $(aws configure get aws_access_key_id)\naws_secret_access_key = $(aws configure get aws_secret_access_key)")
CLUSTER_ID := $(whoami)
EXISTING_NAMESPACES := $(shell kubectl get ns --show-labels | sed 1,1d | cut -d ' ' -f1)

define chdir
	$(eval _D=$(firstword $(1) $(@D)))
	$(info $(MAKE): cd $(_D)) $(eval SHELL = cd $(_D); $(CHDIR_SHELL))
endef

cluster:
	k3d cluster create local-$(shell whoami) --config ./lib/assets/k3d_local.yaml --wait;
	kubectl wait --for=condition=available --timeout=600s --all deployments --all-namespaces;
	sleep 20
	kubectl wait \
			--for=condition=available \
			--timeout=360s \
			--all deployments \
			--all-namespaces;

argocd-namespace:
	kubectl create namespace argocd

sealed-secrets-namespace:
	kubectl create namespace sealed-secrets

crossplane-namespace:
	kubectl create namespace crossplane-system

bootstrap-argocd:
	export TZ=UTC
	$(MAKE) argocd-namespace
	$(MAKE) crossplane-namespace
	$(MAKE) sealed-secrets-namespace
	$(MAKE) github-credentials
	$(MAKE) install-argocd
	$(MAKE) install-argocd-applicationset
	$(MAKE) install-cluster-resources
	sleep 40
	$(MAKE) crossplane-aws-sealed-secret

github-credentials:
	kubectl -n argocd create secret generic \
		github-repo-secret \
		--from-literal git_username=$$GITHUB_USER \
		--from-literal git-token=$$GIT_TOKEN

install-argocd:
	export TZ=UTC
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		argocd-app-sets/cluster-resources/argocd \
		| kubectl -n argocd apply -f - \
		&& kubectl wait \
			--for=condition=available \
			--timeout=360s \
			--all deployments \
			--all-namespaces

install-argocd-applicationset:
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		argocd-app-sets/cluster-resources/argocd-applicationset \
		| kubectl -n argocd apply -f -
	kubectl wait \
			--for=condition=available \
			--timeout=360s \
			--all deployments \
			--all-namespaces;

install-cluster-resources:
	kubectl create -n argocd -f lib/bootstrap/apps/appset-cluster-resources.yaml;
	kubectl wait \
		--for=condition=available \
		--timeout=360s \
		--all deployments \
		--all-namespaces;

remove-argocd:
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		argocd-app-sets/cluster-resources/argocd \
		| kubectl -n argocd delete -f -;
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		argocd-app-sets/cluster-resources/argocd-applicationset \
		| kubectl -n argocd delete -f -;
	kubectl delete namespace argocd

crossplane-aws-sealed-secret:
	echo "[default]\naws_access_key_id = $$(aws configure get aws_access_key_id)\naws_secret_access_key = $$(aws configure get aws_secret_access_key)" \
	| \
	kubectl create secret generic aws-credentials \
		--from-file=aws-credentials=/dev/stdin\
		--output json \
		--dry-run=client \
    | kubeseal \
		--format yaml \
		--controller-namespace sealed-secrets \
		--controller-name sealed-secrets \
		--namespace crossplane-system \
    | tee lib/crossplane-assets/configs/aws-credentials.yaml

destroy-cluster:
	k3d cluster delete local-$(shell whoami)


# bootstrap-argocd:

# 	kubectl -n argocd create secret generic \
# 		autopilot-secret \
# 		--from-literal git_username=$GITHUB_USER \
# 		--from-literal git-token=$GIT_TOKEN
# 	kustomize build \
# 		lib/dependencies/argo-cd \
# 		> lib/bootstrap/argo-cd/argo-cd.base.yaml
# 	kustomize build --enable-helm \
# 		lib/dependencies/argocd-applicationset \
# 		> lib/bootstrap/argo-cd/argocd-applicationsets.base.yaml
# 	kustomize build \
# 		lib/bootstrap/argo-cd \
# 		| kubectl apply -n argocd -f -

# destroy all the things
