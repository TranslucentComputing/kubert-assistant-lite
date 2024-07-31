#!/usr/bin/env bats

load '../test_helper/bats-support/load'
load '../test_helper/bats-assert/load'

setup() {
    # Ensure relative paths are resolved correctly.
    BASE_DIR="$(dirname "$BATS_TEST_FILENAME")"
    source "$BASE_DIR/../../scripts/utils.sh"
    source "$BASE_DIR/../../scripts/variables.sh"

    # Define a temporary log file for testing
    TEMP_LOG_FILE=$(mktemp)
    export LOG_FILE="$TEMP_LOG_FILE"

    echo "# Setting up integration test for deploy_application..." >&3

    # Create a kind cluster for the test
    create_kind_cluster "$KIND_CLUSTER_NAME" "tests/integration/kind-config.yaml"

    # Wait for the nodes to be ready
    wait_for_nodes
}

teardown() {
    # Clean up the temporary log file after tests
    rm -f "$TEMP_LOG_FILE"

    # Clean up the kind cluster
    echo "# Cleaning up by deleting the kind cluster..." >&3
    kind delete cluster --name "$KIND_CLUSTER_NAME" >&3 || true
    echo "# Cleanup step completed." >&3

    echo "# Integration test for deploy_application completed." >&3
}

@test "update_coredns_config should update CoreDNS ConfigMap with host IP and local domains" {
    # Ensure get_host_ip returns a valid IP address
    host_ip=$(get_host_ip)
    [ -n "$host_ip" ]

    kubectl_output=$(kubectl get configmap coredns -n kube-system -o jsonpath='{.data.Corefile}')
    echo "kubectl coredns configmap output (before update): $kubectl_output" >&3

    # Run the update_coredns_config function
    run update_coredns_config "${HOSTS_ENTRIES[@]}"
    assert_success
    run tail -n 3 "$LOG_FILE"
    assert_output --partial "[INFO]: CoreDNS ConfigMap updated successfully."
    assert_output --partial "[INFO]: Restarting CoreDNS pods..."
    assert_output --partial "[INFO]: CoreDNS pods restarted successfully."
    
    kubectl_output=$(kubectl get configmap coredns -n kube-system -o jsonpath='{.data.Corefile}')
    echo "kubectl coredns configmap output (after update): $kubectl_output" >&3

    for domain in "${HOSTS_ENTRIES[@]}"; do
        echo "$output" >&3
        run grep -q "$host_ip $domain" <<< "$kubectl_output"
        assert_success "CoreDNS ConfigMap should contain the entry for $domain"
    done
}

@test "deploy_application should deploy the echo server" {
    local repo_name="ealenn"
    local repo_url="https://ealenn.github.io/charts"
    local release_name="echo-server"
    local chart_name="ealenn/echo-server"
    local namespace="echo-server-ns"

    # Deploy the echo server using Helm
    echo "# Deploying the echo server application..." >&3
    run deploy_application "$repo_name" "$repo_url" "$release_name" "$chart_name" "$namespace"
    assert_success "deploy_application function should succeed"
    echo "# Echo server application deployment step completed." >&3

    # Verify that the namespace is created
    echo "# Checking if the namespace is created..." >&3
    run kubectl get namespace "$namespace"
    assert_success "Namespace should be present"
    echo "# Namespace verification completed." >&3

    # Verify that the echo server pod is running
    echo "# Checking if echo server pod is running in the namespace..." >&3
    run kubectl get pods --namespace "$namespace"
    assert_success "Echo server pod should be running in the namespace"
    echo "# Echo server pod verification completed." >&3

    # Verify the echo server service
    echo "# Checking if echo server service is running in the namespace..." >&3
    run kubectl get svc --namespace "$namespace"
    assert_success "Echo server service should be running in the namespace"
    echo "# Echo server service verification completed." >&3

    # Clean up the echo server deployment
    echo "# Cleaning up the echo server deployment..." >&3
    run helm uninstall "$release_name" --namespace "$namespace"
    assert_success "Echo server uninstallation should succeed"
    echo "# Echo server deployment cleanup step completed." >&3
}