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

# OpenJML demo

This folder contains a tiny Java + JML example that can be checked with OpenJML.

## Run

From the repository root:

- `powershell -ExecutionPolicy Bypass -File scripts/openjml.ps1`

By default this runs OpenJML ESC (static verification) on `openjml-demo/src/main/java/demo/Clamp.java`.

## Notes

- The script uses Docker to run OpenJML in Linux. You must have Docker Desktop running.
- If you want to check a different file:
  - `powershell -ExecutionPolicy Bypass -File scripts/openjml.ps1 -Target "path/to/File.java"`

`openjml-demo/src/main/java/demo/Factorial.java` is also included as a more challenging example that may require stronger annotations/lemmas.
