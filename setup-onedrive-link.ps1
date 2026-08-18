# Run once per Windows device, after OneDrive has finished syncing this
# folder locally (cross_device_configs\neovim). Creates the directory
# junction Neovim actually reads its config from - %LOCALAPPDATA%\nvim -
# pointing at this folder, so no other Neovim-side setup is needed.
#
# Junctions (not symlinks) because they work without admin rights or
# Developer Mode. Safe to re-run: no-ops if already linked correctly here.

$target = $PSScriptRoot
$linkPath = Join-Path $env:LOCALAPPDATA "nvim"

if (Test-Path $linkPath) {
	$existing = Get-Item $linkPath -Force
	if ($existing.LinkType -eq "Junction" -and $existing.Target -eq $target) {
		Write-Host "Already linked: $linkPath -> $target"
		exit 0
	}
	Write-Error "$linkPath already exists and isn't a junction pointing here. Move or remove it first, then re-run this script."
	exit 1
}

New-Item -ItemType Junction -Path $linkPath -Target $target | Out-Null
Write-Host "Linked: $linkPath -> $target"
Write-Host "Note: plugins/Mason tools still install locally per device (nvim-data is not synced) - launch Neovim once to let lazy.nvim bootstrap them."
