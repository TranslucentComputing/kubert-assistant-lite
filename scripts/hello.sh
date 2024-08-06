#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Script Name: hello.sh
# Description: This script prints a welcome message and displays the product name in ASCII art.
#
# Usage:       ./hello.sh
#
# Copyright © 2024 Kubert
# -----------------------------------------------------------------------------

# Source the utils.sh script to use the log function
BASE_DIR="$(dirname "$0")"
# shellcheck disable=SC1091
source "$BASE_DIR/utils.sh"

# Print welcome message
log "INFO" "Hello! Welcome to the deployment of the Kubert AI Assistant Lite application."

# Display the product name in ASCII art with spaces before and after
log "INFO" ""
log "INFO" ""
ascii_art=$(cat << "EOF"
 ██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗ ████████╗     █████╗ ███████╗███████╗██╗███████╗████████╗ █████╗ ███╗   ██╗████████╗
 ██║ ██╔╝██║   ██║██╔══██╗██╔════╝██╔══██╗╚══██╔══╝    ██╔══██╗██╔════╝██╔════╝██║██╔════╝╚══██╔══╝██╔══██╗████╗  ██║╚══██╔══╝
 █████╔╝ ██║   ██║██████╔╝█████╗  ██████╔╝   ██║       ███████║███████╗███████╗██║███████╗   ██║   ███████║██╔██╗ ██║   ██║   
 ██╔═██╗ ██║   ██║██╔══██╗██╔══╝  ██╔══██╗   ██║       ██╔══██║╚════██║╚════██║██║╚════██║   ██║   ██╔══██║██║╚██╗██║   ██║   
 ██║  ██╗╚██████╔╝██████╔╝███████╗██║  ██║   ██║       ██║  ██║███████║███████║██║███████║   ██║   ██║  ██║██║ ╚████║   ██║   
 ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝       ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   
EOF
)
while IFS= read -r line; do
    log "INFO" "$line"
done <<< "$ascii_art"
log "INFO" ""
log "INFO" ""

# Print deployment process explanation
log "INFO" "We are about to start the deployment process which includes the following steps:"
log "INFO" "1. Check if the kind Kubernetes cluster exists or create a new one."
log "INFO" "2. Deploy Calico for network policies."
log "INFO" "3. Wait for all Kubernetes nodes to be ready."
log "INFO" "4. Deploy the NGINX Ingress Controller."
log "INFO" "5. Wait for the NGINX Ingress Controller pods to be ready."
log "INFO" "6. Update the hosts file for local deployment."
log "INFO" "7. Update the CoreDNS hosts."
log "INFO" "8. Deploy the Kubert AI Assistant Lite application."

# Prompt user to press any button to continue
read -n 1 -s -r -p $'\nPress any key to continue...\n'
