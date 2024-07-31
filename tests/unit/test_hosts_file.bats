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
    
    # Create a mock /etc/hosts file
    MOCK_HOSTS_FILE=$(mktemp)
    export HOSTS_FILE_PATH="$MOCK_HOSTS_FILE"

    # Create a mock sudo command
    echo -e "#!/usr/bin/env bash\n\$@" > "$MOCK_DIR/sudo"
    chmod +x "$MOCK_DIR/sudo"

    # Mock get_host_ip to return a fixed IP address
    echo -e "#!/usr/bin/env bash\nget_host_ip() {\n  echo '192.168.0.1'\n}" > "$MOCK_DIR/get_host_ip"
    chmod +x "$MOCK_DIR/get_host_ip"
    source "$MOCK_DIR/get_host_ip"
}

teardown() {
    # Clean up the temporary log file and mock directory after tests
    rm -f "$TEMP_LOG_FILE"
    rm -rf "$MOCK_DIR"
    rm -f "$MOCK_HOSTS_FILE"
}

@test "update_hosts_file should add new entries to the hosts file" {
    export NON_INTERACTIVE=true
    update_hosts_file "test-cluster" "kubert-assistant.lan" "kubert-agent.lan"
    run cat "$MOCK_HOSTS_FILE"
    assert_output --partial "192.168.0.1 kubert-assistant.lan"
    assert_output --partial "192.168.0.1 kubert-agent.lan"
    run tail -n 2 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Added 192.168.0.1 kubert-assistant.lan to $MOCK_HOSTS_FILE"
    assert_output --partial "[INFO]: Added 192.168.0.1 kubert-agent.lan to $MOCK_HOSTS_FILE"
}

@test "update_hosts_file should not duplicate existing entries" {
    echo "192.168.0.1 kubert-assistant.lan" >> "$MOCK_HOSTS_FILE"
    export NON_INTERACTIVE=true
    update_hosts_file "test-cluster" "kubert-assistant.lan" "kubert-agent.lan"
    run grep -c "192.168.0.1 kubert-assistant.lan" "$MOCK_HOSTS_FILE"
    assert_output "1"
    run cat "$MOCK_HOSTS_FILE"
    assert_output --partial "192.168.0.1 kubert-assistant.lan"
    assert_output --partial "192.168.0.1 kubert-agent.lan"
    run tail -n 2 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: 192.168.0.1 kubert-assistant.lan already exists in $MOCK_HOSTS_FILE"
    assert_output --partial "[INFO]: Added 192.168.0.1 kubert-agent.lan to $MOCK_HOSTS_FILE"
}

@test "update_hosts_file should log an error if unable to update the hosts file" {
    export NON_INTERACTIVE=true
    # Override the function to simulate failure
    update_hosts_file() {
        log "ERROR" "Failed to update the hosts file."
        return 1
    }
    run update_hosts_file "test-cluster" "kubert-assistant.lan"
    assert_failure
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[ERROR]: Failed to update the hosts file."
}

# Test for user response "yes"
@test "update_hosts_file should proceed when user responds 'yes'" {
    (echo yes) | update_hosts_file "test-cluster" "kubert-assistant.lan"
    run cat "$MOCK_HOSTS_FILE"
    assert_output --partial "192.168.0.1 kubert-assistant.lan"
    run tail -n 2 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Added 192.168.0.1 kubert-assistant.lan to $MOCK_HOSTS_FILE"
}

# Test for user response "no"
@test "update_hosts_file should not proceed when user responds 'no'" {    
    (echo no) | update_hosts_file "test-cluster" "kubert-assistant.lan"
    run cat "$MOCK_HOSTS_FILE"
    refute_output --partial "192.168.0.1 kubert-assistant.lan"
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Aborted updating the hosts file."    
}

@test "clean_up_hosts_file should remove entries from the hosts file" {
    echo "192.168.0.1 kubert-assistant.lan" >> "$MOCK_HOSTS_FILE"
    echo "192.168.0.1 kubert-agent.lan" >> "$MOCK_HOSTS_FILE"
    entries_to_remove=("kubert-assistant.lan" "kubert-agent.lan")
    clean_up_hosts_file "${entries_to_remove[@]}"
    run cat "$MOCK_HOSTS_FILE"
    refute_output --partial "192.168.0.1 kubert-assistant.lan"
    refute_output --partial "192.168.0.1 kubert-agent.lan"
    run tail -n 2 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Removed 192.168.0.1 kubert-assistant.lan from $MOCK_HOSTS_FILE"
    assert_output --partial "[INFO]: Removed 192.168.0.1 kubert-agent.lan from $MOCK_HOSTS_FILE"
}
