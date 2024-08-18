#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Script Name: deploy.sh
# Description: This script deploys the Kubert AI Assistant Lite application in a kind Kubernetes cluster.
#
# Usage:       ./deploy.sh
#
# Copyright © 2024 Kubert
# -----------------------------------------------------------------------------

# Bash safeties: exit on error, no unset variables, pipelines can't hide errors
set -o errexit
set -o nounset
set -o pipefail

# Source the utils.sh and variables.sh scripts to use their functions and variables
BASE_DIR="$(dirname "$0")"

# shellcheck disable=SC1091
source "${BASE_DIR}/utils.sh"
# shellcheck disable=SC1091
source "${BASE_DIR}/variables.sh"

# Source and execute the hello.sh script for greetings and explanation
# shellcheck disable=SC1091
source "${BASE_DIR}/hello.sh"

# Validate that necessary tools are installed
./scripts/validate-tools.sh

# Main deployment script
log "INFO" "Starting deployment process..."

# Check if the kind cluster already exists
if kind get clusters | grep -q "${KIND_CLUSTER_NAME}"; then
    log "INFO" "kind cluster ${KIND_CLUSTER_NAME} already exists. Skipping creation."
else
    create_kind_cluster "${KIND_CLUSTER_NAME}" "${KIND_CONFIG}"
fi

# Deploy Calico for network policies
deploy_calico "${CALICO_YAML}"

# Wait for all nodes to be ready
wait_for_nodes

# Deploy NGINX Ingress Controller
deploy_nginx_ingress "${NGINX_INGRESS_CONTROLLER_YAML}"

# Wait for NGINX Ingress Controller pods to be ready
wait_for_nginx_ingress

# Update hosts file for local testing
update_hosts_file "${KIND_CLUSTER_NAME}" "${HOSTS_ENTRIES[@]}"

# Update CoreDNS ConfigMap with host IP and local domains
update_coredns_config "${HOSTS_ENTRIES[@]}"

# Deploy Kubert Assistant components using the new function
deploy_kubert_assistant "${CHART_PATH}" "${HELM_NAMESPACE}" "${KIND_CLUSTER_NAME}" "${KUBERT_COMPONENTS[@]}"

# Wait for the ingresses to have an address
wait_for_ingress_ready "${HELM_NAMESPACE}"

# Check if the application is accessible
wait_for_service "http://kubert-assistant.lan"

log "INFO" "Deployment process completed successfully."
log "INFO" "You can now access Kubert Assistant at http://kubert-assistant.lan"
log "INFO" "The access code to use is 'kubert'."