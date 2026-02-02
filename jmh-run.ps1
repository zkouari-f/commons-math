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
