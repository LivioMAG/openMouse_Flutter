FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config \
    && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH

RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME -b stable \
    && flutter doctor