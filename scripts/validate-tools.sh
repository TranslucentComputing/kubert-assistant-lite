#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Script Name: validate-tools.sh
# Description: This script checks if the necessary tools (kind, kubectl, helm, jq)
#              are installed on the system. If any tool is missing, it provides
#              instructions for installing the missing tool.
#
# Usage:       ./validate-tools.sh
#
# Copyright © 2024 Kubert
# -----------------------------------------------------------------------------

# Bash safeties: exit on error, no unset variables, pipelines can't hide errors
set -o errexit
set -o nounset
set -o pipefail

# Source the utils.sh script to use its functions

BASE_DIR="$(dirname "$0")"

# shellcheck disable=SC1091
source "$BASE_DIR/utils.sh"

# Tools and their installation instructions

# shellcheck disable=SC2034
TOOLS=("kind" "kubectl" "helm" "jq")
# shellcheck disable=SC2034
INSTRUCTIONS=(
    "Visit https://kind.sigs.k8s.io/docs/user/quick-start/#installation to install kind."
    "Visit https://kubernetes.io/docs/tasks/tools/ to install kubectl."
    "Visit https://helm.sh/docs/intro/install/ to install Helm."
    "Install jq by running: sudo apt-get install jq (Debian/Ubuntu) or brew install jq (macOS)."
)

# Validate the required tools
log "INFO" "Validating required tools..."
check_command TOOLS INSTRUCTIONS
log "INFO" "All required tools are installed. You are ready to proceed!"