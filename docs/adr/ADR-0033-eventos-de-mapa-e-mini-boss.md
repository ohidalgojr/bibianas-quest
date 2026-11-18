# ADR-0033: eventos de mapa e mini boss anunciado

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-18 |
| Tarefa | TASK-028 |
| GDD | 5, 7, 10, 13 |

## Contexto

O nó de `EVENT` estava com peso 0 no protótipo (`RunRules.PROTOTYPE_EVENT_WEIGHT = 0`) e o `MINI_BOSS` existia apenas no enum `MapNode.Kind`, sem inimigo, sem sorteio no mapa e sem tabela de recompensa. Além disso, o pedido D6 (ADR-0029) previa eventos capazes de aumentar ou reduzir o CRIT por alguns combates.

## Decisão

1. **Sistema de eventos em dados (`game/data/events.json`):**
   - Validado por `DataValidator._check_event` e carregado em `GameData.events` (`scenario_events(scenario_id)`).
   - 6 eventos temáticos na Cidade Abandonada (`weeping_bell`, `plague_wagon`, `blind_herald`, `fountain_of_ash`, `gallows_tree`, `abandoned_armory`), cada um com 2 a 3 escolhas.
   - Escolhas suportam custos (`cost_gold`, `cost_item`, `cost_hp_percent`), sorteio de moeda (`coin: true` com ramos `heads` e `tails` pelo fluxo `streams.coin()`), e resultados de ouro, Poder (padrão `+0,35` se omitido), cura/dano de HP e MP, item, raridade de equipamento, doença/cura, buff de fogueira e modificador temporário de crítico (`crit_bonus`, `crit_combats`, pedido D6).
   - Peso do nó de evento ativado em `RunRules.PROTOTYPE_EVENT_WEIGHT = 9` (GDD §5). No mapa, o nó mostra apenas `"Evento"`, revelando o texto e as opções apenas ao entrar (`RunState.Phase.EVENT`).
2. **Mini boss anunciado (`bell_warden`, Carcereiro do Sino):**
   - Ficha criada em `docs/enemies/ENEMY-07-carcereiro-do-sino.md` e dados em `game/data/enemies.json` (`type: "mini_boss"`, `base_level: 4`, golpe de moeda `deafening_toll` com Cegueira na Coroa, debuff `toll_curse` com Fraqueza, golpe forte `cage_slam`, reações a Defender 2x e vida baixa).
   - Sorteado em `RunState._assign_enemies` com chance `clamp(35 + 10 * max(layers - 5, 0), 0, 75)%` (45% no mapa de 6 camadas; 0 na 1ª Descida para preservar o roteiro fixo da `TASK-026`), sempre na segunda metade do mapa (`layer >= (layers + 1) / 2 + 1`) e somente quando todos os nós anteriores que levam a ele mantêm ao menos uma opção calma (`!= ELITE` e `!= MINI_BOSS`).
   - Anunciado no cabeçalho do `MapView` (`"Sino rachado: Carcereiro do Sino (nv N) na camada L"`) e com borda vermelha no tabuleiro (`MapScreen`), sem permitir fuga (`can_flee = false`, GDD §13).
   - Recompensa ao vencer: Poder `×2,5`, ouro `×2,5`, **equipamento raro garantido** (`100%` com peso `100%` raro), **1 Galho Seco garantido** e **1 Moeda da Sorte garantida** (GDD §10, §12, §13; ADR-0026 e ADR-0028).
3. **`RULES_VERSION`:** incrementado de 15 para 16.

## Simulador (regras v16)

| Perfil | Vitória cen. 1 | Turnos comum | Mortes por moeda | Chegou ao chefe |
| --- | --- | --- | --- | --- |
| Mediano | 59,3% (meta 55–65%) | 6,8 (meta 6–10) | 11,5% (meta ≤ 25%) | 95,3% |
| Cuidadoso | 78,0% | 6,7 | 24,2% | 92,0% |
| 1ª Descida | 51,3% (meta 35–55%) | 6,8 | 19,2% | 98,0% |

40 de 40 mapas com rota vencível (0 descartados sem caminho).

## Consequências

- Os 8 tipos de nó do GDD §5 (`START`, `BATTLE`, `AMBUSH`, `ELITE`, `CHEST`, `EVENT`, `BONFIRE`, `MINI_BOSS`, `BOSS`) estão ativos e funcionais no núcleo e na apresentação.
- O estado de evento e o modificador de CRIT (`seen_events`, `event_crit_bonus`, `event_crit_combats`) são persistidos no `RunSave` e registrados na telemetria (`event`, `event_choice`, `event_coin`).
