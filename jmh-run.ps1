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

param(
  [string]$Image = "commons-math-jmh",
  [switch]$Rebuild,
  [string[]]$Args
)

$ErrorActionPreference = 'Stop'

# Ensure we run from repo root.
# This script is stored in the repo root.
$RepoRoot = $PSScriptRoot
Set-Location $RepoRoot

try {
  docker info *> $null
} catch {
  Write-Host "Docker engine is not running or not accessible.";
  exit 2
}

if ($Rebuild -or -not (docker images -q $Image)) {
  docker build -f Dockerfile.jmh -t $Image .
}

$OutDir = Join-Path $RepoRoot "jmh-results"
New-Item -ItemType Directory -Force -Path $OutDir *> $null

if ($Args -and $Args.Length -gt 0) {
  docker run --rm -v "${OutDir}:/bench/out" $Image @Args
} else {
  docker run --rm -v "${OutDir}:/bench/out" $Image
}

Write-Host "\nResults written to: $OutDir\results.json";
