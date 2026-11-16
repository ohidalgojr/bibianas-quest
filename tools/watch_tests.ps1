# Observador de testes: roda a suite GUT sempre que o codigo muda e grava o resultado em reports\.
# Uso (deixe a janela aberta; Ctrl+C para parar):
#   powershell -ExecutionPolicy Bypass -File tools\watch_tests.ps1
# Uma rodada so, para conferir se funciona (sai com o codigo da suite):
#   powershell -ExecutionPolicy Bypass -File tools\watch_tests.ps1 -Once
#
# Arquivos gerados (reports\ esta no .gitignore):
#   last_run.status  state=running|done|timeout, started, finished, exit (0 = verde), reason
# Limite de tempo por rodada: -TimeoutMinutes (padrao 8). Ao estourar, o processo e seus filhos
# sao encerrados, a saida parcial vai para last_run.txt e o status fica state=timeout, exit=124.
#   last_run.txt     saida completa do run_tests.ps1
#   watcher.alive    hora da ultima volta do laco (prova que o observador esta vivo)
# Para forcar uma rodada sem mudar codigo, crie um arquivo vazio reports\run_now.
#
# ATENCAO: este script executa, sem pedir confirmacao, os scripts GDScript de game\ e tests\.
# Revise o diff (git diff) depois que o agente gravar arquivos, e feche a janela para parar.
# (Somente ASCII neste arquivo: o Windows PowerShell 5.1 le UTF-8 sem BOM como ANSI.)
param([switch]$Once, [int]$TimeoutMinutes = 8)

$ErrorActionPreference = 'Continue'

$Root = Split-Path -Parent $PSScriptRoot
$Reports = Join-Path $Root 'reports'
$Runner = Join-Path $PSScriptRoot 'run_tests.ps1'
$LogFile = Join-Path $Reports 'last_run.txt'
$OutTmp = Join-Path $Reports 'last_run.out.tmp'
$ErrTmp = Join-Path $Reports 'last_run.err.tmp'
$StatusFile = Join-Path $Reports 'last_run.status'
$AliveFile = Join-Path $Reports 'watcher.alive'
$Trigger = Join-Path $Reports 'run_now'
# So estas extensoes disparam a suite. Ficam de fora .uid, .import e .md, que o Godot e a
# documentacao mudam sem que o codigo mude (senao a suite se dispararia em laco).
$Extensions = @('.gd', '.tscn', '.tres', '.res', '.gdshader', '.json', '.cfg')

New-Item -ItemType Directory -Path $Reports -Force | Out-Null
$GdIgnore = Join-Path $Reports '.gdignore'
if (-not (Test-Path $GdIgnore)) { New-Item -ItemType File -Path $GdIgnore | Out-Null }

function Get-Fingerprint {
    $files = @()
    foreach ($dir in 'game', 'tests') {
        $path = Join-Path $Root $dir
        if (Test-Path $path) {
            $files += @(Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue |
                Where-Object { $Extensions -contains $_.Extension.ToLower() })
        }
    }
    foreach ($name in 'project.godot', '.gutconfig.json') {
        $path = Join-Path $Root $name
        if (Test-Path $path) { $files += @(Get-Item $path) }
    }
    $parts = $files | Sort-Object FullName | ForEach-Object {
        '{0}|{1}|{2}' -f $_.FullName, $_.LastWriteTimeUtc.Ticks, $_.Length
    }
    return ($parts -join ';')
}

function Write-Status([string]$state, [string]$started, [string]$finished, $exitCode, [string]$reason) {
    $text = "state=$state`r`nstarted=$started`r`nfinished=$finished`r`nexit=$exitCode`r`nreason=$reason`r`nlog=reports/last_run.txt`r`n"
    [System.IO.File]::WriteAllText($StatusFile, $text)
}

function Invoke-Suite([string]$reason) {
    $started = Get-Date -Format 'o'
    Write-Status 'running' $started '' '' $reason
    Write-Host "[$started] rodando a suite ($reason)..."
    $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $Runner))
    $process = Start-Process -FilePath 'powershell.exe' -ArgumentList $arguments -NoNewWindow -PassThru `
        -RedirectStandardOutput $OutTmp -RedirectStandardError $ErrTmp
    # Sem -Wait, o ExitCode so fica disponivel se o handle for lido logo no inicio.
    $null = $process.Handle
    $state = 'done'
    if ($process.WaitForExit($TimeoutMinutes * 60 * 1000)) {
        $process.WaitForExit()
        $code = $process.ExitCode
    }
    else {
        # Encerra a arvore inteira (powershell, Godot e uma eventual janela de erro do Godot).
        & taskkill.exe /PID $process.Id /T /F | Out-Null
        Get-Process -Name 'Godot*' -ErrorAction SilentlyContinue | Where-Object { $_.StartTime -ge [datetime]$started } |
            Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        $state = 'timeout'
        $code = 124
        Write-Host "AVISO: a suite passou de $TimeoutMinutes minutos e foi encerrada."
    }
    # Junta saida e erro sem mexer na codificacao dos bytes.
    $stream = [System.IO.File]::Create($LogFile)
    foreach ($part in $OutTmp, $ErrTmp) {
        if (Test-Path $part) {
            $bytes = [System.IO.File]::ReadAllBytes($part)
            $stream.Write($bytes, 0, $bytes.Length)
        }
    }
    $stream.Close()
    $finished = Get-Date -Format 'o'
    Write-Status $state $started $finished $code $reason
    Write-Host "[$finished] terminou com codigo $code. Resultado em reports\last_run.txt"
    return $code
}

if ($Once) {
    exit (Invoke-Suite 'uma vez')
}

Write-Host "Observador de testes ativo (limite de $TimeoutMinutes minutos por rodada). Ctrl+C para parar."
Write-Host "Resultado em: $LogFile"
$last = $null
$retries = 0
while ($true) {
    [System.IO.File]::WriteAllText($AliveFile, (Get-Date -Format 'o'))
    $now = Get-Fingerprint
    $forced = Test-Path $Trigger
    if ($forced -or ($now -ne $last)) {
        if ($forced) { $reason = 'pedido (run_now)' }
        elseif ($null -eq $last) { $reason = 'inicio' }
        else { $reason = 'arquivos mudaram' }
        # Espera a gravacao terminar: so segue quando nada muda por 2 segundos.
        do {
            $previous = $now
            Start-Sleep -Seconds 2
            $now = Get-Fingerprint
        } while ($now -ne $previous)
        if (Test-Path $Trigger) { Remove-Item $Trigger -Force -ErrorAction SilentlyContinue }
        $last = $now
        Invoke-Suite $reason | Out-Null
        # Protecao contra laco: se os arquivos mudarem durante a suite duas vezes seguidas,
        # aceita o estado atual e avisa (use run_now para rodar de novo).
        $after = Get-Fingerprint
        if ($after -ne $last) {
            $retries++
            if ($retries -ge 2) {
                Write-Host 'AVISO: os arquivos mudaram durante a suite duas vezes seguidas; seguindo sem nova rodada. Crie reports\run_now para rodar de novo.'
                $last = $after
                $retries = 0
            }
        }
        else {
            $retries = 0
        }
    }
    Start-Sleep -Seconds 1
}
