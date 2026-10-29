.SILENT:
.DEFAULT_GOAL := build

SHELL := bash
.SHELLFLAGS := -e -o pipefail -c

GIT_DIR := $(shell git rev-parse --git-dir)

CHARTS := $(shell find apps/ -regex ".*/upstream/Chart.ya?ml")

%/upstream/values.yml:
	@:

%/upstream/values.yaml:
	@:

%/upstream/Chart.yml: %/upstream/values.yaml %/upstream/values.yml
	@:

%/upstream/Chart.yaml: %/upstream/values.yaml %/upstream/values.yml
	@:

.PHONY: .FORCE
# only replace when changed, so an unchanged mtime doesn't force every chart to re-render
inventoryns: .FORCE
	@if ! command -v kubectl >/dev/null; then \
		echo "kubectl not found, skipping inventoryns" >&2; \
	elif ! kubectl api-resources --namespaced=true --no-headers | awk '{print $$NF}' | sort -u | paste -sd, - > inventoryns.tmp; then \
		rm -f inventoryns.tmp; \
		echo "kubectl failed, inventoryns not updated" >&2; \
	elif cmp -s inventoryns.tmp inventoryns; then \
		rm inventoryns.tmp; \
	else \
		mv inventoryns.tmp inventoryns; \
	fi

%/resources/upstream.yaml: %/upstream/Chart.yaml %/upstream/Chart.yml inventoryns
	trap 'rm -f "$@.tmp"' EXIT && \
	. "$*/BUILDARGS" && \
	[ ! -L "$*/upstream/Chart.lock" ] && \
	helm dependency update "$*/upstream" && \
	helm template \
	    --include-crds \
	    --namespace "$$NAMESPACE" \
	    "$$CHART" \
	    "$*/upstream" | NAMESPACE="$$NAMESPACE" ./scripts/process-ns.in > "$@.tmp" && \
	mv "$@.tmp" "$@"

RENDERS := $(foreach c,$(CHARTS),$(shell dirname $(shell dirname $(c)))/resources/upstream.yaml)

.PHONY: all
all: build

.PHONY: build
build: $(RENDERS)

.PHONY: clean
clean:
	rm -f $(GIT_DIR)/hooks/pre-commit $(GIT_DIR)/hooks/pre-push
	find apps/ -regex ".*/resources/upstream.ya?ml" -delete
	rm -rf .venv/


.PHONY: test
test: validate

.PHONY: validate
validate: $(GIT_DIR)/hooks/pre-commit $(GIT_DIR)/hooks/pre-push | .gitignore
	. .venv/bin/activate && \
	pre-commit run --all-files --color always

.PHONY: lint
lint: $(GIT_DIR)/hooks/pre-commit $(GIT_DIR)/hooks/pre-push | .gitignore
	. .venv/bin/activate && \
	pre-commit run yamllint --all-files --color always --verbose

.PHONY: install
install: $(GIT_DIR)/hooks/pre-commit $(GIT_DIR)/hooks/pre-push | .gitignore

.venv/lock: requirements.txt
	python3 -m venv .venv/

	. .venv/bin/activate && \
	python3 -m pip install -U -r requirements.txt

	touch .venv/lock

$(GIT_DIR)/hooks/pre-commit: .pre-commit-config.yaml .venv/lock
	. .venv/bin/activate && \
	pre-commit install --hook-type pre-commit && \
	touch $(GIT_DIR)/hooks/pre-commit

$(GIT_DIR)/hooks/pre-push: .pre-commit-config.yaml .venv/lock
	. .venv/bin/activate && \
	pre-commit install --hook-type pre-push && \
	touch $(GIT_DIR)/hooks/pre-push

.gitignore:
	touch .gitignore
