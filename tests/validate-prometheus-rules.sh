#!/bin/bash
set -euo pipefail

rc=0
for arg in "$@"; do
  python3 \
    -c 'import sys, yaml, json;
y=yaml.safe_load(sys.stdin.read())
print(json.dumps(y))' < "$arg" \
          | jq -e .spec \
          | promtool check rules --lint=all --lint-fatal \
    || { echo "$arg: invalid rules" >&2; rc=1; }
done
exit "$rc"
