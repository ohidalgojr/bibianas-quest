# TASK-051: estudo de UI mobile, inimigos dark fantasy e estética de mundo morrendo

| Campo | Valor |
| --- | --- |
| Status | Em verificação (estudo, referências reais e esboços conceituais prontos; aguarda avaliação e decisões do Orlando) |
| Aberta em | 2026-11-19 |
| Fase | 1, revisão visual e de UX mobile pré-TASK-040 |
| GDD | 3, 6, 7, 11, 13, 17, 18, 19 |
| ADRs | ADR-0036 (ADRs futuros após decisões do Orlando) |

## Objetivo

Entregar um documento completo de avaliação em `docs/design/ESTUDO-ui-mobile-inimigos-estetica.md` cobrindo: diagnóstico da UI atual e reformulação amigável ao mobile baseada em referências reais de RPGs, roguelikes e táticos de tabuleiro; esboços e especificações IA-friendly para Blender de 8 inimigos dark fantasy perturbadores inspirados em RPGs 3D da Square Enix / FFT; e pesquisa visual de mundos morrendo para refinar a estética sombria do jogo.

## Fora do escopo

- Alterar código de UI, shaders, modelos 3D ou regras do jogo antes da aprovação do Orlando sobre o quadro de decisões da Parte 6.
- Criar novas fichas finais em `docs/enemies/` ou modificar `game/data/*.json` (isso entra nas tarefas próprias após aprovação).

## Critérios de aceite

- [x] Diagnóstico objetivo da UI atual (prints e código em `game/presentation/`) e estudo comparativo com referências visuais reais de interfaces mobile em `docs/design/refs/ui/`.
- [x] Proposta tela a tela da nova UI mobile (combate com 56–58% de palco livre, mapa tátil, loja/fogueira em bottom-sheet, baú, recompensa, menu inicial e Santuário) com mockup conceitual em retrato e wireframes em `540×960`.
- [x] 8 esboços de inimigos dark fantasy perturbadores inéditos gerados com Nano Banana (`docs/design/refs/inimigos/`), com background, proposta de mecânica (GDD §7) e especificação técnica IA-friendly para reconstrução orgânica no Blender.
- [x] Curadoria de referências visuais de estética dark fantasy "mundo morrendo" (`docs/design/refs/estetica/`), diagnóstico do visual atual e Style Bible 2.0 com parâmetros concretos de paleta, luz e `PostFx`.
- [x] Quadro objetivo de decisões abertas e créditos completos das fontes de referência; `docs/HANDOFF.md` atualizado e suíte de testes verde.

## Arquivos afetados

- `docs/design/ESTUDO-ui-mobile-inimigos-estetica.md`
- `docs/design/refs/ui/*`, `docs/design/refs/inimigos/*`, `docs/design/refs/estetica/*`
- `docs/tasks/TASK-051-estudo-ui-mobile-inimigos-estetica.md`
- `docs/HANDOFF.md`

## Testes esperados

- Suíte headless (`tools\run_tests.ps1`), em especial `tests/unit/test_project_standards.gd` validando a numeração contínua das tarefas (`TASK-051`), seções obrigatórias e `HANDOFF.md`.
- Auditoria de 100% dos links de imagem e integridade UTF-8/LF no estudo.

## Regras que esta tarefa não pode quebrar

- Sem alteração de fórmulas, `RULES_VERSION` ou `game/core/`.
- Prompts do Nano Banana sem citar jogos, personagens ou artistas reais (GDD §18).
- Referências externas mantidas apenas em `docs/design/refs/` (fora dos assets do Godot via `docs/.gdignore`).

## Verificação

- Auditoria de links e encoding em 2026-11-19: `40/40` imagens embutidas em `docs/design/ESTUDO-ui-mobile-inimigos-estetica.md` existem e têm conteúdo válido (`32` arquivos em `docs/design/refs/` + `8` prints em `docs/tasks/prints/`), `0` órfãos, UTF-8/LF sem mojibake.
- Suíte headless (`powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1`) em 2026-11-19: `348/348` testes passando em `48` scripts (`39724` asserts, `19.5s`), incluindo `test_project_standards.gd`.

**Não verificado em execução:** esta tarefa é de estudo/design e não altera código de jogo (`game/`); o 2º mockup de menus de loja/fogueira esbarrou no limite de cota de 5h da ferramenta de imagem (`429 RESOURCE_EXHAUSTED`) e foi coberto por wireframes em `540×960` + referências reais.

## Revisão cruzada

Pendente.
