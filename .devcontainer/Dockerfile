FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config \
    && rm -rf /var/lib/apt/lists/*
