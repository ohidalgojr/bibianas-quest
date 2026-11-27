# TASK-080: Roaming Boss O Perseguidor Coroado em jogo (núcleo, ficha e apresentação)

| Campo | Valor |
| --- | --- |
| Status | Aberta |
| Aberta em | 2026-11-27 |
| Fase | 2, expansão pós-MVP (`TASK-054`) |
| GDD | 5, 6, 7, 13, 21 |
| ADRs | Novo ADR obrigatório (TASK-054, incrementa `RULES_VERSION`) |

## Objetivo

Levar o Roaming Boss `crowned_pursuer` (`docs/design/ROAMING-BOSS-perseguidor-coroado.md`, `assets/bibiana/sprites/crowned_pursuer.png`) para dentro do jogo com ficha de inimigo, mecânica pura de perseguição determinística no mapa e confronto especial em combate.

## Fora do escopo

- Alterar o fluxo atual do Cenário 1 sem ADR aprovado (o Roaming Boss pode ser liberado a partir do Cenário 2+ ou conforme definição no ADR da tarefa).

## Critérios de aceite

- [ ] Criar `docs/enemies/ENEMY-20-perseguidor-coroado.md` (`crowned_pursuer`) seguindo todas as regras de justiça (`CLAUDE.md` regra 10).
- [ ] Cadastrar `crowned_pursuer` em `game/data/enemies.json` e implementar o deslocamento/encontro do Roaming Boss em `game/core/run/` usando exclusivamente os fluxos determinísticos de `RngStreams` (sem nós).
- [ ] Exibir marcador/sprite do `crowned_pursuer` no `Map3DScreen` e no `Combat3DStage` (com contraste/borda legível sobre piso escuro).
- [ ] Criar ADR próprio, atualizar `docs/GDD.md` e `docs/HANDOFF.md`, e incrementar `CoreVersion.RULES_VERSION`.
- [ ] Testes unitários verdes cobrindo determinismo da perseguição, justiça de combate e prints `540×960` em `docs/tasks/prints/`.

## Arquivos afetados

- `docs/enemies/ENEMY-20-perseguidor-coroado.md`
- `game/core/run/*.gd`, `game/core/core_version.gd`, `game/data/enemies.json`
- `game/presentation/map3d/map3d_screen.gd`, `game/presentation/combat3d/combat3d_stage.gd`
- `docs/adr/ADR-XXXX-*.md`, `docs/GDD.md`, `docs/HANDOFF.md`, `tests/unit/test_*.gd`

## Testes esperados

- `tests/unit/test_core_purity.gd`, `test_project_standards.gd`, `test_game_data.gd` e novo teste determinístico de movimentação/encontro do Roaming Boss.

## Regras que esta tarefa não pode quebrar

- Núcleo (`game/core/`) 100% puro sem `Node`, `Time`, `OS` ou RNG global.
- Regra de justiça e drops raros configurados no ADR.
- Cânone visual (`ADR-0042`) e zero mecha colorida (`F-024`).

## Verificação

Pendente (aguardando implementação).

## Revisão cruzada

Pendente.
