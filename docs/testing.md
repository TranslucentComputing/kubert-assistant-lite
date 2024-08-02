---
layout: default
title: Testing
nav_nabled: true
---

# Testing Guide

Testing is an essential part of ensuring the reliability and correctness of the Kubert Assistant Lite project. This section outlines the testing strategy, tools used, and how to run the tests for the project.

## Overview

The Kubert Assistant Lite project uses a combination of unit tests and integration tests to ensure all components function as expected. The tests verify that the shell scripts, mock interactions, and overall application behavior align with the expected outcomes.

## Testing Tools

The following tools are used for testing in the Kubert Assistant Lite project:

- **BATS (Bash Automated Testing System)**: A testing framework for Bash scripts that provides a simple way to verify the behavior of shell scripts.
- **bats-support**: A library of helper functions for writing BATS tests, making them easier to read and maintain.
- **bats-assert**: An assertion library for BATS, providing convenient functions for making assertions in tests.
- **kcov**: A code coverage tool for Bash scripts, providing insights into which parts of the scripts are executed during testing.
- **Helm Linter**: Checks if the the helm chart used for the Kubert Assistant Lite components has issues.
- **Helm Test**: After Helm chart deployment, Helm tests are executed to validate the deployment.

## Test Structure

The tests are organized into unit tests and integration tests:

- **Unit Tests**: These tests focus on individual functions and scripts, verifying their behavior in isolation. The unit tests are located in the tests/unit directory.
- **Integration Tests**: These tests focus on the interaction between components, ensuring they work together as expected. Integration tests are located in the tests/integration directory.

## Running Tests

To run the tests, ensure you have the necessary dependencies installed and the project environment set up correctly.

<script src="/kubert-assistant-lite/assets/js/asciinema-player.min.js"></script>

### Unit Tests

Unit tests verify individual components of the project:

```bash
make tests
```

This command runs all unit tests located in the tests/unit directory.

<div id="make-tests"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-tests.cast', document.getElementById('make-tests'));
</script>

To run a single unit test file:

```bash
make tests TEST_FILE=tests/unit/test_wait_functions.bats
```

<div id="make-tests-one-file"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-tests-one-file.cast', document.getElementById('make-tests-one-file'));
</script>

To run a single test in a unit test file:

```bash
make tests TEST_FILE=tests/unit/test_wait_functions.bats TEST_PATTERN="wait_for_nodes should succeed when all nodes are ready"
```

<div id="make-tests-one-file-one-test"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-tests-one-file-one-test.cast', document.getElementById('make-tests-one-file-one-test'));
</script>

### Integration Tests

Integration tests verify the interaction between components:

```bash
make integration-tests
```

<div id="make-tests-integration"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-tests-integration.cast', document.getElementById('make-tests-integration'));
</script>

This command runs all integration tests located in the tests/integration directory.

To run a specific integration test, use the following command:

```bash
make integration-tests INTEGRATION_TEST_FILE=tests/integration/test_deploy_application.bats
```

<div id="make-tests-integration-one-file"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-tests-integration-one-file.cast', document.getElementById('make-tests-integration-one-file'));
</script>

## Test Coverage

To run tests with coverage and generate coverage reports using kcov, follow these steps:

1. Build the kcov Docker image:

    ```bash
    make build-kcov-image
    ```

    <div id="build-kcov-image"></div>
    <script>
        AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/build-kcov-image.cast', document.getElementById('build-kcov-image'));
    </script>

2. Run the coverage target:

    ```bash
    make coverage
    ```

    <div id="make-coverage"></div>
    <script>
        AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-coverage.cast', document.getElementById('make-coverage'));
    </script>

This command will execute the tests and generate coverage reports in the coverage directory using kcov.
