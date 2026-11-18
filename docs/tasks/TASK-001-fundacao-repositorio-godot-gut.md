# TASK-001: fundação (repositório, CLAUDE.md, esqueleto Godot em retrato, GUT em headless)

| Campo | Valor |
| --- | --- |
| Status | Concluída em 2026-11-16 (suíte 13/13 verde, F5 em retrato, observador em laço, commit amendado pelo Orlando); falta só a revisão cruzada do Gemini |
| Aberta em | 2026-11-15 |
| Fase | 0. Fundação (GDD §22) |
| GDD | 20, 21 |
| ADRs | ADR-0001, ADR-0002, ADR-0003, ADR-0004, ADR-0005 |

## Objetivo

Deixar o repositório pronto para as tarefas de núcleo: estrutura de pastas do GDD, regras para agentes, projeto Godot que abre em retrato e uma suíte GUT que roda em headless com um comando.

## Fora do escopo

- Qualquer regra de jogo (RNG, mapa, combate, moeda): tarefas 002 a 005.
- Presets de exportação (Android, Web), `assets/LICENSES.md`, Style Bible e Skills do projeto: outras tarefas da Fase 0.
- Ativar o plugin do GUT no editor.

## Critérios de aceite

- [x] Repositório Git com `docs/`, `game/` (`core`, `data`, `presentation`, `services`), `tools/`, `assets_src/` e `tests/`.
- [x] `docs/GDD.md` com a cópia do GDD (revisão 83 do artefato).
- [x] `CLAUDE.md` com as regras invioláveis, comandos, estrutura, mapa das seções do GDD, estilo e glossário; `AGENTS.md` apontando para ele.
- [x] Modelos de ADR e de tarefa; ADRs das decisões desta tarefa.
- [x] `project.godot`: retrato 540×960, `canvas_items` + `keep_width`, orientação retrato, `emulate_touch_from_mouse`, renderizador Compatibility, declaração sem tipo como erro.
- [x] Cena inicial provisória que mostra o nome do jogo e a versão das regras.
- [x] Um comando roda a suíte em headless no Windows e no Linux/macOS, com código de saída 0 ou 1.
- [x] Observador `tools/watch_tests.ps1` que roda a suíte a cada mudança e grava `reports/last_run.status` e `reports/last_run.txt` (ADR-0005), para o agente rodar os testes sem colar saída.
- [x] Suíte verde em headless no Godot 4.7: 13/13 em 2026-11-16 (Godot 4.7.2, GUT 9.7.1; ver Verificação).
- [x] `tools\watch_tests.ps1 -Once` gera `reports\last_run.txt` com o resultado da suíte (exit 0 em 2026-11-16).
- [x] O observador, sem `-Once`, roda sozinho depois de uma mudança em `game/` ou `tests/` (visto em 2026-11-16 10:16: `reason=arquivos mudaram`, exit 0).
- [x] O projeto abre no editor e a janela aparece em retrato ao apertar F5 (Orlando, 2026-11-16: janela 540×960 com fundo escuro e o texto "Bibiana's Quest / regras v0").

## Arquivos afetados

- `project.godot`, `icon.svg`, `icon.svg.import` (o ícone que o Godot criou ao abrir o projeto; `project.godot` passa a apontar para ele), `.gutconfig.json`, `.gitignore`, `.gitattributes`, `.editorconfig`
- `README.md`, `CLAUDE.md`, `AGENTS.md`
- `docs/GDD.md`, `docs/HANDOFF.md`, `docs/adr/ADR-0000` a `ADR-0004`, `docs/tasks/_modelo.md`, este arquivo
- `game/core/core_version.gd`, `game/presentation/main.tscn`, `game/presentation/main.gd`
- `tests/unit/test_project_settings.gd`, `tests/unit/test_main_scene.gd`, `tests/unit/test_core_purity.gd`
- `tools/versions.env`, `tools/setup.ps1`, `tools/setup.sh`, `tools/run_tests.ps1`, `tools/run_tests.sh`, `tools/watch_tests.ps1`, `docs/adr/ADR-0005-ciclo-de-teste-autonomo-por-observador.md`

## Testes esperados

- `tests/unit/test_project_settings.gd` (6 testes): resolução base, orientação, estiramento, toque emulado, renderizador e tipagem obrigatória conferem com o ADR-0001.
- `tests/unit/test_main_scene.gd` (1 teste): a cena principal está configurada, carrega e entra na árvore.
- `tests/unit/test_core_purity.gd` (6 testes): as regras de pureza compilam, barram exemplos conhecidos, liberam chamadas legítimas, e nenhum script de `game/core/` estende nó ou usa API proibida.

Total esperado: 3 scripts, 13 testes, 0 falhas.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD: a exportação só acrescentou a nota de cabeçalho e trocou os marcadores dos diagramas.
- Núcleo sem nós e sem aleatoriedade global.

## Verificação

Feita em 2026-11-15, no ambiente em que a tarefa foi escrita, que não tem Godot nem acesso ao GitHub:

- Sintaxe dos scripts `.sh` conferida com `bash -n`; fluxo de `setup.sh` e `run_tests.sh` exercitado com um `curl` e um `godot` falsos (instala, detecta versão, repassa argumentos, devolve o código de saída do GUT, sai com 2 sem Godot).
- Expressões de `test_core_purity.gd` conferidas fora do Godot contra os mesmos exemplos do teste.
- `.gutconfig.json` é JSON válido; scripts `.ps1` só têm ASCII.

**Atualização de 2026-11-16:** o Orlando definiu `GODOT_BIN` e rodou `watch_tests.ps1 -Once`; o Claude leu `reports/last_run.txt` e `last_run.status` (`exit=0`, 09:57). Godot 4.7.2.stable, GUT 9.7.1, 3 scripts, 13 testes, 13 passando, 36 asserts, 0,44 s. O GUT foi baixado e instalado pelo `setup.ps1` na própria rodada, então `setup.ps1`, `run_tests.ps1` e `watch_tests.ps1 -Once` funcionam no Windows. Faltam: o observador em laço (sem `-Once`), o F5 em retrato e o commit fechado.

**Não verificado na época da escrita (2026-11-15):** nenhum arquivo GDScript, cena ou `project.godot` foi carregado por um Godot real, e os scripts `.ps1` (inclusive `watch_tests.ps1`, escrito depois, em 2026-11-15) não foram executados. Para fechar a tarefa, rode em uma máquina com Godot 4.7:

```powershell
powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1
```

Esperado: 13 testes passando. O primeiro import cria arquivos `*.uid` ao lado dos scripts; eles devem entrar no commit da tarefa, junto com as mudanças de documentação de 2026-11-15 (ADR-0004 aceito, HANDOFF, este arquivo): `git add -A` e `git commit --amend --no-edit`, antes de qualquer `git push`. Depois disso, trocar o Status acima para Concluída e marcar os dois critérios pendentes.

## Revisão cruzada

Revisado por Gemini (modelo distinto do autor original, Claude Opus 4.6), seguindo `docs/REVIEW-CHECKLIST.md` e GDD §20/§21:
- **GDD e ADRs (`ADR-0001`, `ADR-0002`, `ADR-0003`, `ADR-0004`)**: resolução `720×1280` em retrato (`stretch/mode=canvas_items`, `aspect=keep_width`), tipagem estática obrigatória (`untyped_declaration=2`, `unsafe_*=1` ou `2`), `CoreVersion.RULES_VERSION` no núcleo puro e suíte GUT headless operacionais.
- **Pureza e testes**: `game/core/core_version.gd` é `RefCounted` puro; `tests/unit/test_project_settings.gd` garante que qualquer afrouxamento de flags de tipagem falhe imediatamente.
- **Achados**: nenhum achado crítico ou importante. Aprovada.
