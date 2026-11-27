# TASK-079: fichas de design e integração de O Coro Sem Lábios e O Cavaleiro Calcificado

| Campo | Valor |
| --- | --- |
| Status | Aberta |
| Aberta em | 2026-11-27 |
| Fase | 1, conteúdo de inimigos |
| GDD | 6, 7, 11, 21 |
| ADRs | Novo ADR obrigatório (incrementa `RULES_VERSION`) |

## Objetivo

Criar as fichas de design obrigatórias em `docs/enemies/` e integrar ao jogo os dois inimigos do estudo cujos sprites já estão prontos (`assets/bibiana/sprites/lipless_choir.png` e `calcified_knight.png`).

## Fora do escopo

- O Roaming Boss `crowned_pursuer`, que possui mecânica própria no mapa (`TASK-080`).

## Critérios de aceite

- [ ] Criar `docs/enemies/ENEMY-18-coro-sem-labios.md` (`lipless_choir`) e `docs/enemies/ENEMY-19-cavaleiro-calcificado.md` (`calcified_knight`) com fantasia, golpes de moeda temáticos, reações e auditoria de justiça (`CLAUDE.md` regra 10).
- [ ] Cadastrar ambos em `game/data/enemies.json` e `game/data/scenarios.json`, e incluir na ordem do Códice (`SanctuaryRules.ENEMY_ORDER`).
- [ ] Criar ADR próprio, atualizar `docs/GDD.md` se aplicável e incrementar `CoreVersion.RULES_VERSION` + `docs/HANDOFF.md`.
- [ ] Validar `combat3d_preview.tscn` com `inimigo=lipless_choir` e `inimigo=calcified_knight`, anexando prints `540×960` em `docs/tasks/prints/`.
- [ ] Suíte headless verde (`test_project_standards.gd`, `test_game_data.gd`, `test_sanctuary.gd`).

## Arquivos afetados

- `docs/enemies/ENEMY-18-coro-sem-labios.md`, `docs/enemies/ENEMY-19-cavaleiro-calcificado.md`
- `game/data/enemies.json`, `game/data/scenarios.json`
- `game/core/core_version.gd`, `game/core/run/sanctuary_rules.gd`
- `docs/adr/ADR-XXXX-*.md`, `docs/GDD.md`, `docs/HANDOFF.md`, `tests/unit/test_*.gd`

## Testes esperados

- `tests/unit/test_project_standards.gd` (`test_every_enemy_has_a_design_sheet`), `test_game_data.gd` (auditor de justiça), `test_sanctuary.gd` (Códice).

## Regras que esta tarefa não pode quebrar

- Regra de justiça: golpe perigoso avisado 1 turno antes, intervalo mínimo de 2 golpes entre golpes de moeda, Golpe Mortal só em chefe.
- Núcleo sem nós e sem aleatoriedade global (`test_core_purity.gd`).
- Cânone visual (`ADR-0042`).

## Verificação

Pendente (aguardando implementação).

## Revisão cruzada

Pendente.
