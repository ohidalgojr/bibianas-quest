# Liga os hooks de git do projeto (.githooks): formato da mensagem de commit e testes
# verdes antes do commit. Rode uma vez por clone ou worktree.
# Uso: powershell -ExecutionPolicy Bypass -File tools\setup_hooks.ps1
# Para desligar: git config --unset core.hooksPath
# (Somente ASCII neste arquivo: o Windows PowerShell 5.1 le UTF-8 sem BOM como ANSI.)
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
Push-Location $Root
try {
    git config core.hooksPath .githooks
    Write-Host 'Hooks ligados: core.hooksPath = .githooks'
    Write-Host 'commit-msg confere TASK-NNN: resumo (ADR-XXXX); pre-commit roda a suite.'
} finally {
    Pop-Location
}
