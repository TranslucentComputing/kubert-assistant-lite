# -----------------------------------------------------------------------------
# Dockerfile for Building kcov with Additional Tools
#
# Description:
# This Dockerfile builds a Docker image based on the latest kcov image and
# installs additional tools such as jq and curl. This image is used to run
# tests and generate coverage reports for shell scripts.
#
# Usage:
# docker build -t my_kcov .
#
# Base Image:
# kcov/kcov:latest
#
# Maintainer:
# Translucent Computing Inc.
# -----------------------------------------------------------------------------

# Use the latest kcov image as the base image
FROM kcov/kcov:latest

# Install additional tools (jq and curl)
# Using && and a single RUN layer to minimize the number of layers
RUN apt-get update && \
    apt-get install -y jq curl && \
    rm -rf /var/lib/apt/lists/*
