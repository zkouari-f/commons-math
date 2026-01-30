<!--
Licensed to the Apache Software Foundation (ASF) under one or more
contributor license agreements.  See the NOTICE file distributed with
this work for additional information regarding copyright ownership.
The ASF licenses this file to You under the Apache License, Version 2.0
(the "License"); you may not use this file except in compliance with
the License.  You may obtain a copy of the License at

   https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->

# CI / CD (GitHub Actions)

This repository contains a CI workflow that builds and runs the Maven test suite across multiple Java runtimes.

- Workflow file: `.github/workflows/ci.yml`
- Trigger: `push` + `pull_request`
- Build tool: Maven (`mvn test`)

## Java matrix

The workflow runs a matrix of:

- Java 8, 11, 17, 20, 21, 23, 25
- Java 26 is configured as early-access (`26-ea`) and is **allowed to fail** (because EA availability can vary by runner and date).

If you want Java 26 to be required, change `26-ea` to `26` and set `continue_on_error: false`.

## Local multi-Java build

To run the same Java-version matrix locally, provide the JDK home directories via environment variables and run the helper script.

### PowerShell (Windows)

1. Set environment variables (JDK *home* directories):

   - `JDK_8`, `JDK_11`, `JDK_17`, `JDK_20`, `JDK_21`, `JDK_23`, `JDK_25`, `JDK_26`

2. Run:

   - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build-matrix.ps1`

### Bash (Linux/macOS)

1. Export variables `JDK_8`, `JDK_11`, ... with JDK home directories.
2. Run:

   - `bash scripts/build-matrix.sh`

## Notes

- The scripts set `JAVA_HOME` for each run and prepend `$JAVA_HOME/bin` to `PATH`.
- Each entry runs `mvn test`.
