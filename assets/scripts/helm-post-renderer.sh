#!/bin/bash
set -e

PATCH_PATH="dependencies/patches"

cd $PATCH_PATH
cat <&0 > synthesized.yaml
kustomize edit add resource synthesized.yaml
kustomize build . && rm synthesized.yaml
kustomize edit remove resource synthesized.yaml
