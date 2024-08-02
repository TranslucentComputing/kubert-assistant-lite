#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Script Name: utils.sh
# Description: This file contains utility functions used in the deployment script.
#
# Copyright © 2024 Translucent Computing Inc.
# -----------------------------------------------------------------------------

# Bash safeties: exit on error, no unset variables, pipelines can't hide errors
set -o errexit
set -o nounset
set -o pipefail

# Default path for hosts file (can be overridden in tests)
HOSTS_FILE_PATH=${HOSTS_FILE_PATH:-/etc/hosts}

# Color codes
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

# -----------------------------------------------------------------------------
# Function: log
# Description: Logs messages with a timestamp and specified log level.
# Parameters:
#   $1 - Log level (INFO, ERROR, WARN, DEBUG)
#   $2 - Log message
# -----------------------------------------------------------------------------
log() {
    local known_levels=("INFO" "ERROR" "WARN" "DEBUG")
    local level="INFO"  # Default log level
    local timestamp=$(date +"%Y-%m-%d %T")
    local in_test_mode="${LOG_TEST_MODE:-false}"
    local log_file="${LOG_FILE:-output.log}"  # Default to output.log if LOG_FILE is not set
    local log_to_terminal="${LOG_TO_TERMINAL:-false}"
    local color="$RESET"

    # Ensure the log file exists
    if [[ ! -f "$log_file" ]]; then
        mkdir -p "$(dirname "$log_file")"
        touch "$log_file"
    fi

    # Check if the first argument is a known log level
    for lvl in "${known_levels[@]}"; do
        if [[ $1 == "$lvl" ]]; then
            level=$1
            case $level in
                "INFO")
                    color="$GREEN"
                    ;;
                "ERROR")
                    color="$RED"
                    ;;
                "WARN")
                    color="$YELLOW"
                    ;;
                "DEBUG")
                    color="$BLUE"
                    ;;
            esac
            shift # Remove the first argument, so $2 becomes $1, etc.
            break
        fi
    done

    local log_message="$timestamp [$level]: $*"

    # Modify behavior if in test mode
    if [[ "$in_test_mode" == "true" ]]; then
        # Omit the timestamp entirely and write directly to the log file
        echo "[$level]: $*" >> "$log_file"
        if [[ "$log_to_terminal" == "true" ]]; then
            echo -e "${color}[$level]: $*${RESET}"
        fi
        return
    fi

    # Write the log with timestamp to the log file and display it in the terminal if enabled
    echo "$log_message" >> "$log_file"
    if [[ "$log_to_terminal" == "true" ]]; then
       echo -e "${color}$log_message${RESET}"
    fi
}

# -----------------------------------------------------------------------------
# Function: check_command
# Description: Checks if the specified commands exist and provides installation
#              instructions if they do not.
# Parameters:
#   $1 - Variable name of the array containing the commands to check
#   $2 - (Optional) Variable name of the array containing installation instructions
# -----------------------------------------------------------------------------
check_command() {
    local tools_var=$1
    local instructions_var=${2:-}
    eval "local tools=(\"\${${tools_var}[@]}\")"
    if [[ -n "$instructions_var" ]]; then
        eval "local instructions=(\"\${${instructions_var}[@]}\")"
    fi
    
    for i in "${!tools[@]}"; do
        cmd="${tools[$i]}"
        if ! command -v "$cmd" &> /dev/null; then
            if [[ -n "$instructions_var" ]]; then
                log "ERROR" "$cmd is not installed. To install $cmd, follow these instructions: ${instructions[$i]}"
            else
                log "ERROR" "$cmd is not installed."
            fi
            exit 1
        else
            log "INFO" "$cmd is installed."
        fi
    done
}

# -----------------------------------------------------------------------------
# Function: error_exit
# Description: Logs an error message and exits the script with a specified or
#              default exit code.
# Parameters:
#   $1 - Error message
#   $2 - (Optional) Exit code (default is 1)
# -----------------------------------------------------------------------------
error_exit() {
    log "ERROR" "$1"
    exit ${2:-1}
}

# -----------------------------------------------------------------------------
# Function: create_kind_cluster
# Description: Creates a kind Kubernetes cluster with the specified name and
#              configuration file.
# Parameters:
#   $1 - Cluster name
#   $2 - (Optional) Configuration file (default is kind-config.yaml)
# -----------------------------------------------------------------------------
create_kind_cluster() {
    local cluster_name=$1
    local config_file=${2:-kind-config.yaml}
    
    log "INFO" "Creating kind cluster named $cluster_name..."
    kind create cluster --name "$cluster_name" --config "$config_file"
    log "INFO" "Kind cluster $cluster_name created successfully."
}

# -----------------------------------------------------------------------------
# Function: deploy_application
# Description: Deploys the Kubert Assistant Lite application using Helm.
# Parameters:
#   $1 - Helm repository name
#   $2 - Helm repository URL
#   $3 - Helm release name
#   $4 - Helm chart name
#   $5 - Kubernetes namespace
# -----------------------------------------------------------------------------
deploy_application() {
    local repo_name=$1
    local repo_url=$2
    local release_name=$3
    local chart_name=$4
    local namespace=$5

    log "INFO" "Deploying Kubert Assistant Lite application using Helm..."
    helm repo add "$repo_name" "$repo_url"
    helm repo update
    helm upgrade --install "$release_name" "$chart_name" --namespace "$namespace" --create-namespace
    log "INFO" "Kubert Assistant Lite application deployed successfully."
}

# -----------------------------------------------------------------------------
# Function: update_hosts_file
# Description: Updates the hosts file with the provided entries.
# Parameters:
#   $1 - Cluster name
#   $2 - Array of hosts entries
# -----------------------------------------------------------------------------
update_hosts_file() {
    local cluster_name=$1
    shift
    local hosts_entries=("$@")
    local host_ip=$(get_host_ip)

    if [[ -z "$host_ip" ]]; then
        log "ERROR" "Unable to retrieve host IP."
        exit 1
    fi

    log "INFO" "Host IP: $host_ip"
    log "INFO" "Updating $HOSTS_FILE_PATH file for cluster $cluster_name..."
    
    log "INFO" "The following entries will be added to your hosts file ($HOSTS_FILE_PATH):"
    for entry in "${hosts_entries[@]}"; do
        echo "$entry"
    done

    if [[ -z "${NON_INTERACTIVE:-}" ]]; then
        read -p $'\033[0;34mDo you want to proceed with adding these entries to your hosts file? (yes/no) \033[0m' -r
        if [[ $REPLY =~ ^yes$ ]]; then
            proceed=true
        else
            proceed=false
        fi
    else
        proceed=true
    fi

    if [[ "$proceed" == true ]]; then
        for domain in "${hosts_entries[@]}"; do
            entry="$host_ip $domain"
            if ! grep -q "$entry" "$HOSTS_FILE_PATH"; then
                echo "$entry" | sudo tee -a "$HOSTS_FILE_PATH"
                log "INFO" "Added $entry to $HOSTS_FILE_PATH"
            else
                log "INFO" "$entry already exists in $HOSTS_FILE_PATH"
            fi
        done

        # Detect if running on WSL or PowerShell and update the Windows hosts file
        if grep -qi microsoft /proc/version || command -v powershell.exe &> /dev/null; then
            local windows_hosts_file="/mnt/c/Windows/System32/drivers/etc/hosts"
            temp_file=$(mktemp)
            sudo cp "${windows_hosts_file}" "${temp_file}"
            
            for domain in "${hosts_entries[@]}"; do
                entry="${host_ip} ${domain}"
                hostname=$(echo "$entry" | awk '{print $2}')
                if ! grep -q "$entry" "${temp_file}"; then
                    sudo sed -i "\$a${entry}" "${temp_file}"
                    log "INFO" "Added $entry to $windows_hosts_file"
                else
                    log "INFO" "$entry already exists in $windows_hosts_file"
                fi
            done

            # Convert WSL path to Windows path
            temp_windows_path=$(wslpath -w "${temp_file}")

            # Use PowerShell to move the file with elevated permissions
            powershell.exe -Command "Start-Process powershell -ArgumentList 'Move-Item -Force -Path \"${temp_windows_path}\" -Destination \"C:\\Windows\\System32\\drivers\\etc\\hosts\"' -Verb RunAs; if (\$?) { exit 0 } else { exit 1 }"

            if [ $? -ne 0 ]; then
                echo "Failed to update hosts file. Please run the script as an administrator."
                exit 1
            fi

            # Flush DNS cache on Windows with elevated permissions
            powershell.exe -Command "Start-Process powershell -ArgumentList 'ipconfig /flushdns' -Verb RunAs; if (\$?) { exit 0 } else { exit 1 }"

            if [ $? -ne 0 ]; then
                echo "Failed to flush DNS cache. Please run the script as an administrator."
                exit 1
            fi
        fi
    else
        log "INFO" "Aborted updating the hosts file."
    fi
}


# -----------------------------------------------------------------------------
# Function: clean_up_hosts_file
# Description: Removes the provided entries from the hosts file.
# Parameters:
#   $1 - Array of hosts entries
# -----------------------------------------------------------------------------
clean_up_hosts_file() {
    local hosts_entries=("$@")
    local temp_file

    temp_file=$(mktemp)
    local host_ip=$(get_host_ip)

    if [[ -z "$host_ip" ]]; then
        log "ERROR" "Unable to retrieve host IP."
        exit 1
    fi

    log "INFO" "Cleaning up ${HOSTS_FILE_PATH} file..."

    # Copy the current hosts file to the temporary file using sudo
    sudo cp "${HOSTS_FILE_PATH}" "${temp_file}"

    # Iterate over the entries to remove and delete them from the temp file using sudo
    for domain in "${hosts_entries[@]}"; do
        entry="${host_ip} ${domain}"
        # Extract the hostname part of the entry
        hostname=$(echo "$entry" | awk '{print $2}')
        # Use sed to filter out the entry by hostname
        sudo sed -i.bak "/[[:space:]]${hostname}[[:space:]]*$/d" "${temp_file}"
        log "INFO" "Removed $entry from $HOSTS_FILE_PATH"
    done

    # Move the temp file back to the hosts file using sudo
    sudo mv "${temp_file}" "${HOSTS_FILE_PATH}"

    # Detect if running on WSL or PowerShell and update the Windows hosts file
    if grep -qi microsoft /proc/version || command -v powershell.exe &> /dev/null; then
        local windows_hosts_file="/mnt/c/Windows/System32/drivers/etc/hosts"
        temp_file=$(mktemp)
        sudo cp "${windows_hosts_file}" "${temp_file}"
        for domain in "${hosts_entries[@]}"; do
            entry="${host_ip} ${domain}"
            hostname=$(echo "$entry" | awk '{print $2}')
            sudo sed -i.bak "/[[:space:]]${hostname}[[:space:]]*$/d" "${temp_file}"
            log "INFO" "Removed $entry from $windows_hosts_file"
        done

        # Convert WSL path to Windows path
        temp_windows_path=$(wslpath -w "${temp_file}")

        # Use PowerShell to move the file with elevated permissions
        powershell.exe -Command "Start-Process powershell -ArgumentList 'Move-Item -Force -Path \"${temp_windows_path}\" -Destination \"C:\\Windows\\System32\\drivers\\etc\\hosts\"' -Verb RunAs; if (\$?) { exit 0 } else { exit 1 }"

        if [ $? -ne 0 ]; then
            echo "Failed to move hosts file. Please run the script as an administrator."
            exit 1
        fi

        # Flush DNS cache on Windows with elevated permissions
        powershell.exe -Command "Start-Process powershell -ArgumentList 'ipconfig /flushdns' -Verb RunAs; if (\$?) { exit 0 } else { exit 1 }"

        if [ $? -ne 0 ]; then
            echo "Failed to flush DNS cache. Please run the script as an administrator."
            exit 1
        fi
    fi
}


# -----------------------------------------------------------------------------
# Function: wait_for_nodes
# Description: Waits for all nodes in the kind Kubernetes cluster to be in the "Ready" state.
#              This function periodically checks the status of all nodes in the cluster.
#              If all nodes are not ready within a specified timeout period, the function
#              logs an error message and exits the script with a non-zero status code.
# Parameters:
#   $1 - (Optional) Timeout in seconds (default: 300)
#   $2 - (Optional) Interval in seconds between checks (default: 10)
# -----------------------------------------------------------------------------
wait_for_nodes() {
  local timeout=${1:-600}      # Maximum time to wait for nodes to be ready (in seconds)
  local interval=${2:-10}      # Interval between status checks (in seconds)

  local start_time       # Start time of the wait period

  start_time=$(date +%s) # Record the start time

  log "INFO" "Waiting for all kind nodes to be ready..."

  while true; do
    local ready_nodes=0  # Number of nodes that are in the "Ready" state
    local total_nodes=0  # Total number of nodes in the cluster
    local current_time   # Current time
    local elapsed_time   # Time elapsed since the start of the wait period

    # Get the number of nodes that are ready
    kubectl_output=$(kubectl get nodes --no-headers 2>&1)
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
      log "ERROR" "Failed to get nodes. Output: $kubectl_output"
      sleep "${interval}"
      continue
    fi

    # Count the number of "Ready" nodes
    ready_nodes=$(echo "$kubectl_output" | grep -c " Ready" || true)
    # Count the total number of nodes
    total_nodes=$(echo "$kubectl_output" | wc -l | xargs)

    log "INFO" "Ready Nodes: ${ready_nodes}/${total_nodes}"

    # Check if all nodes are ready
    if [ "${ready_nodes}" -eq "${total_nodes}" ] && [ "${total_nodes}" -ne 0 ]; then
      log "INFO" "All kind nodes are ready!"
      break
    fi

    # Calculate the elapsed time
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))

    # Check if the timeout has been reached
    if [ "${elapsed_time}" -ge "${timeout}" ]; then
      log "ERROR" "Timeout reached. Kind nodes are not ready after ${timeout} seconds."
      exit 1
    fi

    # Wait for the next interval
    sleep "${interval}"
  done
}

# -----------------------------------------------------------------------------
# Function: wait_for_nginx_ingress
# Description: Waits for all Nginx Ingress Controller pods to be in the "Ready" state.
#              This function periodically checks the status of the pods within the specified
#              namespace and with the specified label selector. If all pods are not ready
#              within a specified timeout period, the function logs an error message and
#              exits the script with a non-zero status code.
# Parameters:
#   $1 - (Optional) Timeout in seconds (default: 500)
#   $2 - (Optional) Interval in seconds between checks (default: 10)
# -----------------------------------------------------------------------------
wait_for_nginx_ingress() {
  local namespace="ingress-nginx"   # Namespace where the Nginx Ingress Controller is deployed
  local selector="app.kubernetes.io/component=controller"  # Label selector to identify the pods
  
  local timeout=${1:-600}      # Maximum time to wait for pods to be ready (in seconds)
  local interval=${2:-10}      # Interval between status checks (in seconds)

  local start_time       # Start time of the wait period
  
  start_time=$(date +%s) # Record the start time

  log "INFO" "Waiting for Nginx Ingress Controller pods to be ready..."

  while true; do
    local ready_pods=0   # Number of pods that are in the "Ready" state
    local total_pods=0   # Total number of pods matching the selector
    local current_time   # Current time
    local elapsed_time   # Time elapsed since the start of the wait period

    # Get the number of pods that are ready
    kubectl_output=$(kubectl get pods -n ${namespace} -l ${selector} -o jsonpath='{.items[*].status.containerStatuses[*].ready}' 2>&1)

    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
      log "ERROR" "Failed to get pods. Output: $kubectl_output"
      sleep "${interval}"
      continue
    fi
    ready_pods=$(echo "$kubectl_output" | grep -o "true" | wc -l | xargs || true)

    # Get the total number of pods
    kubectl_output=$(kubectl get pods -n ${namespace} -l ${selector} --no-headers 2>&1)

    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
      log "ERROR" "Failed to get total number of pods. Output: $kubectl_output"
      sleep "${interval}"
      continue
    fi
    total_pods=$(echo "$kubectl_output" | wc -l | xargs)

    log "INFO" "Ready Pods: ${ready_pods}/${total_pods}"

    # Check if all pods are ready
    if [ "${ready_pods}" -eq "${total_pods}" ] && [ "${total_pods}" -ne 0 ]; then
      log "INFO" "All Nginx Ingress Controller pods are ready!"
      break
    fi

    # Calculate the elapsed time
    current_time=$(date +%s) 
    elapsed_time=$((current_time - start_time))

    # Check if the timeout has been reached
    if [ "${elapsed_time}" -ge "${timeout}" ]; then
      log "ERROR" "Timeout reached. Nginx Ingress Controller pods are not ready after ${timeout} seconds."
      exit 1
    fi

    # Wait for the next interval
    sleep "${interval}"
  done
}

# -----------------------------------------------------------------------------
# Function: deploy_calico
# Description: Deploys Calico for network policies in the Kubernetes cluster.
# Parameters:
#   $1 - Path to the Calico deployment YAML file
# -----------------------------------------------------------------------------
deploy_calico() {
  local calico_yaml=$1
  log "INFO" "Deploying Calico..."
  kubectl apply -f "${calico_yaml}"
}

# -----------------------------------------------------------------------------
# Function: deploy_nginx_ingress
# Description: Deploys the NGINX Ingress Controller in the Kubernetes cluster.
# Parameters:
#   $1 - Path to the NGINX Ingress Controller deployment YAML file
# -----------------------------------------------------------------------------
deploy_nginx_ingress() {
  local nginx_ingress_yaml=$1
  log "INFO" "Deploying NGINX Ingress Controller..."
  kubectl apply -f "${nginx_ingress_yaml}"
}

# -----------------------------------------------------------------------------
# Function: deploy_local_chart
# Description: Deploys a Helm chart using specified values file.
# Parameters:
#   $1 - Path to the Helm chart directory
#   $2 - Path to the values YAML file
#   $3 - Helm release name
#   $4 - Kubernetes namespace
#   $5 - Additional Helm --set parameters (optional)
# -----------------------------------------------------------------------------
deploy_local_chart() {
    local chart_path="$1"
    local values_file="$2"
    local release_name="$3"
    local namespace="$4"
    local additional_sets="$5"

    # Construct the Helm upgrade/install command
    local helm_command="helm upgrade --install \"$release_name\" \"$chart_path\" --values \"$values_file\" --namespace \"$namespace\" --create-namespace"

    # Append additional --set parameters if provided
    if [ -n "$additional_sets" ]; then
        helm_command="$helm_command $additional_sets"
    fi


    log "INFO" "Deploying $release_name using Helm..."
    eval $helm_command
    log "INFO" "$release_name deployed successfully."
}

# -----------------------------------------------------------------------------
# Function: deploy_kubert_assistant
# Description: Deploys the Kubert Assistant components using Helm.
# Parameters:
#   $1 - Path to the Helm chart directory
#   $2 - Kubernetes namespace
#   $3 - Kind cluster name
#   $4 - Array of components with their release names and values files
# -----------------------------------------------------------------------------
deploy_kubert_assistant() {
    local chart_path="$1"
    local namespace="$2"
    local kind_cluster_name="$3"
    shift 3
    local components=("$@")
    
    log "INFO" "Deploying Kubert Assistant components into namespace: $namespace using Helm..."

    # Prompt user for API keys
    local openai_provided="false"
    local anthropic_provided="false"

    read -p "Would you like to provide an OpenAI API key now? (yes/no): " provide_openai_key
    if [[ "$provide_openai_key" == "yes" ]]; then
        read -p "Please enter your OpenAI API key: " OPENAI_API_KEY
        openai_provided="true"
    fi

    if [[ "$openai_provided" == "false" ]]; then
        read -p "Would you like to provide an Anthropic API key now? (yes/no): " provide_anthropic_key
        if [[ "$provide_anthropic_key" == "yes" ]]; then
            read -p "Please enter your Anthropic API key: " ANTHROPIC_API_KEY
            anthropic_provided="true"
        fi
    fi

    for component in "${components[@]}"; do
        IFS=":" read -r release_name values_file <<< "$component"

        # Determine additional sets for the current component
        local additional_sets=""
        case "$release_name" in
            "command-runner")
                local docker_ip=$(get_docker_ip "${kind_cluster_name}")
                additional_sets="--set networkPolicy.extraEgress[0].to[0].ipBlock.cidr=${docker_ip}/32 --set networkPolicy.extraEgress[0].ports[0].port=6443"
                ;;
            "lobechat")
                if [[ -n "${OPENAI_API_KEY:-}" ]]; then
                    additional_sets="--set extraEnvVars[0].value=${OPENAI_API_KEY}"
                fi
                if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
                    additional_sets="--set extraEnvVars[1].value=${ANTHROPIC_API_KEY}"
                fi
                ;;
            *)
                additional_sets=""
                ;;
        esac        

        deploy_local_chart "$chart_path" \
                        "$values_file" \
                        "$release_name" \
                        "$namespace" \
                        "$additional_sets"
    done
}

# -----------------------------------------------------------------------------
# Function: get_docker_ip
# Description: Retrieves the Docker IP of the kind control plane container.
# Parameters:
#   $1 - Kind cluster name
# -----------------------------------------------------------------------------
get_docker_ip() {
    local kind_cluster_name="$1"
    local kind_container_name
    local docker_ip

    kind_container_name=$(docker ps --filter "label=io.x-k8s.kind.cluster=${kind_cluster_name}" --filter "label=io.x-k8s.kind.role=control-plane" --format "{{.Names}}")
    docker_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$kind_container_name")

    echo "$docker_ip"
}

# -----------------------------------------------------------------------------
# Function: uninstall_kubert_assistant
# Description: Uninstalls the Kubert Assistant components using Helm.
# Parameters:
#   $1 - Kubernetes namespace
#   $2 - Array of components with their release names
# -----------------------------------------------------------------------------
uninstall_kubert_assistant() {
    local namespace="$1"
    shift
    local components=("$@")
    
    log "INFO" "Uninstalling Kubert Assistant components from namespace: $namespace using Helm..."

    for component in "${components[@]}"; do
        IFS=":" read -r release_name _ <<< "$component"
        log "INFO" "Uninstalling $release_name..."
        helm uninstall "$release_name" --namespace "$namespace"
        log "INFO" "$release_name uninstalled successfully."
    done
}

# -----------------------------------------------------------------------------
# Function: get_host_ip
# Description: Retrieves the host IP address.
# Returns:
#   Host IP address
# -----------------------------------------------------------------------------
get_host_ip() {
    local host_ip=""

    # Try to get the host IP using ip command
    if command -v ip &> /dev/null; then
        host_ip=$(ip route get 1 | awk '{print $7; exit}')
    fi

    # If ip command is not available or failed, use ifconfig
    if [[ -z "$host_ip" ]] && command -v ifconfig &> /dev/null; then
        host_ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*)' | grep -Eo '([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*)' | grep -v '127.0.0.1' | head -n 1)
    fi

    echo "$host_ip"
}

# -----------------------------------------------------------------------------
# Function: update_coredns_config
# Description: Updates the CoreDNS ConfigMap in the kind Kubernetes cluster
#              with the host IP and local domains.
# Parameters:
#   $1 - Array of local domains
# -----------------------------------------------------------------------------
update_coredns_config() {
    local local_domains=("$@")
    local namespace="kube-system"
    local configmap_name="coredns"

    log "INFO" "Retrieving host IP..."
    local host_ip=$(get_host_ip)

    if [[ -z "$host_ip" ]]; then
        log "ERROR" "Unable to retrieve host IP."
        exit 1
    fi

    log "INFO" "Host IP: $host_ip"

    log "INFO" "Updating CoreDNS ConfigMap with host IP and local domains..."

    # Fetch the existing Corefile
    corefile=$(kubectl get configmap "${configmap_name}" -n "${namespace}" -o jsonpath='{.data.Corefile}')

    # Check if the Corefile was fetched successfully
    if [[ -z "$corefile" ]]; then
        log "ERROR" "Unable to retrieve CoreDNS Corefile."
        exit 1
    fi

    # Generate the hosts entries
    local hosts_entries=""
    for domain in "${local_domains[@]}"; do
        hosts_entries+="         ${host_ip} ${domain}\n"
    done

    # Prepare the hosts block
    hosts_block="    hosts {\n${hosts_entries}         fallthrough\n    }"

    # Insert the hosts block inside the main braces of the CoreDNS configuration
    new_corefile=$(echo "${corefile}" | awk -v block="$hosts_block" '
        /^ *\.:53 *{ *$/ {
            print
            print block
            next
        }
        { print }
    ')

    # Apply the updated Corefile to the ConfigMap
    new_corefile_json=$(jq -Rs . <<< "${new_corefile}")
    kubectl patch configmap "${configmap_name}" -n "${namespace}" --type merge -p "{\"data\": {\"Corefile\": ${new_corefile_json}}}"
    if [[ $? -ne 0 ]]; then
        log "ERROR" "Failed to update CoreDNS ConfigMap."
        exit 1
    fi

    log "INFO" "CoreDNS ConfigMap updated successfully."

    # Restart the CoreDNS pods to apply changes
    log "INFO" "Restarting CoreDNS pods..."
    kubectl rollout restart deployment coredns -n "${namespace}"
    if [[ $? -ne 0 ]]; then
        log "ERROR" "Failed to restart CoreDNS pods."
        exit 1
    fi

    log "INFO" "CoreDNS pods restarted successfully."
}

# -----------------------------------------------------------------------------
# Function: wait_for_ingress_ready
# Description: Waits for all ingresses in the specified namespace to have an address.
#              This function periodically checks the status of all ingresses in the
#              provided namespace. If all ingresses do not have an address within a
#              specified timeout period, the function logs an error message and exits
#              the script with a non-zero status code.
# Parameters:
#   $1 - Namespace where the ingresses are deployed
#   $2 - (Optional) Timeout in seconds (default: 300)
#   $3 - (Optional) Interval in seconds between checks (default: 5)
# -----------------------------------------------------------------------------
wait_for_ingress_ready() {
    local namespace=$1
    local timeout=${2:-300}
    local interval=${3:-5}

    local start_time=$(date +%s)

    log "INFO" "Waiting for all ingresses in namespace: $namespace to have an address..."

    while true; do
        local all_ready=true
        local ingress_list=$(kubectl get ingress -n "$namespace" --no-headers -o custom-columns=":metadata.name")

        for ingress in $ingress_list; do
            local address=$(kubectl get ingress -n "$namespace" "$ingress" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
            if [[ -z "$address" ]]; then
                address=$(kubectl get ingress -n "$namespace" "$ingress" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
            fi            
            if [[ -z "$address" ]]; then
                all_ready=false                
                break
            fi
        done

        if [[ "$all_ready" == "true" ]]; then
            log "INFO" "All ingresses in namespace $namespace are ready with an address."
            break
        fi

        local current_time=$(date +%s)
        local elapsed_time=$((current_time - start_time))

        if [[ $elapsed_time -ge $timeout ]]; then
            log "ERROR" "Timeout reached. Not all ingresses in namespace $namespace have an address."
            exit 1
        fi

        log "INFO" "Waiting for ingresses in namespace $namespace to have an address..."
        sleep $interval
    done
}

# -----------------------------------------------------------------------------
# Function: wait_for_service
# Description: Waits for a service to become available by checking its HTTP status.
# Parameters:
#   $1 - URL to check
#   $2 - (Optional) Maximum number of attempts (default: 30)
#   $3 - (Optional) Sleep time between attempts in seconds (default: 10)
# -----------------------------------------------------------------------------
wait_for_service() {
    local url="$1"
    local max_attempts="${2:-30}"
    local attempt=1
    local sleep_time="${3:-10}"
    local start_time
    local elapsed_time

    log "INFO" "Waiting for the service to become available at $url..."

    start_time=$(date +%s)

    until curl --fail --silent --head "$url" > /dev/null; do
        if (( attempt == max_attempts )); then
            elapsed_time=$(( $(date +%s) - start_time ))
            log "ERROR" "Service at $url did not become available after $elapsed_time seconds."
            exit 1
        fi
        log "INFO" "Attempt $attempt/$max_attempts: Service not yet available, retrying in ${sleep_time}s..."
        sleep "$sleep_time"
        ((attempt++))
    done

    elapsed_time=$(( $(date +%s) - start_time ))
    log "INFO" "Service is available at $url after $elapsed_time seconds."
}