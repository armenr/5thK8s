- Docker Desktop
- Brew
- `kubernetes.docker.internal` in /etc/ hosts --> pointing to 127.0.0.1
- export your GitHub username
- export a GitHub token
        ```sh
        export GIT_TOKEN=TOKEN
        export GITHUB_USER=USER
        ```
- If you wanna be really productive, then use VSCode with the included configs and extensions/plugins recommendations I've curated.

NOTES:

This REPO is the backbone of our new GitOps approach/flow, AND is the starting point for a significant "shift left" in the way 5K TechOps runs.

1. This repo was initially generated with argocd-autopilot (please check that out)
2. This repo is incomplete -- mostly a POC turning into an MVP
3. Have a look at the makefile to get an idea of what's happening here...

If you wanna inspect what's happening in the network, do this:

`kubectl get pod -n kube-system`

Find the pod that's named kinda like this one --> `traefik-6b84f7cbc-2jg5j`

Run this command: `kubectl port-forward traefik-6b84f7cbc-2jg5j -n kube-system 9000:9000`

Go here: http://localhost:9000/dashboard/#/

### Shit for Brew (lots of goodies in here, explore at will!)

Some of these are required for THIS repo.

Others are included because, in my not-so-humble-opinion, it would behoove any architect, engineer, or platform developer/operator to know about and leverage the wonderful tools in this list!

Please keep in mind, I hadn't had much hands-on time with k8s prior to this, so if my choices in tooling make me look like a newb, so be it. I like to be efficient, not write a 15-line bash command with a friendly \ at the end of every bloody line, directly in my terminal.

🤓🤓🤓🤓🤓🤓🤓🤓🤓

```sh
brew install k3d argocd argo
brew install lazygit pre-commit
brew tap vmware-tanzu/carvel
brew install vendir
brew install remake
brew install kuztomize
brew install --cask cakebrew
brew install kubeseal
brew install helm
brew install dive
brew install robscott/tap/kube-capacity
brew install kubectx
brew install octant
brew install boz/repo/kail
brew install --cask lens
brew install yq jq ytt fx
```

Install this - thank me later :)

https://github.com/patrickdappollonio/kubectl-slice

### Get started

```sh
make cluster            # K3d cluster serving up k3s goodness
make v-sync             # vendir sync (look up vendir, awesome!)
make v-manifests        # render custom templates from ytt overrides + vendir
make argo-bootstrap     # bootstrap argo completely
```

THIS will bootstrap a best-practices/opinionated argoCD-oriented GitOps repo for you

Access Argo right away with: https://kubernetes.docker.internal/argocd/

Go here --> https://argocd-autopilot.readthedocs.io/en/stable/

To observe what does a "new project/new environment/new application workflow" look like:

`argocd-autopilot project create testing`

`argocd-autopilot app create hello-world --app github.com/argoproj-labs/`

`argocd-autopilot/examples/demo-app/ -p testing --wait-timeout 2m`

__NOTE:__ Please be CERTAIN to run `git pull` after EVERY `argocd-autopilot` command you run! It very quietly adds shit to your code repo and pushes it for you.

So, just to be safe, please pull after each argocd-autopilot command.

Additionally, there's a bug in the argocd-autopilot CLI --> DO NOT USE ANY OF THE REMOVE/DELETE functionality of the CLI tool for argocd-autopilot.

It will nuke things and automatically push them to github that you do NOT want to lose. Just REMOVE the corresponding project file and App files it creates if you want to remove deployments!

### TEARDOWN/RESET

`make destroy` --> ALL resources will be dispatched to their doom, easily and quickly.
