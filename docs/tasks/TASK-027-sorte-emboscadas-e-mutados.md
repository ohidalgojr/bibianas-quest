# TASK-027: sorte, emboscadas e inimigos mutados

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada) |
| Aberta em | 2026-11-18 |
| Fase | 1, pendência do ADR-0026 (item 6) e do ADR-0030 |
| GDD | 5, 7, 11 |
| ADRs | a criar |

## Objetivo

Fechar o que o Orlando pediu em D1: SORTE, Maré de azar e eventos passam a influenciar também **emboscadas**, **inimigos mais difíceis** e a **chance de achar itens raros**. Hoje a SORTE só mexe em drops, baús e Moeda da Sorte.

## Fora do escopo

- Mini boss e roaming boss (TASK-028); eventos de mapa (TASK-028).

## Critérios de aceite

- [ ] **Inimigo mutado:** uma variante visível no mapa antes da luta (GDD §5, neblina) com nível maior, Poder ×1,5, melhor drop e chance maior de Moeda da Sorte (o GDD §10 lista "inimigo mutado" como fonte da re-jogada); a mutação sai dos dados de cada inimigo e respeita a vencibilidade.
- [ ] **Emboscada:** o nó de emboscada (hoje só rótulo) vira uma luta em que o inimigo começa com um status inicial (GDD §5: sangramento ou pavor) ou age primeiro; avisada no mapa.
- [ ] **SORTE e Maré de azar** mexem na chance de mutados e de emboscadas (por exemplo, SORTE baixa ou Maré de azar acumulada aumenta a chance), com valores em constantes e testes de distribuição.
- [ ] Simulador rodado; `RULES_VERSION` incrementado; GDD §5, §7 e §11 atualizados; ADR.

## Arquivos afetados (previstos)

- `game/core/map/`, `game/core/run/` (`run_rules`, `run_state`), `game/core/combat/`, `game/data/enemies.json`, `game/presentation/map/`, `tests/`, `docs/GDD.md`

## Verificação

(preencher)

## Revisão cruzada

Pendente.
