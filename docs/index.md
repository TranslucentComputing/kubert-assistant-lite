---
layout: default
title: Home
nav_nabled: true
---

# Kubert AI Assistant Lite

Kubert AI Assistant Lite is a lightweight open-source project that enables the deployment of a Kubernetes cluster using [Kind](https://kind.sigs.k8s.io/){:target="_blank"} and the deployment of Kubert AI Assistant with a single AI agent, the Kubectl Agent. 

*Kubectl AI Agent At Work: Retrieving pod status*{: .fw-300 }
[![Namespace Status](/kubert-assistant-lite/assets/images/namespace-status.png)](/kubert-assistant-lite/assets/images/namespace-status.png)

## Key Features

- **Kind Cluster Deployment**: Leverage Kubernetes in Docker (Kind) to create a local Kubernetes cluster for testing and development, enabling rapid prototyping and experimentation.
- **Kubectl AI Agent**: An AI-powered agent capable of executing `kubectl` commands based on user prompts. This agent enhances productivity by automating routine Kubernetes management tasks.
- **Automation and Insights**: Gain insights into your Kubernetes environment through automated command execution and analysis provided by the AI agent.

## Project Architecture

```mermaid
graph TD;
    subgraph Local Environment
        A[Developer's Machine] -->|runs| B[Docker]
    end

    subgraph Kubernetes Cluster                
        B --> C[Kind Cluster]
        C --> D[Kubert Assistant]
        D --> E[Kubectl AI Agent]
    end

    F[User Prompt] -->|sends commands to| E
    E -->|executes commands in| C

    classDef localEnv fill:#FDAFAF,stroke:#333,stroke-width:1px;
    classDef k8sCluster fill:#ccffcc,stroke:#333,stroke-width:1px;
    classDef aiAgent fill:#1DCEE3,stroke:#333,stroke-width:1px;
    classDef userPrompt fill:#fff2cc,stroke:#333,stroke-width:1px;
    classDef kubertAssistant fill:#ffeb99,stroke:#333,stroke-width:1px;


    class A,B localEnv;
    class C k8sCluster;
    class D kubertAssistant;
    class E aiAgent;
    class F userPrompt

    linkStyle 0 stroke:#A1BA90,stroke-width:1px;
    linkStyle 1 stroke-width:1px;
    linkStyle 2 stroke-width:1px;
    linkStyle 3 stroke-width:1px;
    linkStyle 4 stroke:#A1BA90,stroke-width:1px;
    linkStyle 5 stroke:#A1BA90,stroke-width:1px;
```

The architecture of Kubert AI Assistant Lite consists of several key components that work together to create a robust and flexible local Kubernetes environment using Kind. Here’s a detailed breakdown:

- **Local Environment**: The project is initiated on the developer's machine, which runs Docker to host the Kubernetes cluster using Kind. This setup ensures a lightweight and easily configurable development environment.

- **Kind Cluster**: Kind (Kubernetes in Docker) is used to create a local Kubernetes environment within Docker containers. It provides a lightweight and configurable cluster setup, ideal for testing and development purposes.

- **Kubert AI Assistant**: Deployed within the Kind cluster, the Kubert Assistant serves as a management layer that interprets user prompts and coordinates actions within the cluster. It acts as a bridge between user commands and Kubernetes operations.

- **Kubectl AI Agent**: This AI-powered agent operates within the Kind cluster, executing `kubectl` commands based on natural language prompts. It offers automated management and diagnostic capabilities, simplifying Kubernetes operations and enhancing productivity.

- **User Interaction**: Users send commands through a prompt interface, which are interpreted by the Kubectl AI Agent to perform the necessary operations within the Kubernetes cluster.

This architecture enables seamless interaction and automation within a localized Kubernetes environment, making it an ideal tool for developers and DevOps professionals looking to streamline their Kubernetes workflows.

## Components

1. **Scripts**: A collection of shell scripts that automate setup, deployment, and cleanup processes. These scripts include utility functions and validation checks to ensure a smooth workflow.
2. **Helm Charts**: Used to manage the deployment of Kubernetes components, ensuring consistent and reproducible installations.
3. **Makefile**: Provides a simplified interface for executing complex command sequences related to deployment and testing, making it easier for developers to interact with the project.

## Goals

- **Simplify Kubernetes Setup**: Provide an easy-to-use platform for setting up local Kubernetes clusters, reducing the barrier to entry for developers new to Kubernetes.
- **Testbed for AI-Driven Automation**: Offer a sandbox environment where developers can explore the capabilities of the Kubectl AI agent and experiment with AI-driven Kubernetes management.
- **Enhance Developer Productivity**: Allow developers to focus on higher-level tasks by automating routine Kubernetes operations through intelligent command execution.

## Getting Started

To get started with Kubert Assistant Lite, follow the installation guide and deploy your local Kubernetes cluster using Kind. Explore the capabilities of the Kubectl AI agent and discover how it can streamline your Kubernetes workflows.

For detailed installation instructions, please refer to the [Installation Guide](installation.html).

## Contributing

We welcome contributions from the open-source community to help improve Kubert Assistant Lite. Whether you want to report a bug, suggest a feature, or contribute code.

## License

Kubert Assistant Lite is released under the MIT License. See the [LICENSE](https://github.com/TranslucentComputing/kubert-assistant-lite/blob/main/LICENSE){:target="_blank"} file for more details.
