#!/bin/sh
# ACCEPTS path to `kustomization.yaml`
set -eu

parallel -j0 'kustomize build {//}' ::: "$@"
