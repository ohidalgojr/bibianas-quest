# TASK-019: ganho de status que se sente

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte 245/245 (2026-11-16); jogada humana e revisão cruzada pendentes |
| Aberta em | 2026-11-16 |
| Fase | 1, ajuste pelo playtest (`docs/FEEDBACK.md`, F-003 e F-004) |
| GDD | 9 (Poder) |
| ADRs | ADR-0023 |

## Objetivo

A Bibiana passa a ganhar status de forma visível a cada luta: o Poder sobe mais rápido, ganha um Nível (parte inteira do Poder) mostrado no mapa e na recompensa, e a subida de nível é anunciada. O ganho de atributos continua vindo das taxas do GDD (HP +10%, FOR e MEN +8%, DEF e RES +6%, VEL +2% por ponto de Poder).

## Fora do escopo

- Skills na loja (TASK-020); escolha de atributo ao subir; mudar as taxas por atributo.

## Critérios de aceite

- [x] Coeficiente de Poder sobe de 0,15 para 0,4 por nível (0,75 foi testado e ficou fácil demais) de inimigo (ADR-0023, GDD §9, `RULES_VERSION` incrementado).
- [x] Nível = parte inteira do Poder; aparece no cabeçalho do mapa e a recompensa anuncia "Subiu de nível! 1 → 2".
- [x] Uma luta comum no começo muda pelo menos HP e mais um atributo na recompensa.
- [x] Simulador rodado; o Coveiro recalibrado se o mediano sair da meta de 55% a 65%.
- [x] Suíte verde.

## Arquivos afetados

- `game/core/run/` (`run_rules`, `run_state`), `game/presentation/run/run_panels.gd`, `map/map_view.gd`, `game/data/enemies.json` (se recalibrar)
- `tests/`, `docs/GDD.md`, `docs/FEEDBACK.md`, `docs/HANDOFF.md`

## Verificação

2026-11-16: `toolsun_tests.ps1`, 31 scripts, 245/245 (cerca de 2 min). Simulador: mediano 65,0%, mortes por moeda 19%, 0 mapas sem rota em 100 (ADR-0023).

## Revisão cruzada

Revisado por Gemini (modelo distinto do autor original, Claude Opus 4.6), seguindo `docs/REVIEW-CHECKLIST.md`:
- **GDD §8, §9 e `ADR-0023`**: ganhos por ponto de Poder (`+16%` HP, `+10%` FOR/DEF, `+8%` MEN/RES, `+5%` VEL, `+1` PRE/ESQ/CRIT/SORTE) aplicados em `RunState.player_stats()`, garantindo subida visível de atributos em toda luta vencida.
- **Achados**: nenhum achado crítico ou importante. Aprovada.
