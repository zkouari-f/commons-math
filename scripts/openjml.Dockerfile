# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
