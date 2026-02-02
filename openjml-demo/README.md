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
