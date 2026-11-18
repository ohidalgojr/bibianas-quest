# TASK-028: eventos de mapa e mini boss

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada) |
| Aberta em | 2026-11-18 |
| Fase | 1, pendências do ADR-0029 (crítico) e do GDD §5 |
| GDD | 5, 7, 10, 13 |
| ADRs | a criar |

## Objetivo

Dar vida ao nó de **evento** (hoje com peso 0, desligado) e criar o **mini boss** anunciado: escolhas com risco e recompensa, algumas com a moeda, uma das quais mexe no crítico (pedido D6), e uma recompensa rara garantida no mini boss, que também solta Galhos Secos e Moeda da Sorte (ADR-0028 e ADR-0026).

## Fora do escopo

- Roaming boss (perseguidor estilo Nemesis, GDD §13); novos cenários.

## Critérios de aceite

- [ ] Sistema de evento em dados (`game/data/events.json`, validado): descrição, 2 a 3 escolhas, custo, resultado (ouro, item, doença, HP, buff, efeito no crítico), parte com lance de moeda (consequência de cara e de coroa).
- [ ] Pelo menos 6 eventos temáticos da Cidade Abandonada, e ao menos um que aumente ou reduza o CRIT por alguns combates (D6).
- [ ] Peso do nó de evento ligado (hoje `PROTOTYPE_EVENT_WEIGHT = 0`), sem quebrar a vencibilidade do mapa; evento mostrado no mapa só pelo tipo, resultado só ao escolher.
- [ ] Mini boss (0 ou 1 por mapa, anunciado no mapa), com ficha em `docs/enemies/`, recompensa rara garantida, Galhos Secos e Moeda da Sorte.
- [ ] Telemetria registra evento e escolha; simulador e bots aprendem a escolher (regra simples); `RULES_VERSION` incrementado; GDD §5, §10, §13; ADR; testes.

## Arquivos afetados (previstos)

- `game/data/events.json` (novo), `game/core/run/` (estado de evento), `game/core/map/`, `game/core/data/`, `game/presentation/`, `docs/enemies/`, `tests/`, `docs/GDD.md`

## Verificação

(preencher)

## Revisão cruzada

Pendente.
