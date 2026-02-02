param(
  [string]$Target = "openjml-demo/src/main/java/demo/Clamp.java",
  [string]$Image = "local/openjml:21-0.21",
  [string]$Mode = "-esc",
  [switch]$Rebuild,
  # Optional: If set, build a Maven compile classpath for this module and pass it to OpenJML.
  # Example: -Module commons-math-transform -Target commons-math-transform/src/main/java/.../TransformUtils.java
  [string]$Module = ""
)

$ErrorActionPreference = 'Stop'

function Write-Die([string]$Message) {
  Write-Host $Message
  exit 1
}

function Invoke-Checked([string]$Label, [scriptblock]$Command) {
  Write-Host "==> $Label"
  & $Command
  $code = $LASTEXITCODE
  if ($code -ne $null -and $code -ne 0) {
    Write-Host "FAILED ($code): $Label"
    exit $code
  }
}

function Convert-WindowsClasspathToLinux([string]$WindowsCp, [string]$RepoRootWindows, [string]$M2RepoWindows) {
  # Maven on Windows returns a ';' separated classpath with Windows paths.
  # We mount:
  #   repo root -> /work
  #   ~/.m2     -> /m2
  # Convert those paths to container paths.
  $cp = $WindowsCp.Trim()
  if ([string]::IsNullOrWhiteSpace($cp)) { return "" }

  $repoRootNorm = $RepoRootWindows.TrimEnd('\\')
  $m2Norm = $M2RepoWindows.TrimEnd('\\')

  # Normalize separators for simpler replacement.
  $cp = $cp.Replace('\', '/')
  $repoRootNorm = $repoRootNorm.Replace('\', '/')
  $m2Norm = $m2Norm.Replace('\', '/')

  # Replace prefixes.
  $cp = $cp.Replace($repoRootNorm, '/work')
  $cp = $cp.Replace($m2Norm, '/m2')

  # Convert path list separator.
  $cp = $cp.Replace(';', ':')
  return $cp
}

# Ensure we run from repo root.
$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

# Require Docker engine.
try {
  docker info *> $null
} catch {
  Write-Host "Docker engine is not running or not accessible."
  Write-Host "- Start Docker Desktop (or ask an admin to start the service 'com.docker.service')."
  Write-Host "- Then re-run: powershell -ExecutionPolicy Bypass -File scripts/openjml.ps1"
  exit 2
}

# Build the local OpenJML image if needed.
$Dockerfile = Join-Path $PSScriptRoot 'openjml.Dockerfile'
if (-not (Test-Path $Dockerfile)) {
  Write-Die "Missing Dockerfile: $Dockerfile"
}

$Existing = (docker images -q $Image 2>$null)
if ($Rebuild -or -not $Existing) {
  Write-Host "Building OpenJML image: $Image"
  Invoke-Checked "docker build" { docker build -t $Image -f $Dockerfile $RepoRoot }
}

# Normalize to container path.
$TargetUnix = $Target -replace '\\','/'

$M2 = Join-Path $env:USERPROFILE ".m2"
if (-not (Test-Path $M2)) {
  Write-Die "Maven repository folder not found: $M2"
}

# Optional workspace overlay for JML specs (used to provide lightweight specs for external deps).
$SpecOverlay = Join-Path $RepoRoot "openjml-specs"
$LinuxSpecPath = ""
if (Test-Path $SpecOverlay) {
  $LinuxSpecPath = "/opt/openjml/specs:/work/openjml-specs"
}

# If a module was provided, build and compute a Linux container classpath.
$LinuxClasspath = ""
if (-not [string]::IsNullOrWhiteSpace($Module)) {
  $ModuleDir = Join-Path $RepoRoot $Module
  $ModulePom = Join-Path $ModuleDir "pom.xml"
  if (-not (Test-Path $ModulePom)) {
    Write-Die "Module not found or missing pom.xml: $Module"
  }

  Write-Host "Preparing Maven classpath for module: $Module"

  # Keep classpath preparation quick: we only need compiled classes + dependency jars.
  $MvnFast = @(
    "-q",
    "-pl", $Module,
    "-am",
    "-DskipTests=true",
    "-DskipITs=true",
    "-DskipRat=true",
    "-Drat.skip=true",
    "-Dcheckstyle.skip=true",
    "-Dpmd.skip=true",
    "-Dspotbugs.skip=true",
    "-Dstyle.color=never",
    "-Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn"
  )

  # Compile the module so target/classes exists.
  Invoke-Checked "mvn test-compile ($Module)" { mvn @MvnFast test-compile }

  # Build dependency classpath (compile scope) into a file.
  $CpFile = Join-Path $ModuleDir "target\openjml.classpath"
  Invoke-Checked "mvn dependency:build-classpath ($Module)" { mvn @MvnFast "-DincludeScope=compile" "dependency:build-classpath" "-Dmdep.outputFile=$CpFile" }

  if (-not (Test-Path $CpFile)) {
    Write-Die "Classpath file was not generated: $CpFile"
  }

  $WindowsDepsCp = (Get-Content -Raw $CpFile)
  $LinuxDepsCp = Convert-WindowsClasspathToLinux -WindowsCp $WindowsDepsCp -RepoRootWindows $RepoRoot -M2RepoWindows $M2

  # Add the module's compiled classes.
  $LinuxModuleClasses = "/work/$($Module -replace '\\','/')/target/classes"
  if ([string]::IsNullOrWhiteSpace($LinuxDepsCp)) {
    $LinuxClasspath = $LinuxModuleClasses
  } else {
    $LinuxClasspath = "${LinuxModuleClasses}:${LinuxDepsCp}"
  }

  $entries = ($LinuxClasspath -split ':').Count
  Write-Host "Computed Linux classpath entries: $entries"
}

Write-Host "Running OpenJML ($Mode) on $Target" 

# Run OpenJML in a Linux container and mount this repo at /work.
# If -Module was provided, also mount the local Maven repository and pass a translated classpath.
$DockerArgs = @(
  "run", "--rm",
  "-v", "${RepoRoot}:/work",
  "-w", "/work"
)

if (-not [string]::IsNullOrWhiteSpace($Module)) {
  $DockerArgs += @("-v", "${M2}:/m2:ro")
}

if ([string]::IsNullOrWhiteSpace($LinuxClasspath)) {
  if ([string]::IsNullOrWhiteSpace($LinuxSpecPath)) {
    docker @DockerArgs $Image $Mode "/work/$TargetUnix"
  } else {
    docker @DockerArgs $Image $Mode "-specspath" $LinuxSpecPath "/work/$TargetUnix"
  }
} else {
  if ([string]::IsNullOrWhiteSpace($LinuxSpecPath)) {
    docker @DockerArgs $Image $Mode "-classpath" $LinuxClasspath "/work/$TargetUnix"
  } else {
    docker @DockerArgs $Image $Mode "-specspath" $LinuxSpecPath "-classpath" $LinuxClasspath "/work/$TargetUnix"
  }
}

if ($LASTEXITCODE -eq 0) {
  Write-Host "OpenJML OK"
} else {
  Write-Host "OpenJML FAILED ($LASTEXITCODE)"
  exit $LASTEXITCODE
}
