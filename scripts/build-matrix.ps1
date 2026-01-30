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

[CmdletBinding()]
param(
  [string[]]$Versions = @('8','11','17','20','21','23','26')
)

$ErrorActionPreference = 'Stop'

function Invoke-Maven([string]$jdkHome, [string]$version) {
  if (-not (Test-Path -LiteralPath $jdkHome)) {
    throw "JDK home not found for Java $version: '$jdkHome'"
  }

  $env:JAVA_HOME = $jdkHome
  $env:PATH = (Join-Path $env:JAVA_HOME 'bin') + ';' + $env:PATH

  Write-Host "\n=== Java $version ==="
  & java -version
  & mvn -version

  & mvn -B -ntp -DtrimStackTrace=false test
}

foreach ($v in $Versions) {
  $envVar = "JDK_$v"
  $jdkHome = [Environment]::GetEnvironmentVariable($envVar)

  if ([string]::IsNullOrWhiteSpace($jdkHome)) {
    throw "Missing environment variable $envVar. Set it to the JDK home directory for Java $v (e.g. C:\\Program Files\\Java\\jdk-$v)."
  }

  Invoke-Maven -jdkHome $jdkHome -version $v
}
