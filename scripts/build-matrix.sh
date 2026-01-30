#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -euo pipefail

versions=("${@:-8 11 17 20 21 23 26}")

for v in "${versions[@]}"; do
  env_var="JDK_${v}"
  jdk_home="${!env_var:-}"

  if [[ -z "$jdk_home" ]]; then
    echo "Missing environment variable $env_var (set it to the JDK home for Java $v)." >&2
    exit 1
  fi

  if [[ ! -d "$jdk_home" ]]; then
    echo "JDK home not found for Java $v: $jdk_home" >&2
    exit 1
  fi

  export JAVA_HOME="$jdk_home"
  export PATH="$JAVA_HOME/bin:$PATH"

  echo
  echo "=== Java $v ==="
  java -version
  mvn -version

  mvn -B -ntp -DtrimStackTrace=false test

done
