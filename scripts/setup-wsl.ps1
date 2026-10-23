# Kilit: step 1 of the build environment, on Windows.
# Installs WSL2 with Ubuntu 24.04. Run in an elevated PowerShell:
#   powershell -ExecutionPolicy Bypass -File scripts\setup-wsl.ps1
# Windows asks for a restart afterwards. After the restart, open "Ubuntu 24.04"
# from the Start menu once to create the Linux user, then run
# scripts/setup-dev.sh inside it.

$ErrorActionPreference = 'Stop'

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) {
    Write-Error 'Run this from an elevated PowerShell (Run as administrator).'
}

$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
if (-not $cpu.VirtualizationFirmwareEnabled) {
    Write-Error 'Virtualization is off in the firmware (BIOS/UEFI). Turn on Intel VT-x or AMD-V first.'
}

wsl --install -d Ubuntu-24.04 --no-launch
wsl --set-default-version 2

Write-Host ''
Write-Host 'Done. Restart Windows, open "Ubuntu 24.04" once to create your Linux user,'
Write-Host 'then inside Ubuntu run:  bash scripts/setup-dev.sh'
