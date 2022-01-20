# 5thK8nd

A good README shall reside here...please see `lib/bootstrap/README.md to get started`

## Quick Facts

### Spin up a cluster

`make cluster`

### Run/Install a specific app

`make install dependency=< name_of_dependency >` where `dependency=STRING` is the name of the directory in which the manifest or helm chart you want to install is located.

e.g. -

`kubectl create ns argo && install dependency=argo-workflows`

`kubectl create ns argocd && install dependency=argo-cd`
