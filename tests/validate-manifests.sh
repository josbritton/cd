#!/bin/sh
set -eu

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/kubeconform"
mkdir -p "$cache_dir"

kubeconform \
  -n "$(getconf _NPROCESSORS_ONLN)" \
  --cache "$cache_dir" \
  --skip CustomResourceDefinition \
  --ignore-filename-pattern "apps/.*/upstream/.*\.ya?ml" \
  --ignore-filename-pattern "apps/.*/overlays/.*\.ya?ml" \
  --ignore-filename-pattern "apps/.*/files/.*\.ya?ml" \
  --ignore-filename-pattern "/.*\.json" \
  --schema-location default \
  --schema-location "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json" \
  --schema-location "https://json.schemastore.org/{{.ResourceKind}}.json" \
  --summary \
  --strict \
  --verbose \
  -- "$@"
