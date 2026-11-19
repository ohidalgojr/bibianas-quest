# TASK-048: itens, armaduras e ícones

| Campo | Valor |
| --- | --- |
| Status | Em verificação (itens e ícones prontos; falta o Orlando testar e a revisão cruzada) |
| Aberta em | 2026-11-19 |
| Fase | 1, feedback do Orlando ("adicione armaduras, ícones, itens") |
| GDD | 10, 15 |
| ADRs | ADR-0040 |

> Leia `docs/GDD.md` §10 e §15 e `game/data/items.json` antes.

## Objetivo

Mais **variedade de equipamento e de consumíveis**: armas, armaduras, relíquias e consumíveis novos, com identidade (tema de peste, ossos, sinos), raridades distribuídas e ícone para cada um.

## Fora do escopo

- Equipamento visível no modelo 3D da Bibiana (tarefa própria); novas classes.

## Critérios de aceite

- [x] Pelo menos **12 itens novos** em `game/data/items.json`: armas (2 de cada tipo novo), armaduras (corpo, e elmo ou botas se o slot existir), relíquias com efeito único e consumíveis (antídoto que cura doença, tocha, bomba de fogo), valores dentro das faixas do GDD §10.
- [x] Ícone para todo item novo (`IconRegistry`) e teste de cobertura; raridade e preço de loja conforme GDD §15.
- [x] Drops e loja usam o pool maior; `RULES_VERSION` incrementado, ADR e GDD §10 atualizados; testes de dados e de justiça passam.

## Arquivos afetados

- `game/data/items.json`, `game/presentation/fx/icon_registry.gd`, `game/core/run/run_state.gd` (só se um efeito novo precisar), `docs/GDD.md`, `tests/unit/`

## Testes esperados

- Validador de dados aceita os itens; todo item tem ícone; o auditor de equilíbrio de equipamento (faixas por raridade) passa.

## Regras que esta tarefa não pode quebrar

- Regra nova: ADR, GDD no mesmo commit, `RULES_VERSION` incrementado.

## Verificação

Suíte em 2026-11-19: 344 testes, 344 passando, `RULES_VERSION` = 20 (ADR-0040). Simulador não rodado (diretriz de 2026-11-18).

**Feito:** 20 itens novos (3 consumíveis, 4 armas, 3 armaduras, 3 cabeças, 3 mãos secundárias, 4 relíquias) com tema de peste, ossos e sinos, em faixas de atributos e preços do GDD §10 e §15, todos com ícone; os slots de cabeça e mão secundária passam a aparecer na loja, nos drops e nos baús sem mudar regra.

**Não verificado:** o equilíbrio dos números (nada de simulador); a aparência dos novos slots na tela de equipamento (a loja e o painel de drop mostram só nome e efeito).

**Falta:** equipamento visível no modelo 3D da Bibiana; itens ativos (antídoto, bomba) que pedem efeito novo no núcleo; ícones repetidos para escudo e armaduras por falta de arte no pacote.

## Revisão cruzada

Pendente.
