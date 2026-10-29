#!/bin/sh
# ACCEPTS path to `Chart.yaml|Chart.yml`
set -eu

parallel -j0 '
  if [ -L {//}/Chart.lock ]; then echo {//}/Chart.lock must not be a symlink >&2; exit 1; fi
  helm dependency update {//} && helm template --include-crds --namespace testns -- testchart {//}
' ::: "$@"
