<!--
Licensed to the Apache Software Foundation (ASF) under one or more
contributor license agreements.  See the NOTICE file distributed with
this work for additional information regarding copyright ownership.
The ASF licenses this file to You under the Apache License, Version 2.0
(the "License"); you may not use this file except in compliance with
the License.  You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->

# Formal verification with OpenJML (local)

This repository does not ship with JML specifications by default.
For coursework / experimentation, this workspace includes a tiny, self-contained demo under `openjml-demo/` and a wrapper script.

## Prerequisites

- Windows
- Docker Desktop installed and running

## Run OpenJML on the demo

From the repository root:

- `powershell -ExecutionPolicy Bypass -File scripts/openjml.ps1`

This runs OpenJML ESC (static checking) on:

- `openjml-demo/src/main/java/demo/Clamp.java`

`openjml-demo/src/main/java/demo/Factorial.java` is also available as a more challenging example.

## Run OpenJML on another file

- `powershell -ExecutionPolicy Bypass -File scripts/openjml.ps1 -Target "path/to/File.java"`

## Run OpenJML on a Maven module (recommended)

For real source files inside this multi-module Maven build, OpenJML needs the module classpath.
The script can build it for you:

- `powershell -ExecutionPolicy Bypass -File scripts/openjml.ps1 -Module commons-math-transform -Target "commons-math-transform/src/main/java/org/apache/commons/math4/transform/TransformUtils.java"`

## Notes

- The script uses a Linux OpenJML container image. If Docker is not running, it will print a short hint.
- For real projects, OpenJML typically needs correct classpaths and often benefits from starting with small, dependency-light targets.
