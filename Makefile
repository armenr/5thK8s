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

argocd-namespace:
	kubectl create namespace argocd

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

cluster-monitoring-only:
	$(MAKE) cluster
	$(MAKE) install-monitoring-stack

cluster:
	k3d cluster create local-$(shell whoami) --config ./lib/assets/k3d_local.yaml --wait;
	kubectl wait --for=condition=available --timeout=600s --all deployments --all-namespaces;
	kubectl wait --for=condition=complete job/helm-install-traefik -n kube-system --timeout=600s
	kubectl wait --for=condition=complete job/helm-install-traefik-crd -n kube-system --timeout=600s
	kubectl wait --for=condition=available deployment -l "app.kubernetes.io/name=traefik" -n kube-system --timeout=600s
	until kubectl get svc/traefik --namespace kube-system --output=jsonpath='{.status.loadBalancer}' | grep "ingress"; do : ; done
	kubectl wait --for=condition=available --timeout=600s --all deployments --all-namespaces;

crossplane-aws-sealed-secret:
	echo "[default]\naws_access_key_id = $$(aws configure --profile 5k-dev get aws_access_key_id)\naws_secret_access_key = $$(aws configure --profile 5k-dev get aws_secret_access_key)" \
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

crossplane-namespace:
	kubectl create namespace crossplane-system

destroy-cluster:
	k3d cluster delete local-$(shell whoami)

github-credentials:
	kubectl -n argocd create secret generic \
		github-repo-secret \
		--from-literal git_username=$$GITHUB_USER \
		--from-literal git-token=$$GIT_TOKEN

install:
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		lib/dependencies/$(dependency) \
		| kubectl apply -f - \
		&& kubectl wait \
			--for=condition=available \
			--timeout=360s \
			--all deployments \
			--all-namespaces

remove:
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		lib/dependencies/$(dependency) \
		| kubectl delete -f - \
		&& kubectl wait \
			--for=condition=available \
			--timeout=360s \
			--all deployments \
			--all-namespaces

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

install-monitoring-stack:
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		lib/dependencies/monitoring-stack \
		| kubectl apply -f - \
		&& kubectl wait \
			--for=condition=available \
			--timeout=360s \
			--all deployments \
			--all-namespaces

remove-argocd:
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		argocd-app-sets/cluster-resources/argocd \
		| kubectl -n argocd delete -f -;
	kustomize build --load-restrictor LoadRestrictionsNone --enable-helm \
		argocd-app-sets/cluster-resources/argocd-applicationset \
		| kubectl -n argocd delete -f -;
	kubectl delete namespace argo sealed-secrets argocd crossplane-system

sealed-secrets-namespace:
	kubectl create namespace sealed-secrets


# kapp-deploy-%:

# 	helm template \
# 			--release-name $(word 1, $(MAKECMDGOALS)) \
# 			--include-crds \
# 			--namespace argo \
# 			--values lib/dependencies/helm-chart-values/$(word 1, $(MAKECMDGOALS)).yaml \
# 			--repo https://charts.bitnami.com/bitnami $(word 1, $(MAKECMDGOALS)) \
# 	| if [ -d "lib/dependencies/patches/$(word 1, $(MAKECMDGOALS))/" ]; \
# 		then \
# 			ytt \
# 				-f lib/dependencies/patches/$(word 1, $(MAKECMDGOALS)) \
# 				-f - ; \
# 		else \
# 			tmp_helm_rendered=$$(mktemp -u).yml; \
# 			helmTemplate=$$(</dev/stdin); \
# 			echo "$$helmTemplate"; \
# 	fi \
# 	| kapp deploy \
# 		--app $(word 1, $(MAKECMDGOALS)) \
# 		--namespace $(word 2, $(MAKECMDGOALS)) \
# 		--diff-changes \
# 		--file -

