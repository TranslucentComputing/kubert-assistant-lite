---
layout: default
title: Installation
description: "Step-by-step instructions to install and set up Kubert AI Assistant Lite on your local machine. Ensure Docker, kind, Helm, Kubectl, and other essential tools are ready for a smooth installation."
nav_nabled: true
has_children: true
has_toc: false
nav_fold: false
k_seo:
  title: "Kubert AI Assistant Lite Installation Guide"
---

# Kubert Lite Installation Guide

This guide provides step-by-step instructions to install and set up Kubert AI Assistant Lite on your local machine.

## Prerequisites

Before proceeding with the installation, ensure you have the following software installed:

- [Docker](https://docs.docker.com/get-docker/){:target="_blank"}
- [kind](https://kind.sigs.k8s.io/){:target="_blank"}
- [Helm](https://helm.sh/docs/intro/install/){:target="_blank"}
- [Kubectl](https://kubernetes.io/docs/tasks/tools/){:target="_blank"}
- [jq](https://stedolan.github.io/jq/){:target="_blank"}
- [Make](https://www.gnu.org/software/make/){:target="_blank"}
- [OpenAI API Key](https://platform.openai.com/docs/api-reference/authentication){:target="_blank"} or [Anthropic API Key](https://console.anthropic.com/docs/authentication){:target="_blank"} (for AI capabilities)

Ensure that these tools are properly installed and accessible from your command line.

## Setting up API Keys

To enable the AI capabilities of Kubert AI Assistant Lite, you need to set up an API key from either OpenAI or Anthropic. Follow these steps to obtain and configure your API key:

### OpenAI API Key

1. Sign up for an account at [OpenAI](https://platform.openai.com/signup/){:target="_blank"} if you don't have one already.
2. Navigate to the [API Keys](https://platform.openai.com/account/api-keys){:target="_blank"} section in your OpenAI account dashboard.
3. Click on the "Create new secret key" button to generate a new API key.
4. Copy the generated API key and store it securely.

### Anthropic API Key

1. Sign up for an account at [Anthropic](https://console.anthropic.com/login){:target="_blank"} if you don't have one already.
2. Navigate to the [API Keys](https://console.anthropic.com/settings/keys){:target="_blank"} section in your Anthropic account dashboard.
3. Click on the "Create Key" button to generate a new API key.
4. Copy the generated API key and store it securely.

### Groq API Key

1. Sign up for an account at [groqcloud](https://console.groq.com/login){:target="_blank"} if you don't have one already.
2. Navigate to the [API Keys](https://console.groq.com/keys){:target="_blank"} section in your groqcloud account dashboard.
3. Click on teh "Create Key" button to generate a new API key.
4. Copy the generated API key and store it securely.

### Google AI API key

1. Sign up for an account at [AI Studio](https://ai.google.dev/aistudio){:target="_blank"} if you don't have one already.
2. Click on teh "Get API Key" to navigate to the API keys section.
3. Click on teh "Create Key" button to generate a new API key.
4. Copy the generated API key and store it securely.

Once you have obtained your API key, you will need to provide it during the installation process.

## Installation Steps

Follow these steps to install and set up Kubert AI Assistant Lite:

1. **Clone the repository**

   Open a terminal and run:

   ```bash
   git clone https://github.com/TranslucentComputing/kubert-assistant-lite.git
   cd kubert-assistant-lite
   ```

2. **(Optional) Initialize Git submodules for testing**

   If you plan to run tests, initialize the BATS submodules:

   ```bash
   git submodule update --init --recursive
   ```

3. **Check deployment dependencies.**

    ```bash
    make check-deps-deploy
    ```

4. **Deploy the kind Cluster and Application**

    Use the Makefile to deploy:

    ```bash
    make deploy
    ```

    This command will set up the kind cluster and deploy the application using Helm. During the deployment `OPENAI_API_KEY` will be requested as well as the system password to update `/etc/hosts` file with the local domains. For Windows users the user admin password is required to update `c:\Windows\System32\Drivers\etc\hosts`.

5. **Open browser to [http://kubert-assistant.lan/](http://kubert-assistant.lan/){:target="_blank"}**

    <div class="video-container">
        <video width="700" height="315" controls>
            <source src="/kubert-assistant-lite/assets/video/open-browser.mov" type="video/mp4">
            Your browser does not support the video tag.
        </video>
    </div>

## Cleaning Up

To clean up and delete the kind cluster and the Kubert AI Assistant Lite components, run the following command:

```bash
make cleanup
```

This command will remove the kind cluster and all the associated resources, bringing your environment back to its initial state.

## Terminal Deployment

### Make Deploy

#### Mac Version

Example running `make deploy` in iTerminal on a Mac.

<div id="make-deploy-mac"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-deploy-mac.cast', document.getElementById('make-deploy-mac'),{
           poster: 'npt:10'
        });
</script>

### Make Cleanup

#### Mac Version

Example running `make cleanup` in iTerminal on a Mac.

<div id="make-cleanup-mac"></div>
<script>
    AsciinemaPlayer.create('/kubert-assistant-lite/assets/terminal/make-cleanup-mac.cast', document.getElementById('make-cleanup-mac'),{
           poster: 'npt:10'
        });
</script>
