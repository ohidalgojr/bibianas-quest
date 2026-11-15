# Roda a suite GUT em modo headless com um comando.
# Uso: powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1
# Argumentos extras sao repassados ao GUT.
# O Godot vem de $env:GODOT_BIN ou do PATH (godot, godot4).
# Codigo de saida: 0 = suite verde, 1 = falha em teste, 2 = ambiente incompleto.
# (Somente ASCII neste arquivo: o Windows PowerShell 5.1 le UTF-8 sem BOM como ANSI.)
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$Versions = @{}
foreach ($line in Get-Content (Join-Path $PSScriptRoot 'versions.env')) {
    if ($line -match '^\s*([A-Z_]+)=(.+)$') { $Versions[$Matches[1]] = $Matches[2].Trim() }
}
$GodotMinor = $Versions['GODOT_MINOR']
$GutVersion = $Versions['GUT_VERSION']

$Godot = $env:GODOT_BIN
if (-not $Godot) {
    foreach ($name in 'godot', 'godot4') {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) { $Godot = $cmd.Source; break }
    }
}
if (-not $Godot) {
    Write-Host "ERRO: Godot nao encontrado. Instale o Godot $GodotMinor e defina GODOT_BIN com o caminho do executavel (o *_console.exe)."
    exit 2
}
# No Windows, so o executavel *_console.exe escreve no terminal e devolve codigo de saida.
if ($Godot -match '\.exe$' -and $Godot -notmatch '_console\.exe$') {
    $console = $Godot -replace '\.exe$', '_console.exe'
    if (Test-Path $console) { $Godot = $console }
}

& (Join-Path $PSScriptRoot 'setup.ps1')

# A partir daqui o Godot escreve avisos em stderr; isso nao pode abortar o script.
$ErrorActionPreference = 'Continue'

$Version = (& $Godot --version | Select-Object -First 1)
if (-not $Version) {
    Write-Host "AVISO: nao consegui ler a versao do Godot. Aponte GODOT_BIN para o *_console.exe."
}
elseif (-not "$Version".StartsWith("$GodotMinor.")) {
    Write-Host "AVISO: Godot $Version em uso; o projeto fixa $GodotMinor.x (tools/versions.env)."
}

# O import gera .godot/ e registra os class_name; sem ele o GUT nao acha as classes.
Write-Host '== Importando o projeto =='
& $Godot --headless --path $Root --import | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "AVISO: o import terminou com codigo $LASTEXITCODE."
}

Write-Host "== Rodando os testes (GUT $GutVersion, Godot $Version) =="
& $Godot --headless --path $Root -s addons/gut/gut_cmdln.gd -gexit @args
exit $LASTEXITCODE
