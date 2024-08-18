# Kubert AI Assistant Lite Project

Kubert AI Assistant Lite is an open-source project designed to deploy a lightweight version of Kubert Assistant in a local kind (Kubernetes in Docker) cluster. This version includes a single AI agent, the Kubectl Agent, which can execute `kubectl` commands within the cluster.

Additional documentations can be found here -> [Documentations](https://translucentcomputing.github.io/kubert-assistant-lite/)

Setup video -> [Video](https://translucentcomputing.github.io/kubert-assistant-lite/usage.html#kubert-ai-assistant-setup)

## Table of Contents

- [Kubert AI Assistant Lite Project](#kubert-ai-assistant-lite-project)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Features](#features)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Deploy the Kubernetes Cluster and Application](#deploy-the-kubernetes-cluster-and-application)
  - [Scripts](#scripts)
  - [Helm Configuration](#helm-configuration)
  - [Makefile Targets](#makefile-targets)
  - [Testing](#testing)
    - [Running Tests](#running-tests)
      - [Unit Tests](#unit-tests)
      - [Integration Tests](#integration-tests)
    - [Test Coverage with kcov](#test-coverage-with-kcov)
  - [Contributing](#contributing)
  - [License](#license)
  - [Acknowledgments](#acknowledgments)

## Introduction

Kubert Assistant is a DevOps productivity tool designed to simplify the management of workloads within a Kubernetes cluster. It provides a suite of capabilities that allow DevOps teams to automate, monitor, and manage their Kubernetes environments more efficiently.

Kubert AI Assistant Lite provides an easy way to set up a local Kubernetes environment using kind and deploys a minimal version of the Kubert Assistant platform. This project is ideal for testing and development purposes, offering the core functionalities of Kubert Assistant with a focus on the Kubectl Agent.

## Features

- Deploys a local kind cluster.
- Includes a Kubectl Agent for executing `kubectl` commands.
- Utilizes Helm charts for easy deployment and management.
- Lightweight and easy to set up for local testing and development.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- [Docker](https://docs.docker.com/get-docker/)
- [kind](https://kind.sigs.k8s.io/)
- [Helm](https://helm.sh/docs/intro/install/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)
- [jq](https://stedolan.github.io/jq/)
- [Make](https://www.gnu.org/software/make/)
- [OpenAI API Key](https://platform.openai.com/docs/api-reference/authentication) or [Anthropic API Key](https://console.anthropic.com/docs/authentication) (for AI capabilities)


## Installation

1. Clone the Repository

    ```bash
    git clone https://github.com/TranslucentComputing/kubert-assistant-lite.git
    cd kubert-assistant-lite
    ```

2. For testing initialize BATS submodules

    ```bash
    git submodule update --init --recursive
    ```

## Usage

### Deploy the Kubernetes Cluster and Application

The deployment process is automated using a Makefile. To deploy the kind cluster and the Kubert AI Assistant Lite application, run:

```bash
make deploy
```

This will execute the deploy.sh script which sets up the kind cluster and deploys the application using Helm.

## Scripts

- `deploy.sh`: Deploys the kind cluster and the Kubert AI Assistant Lite application.
- `utils.sh`: Contains utility functions used across the scripts.
- `hello.sh`: Greetings and deployment description.
- `validate-tools.sh`: Validates the installation of required tools.
- `variables.sh`: Contains variables used in the deployment script.
- `cleanup.sh`: Cleans up resources after deployment by deleting the kind cluster and updating the hosts file.

## Helm Configuration

Configuration files are located in the manifests/kubert-assistant/ directory. You can customize the deployment by modifying these Helm values files:

- `gateway-values.yaml`
- `agent-repo-values.yaml`
- `command-runner-values.yaml`
- `lobe-chat-values.yaml`
- `plugin-repo-values.yaml`

## Makefile Targets

- `help`: Displays available commands.
- `build-kcov-image`: Builds the Docker image for kcov used for test coverage.
- `tests`: Runs unit tests.
- `integration-tests`: Runs integration tests.
- `coverage`: Runs tests with kcov for coverage.
- `clean-build`: Cleans up the coverage directory and Docker image.
- `deploy`: Deploys the kind cluster and Kubert AI Assistant Lite application.
- `deploy-kubert-assistant`: Deploys Kubert Assistant components using Helm.
- `cleanup-kubert-assistant`: Uninstall deployed Kubert Assistant components with Helm
- `cleanup`: Cleans up the kind cluster and hosts file.
- `check-deps-dev`: Checks for required dev dependencies.
- `check-deps-deploy`: Checks for required deployment dependencies.
- `lint-chart`: Lints the Helm chart.
- `template-chart`: Templates the Helm chart.
- `helm-test`: Execute Helm tests

## Testing

BATS is a testing framework for Bash scripts that provides a simple way to test and validate shell scripts. It is used in this project to ensure the reliability and correctness of shell scripts and command-line operations. BATS tests are written in a plain text format, making them easy to read and understand.

### Running Tests

#### Unit Tests

To run the BATS unit tests:

```bash
make tests
```

#### Integration Tests

To run the BATS integration tests:

```bash
make integration-tests
```

To run specific integration test:

```bash
make integration-tests INTEGRATION_TEST_FILE=tests/integration/test_deploy_application.bats
```

### Test Coverage with kcov

To run the tests with kcov for coverage, follow these steps:

1. Build the kcov Docker image:

    ```bash
    make build-kcov-image
    ```

2. Run the coverage target:

    ```bash
    make coverage
    ```

This will execute the tests and generate coverage reports in coverage folder using kcov.

## Contributing

We welcome contributions from the community! To contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch: git checkout -b feature/YourFeatureName.
3. Make your changes and commit them: git commit -m 'Add some feature'.
4. Push to the branch: git push origin feature/YourFeatureName.
5. Open a pull request.

## License

This project is licensed under the terms of the `LICENSE` file.

## Acknowledgments

Thank you to all contributors and the open-source community for making this project possible.
Special thanks to the authors of the tools and libraries used in this project.
