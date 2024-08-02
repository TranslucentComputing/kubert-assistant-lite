---
layout: default
title: Installation
nav_nabled: true
---

# Installation Guide

This guide provides step-by-step instructions to install and set up Kubert Assistant Lite on your local machine.

## Prerequisites

Ensure you have the following software installed:

- [Docker](https://docs.docker.com/get-docker/){:target="_blank"}
- [Kind](https://kind.sigs.k8s.io/){:target="_blank"}
- [Helm](https://helm.sh/docs/intro/install/){:target="_blank"}
- [Kubectl](https://kubernetes.io/docs/tasks/tools/){:target="_blank"}
- [jq](https://stedolan.github.io/jq/){:target="_blank"}
- [Make](https://www.gnu.org/software/make/){:target="_blank"}
- [OpenAI API Key](https://platform.openai.com/docs/api-reference/authentication){:target="_blank"} or [Anthropic API Key](https://console.anthropic.com/docs/authentication){:target="_blank"} (for AI capabilities)

## Installation Steps

1. **Clone the repository**

   Open a terminal and run:

   ```bash
   git clone https://github.com/yourusername/kubert-assistant-lite.git
   cd kubert-assistant-lite
   ```

2. **(Optional) Initialize Git submodules for testing**

   If you plan to run tests, initialize the BATS submodules:

   ```bash
   git submodule update --init --recursive
   ```

3. **Deploy the Kind Cluster and Application**

    Use the Makefile to deploy:

    ```bash
    make deploy
    ```

    This command will set up the Kind cluster and deploy the application using Helm. During the deployment `OPENAI_API_KEY` will be requested as well as the system password to update `/etc/hosts` file with the local domains. For Windows users the user admin password is required to update `c:\Windows\System32\Drivers\etc\hosts`.

## Terminal Deployment

<script src="/kubert-assistant-lite/assets/js/asciinema-player.min.js"></script>

### Make Deploy - Mac

Example running `make deploy` in iTerminal on a Mac.

<div id="make-deploy-mac"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-deploy-mac.cast', document.getElementById('make-deploy-mac'));
</script>

### Make Cleanup - Mac

Example running `make cleanup` in iTerminal on a Mac.

<div id="make-cleanup-mac"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-cleanup-mac.cast', document.getElementById('make-cleanup-mac'));
</script>