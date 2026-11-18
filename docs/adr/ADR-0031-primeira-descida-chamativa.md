# ADR-0031: primeira Descida chamativa e morte que ensina

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-18 |
| Tarefa | TASK-026 |
| GDD | 4, 5, 9, 26 |

## Contexto

F-019 do playtest (`docs/FEEDBACK.md`): o Orlando pediu que a primeira Descida (`runs_played == 0`, sem Ecos anteriores) seja chamativa, dê um gostinho da dificuldade e uma recompensa que se vê logo nos primeiros minutos, e termine com vontade de continuar jogando — sem tutorial de texto nem mudança definitiva para as Descidas seguintes.

## Decisão

1. **Ativação apenas quando `runs_played == 0`.** `RunState.create()` aceita `first_run: bool = false`. O `GameScreen` ativa `first_run` somente quando `runs_played == 0` no `SaveStore`. Da segunda Descida em diante (`runs_played >= 1`), `first_run` é falso e valem as regras normais.
2. **Elementos garantidos no mapa da primeira Descida (`_apply_first_run_guarantees`):**
   - **Camada 1 (primeiro encontro):** todos os nós alcançáveis na camada 1 enfrentam o **Cidadão Infectado** (`infected_citizen`) em nível 1 (encontro que demonstra o aviso e o golpe de moeda temático Abraço Febril sem risco desproporcional). A suavização de vencibilidade (`Winnability.smooth`) não converte a camada 1 em baú quando `first_run` está ativo.
   - **Baú nas duas primeiras camadas:** se a camada 2 não tiver nenhum baú nos nós alcançáveis, um nó da camada 2 vira `CHEST`. O primeiro baú aberto na primeira Descida (`first_chest_opened`) garante um equipamento **incomum** e **+1 Moeda da Sorte** além do ouro normal.
   - **Elite no meio do mapa:** se as camadas 3 e 4 não tiverem nenhum `ELITE`, um nó da camada 3 (sem quebrar a regra de opção segura) vira `ELITE`. Na primeira Descida, derrotar um elite garante um drop de equipamento **raro** (se ainda não sorteado) e **+1 Moeda da Sorte**.
   - **Chefe com tensão calibrada:** na primeira Descida, o chefe recebe `+1` nível (`FIRST_RUN_BOSS_LEVEL_BONUS = 1`) e a meta de vencibilidade da rota segura na primeira Descida é `42%` (`FIRST_RUN_WINNABLE_TARGET = 42.0`), para que quase todo jogador chegue ao chefe com loot visível, mas sinta o peso real do Coveiro (vitória do bot mediano entre 35% e 55%).
3. **O chefe aparece de longe no mapa:** no `MapView`, o nó `State.BOSS` exibe o nome do chefe e o nível mesmo à distância (`"O Coveiro te espera, nv 7"`), em vez de `"???"`.
4. **Ecos em dobro na primeira Descida:** `RunRules.echoes(nodes_cleared, bosses_defeated, first_run)` multiplica os Ecos por `FIRST_RUN_ECHO_MULT = 2` quando `first_run` é verdadeiro, tanto na vitória quanto na derrota.
5. **Tela final "Morte que ensina" (GDD §26):** `RunState.end_summary()` e `RunState.teaching_tip()` estruturam o resumo pós-Descida com:
   - Quem derrubou a Bibiana, o golpe final e a porcentagem de HP restante do inimigo (`"O Coveiro ficou com 18% de vida"`).
   - O que foi conquistado na Descida (nós vencidos, inimigos derrotados, Nível/Poder alcançado, ouro e itens).
   - Dica tática contextual ao golpe ou causa da derrota (ex.: uso de Defender ou Moeda da Sorte contra golpes de moeda, tratamento de doença na fogueira, compra de equipamento/skills na loja).
   - O que ficou para a próxima Descida (Ecos ganhos — destacando o bônus em dobro da 1ª Descida — e aviso de que o Coveiro espera a revanche).
6. **Persistência e simulador:** `RunSave` grava e restaura `first_run` e `first_chest_opened`. O `Simulator` e `tools/simulate.gd` incluem o perfil `"Primeira Descida (bot mediano)"`.
7. `RULES_VERSION` sobe para 14.

## Verificação no simulador

Regras v14, 150 Descidas por perfil com checagem de 20 simulações por mapa e 40 mapas com 40 simulações (`reports/simulation.md`, 2026-11-18):

| Perfil | Vitória (meta) | Chegou ao chefe | Turnos/luta comum | Mortes por moeda (meta <= 25%) |
| --- | --- | --- | --- | --- |
| Bot mediano (normal) | 62,7% (55% a 65%) | 94,7% | 6,8 | 14,3% (8/56) |
| Bot cuidadoso (normal) | 70,7% | 80,7% | 7,3 | 9,1% (4/44) |
| **Primeira Descida (bot mediano)** | **52,7% (35% a 55%)** | **98,0%** | **6,6** | **14,1% (10/71)** |

Vencibilidade do mapa: 0 de 40 mapas sem caminho vencível no fim (70,2% de vitória média na rota segura).

## Alternativas

- **Tutorial roteirizado separado do mapa:** descartado pelo próprio objetivo da tarefa ("Nada de tutorial de texto: a Descida é a mesma, com garantias").
- **Primeira Descida fácil (80%+ de vitória):** descartado porque tira o medo do Coveiro e a razão para tentar a segunda Descida; a meta de 35% a 55% com 98% de chegada ao chefe entrega recompensa durante a subida e tensão real no final.

## Consequências

- O primeiro contato do jogador sempre mostra o Cidadão Infectado na camada 1, um baú recheado logo no início, a Moeda da Sorte e o nome do Coveiro no topo do mapa.
- A partir da segunda Descida (`runs_played >= 1`), nenhuma garantia extra é aplicada.
