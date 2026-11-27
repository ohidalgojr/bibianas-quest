# TASK-076: revisão cruzada das TASK-070 a 073, handoff atualizado e executável Windows

| Campo | Valor |
| --- | --- |
| Status | Em verificação |
| Aberta em | 2026-11-27 |
| Fase | 1, fechamento e revisão (`GDD §21`) |
| GDD | 17, 18, 21 |
| ADRs | ADR-0063 |

## Objetivo

Concluir a revisão cruzada por modelo distinto (`Gemini`) sobre as tarefas `TASK-070` a `TASK-073` (`docs/REVIEW-CHECKLIST.md`), organizar `docs/HANDOFF.md` com tudo o que ainda falta fazer (incluindo as pranchas `walk-v2` e `strike` de `F-025`) e gerar o executável atualizado de teste em Windows (`build/windows/BibianasQuest.exe`).

## Fora do escopo

- Alterar regras de `game/core/` (`RULES_VERSION` permanece `21`) ou código funcional fora do já commitado em `TASK-074` e `TASK-075`.
- Enviar commits ao GitHub (`CLAUDE.md` regra 11).

## Critérios de aceite

- [x] Seções `## Revisão cruzada` preenchidas em `TASK-070`, `TASK-071` (com `## Verificação` completa), `TASK-072` e `TASK-073` usando `docs/REVIEW-CHECKLIST.md`.
- [x] `docs/HANDOFF.md` atualizado com resumo das `TASK-070` a `TASK-076`, fila completa do Gemini e tabela `Decisões` até `ADR-0063`.
- [x] Suíte headless verde (`tools\run_tests.ps1`, incluindo `test_project_standards.gd`) após todas as edições.
- [x] Executável Windows (`build\windows\BibianasQuest.exe`) gerado via `tools\build_windows.ps1`.

## Arquivos afetados

- `docs/tasks/TASK-070-tabuleiro-isometrico-fiel-ao-gdd.md`, `TASK-071-...md`, `TASK-072-...md`, `TASK-073-...md`, `TASK-076-...md`
- `docs/adr/ADR-0063-revisao-cruzada-lote-hd2d.md`
- `docs/HANDOFF.md`

## Testes esperados

- `tests/unit/test_project_standards.gd` e suíte completa em `tools\run_tests.ps1`.

## Regras que esta tarefa não pode quebrar

- Núcleo sem nós e `RULES_VERSION` = 21.
- UTF-8 sem BOM, LF, zero mojibake em todos os `.md`.
- Não fazer `git push` sem pedido explícito.

## Verificação

- Suíte headless (`powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1`, 2026-11-27): `380/380` passando em `52` scripts (`57639` asserts, `29,583s`), incluindo `test_project_standards.gd`.
- Build Windows (`powershell -ExecutionPolicy Bypass -File tools\build_windows.ps1`, 2026-11-27): `C:\Users\Orlando\Downloads\Projetos\bibianas-quest\build\windows\BibianasQuest.exe` gerado com sucesso (`141,7 MB`).
- Encoding UTF-8 sem BOM e fim de linha LF verificados em todos os arquivos `.md` editados.

## Revisão cruzada

Pendente: revisão por outro modelo (GDD §21, etapa 4).
