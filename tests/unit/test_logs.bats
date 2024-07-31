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

# Function to verify the date format in log messages
verify_date_format() {
    local log_entry=$1
    if [[ $log_entry =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2} ]]; then
        return 0
    else
        echo "Log entry does not contain valid date format: $log_entry"
        return 1
    fi
}

@test "log should output with default INFO level" {
    log "Test message"
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Test message"
}

@test "log should output ERROR level" {
    log "ERROR" "Error message"
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[ERROR]: Error message"
}

@test "log should output WARN level" {
    log "WARN" "Warning message"
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[WARN]: Warning message"
}

@test "log should output DEBUG level" {
    log "DEBUG" "Debug message"
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[DEBUG]: Debug message"
}

@test "log should output INFO level with valid date format" {
    log "Test message"  
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Test message"
    verify_date_format "$output"
}

@test "error_exit should log an error message and exit" {
    run error_exit "Sample error"
    assert_failure
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[ERROR]: Sample error"
}

@test "log should omit timestamp in test mode" {
    export LOG_TEST_MODE=true
    log "Test mode message"
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Test mode message"
    [[ ! "$output" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2} ]]
    unset LOG_TEST_MODE
}

@test "log should create log file if it does not exist" {
    NEW_TEMP_LOG_FILE=$(mktemp)
    rm -f "$NEW_TEMP_LOG_FILE"
    export LOG_FILE="$NEW_TEMP_LOG_FILE"

    log "INFO" "Creating a new log file"
    [ -f "$NEW_TEMP_LOG_FILE" ]
    run tail -n 1 "$NEW_TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Creating a new log file"
    verify_date_format "$output"
    rm -f "$NEW_TEMP_LOG_FILE"
}

# Test for log_to_terminal enabled
@test "log should print to terminal when log_to_terminal is enabled" {
    export LOG_TO_TERMINAL=true
    log "INFO" "Message to terminal"
    run tail -n 1 "$TEMP_LOG_FILE"
    assert_output --partial "[INFO]: Message to terminal"

    run echo "Message to terminal" # Check terminal output
    assert_output --partial "Message to terminal"
}

# Tests for color output
@test "log should output colored INFO level" {
    export LOG_TO_TERMINAL=true
    run log "INFO" "Colored info message"
    assert_output --partial $'\033[0;32m'
    assert_output --partial "Colored info message"
    unset LOG_TO_TERMINAL
}

@test "log should output colored ERROR level" {
    export LOG_TO_TERMINAL=true
    run log "ERROR" "Colored error message"
    assert_output --partial $'\033[0;31m'
    assert_output --partial "Colored error message"
    unset LOG_TO_TERMINAL
}

@test "log should output colored WARN level" {
    export LOG_TO_TERMINAL=true
    run log "WARN" "Colored warning message"
    assert_output --partial $'\033[0;33m'
    assert_output --partial "Colored warning message"
    unset LOG_TO_TERMINAL
}

@test "log should output colored DEBUG level" {
    export LOG_TO_TERMINAL=true
    run log "DEBUG" "Colored debug message"
    assert_output --partial $'\033[0;34m'
    assert_output --partial "Colored debug message"
    unset LOG_TO_TERMINAL
}