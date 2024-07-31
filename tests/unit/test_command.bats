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
}

teardown() {
    # Clean up the temporary log file
    rm -f "$TEMP_LOG_FILE"
}

TOOLS=("ls" "echo")
INSTRUCTIONS=("Command ls should be installed." "Command echo should be installed.")

@test "check_command should succeed for existing commands" {
    run check_command TOOLS INSTRUCTIONS
    assert_success
}

@test "check_command should fail for non-existing commands" {
    NON_EXISTING_TOOLS=("nonexistingcommand")
    NON_EXISTING_INSTRUCTIONS=("Non-existing command should be installed.")
  
    run check_command NON_EXISTING_TOOLS NON_EXISTING_INSTRUCTIONS
    assert_failure
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[ERROR]: nonexistingcommand is not installed."
}

@test "check_command should succeed for existing commands without instructions" {
    run check_command TOOLS
    assert_success
}

@test "check_command should fail for non-existing commands without instructions" {
    NON_EXISTING_TOOLS=("nonexistingcommand")
  
    run check_command NON_EXISTING_TOOLS
    assert_failure
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[ERROR]: nonexistingcommand is not installed."
}
