#!/bin/sh

# shellcheck disable=SC3040
(set -o pipefail 2> /dev/null) \
  || { echo "ERR: shell with pipefail required" >&2; exit 1; }
set -o pipefail

for arg in "$@"; do
  python3 \
    -c 'import sys, yaml, json;
y=yaml.safe_load(sys.stdin.read())
print(json.dumps(y))' < "$arg" \
          | jq -e .spec \
          | promtool check rules --lint=all --lint-fatal
done
