---
layout: default
title: Home
nav_nabled: true
---

# Kubert AI Assistant Lite

Kubert AI Assistant Lite is a lightweight open-source project that enables the deployment of a Kubernetes cluster using [Kind](https://kind.sigs.k8s.io/){:target="_blank"} and the deployment of Kubert Assistant with a single AI agent, the Kubectl Agent. 

<img src="/kubert-assistant-lite/assets/images/namespace-status.png" alt="Namespace Status" width="800" />

## Project Architecture

- **Kind Cluster**: Uses Kubernetes in Docker (Kind) to create a local cluster for testing and development.
- **Kubectl Agent**: An AI agent capable of executing `kubectl` commands within the cluster, providing insights and automation capabilities.

## Components

1. **Scripts**: Automate the setup and teardown processes, including utility functions and validation checks.
2. **Helm Charts**: Manage the deployment of Kubernetes components.
3. **Makefile**: Simplifies the execution of complex command sequences for deployment and testing.

## Goals

- Simplify local Kubernetes cluster setup.
- Provide a testbed for Kubert Assistant's functionalities.
- Allow developers to experiment with the Kubectl Agent's capabilities.
