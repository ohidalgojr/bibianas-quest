# TASK-018: drops de inimigos e equipamento

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte 244/244 (2026-11-16); jogada humana e revisão cruzada pendentes |
| Aberta em | 2026-11-16 |
| Fase | 1, ajuste pelo playtest (`docs/FEEDBACK.md`, F-003 e F-004) |
| GDD | 10 (drops, raridades), 15 (venda a 40%) |
| ADRs | ADR-0022 |

## Objetivo

Matar inimigos passa a render equipamento e consumíveis. A recompensa mostra o item caído com a comparação de atributos e pergunta "Equipar" ou "Vender". Há mais itens, com raridade, em arma, armadura e relíquia.

## Fora do escopo

- Ganho de status por nível (TASK-019) e skills na loja (TASK-020).
- Itens malditos, Almas, Forja, inventário reserva de 6 equipamentos (a decisão é na hora), mini boss.

## Critérios de aceite

- [x] Inimigo comum solta equipamento com 12% e elite com 35% (GDD §10), com raridade por pesos; consumível com chance própria (ADR-0022). O chefe não solta.
- [x] Sorteio de drop no fluxo de loot, determinístico por semente.
- [x] `RunState` guarda o drop pendente; `take_drop` equipa (e vende o item trocado a 40%) e `sell_drop` vende a 40%; sair da loja com drop pendente o vende.
- [x] A recompensa mostra o item, a raridade e as mudanças de atributo, com os botões Equipar e Vender.
- [x] 9 itens novos nos dados (arma, armadura, relíquia, de gasto a raro); itens raros só caem, não entram na loja.
- [x] Os bots decidem o drop; telemetria registra o drop; simulador roda de novo e o relatório é anotado.
- [x] GDD §10 atualizado, ADR-0022, `RULES_VERSION` incrementado, suíte verde.

## Arquivos afetados

- `game/data/items.json`; `game/core/run/` (`run_rules`, `run_state`, `run_event`); `game/core/sim/run_bot.gd`; `game/services/telemetry.gd`
- `game/presentation/run/` (painéis); `tests/`; `docs/GDD.md`, `docs/FEEDBACK.md`, `docs/HANDOFF.md`

## Verificação

2026-11-16: `toolsun_tests.ps1`, 31 scripts, 244/244. Simulador (200 Descidas, regras v6): mediano 65,5% de vitória, cuidadoso 78,5% (ADR-0022).

## Revisão cruzada

Revisado por Gemini (modelo distinto do autor original, Claude Opus 4.6), seguindo `docs/REVIEW-CHECKLIST.md`:
- **GDD §14, §15 e `ADR-0022`**: catálogo de 14 equipamentos (comuns, incomuns, raros) com escolha explícita entre equipar (`take_drop()`) ou vender (`sell_drop()`) na recompensa pós-luta, persistindo `pending_drop` no `RunSave`.
- **Achado corrigido na `TASK-029`**: adicionado `"precision": "PRE"` e `"relic": "Relíquia"` em `RunPanels` (`game/presentation/run/run_panels.gd`) para que itens como `spiked_mace` e relíquias exibam rótulos em `pt-BR`.
