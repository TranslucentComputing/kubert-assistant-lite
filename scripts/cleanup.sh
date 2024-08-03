#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Script Name: cleanup.sh
# Description: This script cleans up the Kubert AI Assistant Lite application by
#              removing the kind Kubernetes cluster and cleaning up the hosts file.
#
# Usage:       ./cleanup.sh
#
# Copyright © 2024 KubertAI
# -----------------------------------------------------------------------------

# Bash safeties: exit on error, no unset variables, pipelines can't hide errors
set -o errexit
set -o nounset
set -o pipefail

# Source the utils.sh and variables.sh scripts to use their functions and variables
BASE_DIR="$(dirname "$0")"

# shellcheck disable=SC1091
source "$BASE_DIR/utils.sh"
# shellcheck disable=SC1091
source "$BASE_DIR/variables.sh"

# Validate that necessary tools are installed
./scripts/validate-tools.sh

# Main cleanup script
log "INFO" "Starting cleanup process..."

# Remove the kind cluster
if kind get clusters | grep -q "$KIND_CLUSTER_NAME"; then
    log "INFO" "Deleting kind cluster $KIND_CLUSTER_NAME..."
    kind delete cluster --name "$KIND_CLUSTER_NAME"
else
    log "INFO" "Kind cluster $KIND_CLUSTER_NAME does not exist. Skipping deletion."
fi

# Clean up hosts file entries
log "INFO" "Cleaning up hosts file entries..."
clean_up_hosts_file "${HOSTS_ENTRIES[@]}"

log "INFO" "Cleanup process completed successfully."
