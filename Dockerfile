FROM ubuntu:24.04
ARG FLUTTER_VERSION=3.41.6
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git unzip xz-utils libglu1-mesa python3 \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"
ENV PUB_CACHE=/opt/pub-cache
ENV CI=true
RUN flutter config --no-analytics --enable-web && flutter precache --web && flutter --version
WORKDIR /workspace/app
EXPOSE 8080
CMD ["flutter", "--version"]
