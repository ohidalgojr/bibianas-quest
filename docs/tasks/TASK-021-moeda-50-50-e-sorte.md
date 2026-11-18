# TASK-021: moeda 50/50 sem número, sorte nos drops e Moeda da Sorte

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte 260/260 (2026-11-16); jogada humana e revisão cruzada pendentes |
| Aberta em | 2026-11-16 |
| Fase | 1, ajuste pelo playtest (D1 do ADR-0025; `docs/FEEDBACK.md` F-014, F-017) |
| GDD | 7, 10, 16 |
| ADRs | ADR-0025, ADR-0026 |

## Objetivo

A moeda passa a ser só cara ou coroa: 50% fixo, sem exibir chance. SORTE e Maré de azar deixam de mexer na moeda e passam a influenciar os drops e os baús. A re-jogada vira a Moeda da Sorte, item raro (baú, elite, chefe) que o jogador arma antes do lance.

## Fora do escopo

- Inimigos mais difíceis e emboscadas por sorte (entram com a TASK-025), multiplicador de baú (TASK-022), mini boss, roaming boss, mutados (não existem).
- Decisão de monetização que substitua a trapaça por anúncio (fica anotada no GDD).

## Critérios de aceite

- [x] `CoinRules.chance()` devolve 50 sempre; SORTE, Maré de azar e trapaça saem da fórmula da moeda.
- [x] Nenhum texto da tela (aviso do inimigo, giro, dicas) mostra chance da moeda.
- [x] SORTE aumenta a chance de equipamento (+1 ponto por SORTE, até +15) e desloca pesos de raridade para o raro; a Maré de azar (3 lances perdidos seguidos) garante o próximo drop de equipamento e melhora a raridade, e zera.
- [x] Baú dá mais ouro com SORTE e pode soltar Moeda da Sorte; elite e chefe também soltam.
- [x] Moeda da Sorte: item de consumível raro, fora da loja, que o jogador arma no combate; no primeiro lance que cair errado ele é rejogado e a moeda é gasta; o resultado mostra a re-jogada.
- [x] GDD §7, §10 e §16 atualizados, ADR-0026, `RULES_VERSION` incrementado, simulador rodado, suíte verde.

## Arquivos afetados

- `game/core/combat/` (`coin_rules`, `coin_state`, `combat`), `game/core/run/` (`run_rules`, `run_state`), `game/core/data/data_validator.gd`, `game/data/items.json`
- `game/presentation/combat/` (sessão, textos, tela), `game/services/telemetry.gd`
- `tests/`, `docs/GDD.md`, `docs/FEEDBACK.md`, `docs/HANDOFF.md`

## Verificação

2026-11-16: `tools\run_tests.ps1`, 33 scripts, 260/260. Simulador regras v9: mediano 64,7%, mortes por moeda 15,1% (ADR-0026).

## Revisão cruzada

Revisado por Gemini (modelo distinto do autor original, Claude Opus 4.6), seguindo `docs/REVIEW-CHECKLIST.md`:
- **GDD §7, §8, §14 e `ADR-0026`**: `CoinRules.flip_50_50()` sorteia Cara ou Coroa em 50/50 real no fluxo `coin` sem influência de `SORTE` nem de Maré de azar; `lucky_coin` re-joga lance errado quando armada antes da ação (`arm_lucky_coin`); `SORTE` e Maré de azar atuam no fluxo `loot` melhorando raridade e chance de drops.
- **Achados**: nenhum achado crítico ou importante. Aprovada.
