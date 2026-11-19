# ADR-0032: sorte, emboscadas e inimigos mutados

- **Status:** Aceito
- **Data:** 2026-11-18
- **Tarefa:** TASK-027
- **GDD:** seções 5, 7, 9, 10 e 11

## Contexto

Na decisão **D1** (ADR-0025 e item 6 do ADR-0026), o Orlando definiu que a moeda é sempre 50/50 sem número na tela e que **SORTE**, **Maré de azar** e eventos devem influenciar a **chance de achar itens raros**, **inimigos mais difíceis** e **emboscadas**, além de incluir o **inimigo mutado** como fonte da **Moeda da Sorte** (GDD §10).

Até a TASK-026:
1. O nó `AMBUSH` (`Emboscada`) era apenas um rótulo no mapa que abria uma batalha comum idêntica a `BATTLE`.
2. As mutações do GDD §11 (`Inchado`, `Voraz`, `Fantasma`, `Espinhoso`) não existiam nos dados nem no motor.
3. A `SORTE` e a `Maré de azar` só mexiam em drops, ouro de baú e chance de Moeda da Sorte/Galhos Secos.

## Decisões

1. **Quatro mutações temáticas em dados (`game/core/combat/mutations.gd` e `game/data/enemies.json`):**
   - Cada inimigo comum do cenário 1 declara sua mutação assinatura no campo `"mutation"` de `enemies.json`, validado por `DataValidator`:
     - `infected_citizen` → `bloated` (**Inchado**): +50% de HP máximo, `VEL -2`.
     - `giant_rat` → `voracious` (**Voraz**): cura 25% do dano físico causado a cada golpe que acerta.
     - `carrion_crow` → `phantom` (**Fantasma**): `ESQ +15` pontos.
     - `plague_hound` → `thorny` (**Espinhoso**): reflete 15% do dano físico recebido de volta na Bibiana.
2. **Regras de mapa, visibilidade e recompensas do inimigo mutado:**
   - Mutações só ocorrem da **camada 3 em diante** (`MUTATION_MIN_LAYER = 3`), **no máximo 1 nó mutado por camada** (`MapRules._check_mutations`: `MUTATION_EARLY`, `MUTATION_CROWD`), e nunca fecham todas as saídas de um nó da camada anterior em apenas elites ou mutados (`RunState._can_mutate_node`).
   - O nó mutado ganha `+1` de nível (respeitando o teto do cenário), aparece na camada alcançável do mapa com título `"Luta Mutada"` ou `"Emboscada Mutada (age 1º)"` e detalhe `"Nome [Mutação], nv N"`, e na suavização de vencibilidade (`Winnability.smooth`) tem custo `1,5 × nível` e pode ser desmutado na rota segura se necessário.
   - Recompensa (`enemy_type = "mutated"`): **Poder ×1,5** e **ouro ×1,5** (`TYPE_MULTIPLIERS["mutated"] = 1.5`), **30%** de chance base de equipamento com pesos **35% comum / 45% incomum / 20% raro**, **45%** de consumível de cura, **15%** (+SORTE) de Galhos Secos e **12%** (+SORTE) de **Moeda da Sorte** (`LUCKY_COIN_MUTATED_PERCENT = 12`).
3. **Emboscada mecânica e justa (`Combat.ambushed`):**
   - No nó `AMBUSH`, avisado no mapa como `"Emboscada (age 1º)"`, o inimigo inicia o combate com `charge = CHARGE_TO_ACT` (100) e a Bibiana inicia com `Guarda aberta` (`ARMOR_DOWN`, DEF -20%) durante o bote inicial e o 1º turno dela (`AMBUSH_ARMOR_DOWN_TURNS = 2`).
   - Como `_choose_intent()` no início da luta respeita a trava do 1º turno (`!_has_seen_player_turn()`) do ADR-0008, o bote inicial da emboscada **nunca é um golpe de moeda nem ataque forte sem aviso**.
4. **Influência de SORTE e Maré de azar no mapa (`RunRules` e `RunState._apply_luck_to_layer`):**
   - Chance de mutação por camada elegível: `clamp(base - 2 × SORTE + (25 se Maré de azar), 0, 65)`, com `MUTATION_BASE_PERCENT = 18` na geração do mapa.
   - Ao concluir um nó na camada `L`, a camada `L + 1` (que estava na névoa `FOG` até esse momento) recebe o ajuste dinâmico de `SORTE` e `Maré de azar`:
     - Se a Bibiana estiver em **Maré de azar** (3 coroas seguidas) ou com `SORTE < 0`, a camada `L + 1` pode ganhar uma mutação extra (se ainda não tiver mutado na camada) e cada `BATTLE` tem `clamp(35 se Maré + max(-SORTE, 0) × 4, 0, 60)%` de chance de virar `AMBUSH`.
     - Se a Bibiana tiver `SORTE > 0` e não estiver em Maré de azar, cada `AMBUSH` da camada `L + 1` tem `clamp(SORTE × 4, 0, 50)%` de chance de ser evitada e virar `BATTLE`.
5. **Versão das regras:** `CoreVersion.RULES_VERSION` passa de **14 para 15**, invalidando saves de Descida em andamento de versões anteriores (`RunSave` persiste `node.mutation`).

## Simulador (`tools/simulate.gd -- --runs 150 --check 20 --maps 40 --map-check 40`, regras v15)

| Perfil | Vitória cenário 1 | Meta (GDD §23) | Turnos/comum | Mortes por moeda | Chegou ao chefe |
| --- | --- | --- | --- | --- | --- |
| Bot mediano | 66,0% | 55% a 65% | 6,7 | 13,7% (7/51) | 94,0% |
| Bot cuidadoso | 72,0% | — | 7,3 | 9,5% (4/42) | 82,7% |
| Primeira Descida (mediano) | 49,3% | 35% a 55% | 6,7 | 15,8% (12/76) | 98,0% |

- Vencibilidade (40 mapas × 40 simulações): **0 mapas sem caminho vencível**, 8,88 suavizações/mapa, 70,4% de vitória na rota segura, 1285 ms por Descida criada.

## Consequências

- O pedido **D1** fica 100% fechado no núcleo e na apresentação: SORTE e Maré de azar agora alteram drops raros, baús, mutações e emboscadas, e inimigos mutados soltam Moeda da Sorte e itens raros.
- Todas as regras de justiça do GDD §5, §6, §7 e §11 continuam intactas e verificadas por testes unitários e pelo simulador.
