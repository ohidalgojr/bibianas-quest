# TASK-017: progressão visível

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte 233/233 (2026-11-16); jogada humana e revisão cruzada pendentes |
| Aberta em | 2026-11-16 |
| Fase | 1, ajuste pelo playtest (`docs/FEEDBACK.md`, F-003) |
| GDD | 9, 19 |
| ADRs | ADR-0021 |

## Objetivo

Matar inimigos passa a dar sensação de avanço: a recompensa mostra o que a Bibiana ganhou (atributos antes e depois), o mapa mostra a força atual e o número de inimigos derrotados, e o abate tem retorno visual na luta. Só apresentação e contadores; nenhuma fórmula muda.

## Fora do escopo (a decidir com o Orlando)

- Drops de itens e equipamentos dos inimigos, marcos por camada, códice e progressão permanente por tipo de inimigo: mexem na economia e no laço (GDD §9, §10, §15) e exigem ADR e nova calibração.

## Critérios de aceite

- [x] Depois de cada vitória, a tela de recompensa diz quem foi derrotado e mostra Poder e cada atributo que mudou, no formato "FOR 14 → 15".
- [x] O cabeçalho do mapa mostra FOR, DEF e VEL atuais e o contador de inimigos derrotados; a tela de fim também.
- [x] Na luta, números de dano sobem do alvo e o abate do inimigo tem animação e texto "Derrotado!".
- [x] O contador entra no save.
- [x] Suíte verde; nenhuma regra nem fórmula alterada (`RULES_VERSION` igual).

## Arquivos afetados

- `game/core/run/run_state.gd`, `run_save.gd`; `game/presentation/run/run_panels.gd`; `map/map_view.gd`; `game_screen.gd`; `combat/combat_screen.gd`
- `tests/unit/` (painéis, mapa, save, tela de combate), `docs/adr/ADR-0021-progressao-visivel.md`

## Verificação

2026-11-16: `toolsun_tests.ps1`, 30 scripts, 233/233. Achado: o ganho de uma luta comum no começo é de 1 a 2 de HP (ver ADR-0021).

## Revisão cruzada

Pendente.
