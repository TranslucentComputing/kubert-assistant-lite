# Kubert Assistant Lite Project

This project is designed to deploy a Kubernetes cluster using kind and deploy a Lite version of the Kubert Assistant application using Helm. The project includes automation scripts, utility functions, and integration tests to ensure a smooth deployment process.

## Project Structure

```plaintext
.
├── Makefile
├── README.md
├── kind-config.yaml
├── manifests
│   ├── calico
│   ├── chart
│   ├── kubert-assistant
│   └── nginx-ingress-controller
├── scripts
└── tests
    ├── integration
    ├── unit
    ├── support
    ├── bats
    ├── test_helper
    │   ├── bats-assert
    │   └── bats-support
```

## Setup Instructions

## Prerequisites

- Docker
- kind
- kubectl
- Helm
- BATS (included as a git submodule)

## Installation

1. Clone the Repository

    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```

2. Initialize Submodules

    ```bash
    git submodule update --init --recursive
    ```

## Usage

### Deploy the Kubernetes Cluster and Application

The deployment process is automated using a Makefile. To deploy the kind cluster and the Kubert Assistant Lite application, run:

```bash
make deploy
```

This will execute the deploy.sh script which sets up the kind cluster and deploys the application using Helm.

## Scripts

- `deploy.sh`: Deploys the kind cluster and the Kubert Assistant Lite application.
- `utils.sh`: Contains utility functions used across the scripts.
- `hello.sh`: Greetings and deployment description.
- `validate-tools.sh`: Validates the installation of required tools.
- `variables.sh`: Contains variables used in the deployment script.
- `cleanup.sh`: Cleans up resources after deployment by deleting the Kind cluster and updating the hosts file.

## Makefile Targets

- `help`: Displays available commands.
- `build-kcov-image`: Builds the Docker image for kcov used for test coverage.
- `tests`: Runs unit tests.
- `integration-tests`: Runs integration tests.
- `coverage`: Runs tests with kcov for coverage.
- `clean-build`: Cleans up the coverage directory and Docker image.
- `deploy`: Deploys the kind cluster and Kubert Assistant Lite application.
- `deploy-kubert-assistant`: Deploys Kubert Assistant components using Helm.
- `cleanup`: Cleans up the kind cluster and hosts file.
- `check-deps`: Checks for required dependencies.
- `lint-chart`: Lints the Helm chart.
- `template-chart`: Templates the Helm chart.
- `helm-test`: ## Run Helm tests

## Testing

### Running Tests

#### Unit Tests

To run the unit tests:

```bash
make tests
```

#### Integration Tests

To run the integration tests:

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

## License

This project is licensed under the terms of the `LICENSE.txt` file.
