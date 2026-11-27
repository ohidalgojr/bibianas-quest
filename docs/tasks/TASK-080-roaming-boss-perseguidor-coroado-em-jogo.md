# TASK-080: Roaming Boss O Perseguidor Coroado em jogo (núcleo, ficha e apresentação)

| Campo | Valor |
| --- | --- |
| Status | Em verificação (revisão cruzada pendente no fechamento do lote) |
| Aberta em | 2026-11-27 |
| Fase | 2, expansão pós-MVP (`TASK-054`) |
| GDD | 5, 6, 7, 13, 21 |
| ADRs | ADR-0066 (`RULES_VERSION` 23) |

## Objetivo

Levar o Roaming Boss `crowned_pursuer` (`docs/design/ROAMING-BOSS-perseguidor-coroado.md`, `assets/bibiana/sprites/crowned_pursuer.png`) para dentro do jogo com ficha de inimigo, mecânica pura de perseguição determinística no mapa e confronto especial em combate.

## Fora do escopo

- Alterar o fluxo atual do Cenário 1 sem ADR aprovado (o Roaming Boss pode ser liberado a partir do Cenário 2+ ou conforme definição no ADR da tarefa).

## Critérios de aceite

- [x] Criar `docs/enemies/ENEMY-20-perseguidor-coroado.md` (`crowned_pursuer`) seguindo todas as regras de justiça (`CLAUDE.md` regra 10).
- [x] Cadastrar `crowned_pursuer` em `game/data/enemies.json` e implementar o deslocamento/encontro do Roaming Boss em `game/core/run/` usando exclusivamente os fluxos determinísticos de `RngStreams` (sem nós).
- [x] Exibir marcador/sprite do `crowned_pursuer` no `Map3DScreen` e no `Combat3DStage` (com contraste/borda legível sobre piso escuro).
- [x] Criar ADR próprio, atualizar `docs/GDD.md` e `docs/HANDOFF.md`, e incrementar `CoreVersion.RULES_VERSION`.
- [x] Testes unitários verdes cobrindo determinismo da perseguição, justiça de combate e prints `540×960` em `docs/tasks/prints/`.

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

Suíte 388/388 (`RULES_VERSION` = 23), 8 testes novos em `tests/unit/test_roaming_boss.gd` (cenário 1 sem a flag, alarme, avanço e parada em fogueira, encontro que intercepta o movimento, vitória sem retorno, derrota, determinismo, save). Prints `docs/tasks/prints/TASK-080-mapa.png` (aviso "a 2 nós") e `TASK-080-combate.png`. A flag `roaming_boss` está desligada no único cenário existente; a mecânica só aparece com cenário 2+ ou `roaming_override`. Não implementado: patentes, Cemitério de Rivais, Incenso de Cinzas, Alma. Sprite do Perseguidor no mapa fica atrás da Bibiana, fora da tela no print.

## Revisão cruzada

Pendente.
