# TASK-048: itens, armaduras e ícones

| Campo | Valor |
| --- | --- |
| Status | Em andamento |
| Aberta em | 2026-11-19 |
| Fase | 1, feedback do Orlando ("adicione armaduras, ícones, itens") |
| GDD | 10, 15 |
| ADRs | a criar (ADR-0039) |

> Leia `docs/GDD.md` §10 e §15 e `game/data/items.json` antes.

## Objetivo

Mais **variedade de equipamento e de consumíveis**: armas, armaduras, relíquias e consumíveis novos, com identidade (tema de peste, ossos, sinos), raridades distribuídas e ícone para cada um.

## Fora do escopo

- Equipamento visível no modelo 3D da Bibiana (tarefa própria); novas classes.

## Critérios de aceite

- [ ] Pelo menos **12 itens novos** em `game/data/items.json`: armas (2 de cada tipo novo), armaduras (corpo, e elmo ou botas se o slot existir), relíquias com efeito único e consumíveis (antídoto que cura doença, tocha, bomba de fogo), valores dentro das faixas do GDD §10.
- [ ] Ícone para todo item novo (`IconRegistry`) e teste de cobertura; raridade e preço de loja conforme GDD §15.
- [ ] Drops e loja usam o pool maior; `RULES_VERSION` incrementado, ADR e GDD §10 atualizados; testes de dados e de justiça passam.

## Arquivos afetados

- `game/data/items.json`, `game/presentation/fx/icon_registry.gd`, `game/core/run/run_state.gd` (só se um efeito novo precisar), `docs/GDD.md`, `tests/unit/`

## Testes esperados

- Validador de dados aceita os itens; todo item tem ícone; o auditor de equilíbrio de equipamento (faixas por raridade) passa.

## Regras que esta tarefa não pode quebrar

- Regra nova: ADR, GDD no mesmo commit, `RULES_VERSION` incrementado.

## Verificação

Ainda não executada.

## Revisão cruzada

Pendente.
