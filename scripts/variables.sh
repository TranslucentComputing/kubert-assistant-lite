#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Script Name: variables.sh
# Description: This file contains all the variables used in the deployment script.
#
# Copyright © 2024 Translucent Computing Inc.
# -----------------------------------------------------------------------------

#shellcheck disable=SC2034

# kind cluaster vars
KIND_CLUSTER_NAME="kubert-cluster"
KIND_CONFIG="kind-config.yaml"

# Manifests
NGINX_INGRESS_CONTROLLER_YAML="manifests/nginx-ingress-controller/deploy.yaml"
CALICO_YAML="manifests/calico/deploy.yaml"
KUBERT_COMPONENTS=(
    "command-runner:manifests/kubert-assistant/command-runner-values.yaml"
    "agent-repo:manifests/kubert-assistant/agent-repo-values.yaml"
    "plugin-repo:manifests/kubert-assistant/plugin-repo-values.yaml"
    "gateway:manifests/kubert-assistant/gateway-values.yaml"
    "lobechat:manifests/kubert-assistant/lobe-chat-values.yaml"
)

# Helm vars
HELM_NAMESPACE="kubert-assistant"
CHART_PATH="manifests/chart"

# Hosts entries for the applications
HOSTS_ENTRIES=(
    "kubert-assistant.lan"
    "kubert-agent.lan"
    "kubert-plugin.lan"
    "kubert-plugin-gateway.lan"
)