#!/usr/bin/env bats

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
    
    # Create mock commands
    echo -e "#!/usr/bin/env bash\necho 'kind create cluster --name \$1 --config \$2'" > "$MOCK_DIR/kind"
    chmod +x "$MOCK_DIR/kind"
    echo -e "#!/usr/bin/env bash\nif [ \$1 = 'repo' ]; then echo 'helm repo \$2 \$3'; elif [ \$1 = 'install' ]; then echo 'helm install \$2 \$3'; fi" > "$MOCK_DIR/helm"
    chmod +x "$MOCK_DIR/helm"
}

teardown() {
    # Clean up the temporary log file and mock directory after tests
    rm -f "$TEMP_LOG_FILE"
    rm -rf "$MOCK_DIR"
}

# Mock kind and helm commands for create_kind_cluster and deploy_application tests
setup_mock_kind() {
    echo -e "#!/usr/bin/env bash\necho 'kind create cluster --name $1 --config $2'" > "$MOCK_DIR/kind"
    chmod +x "$MOCK_DIR/kind"
}

setup_mock_helm() {
    echo -e "#!/usr/bin/env bash\nif [ \$1 = 'repo' ]; then echo 'helm repo $2 $3'; elif [ \$1 = 'install' ]; then echo 'helm install $2 $3'; fi" > "$MOCK_DIR/helm"
    chmod +x "$MOCK_DIR/helm"
}

@test "create_kind_cluster should log and call kind command" {
    setup_mock_kind "test-cluster" "test-config.yaml"
    run create_kind_cluster "test-cluster" "test-config.yaml"
    assert_success
    run tail -n 2 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Creating kind cluster named test-cluster..."
    assert_output --partial "[INFO]: Kind cluster test-cluster created successfully."
}

@test "deploy_application should log and call helm commands" {
    setup_mock_helm "repo" "add" "https://example.com/helm-charts"
    run deploy_application "test-repo" "https://example.com/helm-charts" "test-release" "test-chart" "test-assistant"
    assert_success
    run tail -n 4 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Deploying Kubert AI Assistant Lite application using Helm..."
    assert_output --partial "[INFO]: Kubert AI Assistant Lite application deployed successfully."
}

# Mock for kubectl
setup_mock_kubectl() {
    # Mock kubectl get configmap command
    echo -e "#!/usr/bin/env bash\n\
if [[ \$* == *'get configmap coredns -n kube-system -o jsonpath={.data.Corefile}'* ]]; then\n\
    echo '.:53 {\nerrors\nhealth { lameduck 5s }\nready\nkubernetes cluster.local in-addr.arpa ip6.arpa {\npods insecure\nfallthrough in-addr.arpa ip6.arpa\nttl 30\n}\nprometheus :9153\nforward . /etc/resolv.conf { max_concurrent 1000 }\ncache 30\nloop\nreload\nloadbalance\n}'\n\
fi" > "$MOCK_DIR/kubectl_get"

    # Mock kubectl patch configmap command
    echo -e "#!/usr/bin/env bash\n\
if [[ \$* == *'patch configmap coredns -n kube-system --type merge -p'* ]]; then\n\
    echo 'configmap/coredns patched'\n\
fi" > "$MOCK_DIR/kubectl_patch"

    # Mock kubectl rollout restart deployment command
    echo -e "#!/usr/bin/env bash\n\
if [[ \$* == *'rollout restart deployment coredns -n kube-system'* ]]; then\n\
    echo 'deployment.apps/coredns restarted'\n\
fi" > "$MOCK_DIR/kubectl_restart"

    chmod +x "$MOCK_DIR/kubectl_get"
    chmod +x "$MOCK_DIR/kubectl_patch"
    chmod +x "$MOCK_DIR/kubectl_restart"

    # Create a wrapper script to call the appropriate mock based on arguments
    echo -e "#!/usr/bin/env bash\n\
if [[ \$* == *'get configmap coredns -n kube-system -o jsonpath={.data.Corefile}'* ]]; then\n\
    $MOCK_DIR/kubectl_get \"\$@\"\n\
elif [[ \$* == *'patch configmap coredns -n kube-system --type merge -p'* ]]; then\n\
    $MOCK_DIR/kubectl_patch \"\$@\"\n\
elif [[ \$* == *'rollout restart deployment coredns -n kube-system'* ]]; then\n\
    $MOCK_DIR/kubectl_restart \"\$@\"\n\
else\n\
    echo \"Unexpected kubectl command: \$*\" >&2\n\
    exit 1\n\
fi" > "$MOCK_DIR/kubectl"

    chmod +x "$MOCK_DIR/kubectl"
}

@test "update_coredns_config should update CoreDNS ConfigMap with host IP and local domains" {
    setup_mock_kubectl

    # Mock get_host_ip to return a fixed IP address
    echo -e "#!/usr/bin/env bash\nget_host_ip() {\n  echo '192.168.0.1'\n}" > "$MOCK_DIR/get_host_ip"
    chmod +x "$MOCK_DIR/get_host_ip"
    source "$MOCK_DIR/get_host_ip"

    local_domains=("kubert-assistant.lan" "kubert-agent.lan" "kubert-plugin.lan" "kubert-plugin-gateway.lan")
    run update_coredns_config "${local_domains[@]}"
    assert_success
    run tail -n 2 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Restarting CoreDNS pods..."
    assert_output --partial "[INFO]: CoreDNS pods restarted successfully."
}