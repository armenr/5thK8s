# Useful examples & commands

kustomize build --load-restrictor LoadRestrictionsNone --enable-helm . | kubectl-slice --input-file=- -o ./sliced
