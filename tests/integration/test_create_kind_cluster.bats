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

    echo "# Setting up integration test for create_kind_cluster..." >&3
}

teardown() {
    # Clean up the temporary log file after tests
    rm -f "$TEMP_LOG_FILE"

    # Clean up the kind cluster
    echo "# Cleaning up by deleting the kind cluster..." >&3
    kind delete cluster --name "$KIND_CLUSTER_NAME" >&3 || true
    echo "# Cleanup step completed." >&3

    echo "# Integration test for create_kind_cluster completed." >&3
}

@test "create_kind_cluster should create a kind cluster" {
    # Step 1: Run the function to create a kind cluster
    echo "# Running create_kind_cluster function..." >&3
    run create_kind_cluster "$KIND_CLUSTER_NAME" "tests/integration/kind-config.yaml"
    assert_success "create_kind_cluster function should succeed"
    echo "# kind cluster creation step completed." >&3

    # Wait for the nodes to be ready
    wait_for_nodes

    # Step 2: Check that the kind cluster was created
    echo "# Checking if the kind cluster was created..." >&3
    run kind get clusters
    assert_output --partial "$KIND_CLUSTER_NAME" "kind cluster should be listed"
    echo "# kind cluster verification step completed." >&3

    # Check nodes
    echo "# Checking if nodes are present..." >&3
    run kubectl get nodes
    assert_success "Nodes should be present in the cluster"
    echo "# Nodes verification completed." >&3

    # Check namespaces
    run kubectl create namespace testing
    echo "# Checking if the namespace is created..." >&3
    run kubectl get namespace testing
    assert_success "Namespace should be present"
    echo "# Namespace verification completed." >&3
}
