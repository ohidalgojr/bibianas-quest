# Gera o executavel de teste do jogo para Windows (build de depuracao, atalhos F1 a F4 ligados).
# O arquivo sempre vai para a MESMA pasta, mesmo se voce rodar de uma worktree:
#   <repositorio principal>\build\windows\BibianasQuest.exe
# Uso: powershell -ExecutionPolicy Bypass -File tools\build_windows.ps1 [-Run]
# -Run abre o jogo ao terminar.
# Precisa de GODOT_BIN (o executavel *_console.exe) e dos templates de exportacao 4.7.2
# (ja instalados em %APPDATA%\Godot\export_templates\4.7.2.stable).
# (Somente ASCII neste arquivo: o Windows PowerShell 5.1 le UTF-8 sem BOM como ANSI.)
param([switch]$Run)
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$Godot = $env:GODOT_BIN
if (-not $Godot) { throw 'Defina GODOT_BIN (use o executavel *_console.exe).' }

# Pasta do repositorio principal (a worktree aponta para ele pelo git-common-dir).
$Common = (& git -C $Root rev-parse --path-format=absolute --git-common-dir).Trim()
$Main = Split-Path -Parent $Common
$OutDir = Join-Path $Main 'build\windows'
$Exe = Join-Path $OutDir 'BibianasQuest.exe'
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

& $Godot --headless --path $Root --import | Out-Null
& $Godot --headless --path $Root --export-debug 'Windows' $Exe
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $Exe)) {
    throw 'Falha na exportacao. Os templates 4.7.2 do Windows estao instalados?'
}
$Size = [math]::Round((Get-Item $Exe).Length / 1MB, 1)
Write-Host "Executavel pronto ($Size MB): $Exe"
if ($Run) { Start-Process $Exe }
