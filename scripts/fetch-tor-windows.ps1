# Fetches the Tor Expert Bundle for Windows into app/windows/tor, where the
# Windows build picks it up (it is not kept in the repository).
#
#   powershell -ExecutionPolicy Bypass -File scripts\fetch-tor-windows.ps1
#
# The SHA-256 below is taken from sha256sums-signed-build.txt of that Tor
# Browser release, whose signature was checked against the Tor Browser
# Developers key, EF6E 286D DA85 EA2A 4BA7 DE68 4E2C 6E87 9329 8290.
# When updating, check that signature again and change both lines together.
$ErrorActionPreference = 'Stop'
$version = '16.0'
$sha256 = '2ee123e9167318a3742778ff704e75f01d4780f05a14522d451fe011011077c4'

$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root 'app\windows\tor'
$name = "tor-expert-bundle-windows-x86_64-$version.tar.gz"
$tmp = Join-Path ([IO.Path]::GetTempPath()) $name

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest "https://dist.torproject.org/torbrowser/$version/$name" -OutFile $tmp
$got = (Get-FileHash $tmp -Algorithm SHA256).Hash.ToLower()
if ($got -ne $sha256) {
  Remove-Item $tmp
  throw "checksum mismatch for ${name}: $got"
}

if (Test-Path $out) { Remove-Item -Recurse -Force $out }
New-Item -ItemType Directory -Force $out | Out-Null
# Windows' own tar: a tar from Git or MSYS reads "C:" as a remote host
& (Join-Path $env:SystemRoot 'System32\tar.exe') -xzf $tmp -C $out
Remove-Item $tmp
# only what Kilit runs: tor, lyrebird (obfs4, webtunnel, snowflake), geoip
Remove-Item -Recurse -Force (Join-Path $out 'docs')
Remove-Item -Force (Join-Path $out 'tor\tor-gencert.exe')
Remove-Item -Force (Join-Path $out 'tor\pluggable_transports\conjure-client.exe')
Remove-Item -Force (Join-Path $out 'tor\pluggable_transports\README.CONJURE.md')
"Tor $version in $out"
