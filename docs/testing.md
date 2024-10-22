---
layout: default
title: Testing
nav_nabled: true
k_seo:
  title: "Kubert Lite Testing Guide: Unit and Integration Testing with BATS, kcov, and Helm Linter"
---

# **Kubert Lite Testing Guide:** Unit and Integration Testing with BATS, kcov, and Helm Linter

Testing is an essential part of ensuring the reliability and correctness of the Kubert AI Assistant Lite project. This section outlines the testing strategy, tools used, and how to run the tests for the project.

## Testing Philosophy

At Kubert AI Assistant Lite, we believe in the importance of thorough testing to maintain code quality, prevent regressions, and ensure a smooth user experience. We follow a comprehensive testing approach that includes:

- **Unit Testing**: We write unit tests to verify the behavior of individual components and functions in isolation. Unit tests help catch bugs early and provide a safety net for refactoring and making changes to the codebase.

- **Integration Testing**: Integration tests focus on the interaction between different components of the system. These tests ensure that the components work together seamlessly and produce the expected results when combined.

- **Continuous Integration**: We have set up continuous integration (CI) pipelines that automatically run the test suite on each commit or pull request. This helps catch any issues early in the development process and maintains the stability of the main branch. - #TODO

By following this testing philosophy, we aim to deliver a robust and reliable product to our users.

## Testing Tools

The following tools are used for testing in the Kubert AI Assistant Lite project:

- **BATS (Bash Automated Testing System)**: A testing framework for Bash scripts that provides a simple way to verify the behavior of shell scripts.
- **bats-support**: A library of helper functions for writing BATS tests, making them easier to read and maintain.
- **bats-assert**: An assertion library for BATS, providing convenient functions for making assertions in tests.
- **kcov**: A code coverage tool for Bash scripts, providing insights into which parts of the scripts are executed during testing.
- **Helm Linter**: Checks if the the helm chart used for the Kubert AI Assistant Lite components has issues.
- **Helm Test**: After Helm chart deployment, Helm tests are executed to validate the deployment.

## Test Structure

The tests are organized into unit tests and integration tests:

- **Unit Tests**: These tests focus on individual functions and scripts, verifying their behavior in isolation. The unit tests are located in the tests/unit directory.
- **Integration Tests**: These tests focus on the interaction between components, ensuring they work together as expected. Integration tests are located in the tests/integration directory.

## Running Tests

To run the tests, ensure you have the necessary dependencies installed and the project environment set up correctly.

### Unit Tests

Unit tests verify individual components of the project:

```bash
make tests
```

This command runs all unit tests located in the tests/unit directory.

<div id="make-tests"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-tests.cast', document.getElementById('make-tests'),{
           poster: 'npt:1'
        });
</script>

To run a single unit test file:

```bash
make tests TEST_FILE=tests/unit/test_wait_functions.bats
```

<div id="make-tests-one-file"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-tests-one-file.cast', document.getElementById('make-tests-one-file'),{
           poster: 'npt:1'
        });
</script>

To run a single test in a unit test file:

```bash
make tests TEST_FILE=tests/unit/test_wait_functions.bats TEST_PATTERN="wait_for_nodes should succeed when all nodes are ready"
```

<div id="make-tests-one-file-one-test"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-tests-one-file-one-test.cast', document.getElementById('make-tests-one-file-one-test'),{
           poster: 'npt:1'
        });
</script>

### Integration Tests

Integration tests verify the interaction between components:

```bash
make integration-tests
```

<div id="make-tests-integration"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-tests-integration.cast', document.getElementById('make-tests-integration'),{
           poster: 'npt:1'
        });
</script>

This command runs all integration tests located in the tests/integration directory.

To run a specific integration test, use the following command:

```bash
make integration-tests INTEGRATION_TEST_FILE=tests/integration/test_deploy_application.bats
```

<div id="make-tests-integration-one-file"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-tests-integration-one-file.cast', document.getElementById('make-tests-integration-one-file'), {
           poster: 'npt:1'
        });
</script>

## Test Coverage

To run tests with coverage and generate coverage reports using kcov, follow these steps:

1. Build the kcov Docker image:

    ```bash
    make build-kcov-image
    ```

    <div id="build-kcov-image"></div>
    <script>
        AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/build-kcov-image.cast', document.getElementById('build-kcov-image'),{
           poster: 'npt:1'
        });
    </script>

2. Run the coverage target:

    ```bash
    make coverage
    ```

    <div id="make-coverage"></div>
    <script>
        AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-coverage.cast', document.getElementById('make-coverage'),{
           poster: 'npt:1'
        });
    </script>

This command will execute the tests and generate coverage reports in the coverage directory using kcov. To view the coverage open the index.html file in the coverage directory in a browser.

```bash
open coverage/index.html
```

!["Coverage Report"](/kubert-assistant-lite/assets/images/coverage-report.png "Coverage Report")

## Helm Testing

Local Helm chart, `manifests/chart`, is used to deploy the different Kubert AI Assistant Lite component. Use a linter for a quick check:

```bash
make lint-chart
```
<div id="lint-chart"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/lint-chart.cast', document.getElementById('lint-chart'),{
        poster: 'npt:1'
    });
</script>

Using Helm template, we can have a quick view at the Helm templates in the chart:

```bash
make template-chart
```

<div id="template-chart"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/template-chart.cast', document.getElementById('template-chart'),{
        poster: 'npt:1'
    });
</script>

Once the system has been deployed, we can execute Helm tests with:

```bash
make helm-test
```

<div id="helm-tests"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/helm-tests.cast', document.getElementById('helm-tests'),{
        poster: 'npt:1'
    });
</script>

## Conclusion

Testing is a crucial aspect of the Kubert AI Assistant Lite project, ensuring its reliability, stability, and correctness. By following the testing guidelines, writing comprehensive unit tests, running integration tests, and utilizing continuous integration, we aim to deliver a robust and well-tested product to our users.

We encourage all contributors to prioritize testing and to follow the best practices outlined in this guide when working on the project. Together, we can maintain the quality and integrity of Kubert AI Assistant Lite.
