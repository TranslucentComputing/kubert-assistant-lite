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

    # Determine the platform (macOS, Linux, WSL)
    PLATFORM=$(uname -s)
    if grep -qi microsoft /proc/version &> /dev/null; then
        PLATFORM="WSL"
    fi
}

teardown() {
    # Clean up the temporary log file and mock directory after tests
    rm -f "$TEMP_LOG_FILE"
    rm -rf "$MOCK_DIR"
}

# Mock kubectl to simulate deployment of Calico
@test "deploy_calico should apply the Calico YAML" {
    calico_yaml="calico.yaml"

    # Mock kubectl to log the command
    echo -e "#!/usr/bin/env bash\nif [ \$1 = 'apply' ] && [ \$2 = '-f' ]; then echo 'kubectl apply -f $calico_yaml' >> \"$TEMP_LOG_FILE\"; fi" > "$MOCK_DIR/kubectl"
    chmod +x "$MOCK_DIR/kubectl"

    run deploy_calico "$calico_yaml"
    assert_success
    run tail -n 2 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Deploying Calico..."

    run tac "$TEMP_LOG_FILE" | head -n 2
    assert_output --partial "kubectl apply -f $calico_yaml"
}

# Mock kubectl to simulate deployment of NGINX Ingress Controller
@test "deploy_nginx_ingress should apply the NGINX Ingress Controller YAML" {
    nginx_ingress_yaml="nginx-ingress.yaml"

    # Mock kubectl to log the command
    echo -e "#!/usr/bin/env bash\nif [ \$1 = 'apply' ] && [ \$2 = '-f' ]; then echo 'kubectl apply -f $nginx_ingress_yaml' >> \"$TEMP_LOG_FILE\"; fi" > "$MOCK_DIR/kubectl"
    chmod +x "$MOCK_DIR/kubectl"

    run deploy_nginx_ingress "$nginx_ingress_yaml"
    assert_success
    run tail -n 2 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Deploying NGINX Ingress Controller..."

    run tac "$TEMP_LOG_FILE" | head -n 2
    assert_output --partial "kubectl apply -f $nginx_ingress_yaml"
}

# Unit test for deploy_local_chart function
@test "deploy_local_chart should install/upgrade the Helm chart" {
    chart_path="manifests/chart"
    values_file="values.yaml"
    release_name="my-release"
    namespace="my-namespace"
    additional_sets="--set key=value"

    # Mock helm to log the command
    echo -e "#!/usr/bin/env bash\nif [[ \$1 = 'upgrade' && \$2 = '--install' ]]; then shift 2; echo \"helm upgrade --install \$@\" >> \"$TEMP_LOG_FILE\"; fi" > "$MOCK_DIR/helm"
    chmod +x "$MOCK_DIR/helm"

    run deploy_local_chart "$chart_path" "$values_file" "$release_name" "$namespace" "$additional_sets"
    assert_success
    run tail -n 10 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Deploying $release_name using Helm..."

    run tac "$TEMP_LOG_FILE" | head -n 1
    assert_output --partial "helm upgrade --install $release_name $chart_path --values $values_file --namespace $namespace --create-namespace --set key=value"
}

# Mock helm to simulate deployment of Kubert Assistant components
@test "deploy_kubert_assistant should install/upgrade the Helm charts for all components" {
    chart_path="manifests/chart"
    namespace="kubert-assistant"
    kind_cluster_name="kubert-cluster"
    components=("command-runner:values1.yaml" "lobechat:values2.yaml" "another-component:values3.yaml")

    # Mock the deploy_local_chart function to log the calls and source it
    echo -e "#!/usr/bin/env bash\ndeploy_local_chart() {\n  log \"INFO\" \"Deploying \${3} using Helm...\"\n  helm upgrade --install \${3} \${1} --values \${2} --namespace \${4} --create-namespace \${5:+\"\${5}\"}\n}" > "$MOCK_DIR/deploy_local_chart"
    chmod +x "$MOCK_DIR/deploy_local_chart"
    source "$MOCK_DIR/deploy_local_chart"

    # Mock helm to log the command
    echo -e "#!/usr/bin/env bash\nif [[ \$1 = 'upgrade' && \$2 = '--install' ]]; then shift 2; echo \"helm upgrade --install \$@\" >> \"$TEMP_LOG_FILE\"; fi" > "$MOCK_DIR/helm"
    chmod +x "$MOCK_DIR/helm"

    # Mock get_docker_ip to return a fake IP address
    echo -e "#!/usr/bin/env bash\nget_docker_ip() {\n  echo '172.18.0.2'\n}" > "$MOCK_DIR/get_docker_ip"
    chmod +x "$MOCK_DIR/get_docker_ip"
    source "$MOCK_DIR/get_docker_ip"

    # Run the function with simulated input for the API keys
    run deploy_kubert_assistant "$chart_path" "$namespace" "$kind_cluster_name" "${components[@]}" <<EOF
yes
fake-openai-api-key
no
no
no
no
EOF
    assert_success

    run tail -n 20 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Deploying Kubert Assistant components into namespace: $namespace using Helm..."

    run grep "helm upgrade --install another-component $chart_path --values values3.yaml --namespace $namespace --create-namespace" "$TEMP_LOG_FILE"
    assert_success
    
    run grep "helm upgrade --install command-runner $chart_path --values values1.yaml --namespace $namespace --create-namespace --set networkPolicy.extraEgress\[0\].to\[0\].ipBlock.cidr=172.18.0.2/32 --set networkPolicy.extraEgress\[0\].ports\[0\].port=6443" "$TEMP_LOG_FILE"
    assert_success

    run grep "helm upgrade --install lobechat $chart_path --values values2.yaml --namespace $namespace --create-namespace --set extraEnvVars\[0\].value=fake-openai-api-key" "$TEMP_LOG_FILE"
    assert_success    

    run deploy_kubert_assistant "$chart_path" "$namespace" "$kind_cluster_name" "${components[@]}" <<EOF
no
yes
fake-anthropic-api-key
no
no
no
EOF

    assert_success

    run grep "helm upgrade --install lobechat $chart_path --values values2.yaml --namespace $namespace --create-namespace  --set extraEnvVars\[1\].value=fake-anthropic-api-key" "$TEMP_LOG_FILE"
    assert_success

}

# Unit test for get_docker_ip function
@test "get_docker_ip should return the correct Docker IP for the kind control plane container" {
    kind_cluster_name="kubert-cluster"
    expected_ip="172.18.0.2"

    # Mock docker ps to return a specific container name
    echo -e "#!/usr/bin/env bash\nif [ \"\$1\" = 'ps' ]; then echo 'kubert-cluster-control-plane'; fi" > "$MOCK_DIR/docker"
    chmod +x "$MOCK_DIR/docker"

    # Mock docker inspect to return a specific IP address
    echo -e "#!/usr/bin/env bash\nif [ \"\$1\" = 'inspect' ]; then echo '${expected_ip}'; fi" >> "$MOCK_DIR/docker"
    chmod +x "$MOCK_DIR/docker"

    run get_docker_ip "$kind_cluster_name"
    assert_success
    assert_output "$expected_ip"
}

# Mock helm to simulate uninstallation of Kubert Assistant components
@test "uninstall_kubert_assistant should uninstall the Helm charts for all components" {
    namespace="kubert-assistant"
    components=("command-runner:values1.yaml" "another-component:values2.yaml")

    # Mock helm to log the uninstall command
    echo -e "#!/usr/bin/env bash\nif [[ \$1 = 'uninstall' ]]; then echo \"helm uninstall \$2 --namespace \$4\" >> \"$TEMP_LOG_FILE\"; fi" > "$MOCK_DIR/helm"
    chmod +x "$MOCK_DIR/helm"

    run uninstall_kubert_assistant "$namespace" "${components[@]}"
    assert_success

    run tail -n 20 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Uninstalling Kubert Assistant components from namespace: $namespace using Helm..."

    run grep "helm uninstall command-runner --namespace $namespace" "$TEMP_LOG_FILE"
    assert_success

    run grep "helm uninstall another-component --namespace $namespace" "$TEMP_LOG_FILE"
    assert_success
}

@test "get_host_ip should return the correct host IP address using ip" {
    if [[ "$PLATFORM" == "Darwin" || "$PLATFORM" == "Linux" ]]; then
        # Mock the ip command to return a specific IP address
        echo -e "#!/usr/bin/env bash\nif [[ \$1 = 'route' && \$2 = 'get' && \$3 = '1' ]]; then echo '1.1.1.1 via 192.168.0.1 dev eth0 src 192.168.0.10 \n    cache \n'; fi" > "$MOCK_DIR/ip"
        chmod +x "$MOCK_DIR/ip"
        
        run get_host_ip
        assert_success
        assert_output "192.168.0.10"
    else
        skip "Test skipped on non-Linux/macOS platforms"
    fi
}

@test "get_host_ip should return the correct host IP address using ifconfig" {
    if [[ "$PLATFORM" == "Darwin" || "$PLATFORM" == "Linux" ]]; then
        # Save the original PATH
        ORIGINAL_PATH=$PATH
        
        # Remove any directories that contain the ip command from the PATH
        PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "$(dirname $(which ip))" | tr '\n' ':')

        # Prepend MOCK_DIR to PATH to ensure the mock commands are used
        export PATH="$MOCK_DIR:$PATH"

        # Mock the ifconfig command to return a specific IP address
        echo -e "#!/usr/bin/env bash\necho 'inet 192.168.0.10 netmask 255.255.255.0 broadcast 192.168.0.255'" > "$MOCK_DIR/ifconfig"
        chmod +x "$MOCK_DIR/ifconfig"

        run get_host_ip        
        assert_success
        assert_output "192.168.0.10"
        # Restore the original PATH
        export PATH=$ORIGINAL_PATH
    else
        skip "Test skipped on non-Linux/macOS platforms"
    fi
}

@test "get_host_ip should return the correct host IP address using route.exe in WSL" {
    if [[ "$PLATFORM" == "WSL" ]]; then
        # Mock the route.exe command to return a specific IP address
        echo -e "#!/usr/bin/env bash\nif [[ \$1 = 'PRINT' ]]; then echo '0.0.0.0          0.0.0.0         10.0.0.1         10.0.0.4'; fi" > "$MOCK_DIR/route.exe"
        chmod +x "$MOCK_DIR/route.exe"
        
        run get_host_ip
        assert_success
        assert_output "10.0.0.4"
    else
        skip "Test skipped on non-WSL platforms"
    fi
}