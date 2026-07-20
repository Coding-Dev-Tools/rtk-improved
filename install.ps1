param(
    [switch]$Help,
    [switch]$Quiet,
    [switch]$NoRtk,
    [string]$Agent
)

$ErrorActionPreference = "Stop"

$repoRaw = "https://raw.githubusercontent.com/Coding-Dev-Tools/rtk-improved/main"
$rtkApiLatest = "https://api.github.com/repos/rtk-ai/rtk/releases/latest"

if ($Help) {
    Write-Output @"
RTK Improved — Universal Multi-Agent Installer (Windows)

Installs RTK token optimization instructions for your AI coding agent, and (if it
is missing) the RTK binary itself.

Usage:
  .\install.ps1                  Auto-detect your agent and install
  .\install.ps1 -Agent <name>    Install for a specific agent
  .\install.ps1 -Quiet           Silent install (no prompts; auto-installs RTK)
  .\install.ps1 -NoRtk           Do not install the RTK binary, only the instructions
  iwr <raw>/install.ps1 | iex    Install directly from the web

Supported agents: command-code, claude-code, copilot, cursor, gemini, codex,
  cline, windsurf, kilocode, antigravity, opencode, hermes, pi

What it does:
  1. Installs the RTK binary from its latest GitHub release if rtk is missing
  2. Installs agent-specific awareness docs to the correct config directory
  3. For Command Code: AGENTS.md + references\ to ~\.commandcode\

Requires:
  - PowerShell 5.1 or later
"@
    return
}

# --- Helpers ---
function Write-Step($msg) { Write-Host "  => $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  [!!] $msg" -ForegroundColor Yellow }
function Write-Fail($msg) { Write-Host "  [FAIL] $msg" -ForegroundColor Red; exit 1 }

$agentsDir = "$env:USERPROFILE\.commandcode"

function Install-Rtk {
    Write-Step "Installing the RTK binary (latest Windows release)..."
    try {
        $rel = Invoke-RestMethod -Uri $rtkApiLatest -UseBasicParsing -Headers @{ "User-Agent" = "rtk-command-code-installer" }
        $arch = if ($env:PROCESSOR_ARCHITECTURE -match "ARM64") { "aarch64|arm64" } else { "x86_64|amd64|x64" }
        $asset = $rel.assets |
            Where-Object { $_.name -match "windows" -and $_.name -match "\.zip$" -and $_.name -match $arch } |
            Select-Object -First 1
        if (-not $asset) {
            $asset = $rel.assets |
                Where-Object { $_.name -match "windows" -and $_.name -match "\.zip$" } |
                Select-Object -First 1
        }
        if (-not $asset) { throw "No Windows .zip asset found in the latest RTK release." }

        $binDir = Join-Path $agentsDir "bin"
        New-Item -ItemType Directory -Path $binDir -Force | Out-Null
        $zipPath = Join-Path $env:TEMP $asset.name
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -UseBasicParsing
        Expand-Archive -Path $zipPath -DestinationPath $binDir -Force
        Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

        $exe = Get-ChildItem -Path $binDir -Recurse -Filter "rtk.exe" | Select-Object -First 1
        if (-not $exe) { throw "rtk.exe was not found after extraction." }
        if ($exe.DirectoryName -ne $binDir) {
            Copy-Item $exe.FullName (Join-Path $binDir "rtk.exe") -Force
        }

        # Add to the user PATH (persistent) and the current session.
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if (($userPath -split ';') -notcontains $binDir) {
            [Environment]::SetEnvironmentVariable("Path", "$userPath;$binDir", "User")
        }
        $env:Path = "$env:Path;$binDir"
        Write-Ok "RTK installed to $binDir (added to your PATH)"
    } catch {
        Write-Warn "Could not auto-install RTK: $($_.Exception.Message)"
        Write-Warn "Install manually: https://github.com/rtk-ai/rtk/releases"
    }
}

# --- Step 1: Check prerequisites ---
Write-Step "Checking prerequisites..."

$hasCmd = $null -ne (Get-Command "cmd", "cmdc", "command-code" -ErrorAction SilentlyContinue)
if ($hasCmd) {
    Write-Ok "Command Code CLI found"
} else {
    Write-Warn "Command Code CLI not found in PATH."
    Write-Warn "Install it first: npm install -g command-code"
}

$hasRtk = $null -ne (Get-Command "rtk" -ErrorAction SilentlyContinue)
if ($hasRtk) {
    $v = & rtk --version
    Write-Ok "RTK found: $v"
} elseif ($NoRtk) {
    Write-Warn "RTK not found (-NoRtk set). Install later: https://github.com/rtk-ai/rtk#installation"
} else {
    Write-Warn "RTK not found in PATH."
    $doInstall = $true
    if (-not $Quiet) {
        $reply = Read-Host "Install RTK now? (Y/n)"
        if ($reply -eq "n" -or $reply -eq "N") { $doInstall = $false }
    }
    if ($doInstall) {
        Install-Rtk
    } else {
        Write-Warn "Skipped RTK install. Install later: https://github.com/rtk-ai/rtk#installation"
    }
}

# --- Step 2: Determine source paths (null when piped via `iwr | iex`) ---
$scriptDir = $null
if ($MyInvocation.MyCommand.Path) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}

$refDir = Join-Path $agentsDir "references"
New-Item -ItemType Directory -Path $refDir -Force | Out-Null

$agentsDest    = Join-Path $agentsDir "AGENTS.md"
$commandsDest  = Join-Path $refDir "commands.md"
$analyticsDest = Join-Path $refDir "analytics.md"

function Get-RemoteFile($rel, $dest) {
    Invoke-WebRequest -Uri "$repoRaw/$rel" -OutFile $dest -UseBasicParsing
}

# --- Step 3: Install AGENTS.md + references ---
$localAgents = if ($scriptDir) { Join-Path $scriptDir "AGENTS.md" } else { $null }
if ($localAgents -and (Test-Path $localAgents)) {
    Write-Step "Installing instructions from local files..."
    Copy-Item $localAgents $agentsDest -Force
    Copy-Item (Join-Path $scriptDir "references\commands.md")  $commandsDest  -Force
    Copy-Item (Join-Path $scriptDir "references\analytics.md") $analyticsDest -Force
} else {
    Write-Step "Downloading instructions from GitHub..."
    Get-RemoteFile "agents/command-code/AGENTS.md"    $agentsDest
    Get-RemoteFile "agents/command-code/commands.md"  $commandsDest
    Get-RemoteFile "agents/command-code/analytics.md" $analyticsDest
}

# --- Step 4: Verify ---
Write-Step "Verifying installation..."
foreach ($f in @($agentsDest, $commandsDest, $analyticsDest)) {
    if (-not (Test-Path $f) -or (Get-Item $f).Length -eq 0) {
        Write-Fail "Missing or empty after install: $f"
    }
}
$testContent = Get-Content $agentsDest -Raw
if ($testContent -match "RTK") {
    Write-Ok "Installed AGENTS.md + references\ to $agentsDir"
} else {
    Write-Fail "AGENTS.md does not contain RTK instructions"
}

# --- Done ---
Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  RTK instructions installed for $(if ($Agent) { $Agent } else { "your agent" })."
Write-Host "  Restart any active agent sessions to apply."
Write-Host ""
Write-Host "  Verify: rtk gain"
Write-Host ""
