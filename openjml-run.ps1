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
  [string]$Image = "local/openjml:21",
  [string]$Target = "",
  [string]$Mode = "-esc",
  [switch]$Build,
  [switch]$MountM2
)

$ErrorActionPreference = 'Stop'

if ($Build) {
  docker build -f Dockerfile.openjml -t $Image .
}

$repo = (Get-Location).Path
$args = @(
  "run", "--rm",
  "-v", "${repo}:/work",
  "-w", "/work"
)

if ($MountM2) {
  $m2 = Join-Path $env:USERPROFILE ".m2"
  $args += @("-v", "${m2}:/m2:ro")
}

if ([string]::IsNullOrWhiteSpace($Target)) {
  docker @args $Image $Mode "-version"
  exit 0
}

$targetUnix = $Target -replace '\\','/'

docker @args $Image $Mode "/work/$targetUnix"
