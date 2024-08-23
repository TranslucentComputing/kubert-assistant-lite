---
layout: default
title: Home
description: "Kubert AI Assistant Lite: An open-source tool for deploying local Kubernetes clusters with kind and automating kubectl via AI. Enhance productivity and streamline operations."
nav_nabled: true
sitemap:
  priority: 0.7
  changefreq: 'weekly'
---

# Kubert AI Assistant Lite

Kubert AI Assistant Lite is a lightweight open-source project that enables the deployment of a local Kubernetes cluster using [kind](https://kind.sigs.k8s.io/){:target="_blank"} and the deployment of Kubert AI Assistant with a single AI agent, the Kubectl Agent.

[Visit GitHub](https://github.com/TranslucentComputing/kubert-assistant-lite){: .btn .btn-blue target="_blank" rel="noopener" }
[Join Our Discord](https://discord.gg/d22b58ejgV){: .btn .btn-green target="_blank" rel="noopener" }

*Kubectl AI Agent At Work: Retrieving pod status*{: .fw-300 }
[![Namespace Status](/kubert-assistant-lite/assets/images/namespace-status.png)](/kubert-assistant-lite/assets/images/namespace-status.png)

## Key Features

- **kind Cluster Deployment**: Leverage Kubernetes in Docker (kind) to create a local Kubernetes cluster for testing and development, enabling rapid prototyping and experimentation.
- **Kubectl AI Agent**: An AI-powered agent capable of executing `kubectl` commands based on user prompts. This agent enhances productivity by automating routine Kubernetes management tasks.
- **Automation and Insights**: Gain insights into your Kubernetes environment through automated command execution and analysis provided by the AI agent.

## Benefits

- **Simplified Kubernetes Setup**: Kubert AI Assistant Lite provides an easy-to-use platform for setting up local Kubernetes clusters, reducing the barrier to entry for developers new to Kubernetes.
- **Enhanced Productivity**: By automating routine Kubernetes operations through intelligent command execution, developers can focus on higher-level tasks and accelerate their workflows.
- **Testbed for AI-Driven Automation**: Kubert AI Assistant Lite offers a sandbox environment where developers can explore the capabilities of the Kubectl AI agent and experiment with AI-driven Kubernetes management techniques.

## Comparison with Other Tools

Kubert AI Assistant Lite stands out from other Kubernetes management tools in the following ways:

- **AI-Driven Interaction**: Unlike traditional tools that rely on manual commands, Kubert AI Assistant Lite leverages AI to interpret user prompts and execute appropriate actions, making cluster management more intuitive and accessible.
- **Lightweight and Local**: With its focus on local development using kind, Kubert AI Assistant Lite provides a lightweight and self-contained environment for experimentation and testing, without the need for complex setups or external dependencies.
- **Educational Resource**: Kubert AI Assistant Lite serves as an educational tool, allowing developers to learn and explore Kubernetes concepts and best practices through hands-on interaction with the AI agent.

## Project Architecture

```mermaid
graph TD;
    subgraph Local Environment
        A[Developer's Machine] -->|runs| B[Docker]
    end

    subgraph Kubernetes Cluster                
        B --> C[kind Cluster]
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

The architecture of Kubert AI Assistant Lite consists of several key components that work together to create a robust and flexible local Kubernetes environment using kind. Here’s a detailed breakdown:

- **Local Environment**: The project is initiated on the developer's machine, which runs Docker to host the Kubernetes cluster using kind. This setup ensures a lightweight and easily configurable development environment.

- **kind Cluster**: kind (Kubernetes in Docker) is used to create a local Kubernetes environment within Docker containers. It provides a lightweight and configurable cluster setup, ideal for testing and development purposes.

- **Kubert AI Assistant**: Deployed within the kind cluster, the Kubert Assistant serves as a management layer that interprets user prompts and coordinates actions within the cluster. It acts as a bridge between user commands and Kubernetes operations.

- **Kubectl AI Agent**: This AI-powered agent operates within the kind cluster, executing `kubectl` commands based on natural language prompts. It offers automated management and diagnostic capabilities, simplifying Kubernetes operations and enhancing productivity.

- **User Interaction**: Users send commands through a prompt interface, which are interpreted by the Kubectl AI Agent to perform the necessary operations within the Kubernetes cluster.

This architecture enables seamless interaction and automation within a localized Kubernetes environment, making it an ideal tool for developers and DevOps professionals looking to streamline their Kubernetes workflows.

## Components

```mermaid
graph TD;
    A[Project Root]
    A --> C[Makefile]
    A --> D[README.md]    
    A --> F[kind-config.yaml]    
    A --> H[Scripts]
    A --> G[Manifests]
    A --> I[Tests]

    G --> J[calico]
    G --> K[chart]
    G --> L[kubert-assistant]
    G --> M[nginx-ingress-controller]
    G --> N[test-deployment]

    I --> U[integration]
    I --> X[unit]
    I --> T[bats]
    I --> W[test_helper]
    W --> W1[bats-assert]
    W --> W2[bats-support]

    classDef root fill:#FF8C00,stroke:#333,stroke-width:2px,font-weight:bold,color:#fff;
    classDef directory fill:#FFD700,stroke:#333,stroke-width:2px,font-weight:bold,color:#333;
    classDef file fill:#98FB98,stroke:#333,stroke-width:1px,color:#333;

    class A root;
    class C,D,F file;
    class G,H,I directory;
    class J,K,L,M,T,U,X,N directory;
    class W directory;
    class W1,W2 directory;
```

The Kubert AI Assistant Lite project is organized into several key components, each contributing to the overall functionality and structure of the project. Below is a breakdown of these components, aligned with the project tree structure:

- **Project Root**: The top-level directory containing all project files and directories. It serves as the entry point for the entire project.

  - **Makefile**: A build automation tool file containing a set of directives used to compile and manage the project. It simplifies complex command sequences, making it easier for developers to execute tasks.

  - **README.md**: A markdown file providing an overview of the project, including usage instructions, setup steps, and additional resources for users and contributors.

  - **kind-config.yaml**: Configuration file used to set up the kind Kubernetes cluster, defining the cluster's specifications and resources.

- **Scripts**: A directory containing various shell scripts used to automate deployment, cleanup, validation, and other utility functions.

- **Manifests**: A directory containing YAML files and Helm charts for Kubernetes deployments and configurations.

  - **calico**: Includes deployment configurations for Calico, a networking and network policy engine for Kubernetes.

  - **chart**: Contains Helm chart files, including templates and values used to deploy and manage Kubernetes components.

  - **kubert-assistant**: Holds the Helm chart values YAML files for the Kubert Assistant component, specifying values and settings for its operation.

  - **nginx-ingress-controller**: Contains deployment configurations for the NGINX Ingress Controller, managing external access to services within the Kubernetes cluster.
  - **test-deployment**: Manifest files used for testing and demos.

- **Tests**: A directory with test scripts and support files for unit and integration testing, ensuring the project's reliability and performance.

  - **integration**: Contains integration test scripts that verify the functionality of different components working together.

  - **unit**: Includes unit test scripts focusing on individual components and their isolated behavior.

  - **bats**: Holds test files using BATS (Bash Automated Testing System) for bash script testing.

  - **test_helper**: Provides helper scripts and libraries supporting the testing process, including assertions and support functions.
  
    - **bats-assert**: A library providing assertions for BATS test scripts.

    - **bats-support**: A library offering support functions for BATS, aiding in test setup and execution.

## Roadmap and Future Plans

We have exciting plans for the future of Kubert AI Assistant Lite. Some of the key areas we are focusing on include:

- **Enhanced AI Capabilities**: We are continuously working on improving the AI agent's understanding of user prompts and its ability to execute complex Kubernetes operations. This includes expanding the range of supported commands and providing more intelligent suggestions and insights.
- **Additional AI Agents**: We plan to introduce new AI agents specializing in different aspects of Kubernetes management, such as monitoring, security, and performance optimization. These agents will work alongside the Kubectl AI Agent to provide a comprehensive and intelligent cluster management experience.
- **Integration with Popular Tools**: We aim to integrate Kubert AI Assistant Lite with popular Kubernetes tools and platforms, such as Prometheus, Grafana, and LinkerD, to provide a seamless and unified experience for users. Full Kubert AI Assistant comes with Kubert Toolkit. The comprehensive toolkit is not best suited for local development. We are looking at ways to allow users to partially install it.
- **Community Contributions**: We encourage and welcome contributions from the open-source community to help shape the future of Kubert AI Assistant Lite. We plan to establish clear guidelines and processes for contributing, making it easier for developers to get involved and contribute to the project.

## Getting Started

To get started with Kubert Assistant Lite, follow the installation guide and deploy your local Kubernetes cluster using kind. Explore the capabilities of the Kubectl AI agent and discover how it can streamline your Kubernetes workflows.

For detailed installation instructions, please refer to the [Installation Guide](installation.html).

## Contributing

We welcome contributions from the open-source community to help improve Kubert Assistant Lite. Whether you want to report a bug, suggest a feature, or contribute code.

## License

Kubert Assistant Lite is released under the MIT License. See the [LICENSE](https://github.com/TranslucentComputing/kubert-assistant-lite/blob/main/LICENSE){:target="_blank"} file for more details.
