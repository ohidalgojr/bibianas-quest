# TASK-027: sorte, emboscadas e inimigos mutados

| Campo | Valor |
| --- | --- |
| Status | Concluída |
| Aberta em | 2026-11-18 |
| Fase | 1, pendência do ADR-0026 (item 6) e do ADR-0030 |
| GDD | 5, 7, 9, 10, 11 |
| ADRs | ADR-0032 |

## Objetivo

Fechar o que o Orlando pediu em D1: SORTE, Maré de azar e eventos passam a influenciar também **emboscadas**, **inimigos mais difíceis** e a **chance de achar itens raros**. Hoje a SORTE só mexe em drops, baús e Moeda da Sorte.

## Fora do escopo

- Mini boss e roaming boss (TASK-028); eventos de mapa (TASK-028).

## Critérios de aceite

- [x] **Inimigo mutado:** uma variante visível no mapa antes da luta (GDD §5, neblina) com nível maior, Poder ×1,5, melhor drop e chance maior de Moeda da Sorte (o GDD §10 lista "inimigo mutado" como fonte da re-jogada); a mutação sai dos dados de cada inimigo e respeita a vencibilidade.
- [x] **Emboscada:** o nó de emboscada (hoje só rótulo) vira uma luta em que o inimigo começa com um status inicial (GDD §5: sangramento ou pavor) ou age primeiro; avisada no mapa.
- [x] **SORTE e Maré de azar** mexem na chance de mutados e de emboscadas (por exemplo, SORTE baixa ou Maré de azar acumulada aumenta a chance), com valores em constantes e testes de distribuição.
- [x] Simulador rodado; `RULES_VERSION` incrementado; GDD §5, §7 e §11 atualizados; ADR.

## Arquivos afetados (previstos)

- `game/core/map/`, `game/core/run/` (`run_rules`, `run_state`), `game/core/combat/`, `game/data/enemies.json`, `game/presentation/map/`, `tests/`, `docs/GDD.md`

## Verificação

- `tests/unit/test_mutations_and_ambush.gd`: 6/6 verdes (mutações carregadas de `enemies.json`, atributos de `Inchado` e `Fantasma`, cura de `Voraz` e reflexo de `Espinhoso`, bote inicial e `Guarda aberta` na emboscada sem moeda surpresa, regras de justiça de mutados nas camadas 3..6, exibição em `MapView`/`RunPanels`, Poder ×1,5 e testes de distribuição de SORTE e Maré de azar).
- Suíte completa headless (`tools/run_tests.sh`): 303/303 testes verdes em 37 scripts.
- Simulador (`tools/simulate.gd -- --runs 150 --check 20 --maps 40 --map-check 40`): registrado no `ADR-0032` e em `docs/HANDOFF.md`.

## Revisão cruzada

- **Revisor:** Gemini (`docs/REVIEW-CHECKLIST.md`).
- **Conformidade com o GDD:** §5 (emboscadas avisadas com ataque inicial e Guarda aberta), §7 (SORTE e Maré de azar mexendo em mutados, emboscadas e raridade de drops; Moeda da Sorte em mutados), §9 (`m_tipo = 1,5`), §10 (tabela de drops de mutados com 20% de raros) e §11 (4 mutações temáticas nas camadas 3..6, máx. 1 por camada).
- **Pureza e determinismo:** `game/core/combat/mutations.gd` estende `RefCounted`, sem nós nem RNG global; todos os sorteios de mutação e ajuste de camada usam `streams.map()` e as sondas de vencibilidade (`is_probe`) não alteram o grafo.
- **Gravidade:** nenhum bloqueador ou importante pendente.
