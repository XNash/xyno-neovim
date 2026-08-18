#Requires -Version 5.1
<#
Full autonomous bootstrap for this Neovim config on a Windows device - clean
machine or one with an existing config to replace. Designed to be runnable
before ANYTHING else is installed and before OneDrive has necessarily
finished syncing, straight from GitHub (so it doesn't depend on the very
OneDrive sync it waits for):

    irm https://raw.githubusercontent.com/XNash/xyno-neovim/master/bootstrap-device.ps1 | iex

Must run elevated (installs software system-wide via winget, edits PATH).
Every step is idempotent and skips work already done, so it's safe to
re-run - including after a partial failure.

Two things this script deliberately does NOT automate, because they're
credential/GUI flows: signing in to OneDrive, and `claude auth login`. It
checks for both and tells you exactly what to do.
#>

$ErrorActionPreference = "Stop"
$report = [System.Collections.Generic.List[string]]::new()
function Log($msg) { Write-Host $msg -ForegroundColor Cyan }
function Ok($msg) { Write-Host "  OK: $msg" -ForegroundColor Green; $report.Add("[done]   $msg") }
function Skip($msg) { Write-Host "  skip: $msg (already present)" -ForegroundColor DarkGray; $report.Add("[skip]   $msg") }
function Fail($msg, $errText) { Write-Host "  FAILED: $msg - $errText" -ForegroundColor Red; $report.Add("[FAILED] $msg - $errText") }
function Manual($msg) { Write-Host "  MANUAL STEP NEEDED: $msg" -ForegroundColor Yellow; $report.Add("[manual] $msg") }

function Update-SessionPath {
	$machine = [Environment]::GetEnvironmentVariable("PATH", "Machine")
	$user = [Environment]::GetEnvironmentVariable("PATH", "User")
	$env:PATH = "$machine;$user"
}

# --- 1. Elevation check -------------------------------------------------------
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Host "This installs software and edits system PATH - re-run from an elevated (Run as Administrator) PowerShell." -ForegroundColor Red
	exit 1
}

# --- 2. winget itself ----------------------------------------------------------
Log "`nChecking winget..."
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
	Log "winget not found - installing Microsoft.DesktopAppInstaller..."
	try {
		$out = Join-Path $env:TEMP "DesktopAppInstaller.msixbundle"
		Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile $out -UseBasicParsing
		Add-AppxPackage -Path $out
		Update-SessionPath
		Ok "winget (Microsoft.DesktopAppInstaller)"
	} catch {
		Fail "winget install" $_.Exception.Message
		Write-Host "Can't continue without winget - install 'App Installer' from the Microsoft Store manually, then re-run this script." -ForegroundColor Red
		exit 1
	}
} else {
	Skip "winget"
}

# --- 3. OneDrive present & signed in --------------------------------------------
Log "`nChecking OneDrive..."
if (-not $env:OneDrive) {
	Manual "OneDrive isn't set up on this account. Install/sign in to OneDrive (Start > OneDrive), let its initial sync finish, then re-run this script."
	exit 1
}
Ok "OneDrive detected at $env:OneDrive"

# --- 4. Wait for the config folder to sync ---------------------------------------
$target = Join-Path $env:OneDrive "cross_device_configs\neovim"
Log "`nWaiting for '$target' to sync (up to 10 minutes)..."
$deadline = (Get-Date).AddMinutes(10)
$synced = $false
while (-not $synced) {
	if (Test-Path (Join-Path $target "init.lua")) { $synced = $true; break }
	if ((Get-Date) -gt $deadline) {
		Manual "Timed out waiting for OneDrive to sync $target. Make sure OneDrive is running and has finished syncing, then re-run this script."
		exit 1
	}
	Start-Sleep -Seconds 5
}
Ok "Config folder synced: $target"

# --- 5. Link (or replace) the local config, with confirmation -------------------
Log "`nChecking for an existing local Neovim config..."
$linkPath = Join-Path $env:LOCALAPPDATA "nvim"
try {
	if (Test-Path $linkPath) {
		$existing = Get-Item $linkPath -Force
		if ($existing.LinkType -eq "Junction" -and $existing.Target -eq $target) {
			Skip "link at $linkPath"
		} else {
			Write-Host "`nAn existing Neovim config was found at $linkPath." -ForegroundColor Yellow
			$choice = Read-Host "Back it up and replace it with the synced config? [y/N]"
			if ($choice -notmatch '^[Yy]') {
				Write-Host "Aborted - nothing was changed." -ForegroundColor Yellow
				exit 0
			}
			if ($existing.LinkType) {
				# stale junction/symlink pointing elsewhere - no real data to lose
				Remove-Item $linkPath -Force
				Ok "removed stale link at $linkPath"
			} else {
				$backup = "$linkPath.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
				Move-Item $linkPath $backup
				Ok "backed up existing config to $backup"
			}
			New-Item -ItemType Junction -Path $linkPath -Target $target | Out-Null
			Ok "linked $linkPath -> $target"
		}
	} else {
		New-Item -ItemType Junction -Path $linkPath -Target $target | Out-Null
		Ok "linked $linkPath -> $target"
	}
} catch {
	Fail "linking config" "$($_.Exception.Message) - if this says the folder is in use, close any open Neovim windows/terminals in it and re-run"
}

# --- 6. Required tools via winget ------------------------------------------------
function Install-WingetTool($displayName, $wingetId, $checkCmd) {
	Log "`nChecking $displayName..."
	if (Get-Command $checkCmd -ErrorAction SilentlyContinue) {
		Skip $displayName
		return
	}
	for ($attempt = 1; $attempt -le 2; $attempt++) {
		try {
			winget install --id $wingetId -e --silent --accept-package-agreements --accept-source-agreements
			if ($LASTEXITCODE -eq 0) { Ok $displayName; return }
			throw "winget exited with code $LASTEXITCODE"
		} catch {
			if ($attempt -eq 2) { Fail $displayName $_.Exception.Message }
			else { Start-Sleep -Seconds 5 }
		}
	}
}

Install-WingetTool "Git" "Git.Git" "git"
Install-WingetTool "ripgrep" "BurntSushi.ripgrep.MSVC" "rg"
Install-WingetTool "Node.js" "OpenJS.NodeJS.LTS" "node"
Install-WingetTool "Rustup (Rust toolchain)" "Rustlang.Rustup" "rustup"
Install-WingetTool "GCC (WinLibs MinGW, C compiler for Treesitter parsers)" "BrechtSanders.WinLibs.POSIX.UCRT" "gcc"
Install-WingetTool "Neovim" "Neovim.Neovim" "nvim"
Install-WingetTool "Claude Code CLI" "Anthropic.ClaudeCode" "claude"
Update-SessionPath

# --- 7. Flutter SDK (no winget package exists for it) ----------------------------
Log "`nChecking Flutter SDK..."
if (Get-Command flutter -ErrorAction SilentlyContinue) {
	Skip "Flutter SDK"
} else {
	try {
		Log "Fetching Flutter's release manifest..."
		$manifest = Invoke-RestMethod -Uri "https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json"
		$stableHash = $manifest.current_release.stable
		$release = $manifest.releases | Where-Object { $_.hash -eq $stableHash } | Select-Object -First 1
		$archiveUrl = "https://storage.googleapis.com/flutter_infra_release/releases/$($release.archive)"
		$zipPath = Join-Path $env:TEMP "flutter_sdk.zip"
		Log "Downloading Flutter SDK $($release.version)..."
		Invoke-WebRequest -Uri $archiveUrl -OutFile $zipPath -UseBasicParsing
		if ((Get-Item $zipPath).Length -lt 1MB) { throw "downloaded archive looks too small/corrupt" }
		$extractDir = Join-Path $env:TEMP "flutter_extract"
		if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
		Log "Extracting..."
		Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force
		if (Test-Path "C:\flutter-sdk") { Remove-Item "C:\flutter-sdk" -Recurse -Force }
		Move-Item (Join-Path $extractDir "flutter") "C:\flutter-sdk"
		Remove-Item $zipPath -Force
		Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
		Ok "Flutter SDK $($release.version) -> C:\flutter-sdk"
	} catch {
		Fail "Flutter SDK" $_.Exception.Message
	}
}

# --- 8. PATH fixups (entries not registered automatically by their installers) ---
Log "`nEnsuring PATH entries..."
function Add-UserPathEntry($dir) {
	if (-not $dir -or -not (Test-Path $dir)) { return }
	$current = [Environment]::GetEnvironmentVariable("PATH", "User")
	if (($current -split ";") -notcontains $dir) {
		[Environment]::SetEnvironmentVariable("PATH", "$current;$dir", "User")
		Ok "added to PATH: $dir"
	} else {
		Skip "PATH entry $dir"
	}
}

Add-UserPathEntry (Join-Path $env:USERPROFILE ".cargo\bin")
$mingwBin = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Directory -Filter "BrechtSanders.WinLibs*" -ErrorAction SilentlyContinue |
	ForEach-Object { Join-Path $_.FullName "mingw64\bin" } | Where-Object { Test-Path $_ } | Select-Object -First 1
Add-UserPathEntry $mingwBin
Add-UserPathEntry "C:\flutter-sdk\bin"
Update-SessionPath

# --- 9. Local plugin clones -------------------------------------------------------
function Clone-IfMissing($displayName, $repoUrl, $destPath, $branch) {
	Log "`nChecking $displayName..."
	if (Test-Path (Join-Path $destPath ".git")) {
		Skip $displayName
		return
	}
	try {
		New-Item -ItemType Directory -Force -Path (Split-Path $destPath -Parent) | Out-Null
		if ($branch) { git clone --branch $branch $repoUrl $destPath }
		else { git clone $repoUrl $destPath }
		if ($LASTEXITCODE -ne 0) { throw "git clone exited with code $LASTEXITCODE" }
		Ok $displayName
	} catch {
		Fail $displayName $_.Exception.Message
	}
}

Clone-IfMissing "harpoon (harpoon2 branch)" "https://github.com/ThePrimeagen/harpoon" (Join-Path $env:USERPROFILE "personal\harpoon") "harpoon2"
Clone-IfMissing "99" "https://github.com/ThePrimeagen/99" (Join-Path $env:USERPROFILE "personal\99") $null

# --- 10. Bootstrap plugins ---------------------------------------------------------
Log "`nBootstrapping plugins (lazy.nvim sync)..."
try {
	nvim --headless "+Lazy! sync" +qa!
	Ok "plugins synced"
} catch {
	Fail "plugin bootstrap" $_.Exception.Message
	Manual "open Neovim and run :Lazy sync manually"
}

# --- 11. Claude auth reminder (credential flow - not scripted) ---------------------
Log "`nChecking Claude Code authentication..."
if (Get-Command claude -ErrorAction SilentlyContinue) {
	Manual "run 'claude auth login' if this device isn't authenticated yet (not scripted - it's a credential flow)"
}

# --- Summary -------------------------------------------------------------------------
Log "`n==================== Summary ===================="
$report | ForEach-Object { Write-Host $_ }
Write-Host "`nRestart any open terminals so the refreshed PATH takes effect everywhere." -ForegroundColor Cyan
