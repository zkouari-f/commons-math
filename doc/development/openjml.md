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
