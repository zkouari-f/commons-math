param(
  # Your Docker Hub username/org, e.g. "sc123" or "my-org"
  [Parameter(Mandatory = $true)]
  [string]$Namespace,

  # Repository name on Docker Hub, e.g. "commons-math-jmh"
  [string]$Repo = "commons-math-jmh",

  # Image tag to push, e.g. "v1" or "2026-02-02"
  [string]$Tag = "latest",

  # Build platform (Docker Desktop usually uses linux/amd64)
  [string]$Platform = "linux/amd64"
)

$ErrorActionPreference = 'Stop'

$RepoRoot = $PSScriptRoot
Set-Location $RepoRoot

try {
  docker info *> $null
} catch {
  Write-Host "Docker engine is not running or not accessible.";
  exit 2
}

$Full = "${Namespace}/${Repo}:${Tag}"

Write-Host "Building: $Full"
# Buildx is the most reliable way to publish linux images from Windows.
docker buildx build `
  --platform $Platform `
  -f Dockerfile.jmh `
  -t $Full `
  --load `
  .

Write-Host "\nNext steps (manual login required):"
Write-Host "  docker login"
Write-Host "  docker push $Full"
Write-Host "\nOptional: also tag/push latest"
Write-Host "  docker tag $Full ${Namespace}/${Repo}:latest"
Write-Host "  docker push ${Namespace}/${Repo}:latest"
