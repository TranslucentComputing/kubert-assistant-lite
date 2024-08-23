---
layout: default
title: Ollama
description: "Complete guide to Ollama installation with step-by-step instructions for macOS and Windows. Install Ollama on your local system easily today!"
parent: Installation
nav_order: 1
nav_fold: false
---

## Ollama Installation

Full Ollama installation instruction can be found at [Ollama](https://ollama.com){:target="_blank"}.
Bellow you have links to the macOS and Windows installation binaries, download and install.

### Installation macOS

[Download](https://ollama.com/download/Ollama-darwin.zip){:target="_blank"}

### Installation Windows

[Download](https://ollama.com/download/OllamaSetup.exe){:target="_blank"}

### Installation Linux

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

[Manual install instructions](https://github.com/ollama/ollama/blob/main/docs/linux.md){:target="_blank"}

## Ollama Server Configuration Guide

These instructions go over how to configure the Ollama server using environment variables on macOS, Linux, and Windows.

Additional info can be found [Ollama FAQ](https://github.com/ollama/ollama/blob/main/docs/faq.md#how-do-i-configure-ollama-server){:target="_blank"}

### Configuration macOS

If Ollama is run as a macOS application, environment variables should be set using `launchctl`.

#### Steps

1. Open the Terminal application.
2. For each environment variable you need to set, use the following command:

    ```bash
    launchctl setenv OLLAMA_HOST "0.0.0.0"
    launchctl setenv OLLAMA_ORIGINS "*"
    ```

3. After setting the environment variables, restart the Ollama application for the changes to take effect.

### Configuration Linux

If Ollama is run as a systemd service, environment variables should be set using `systemctl`.

#### Steps

1. Open a terminal and edit the systemd service for Ollama by running:

    ```bash
    sudo systemctl edit ollama.service
    ```

    This will open an editor.

2. Under the `[Service]` section, add a line for each environment variable:

    ```ini
    [Service]
    Environment="OLLAMA_HOST=0.0.0.0"
    Environment="OLLAMA_ORIGINS=*"
    ```

3. Save the file and exit the editor.

4. Reload the systemd daemon to apply the changes:

    ```bash
    sudo systemctl daemon-reload
    ```

5. Restart the Ollama service:

    ```bash
    sudo systemctl restart ollama
    ```

### Configuration Windows

On Windows, Ollama inherits your user and system environment variables.

#### Steps

1. Quit Ollama by right-clicking the Ollama icon in the taskbar and selecting "Quit".
2. Open the **Settings** (Windows 11) or **Control Panel** (Windows 10) application.
3. Search for "environment variables" and select **Edit environment variables for your account**.
4. In the Environment Variables window, edit or create a new variable for your user account:
    - Variable Name: `OLLAMA_HOST`
    - Variable Value: `0.0.0.0`
5. Create a new variable for `OLLAMA_ORIGINS` with value `"*"`
6. Click **OK** or **Apply** to save your changes.
7. Restart the Ollama application from the Windows Start menu.

## Models

There are several models we suggest to install. Starting with the main model, LLama3.1. Open a terminal and execute:

```bash
ollama pull llama3.1:latest
```

The other models we suggest are:

| Model              | Parameters | Size  | Download                                             | Why?                                                  |
| ------------------ | ---------- | ----- | -----------------------------------------------------| ----------------------------------------------------- |
| Llama 3.1          | 405B       | 231GB | `ollama pull llama3.1:405b`                          | If you have the space and want full Llama experience. |
| Gemma 2            | 2B         | 1.6GB | `ollama pull gemma2:2b`                              | Good for testing Google SLM                           |
| Mistral            | 7B         | 4.1GB | `ollama pull mistral`                                | SLM with good performance.                            |
| Code Llama         | 7B         | 3.8GB | `ollama pull codellama`                              | Use text prompts to generate and discuss code.        |
| Qwen 2             | 7.62B      | 4.4GB | `ollama pull qwen2:latest`                           | LLM with good performance.                            |
| Qwen 2 Math        | 72B        | 47GB  | `ollama pull incept5/qwen2-math-72b-instruct:latest` | Specialized math LLM built upon the Qwen2 LLM.        |
