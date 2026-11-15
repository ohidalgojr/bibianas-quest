# Instala o GUT na versao fixada em tools/versions.env (ADR-0003). Idempotente.
# Uso: powershell -ExecutionPolicy Bypass -File tools\setup.ps1
# (Somente ASCII neste arquivo: o Windows PowerShell 5.1 le UTF-8 sem BOM como ANSI.)
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$Versions = @{}
foreach ($line in Get-Content (Join-Path $PSScriptRoot 'versions.env')) {
    if ($line -match '^\s*([A-Z_]+)=(.+)$') { $Versions[$Matches[1]] = $Matches[2].Trim() }
}
$GutVersion = $Versions['GUT_VERSION']
if (-not $GutVersion) { throw 'GUT_VERSION ausente em tools/versions.env.' }

$Dest = Join-Path $Root 'addons\gut'
$Stamp = Join-Path $Dest '.gut_version'
if ((Test-Path $Stamp) -and ((Get-Content $Stamp -Raw).Trim() -eq $GutVersion)) {
    Write-Host "GUT $GutVersion ja instalado."
    return
}

$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('gut-' + [System.Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $Tmp | Out-Null
try {
    $Zip = Join-Path $Tmp 'gut.zip'
    $Url = "https://github.com/bitwes/Gut/archive/refs/tags/v$GutVersion.zip"
    Write-Host "Baixando GUT $GutVersion..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $Url -OutFile $Zip -UseBasicParsing
    Expand-Archive -Path $Zip -DestinationPath $Tmp -Force

    $Src = $null
    foreach ($dir in Get-ChildItem -Path $Tmp -Directory) {
        $candidate = Join-Path $dir.FullName 'addons\gut'
        if (Test-Path $candidate) { $Src = $candidate; break }
    }
    if (-not $Src) { throw 'addons/gut nao encontrado no pacote baixado.' }

    if (Test-Path $Dest) { Remove-Item $Dest -Recurse -Force }
    New-Item -ItemType Directory -Path (Join-Path $Root 'addons') -Force | Out-Null
    Copy-Item $Src $Dest -Recurse
    Set-Content -Path $Stamp -Value $GutVersion -NoNewline
    Write-Host "GUT $GutVersion instalado em addons\gut."
}
finally {
    Remove-Item $Tmp -Recurse -Force -ErrorAction SilentlyContinue
}
