#!/usr/bin/env bats

# Load test helpers
load '../test_helper/bats-support/load'
load '../test_helper/bats-assert/load'

setup() {
    # Ensure relative paths are resolved correctly.
    BASE_DIR="$(dirname "$BATS_TEST_FILENAME")"
    source "$BASE_DIR/../../scripts/utils.sh"
    
    # Define a temporary log file for testing
    TEMP_LOG_FILE=$(mktemp)
    export LOG_FILE="$TEMP_LOG_FILE"
    
    # Create a temporary directory for mocks
    MOCK_DIR=$(mktemp -d)
    export PATH="$MOCK_DIR:$PATH"

    # Create a temporary file for CURL_OUTPUT
    CURL_OUTPUT_FILE=$(mktemp)
    export CURL_OUTPUT_FILE
    
    # Initial mock kubectl to handle different cases
    cat << 'EOF' > "$MOCK_DIR/kubectl"
#!/usr/bin/env bash
case "$1 $2" in
  "get nodes")
    if [ -n "$KUBECTL_OUTPUT" ]; then
      echo "$KUBECTL_OUTPUT"
    else
      echo "Error: KUBECTL_OUTPUT not set" >&3
      exit 1
    fi
    ;;
  "get pods")
    if [ "$7" = "-o" ] && [ "$8" = "jsonpath={.items[*].status.containerStatuses[*].ready}" ]; then
      if [ -n "$KUBECTL_PODS_READY_OUTPUT" ]; then
        echo -e "$KUBECTL_PODS_READY_OUTPUT"
      else
        echo "Error: KUBECTL_PODS_READY_OUTPUT not set" >&3
        exit 1
      fi
    else
      if [ -n "$KUBECTL_PODS_OUTPUT" ]; then
        echo -e "$KUBECTL_PODS_OUTPUT"
      else
        echo "Error: KUBECTL_PODS_OUTPUT not set" >&3
        exit 1
      fi
    fi
    ;;
  "get ingress")
    if [ "$5" = "--no-headers" ] && [ "$7" = "custom-columns=:metadata.name" ]; then
      if [ -n "$KUBECTL_INGRESS_LIST" ]; then
        echo -e "$KUBECTL_INGRESS_LIST"
      else
        echo "Error: KUBECTL_INGRESS_LIST not set" >&3
        exit 1
      fi
    elif [ "$6" = "-o" ] && [ "$7" = "jsonpath={.status.loadBalancer.ingress[0].hostname}" ]; then
      if [ "$5" = "ingress1" ] && [ -n "$KUBECTL_INGRESS1_HOSTNAME" ]; then
        echo -e "$KUBECTL_INGRESS1_HOSTNAME"
      elif [ "$5" = "ingress2" ] && [ -n "$KUBECTL_INGRESS2_HOSTNAME" ]; then
        echo -e "$KUBECTL_INGRESS2_HOSTNAME"
      else
        echo ""
      fi
    elif [ "$6" = "-o" ] && [ "$7" = "jsonpath={.status.loadBalancer.ingress[0].ip}" ]; then
      if [ "$5" = "ingress1" ] && [ -n "$KUBECTL_INGRESS1_IP" ]; then
        echo -e "$KUBECTL_INGRESS1_IP"
      elif [ "$5" = "ingress2" ] && [ -n "$KUBECTL_INGRESS2_IP" ]; then
        echo -e "$KUBECTL_INGRESS2_IP"
      else
        echo ""
      fi
    else
      echo "Error: Unsupported kubectl command" >&3
      exit 1
    fi
    ;;
  *)
    echo "kubectl $@"
    ;;
esac
EOF
    chmod +x "$MOCK_DIR/kubectl"

    # Mock curl command for testing wait_for_service
    cat << 'EOF' > "$MOCK_DIR/curl"
#!/usr/bin/env bash
if [[ "$1" == "--fail" && "$2" == "--silent" && "$3" == "--head" ]]; then
    if [[ -s "$CURL_OUTPUT_FILE" ]]; then        
        cat "$CURL_OUTPUT_FILE"
        exit 0
    else
        exit 1
    fi
else
    echo "curl $@"
    exit 0
fi
EOF
    chmod +x "$MOCK_DIR/curl"
}

teardown() {
    # Clean up the temporary log file and mock directory after tests
    rm -f "$TEMP_LOG_FILE"
    rm -rf "$MOCK_DIR"
    rm -f "$CURL_OUTPUT_FILE"
}

@test "wait_for_nodes should succeed when all nodes are ready" {
    export KUBECTL_OUTPUT="node1 Ready\nnode2 Ready"
    run wait_for_nodes 1 0.5
    assert_success
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: All kind nodes are ready!"
}

@test "wait_for_nodes should fail when not all nodes are ready within timeout" {
    export KUBECTL_OUTPUT="node1 NotReady\nnode2 NotReady"
    run wait_for_nodes 1 0.5
    assert_failure
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[ERROR]: Timeout reached. kind nodes are not ready after 1 seconds."
}

@test "wait_for_nginx_ingress should succeed when all pods are ready" {
    export KUBECTL_PODS_READY_OUTPUT="true true"
    export KUBECTL_PODS_OUTPUT="pod1 Ready\npod2 Ready"
    run wait_for_nginx_ingress 1 0.5
    assert_success
    
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: All Nginx Ingress Controller pods are ready!"
}

@test "wait_for_nginx_ingress should fail when not all pods are ready within timeout" {
    export KUBECTL_PODS_READY_OUTPUT="false false"
    export KUBECTL_PODS_OUTPUT="pod1 NotReady\npod2 NotReady"
    run wait_for_nginx_ingress 1 0.5
    assert_failure
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[ERROR]: Timeout reached. Nginx Ingress Controller pods are not ready after 1 seconds."
}

@test "wait_for_ingress_ready should succeed when all ingresses have an address" {
    export KUBECTL_INGRESS_LIST="ingress1\ningress2"
    export KUBECTL_INGRESS1_HOSTNAME="localhost"
    export KUBECTL_INGRESS2_HOSTNAME="localhost"
    run wait_for_ingress_ready "default" 1 0.5   
    assert_success    
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: All ingresses in namespace default are ready with an address."
}

@test "wait_for_ingress_ready should fail when not all ingresses have an address within timeout" {
    export KUBECTL_INGRESS_LIST="ingress1\ningress2"
    export KUBECTL_INGRESS1_HOSTNAME=""
    export KUBECTL_INGRESS1_IP=""
    export KUBECTL_INGRESS2_HOSTNAME="localhost"
    run wait_for_ingress_ready "default" 1 0.5
    tail -n 50 "$TEMP_LOG_FILE"
    assert_failure
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[ERROR]: Timeout reached. Not all ingresses in namespace default have an address."
}

@test "wait_for_service should succeed when the service is available immediately" {
    echo "HTTP/1.1 200 OK" > "$CURL_OUTPUT_FILE"  # Simulate immediate availability

    run wait_for_service "http://example.com" 1 0.5
    assert_success

    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Service is available at http://example.com"
}

@test "wait_for_service should fail when the service is not available within timeout" {
    echo -n "" > "$CURL_OUTPUT_FILE"  # Simulate unavailability

    run wait_for_service "http://example.com" 3 1
    assert_failure

    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[ERROR]: Service at http://example.com did not become available after"
}

@test "wait_for_service should succeed when the service becomes available after a delay" {
    echo -n "" > "$CURL_OUTPUT_FILE"  # Start with no response

    # Set a delay for when the CURL_OUTPUT should be available
    (
        sleep 1  # Simulates the service becoming available after 1 second
        echo "HTTP/1.1 200 OK" > "$CURL_OUTPUT_FILE"
    ) &

    # Ensure we wait for the background process
    run wait_for_service "http://example.com" 5 0.5
    wait  # Wait for all background processes to finish

    assert_success

    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Service is available at http://example.com"
}