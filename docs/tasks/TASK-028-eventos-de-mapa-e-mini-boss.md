# TASK-028: eventos de mapa e mini boss

| Campo | Valor |
| --- | --- |
| Status | Concluída |
| Aberta em | 2026-11-18 |
| Concluída em | 2026-11-18 |
| Fase | 1, pendências do ADR-0029 (crítico) e do GDD §5 |
| GDD | 5, 7, 10, 13 |
| ADRs | ADR-0033 |

## Objetivo

Dar vida ao nó de **evento** (antes com peso 0, desligado) e criar o **mini boss** anunciado: escolhas com risco e recompensa, algumas com a moeda, uma das quais mexe no crítico (pedido D6), e uma recompensa rara garantida no mini boss, que também solta Galhos Secos e Moeda da Sorte (ADR-0028 e ADR-0026).

## Fora do escopo

- Roaming boss (perseguidor estilo Nemesis, GDD §13); novos cenários.

## Critérios de aceite

- [x] Sistema de evento em dados (`game/data/events.json`, validado): descrição, 2 a 3 escolhas, custo, resultado (ouro, item, doença, HP, buff, efeito no crítico), parte com lance de moeda (consequência de cara e de coroa).
- [x] Pelo menos 6 eventos temáticos da Cidade Abandonada, e ao menos um que aumente ou reduza o CRIT por alguns combates (D6).
- [x] Peso do nó de evento ligado (`PROTOTYPE_EVENT_WEIGHT = 9`), sem quebrar a vencibilidade do mapa; evento mostrado no mapa só pelo tipo, resultado só ao escolher.
- [x] Mini boss (0 ou 1 por mapa, anunciado no mapa), com ficha em `docs/enemies/`, recompensa rara garantida, Galhos Secos e Moeda da Sorte.
- [x] Telemetria registra evento e escolha; simulador e bots aprendem a escolher (regra simples); `RULES_VERSION` incrementado; GDD §5, §10, §13; ADR; testes.

## Arquivos afetados

- `game/data/events.json`, `game/data/enemies.json`, `game/data/scenarios.json`
- `docs/enemies/ENEMY-07-carcereiro-do-sino.md`, `docs/adr/ADR-0033-eventos-de-mapa-e-mini-boss.md`, `docs/GDD.md`, `docs/FEEDBACK.md`, `docs/HANDOFF.md`
- `game/core/core_version.gd`, `game/core/data/data_validator.gd`, `game/core/data/game_data.gd`, `game/core/map/map_rules.gd`, `game/core/run/run_event.gd`, `game/core/run/run_rules.gd`, `game/core/run/run_save.gd`, `game/core/run/run_state.gd`, `game/core/run/winnability.gd`, `game/core/sim/run_bot.gd`, `game/core/sim/simulator.gd`
- `game/presentation/combat/combat_texts.gd`, `game/presentation/game_screen.gd`, `game/presentation/map/map_screen.gd`, `game/presentation/map/map_view.gd`, `game/presentation/run/run_panel_screen.gd`, `game/presentation/run/run_panels.gd`, `game/services/telemetry.gd`
- `tests/unit/test_events_and_mini_boss.gd`, `tests/unit/test_data_loader.gd`, `tests/unit/test_run_state.gd`, `tests/unit/test_game_screen.gd`

## Verificação

- Suíte headless (`bash tools/run_tests.sh`): **306/306 testes passando** em 38 scripts (`test_events_and_mini_boss.gd` cobre os 6 eventos, modificadores de CRIT com decaimento por luta, lance de moeda em evento, anúncio e recompensas garantidas do mini boss Carcereiro do Sino e telemetria).
- Simulador (`tools/simulate.gd`): bot mediano 59,3% de vitórias (meta 55% a 65%), cuidadoso 78,0%, 1ª Descida 51,3% (meta 35% a 55%), 11,5% de mortes por moeda (meta ≤ 25%), 0 de 40 mapas sem rota vencível.

## Revisão cruzada

Revisado na entrega (`ADR-0033`): separação núcleo/apresentação respeitada (`test_core_purity.gd` verde), `RULES_VERSION = 16`, ficha `ENEMY-07-carcereiro-do-sino.md` presente.
