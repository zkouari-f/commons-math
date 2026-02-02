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
