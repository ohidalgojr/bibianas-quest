# Exporta o preset Web para build\web (TASK-014, ADR-0019). Precisa dos templates de
# exportacao do Godot (Editor > Gerenciar templates de exportacao) e de GODOT_BIN.
# Uso: powershell -ExecutionPolicy Bypass -File tools\export_web.ps1 [-Serve]
# -Serve abre um servidor local em http://localhost:8060 (o Web nao abre por file://).
# (Somente ASCII neste arquivo: o Windows PowerShell 5.1 le UTF-8 sem BOM como ANSI.)
param([switch]$Serve)
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$Godot = $env:GODOT_BIN
if (-not $Godot) { throw 'Defina GODOT_BIN (use o executavel *_console.exe).' }
$Out = Join-Path $Root 'build\web'
New-Item -ItemType Directory -Force -Path $Out | Out-Null

& $Godot --headless --path $Root --import
& $Godot --headless --path $Root --export-release 'Web' (Join-Path $Out 'index.html')
if ($LASTEXITCODE -ne 0) { throw 'Falha na exportacao. Os templates de exportacao estao instalados?' }
Write-Host "Exportado em $Out"

if ($Serve) {
    Write-Host 'Servindo em http://localhost:8060 (Ctrl+C para parar).'
    python -m http.server 8060 --directory $Out
}
