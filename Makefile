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
	k3d cluster create local-$(shell whoami) --config ./assets/k3d_local.yaml --wait

argocd-namespace:
	kubectl create namespace argocd

bootstrap-argocd:
	echo "Mandatory pause while cluster boots up..."
	sleep 30;
	kubectl wait --for=condition=available --timeout=360s --all deployments --all-namespaces;
	$(MAKE) argocd-namespace
	$(MAKE) install-argocd
	$(MAKE) install-cluster-resources
	echo "WAITING FOR SEALED SECRETS & STUFF..."
	sleep 30;
	kubectl wait --for=condition=available --timeout=360s --all deployments --all-namespaces;
	$(MAKE) crossplane-aws-sealed-secret

install-argocd:
	kubectl -n argocd create secret generic \
		github-repo-secret \
		--from-literal git_username=$$GITHUB_USER \
		--from-literal git-token=$$GIT_TOKEN
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		app-sets/cluster-resources/argocd \
		| kubectl -n argocd apply -f -; \
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		app-sets/cluster-resources/argocd-applicationset \
		| kubectl -n argocd apply -f - \
		&& kubectl wait \
			--for=condition=available \
			--timeout=360s \
			--all deployments \
			--all-namespaces;

remove-argocd:
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		app-sets/cluster-resources/argocd \
		| kubectl -n argocd delete -f -;
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		app-sets/cluster-resources/argocd-applicationset \
		| kubectl -n argocd delete -f -;
	kubectl delete namespace argocd


install-cluster-resources:
	kubectl create -n argocd -f bootstrap/apps/appset-cluster-resources.yaml;

crossplane-aws-sealed-secret:
	echo \
		"[default] \
		aws_access_key_id = $$(aws configure get default.aws_access_key_id) \
		aws_secret_access_key = $$(aws configure get default.aws_secret_access_key) \
		" \
	| kubectl create secret generic aws-credentials \
		--from-file aws-credentials=./aws-creds.cfg \
		--output json \
		--dry-run=client \
    | kubeseal \
		--format yaml \
		--controller-namespace sealed-secrets \
		--controller-name sealed-secrets \
		--namespace crossplane-system \
    | tee crossplane-assets/configs/aws-credentials.yaml


destroy-cluster:
	k3d cluster delete local-$(shell whoami)



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
