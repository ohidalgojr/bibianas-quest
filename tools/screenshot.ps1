# Tira um print de uma cena do jogo COM janela (o headless não desenha).
# Uso: powershell -ExecutionPolicy Bypass -File tools\screenshot.ps1 -Scene res://game/presentation/stage/proof_scene.tscn -Out docs\tasks\prints\TASK-035-prova.png
param(
	[string]$Scene = "res://game/presentation/stage/proof_scene.tscn",
	[string]$Out = "docs\tasks\prints\print.png",
	[int]$Frames = 90,
	[string[]]$Extra = @()
)
$godot = $env:GODOT_BIN
if (-not $godot) { Write-Error "Defina GODOT_BIN (o executável *_console.exe)."; exit 1 }
$root = Split-Path -Parent $PSScriptRoot
$outAbs = Join-Path $root $Out
New-Item -ItemType Directory -Force (Split-Path -Parent $outAbs) | Out-Null
& $godot --path $root -s tools/screenshot.gd -- "cena=$Scene" "saida=$outAbs" "quadros=$Frames" @Extra
exit $LASTEXITCODE
