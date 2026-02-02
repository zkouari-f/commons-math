# OpenJML runner image built from official OpenJML Linux release.
#
# This avoids relying on third-party Docker images and makes the tool reproducible.

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG OPENJML_VERSION=21-0.21

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     ca-certificates \
     curl \
     unzip \
     bash \
    libgomp1 \
  && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  mkdir -p /opt/openjml; \
  curl -fsSL -o /tmp/openjml.zip "https://github.com/OpenJML/OpenJML/releases/download/${OPENJML_VERSION}/openjml-ubuntu-latest-${OPENJML_VERSION}.zip"; \
  unzip -q /tmp/openjml.zip -d /opt/openjml; \
  rm /tmp/openjml.zip; \
  OPENJML_BIN="$(find /opt/openjml -type f -name openjml -o -name openjml.sh | head -n 1)"; \
  test -n "$OPENJML_BIN"; \
  ln -s "$OPENJML_BIN" /usr/local/bin/openjml; \
  chmod +x "$OPENJML_BIN" || true

ENTRYPOINT ["openjml"]
