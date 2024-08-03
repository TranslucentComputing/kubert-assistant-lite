# Makefile for running Bats tests and generating coverage with kcov
#
# Copyright 2024 KubertAI

# Use bash as the shell
SHELL := /bin/bash

# Shell command
SHELL_CMD := /bin/bash

# Directories
TESTS_DIR := tests
UNIT_TESTS_DIR :=  $(TESTS_DIR)/unit
INTEGRATION_TESTS_DIR :=  $(TESTS_DIR)/integration
SCRIPTS_DIR := scripts
COVERAGE_DIR := coverage
BATS_LIBS_DIR := $(TESTS_DIR)/test_helper
BATS_DIR := $(TESTS_DIR)/bats
BATS := $(BATS_DIR)/bin/bats
DOCKER_IMAGE_NAME ?= kubert_kcov
CHART_PATH := manifests/chart

# Unit test file to run, use like this: make tests TEST_FILE=tests/unit/test_specific.bats
# If not specified, runs all tests in the UNIT_TESTS_DIR.
TEST_FILE ?= $(UNIT_TESTS_DIR)

# Pattern to filter tests, use like this: make tests TEST_PATTERN="specific test"
# Leave empty to run all tests within the TEST_FILE or UNIT_TESTS_DIR.
TEST_PATTERN ?=

# Integration test file to run, use like this: make tests TEST_FILE=tests/integration/test_specific.bats
# If not specified, runs all tests in the INTEGRATION_TESTS_DIR.
INTEGRATION_TEST_FILE ?= $(INTEGRATION_TESTS_DIR)

# Pattern to filter tests, use like this: make tests INTEGRATION_TEST_PATTERN="specific test"
# Leave empty to run all tests within the TEST_FILE or INTEGRATION_TEST_FILE.
INTEGRATION_TEST_PATTERN ?=

# Docker security options
DOCKER_SECURITY_OPTS ?= --security-opt seccomp=unconfined

# Docker run command
DOCKER_RUN_CMD := docker run --rm $(DOCKER_SECURITY_OPTS) \
	-v "$(shell pwd):/source"

# kcov command, change to "kcov" if not using Docker
KCOV := $(DOCKER_RUN_CMD) $(DOCKER_IMAGE_NAME) kcov

# Paths to include/exclude in coverage
EXCLUDE_PATH := "/source/$(BATS_LIBS_DIR),/source/$(BATS_DIR)"

# Verbose mode (set VERBOSE=1 to enable)
ifeq ($(VERBOSE),1)
    Q :=
else
    Q := @
endif

# Help target to display available commands
.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Build custom Docker image
.PHONY: build-docker
build-kcov-image: ## Build kcov image with additional tools
	$(Q)command -v docker >/dev/null 2>&1 || { echo >&2 "Docker is not installed. Aborting."; exit 1; }
	$(Q)docker build -t $(DOCKER_IMAGE_NAME) ./tests/support

# Target for running tests
.PHONY: tests
tests: ## Run bats and tests
	$(Q)if [ -z "$(TEST_PATTERN)" ]; then \
        BATS_LIB_PATH=$(BATS_LIBS_DIR) $(BATS) $(TEST_FILE); \
    else \
        BATS_LIB_PATH=$(BATS_LIBS_DIR) $(BATS) -f "$(TEST_PATTERN)" $(TEST_FILE); \
    fi

# Target for running integration tests
.PHONY: integration-tests
integration-tests: ## Run bats integration tests
	$(Q)if [ -z "$(INTEGRATION_TEST_PATTERN)" ]; then \
        BATS_LIB_PATH=$(BATS_LIBS_DIR) $(BATS) -p -t $(INTEGRATION_TEST_FILE); \
    else \
        BATS_LIB_PATH=$(BATS_LIBS_DIR) $(BATS) -p -t -f "$(INTEGRATION_TEST_PATTERN)" $(INTEGRATION_TEST_FILE); \
    fi

# Target for running tests with kcov
.PHONY: coverage
coverage: ## Run kcov and tests
	$(Q)$(KCOV) --exclude-path=$(EXCLUDE_PATH) /source/$(COVERAGE_DIR) /source/$(BATS) /source/$(TEST_FILE)

# Clean up coverage directory
.PHONY: clean-build
clean-build: ## Remove coverage dir and kcov image
	$(Q)rm -rf $(COVERAGE_DIR)
	$(Q)docker rmi $(DOCKER_IMAGE_NAME) || true

# Validate and deploy scripts
.PHONY: deploy
deploy: ## Deploy kind cluster with Kubert Assistant Lite
	$(Q)LOG_TO_TERMINAL=true $(SCRIPTS_DIR)/deploy.sh

# Deploy Kubert Assistant components using Helm
.PHONY: deploy-kubert-assistant
deploy-kubert-assistant: ## Deploy Kubert Assistant components using Helm
	$(Q) LOG_TO_TERMINAL=true && \
	source $(SCRIPTS_DIR)/utils.sh && \
	source $(SCRIPTS_DIR)/variables.sh && \
	deploy_kubert_assistant "$${CHART_PATH}" "$${HELM_NAMESPACE}" "$${KIND_CLUSTER_NAME}" "$${KUBERT_COMPONENTS[@]}"

# Deploy Kubert Assistant components using Helm
.PHONY: cleanup-kubert-assistant
cleanup-kubert-assistant: ## Uninstall deployed Kubert Assistant components with Helm
	$(Q) LOG_TO_TERMINAL=true && \
	source $(SCRIPTS_DIR)/utils.sh && \
	source $(SCRIPTS_DIR)/variables.sh && \
	uninstall_kubert_assistant "$${HELM_NAMESPACE}" "$${KUBERT_COMPONENTS[@]}"

# Cleanup scripts
.PHONY: cleanup
cleanup: ## Clean up kind cluster and hosts file
	$(Q)LOG_TO_TERMINAL=true $(SCRIPTS_DIR)/cleanup.sh

# Dependency check for development
check-deps-dev: ## Check for required dependencies for development
	@command -v docker >/dev/null 2>&1 || { echo >&2 "Docker is not installed. Aborting."; exit 1; }
	@docker info >/dev/null 2>&1 || { echo >&2 "Docker is not running or not accessible. Aborting."; exit 1; }
	@command -v kind >/dev/null 2>&1 || { echo >&2 "Kind is not installed. Aborting."; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo >&2 "Kubectl is not installed. Aborting."; exit 1; }
	@command -v helm >/dev/null 2>&1 || { echo >&2 "Helm is not installed. Aborting."; exit 1; }
	@command -v jq >/dev/null 2>&1 || { echo >&2 "jq is not installed. Aborting."; exit 1; }
	@[ -x "$(BATS)" ] || { echo >&2 "Bats is not installed or not executable. Aborting."; exit 1; }
	@echo "All development dependencies are installed."

# Dependency check for deployment
.PHONY: check-deps-deploy
check-deps-deploy: ## Check for required dependencies for deployment
	$(Q)command -v docker >/dev/null 2>&1 || { echo >&2 "Docker is not installed. Aborting."; exit 1; }
	@docker info >/dev/null 2>&1 || { echo >&2 "Docker is not running or not accessible. Aborting."; exit 1; }
	$(Q)command -v kind >/dev/null 2>&1 || { echo >&2 "Kind is not installed. Aborting."; exit 1; }
	$(Q)command -v kubectl >/dev/null 2>&1 || { echo >&2 "Kubectl is not installed. Aborting."; exit 1; }
	$(Q)command -v helm >/dev/null 2>&1 || { echo >&2 "Helm is not installed. Aborting."; exit 1; }
	$(Q)command -v jq >/dev/null 2>&1 || { echo >&2 "jq is not installed. Aborting."; exit 1; }
	$(Q)echo "All deployment dependencies are installed."

# Lint the Helm chart
.PHONY: lint
lint-chart: ## Lint the Helm chart
	helm lint $(CHART_PATH)

# Template the Helm chart
.PHONY: template
template-chart: ## Template the Helm chart
	helm template --debug $(CHART_PATH)

# Helm test target
.PHONY: helm-test
helm-test: ## Run Helm tests
	$(Q) LOG_TO_TERMINAL=true source $(SCRIPTS_DIR)/variables.sh && \
	for component in "$${KUBERT_COMPONENTS[@]}"; do \
	    IFS=":" read -r release_name values_file <<< "$$component"; \
	    helm test "$$release_name" -n "$$HELM_NAMESPACE"; \
	done