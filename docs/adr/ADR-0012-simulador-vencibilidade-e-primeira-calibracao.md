# ADR-0012: simulador, vencibilidade do mapa e primeira calibração

| Campo | Valor |
| --- | --- |
| Status | Aceito (decisão técnica dentro da tarefa; dois pontos para o Orlando decidir) |
| Data | 2026-11-16 |
| Tarefa | TASK-008 |
| GDD | 5 (vencibilidade), 23 (metas e alavancas) |

## Contexto

Na TASK-007, o bot de regras venceu só 8% das Descidas do cenário 1, e 80% das mortes foram no Coveiro. O GDD §23 pede de 55% a 65% para o jogador mediano. O GDD §5 pede que cada mapa prove ter um caminho vencível. Nenhuma fórmula do GDD muda aqui; mudam números de dados do protótipo (ADR-0009) e a forma de checar o mapa.

## Decisão

**Bots de referência (GDD §23)**

1. **Mediano:** defende golpe perigoso 60% das vezes, usa skills ao acaso, bebe poção abaixo de 35% de vida e compra até 2 poções.
2. **Cuidadoso:** sempre defende golpe de moeda (o Veterano anula a penalidade). Defende o golpe forte só abaixo de 60% de vida e guarda uma poção para o chefe. Usa Golpe de Escudo no chefe para causar Lentidão, descansa abaixo de 85% e compra até 4 poções. A primeira versão defendia todo golpe perigoso e jogava pior que o mediano; essa política foi descartada.
3. Os bots e o simulador ficam em `game/core/sim/` (sem nós), porque a checagem de vencibilidade do mapa usa o bot.

**Vencibilidade do mapa (GDD §5)**

4. **Caminho mais seguro:** menor soma de custo. O custo é o nível para batalha, emboscada e chefe, o dobro do nível para elite, e zero para baú e fogueira.
5. **Checagem:** o bot mediano joga esse caminho 200 vezes a partir do estado da Bibiana ao entrar no cenário. As simulações têm sementes derivadas da Descida e não gastam os quatro fluxos. Abaixo da meta, o caminho é suavizado: o nível de cada luta do caminho cai 1, sem passar do mínimo do cenário e sem mexer no chefe. A batalha de maior nível vira baú, se isso não quebrar as regras do mapa. São até 5 suavizações. Se não bastar, o mapa é descartado e outro é gerado pelo fluxo do mapa, até 10 mapas. Depois disso, fica o último, marcado como reprovado.
6. **Parada antecipada:** a checagem para assim que o resultado contra a meta está decidido (vitórias suficientes, ou derrotas demais para alcançá-la). A decisão é idêntica à das 200 simulações, e um teste confere isso.
7. **Meta de rota do cenário 1: 60%**, no campo `winnable_target` de `scenarios.json`. O GDD dá 70% só como exemplo. Com 70%, quase todo mapa precisava de suavização, e a checagem passava a definir a dificuldade, levando a vitória do mediano acima de 65%. Com 60%, ela funciona como piso.
8. **Número de simulações:** o padrão é 200, do GDD, em `Winnability.DEFAULT_RUNS`. O `RunState` recebe esse número por parâmetro, e 0 desliga a checagem. Os testes de unidade usam 20, e o simulador usa 40 nas Descidas e 20 na prova em milhares de sementes.

**Calibração (alavancas do GDD §23)**

9. **O Coveiro** (dados, não fórmula):
   - HP de 220 para 150 e FOR de 15 para 14.
   - Fase final com dois golpes de moeda em quatro (Mortal, ataque, Cruel e forte), em vez de três (Mortal, Cruel, Pesado e ataque).

   O GDD §13 continua atendido: há golpe Cruel e, na fase final, Golpe Mortal. A varredura sem a checagem cobriu HP de 120 a 220 e FOR de 11 a 15. Depois, com a checagem ligada, foram medidas FOR 12, 13 e 14. Com FOR 12 e 13, o mediano passou da meta (72,8% e 66,7%), porque a suavização deixa o caminho mais fácil. Com FOR 14, o mediano vence 65,0% e o cuidadoso 64,0%. Os números estão em `docs/tasks/TASK-008-simulador-e-vencibilidade.md`.
10. **Chefe e meta de rota estão acoplados.** Com FOR 14, o mapa cru fica abaixo da meta de rota, e a checagem suaviza cerca de 3 vezes por mapa: é ela que segura a vitória perto da meta. Sem a checagem, os bots vencem 43% e 36%. Mexer no chefe, na meta de rota ou na suavização exige medir de novo com a checagem ligada.

## Pontos para o Orlando

- **Custo da checagem no aparelho:** com 200 simulações e cerca de 3 suavizações por mapa, criar uma Descida leva vários segundos no PC (cerca de 5 s medidos com FOR 12; com FOR 14 há mais suavização). Com 20 simulações, leva 0,3 s. No celular, deve ser várias vezes mais. Opções: rodar numa thread durante a transição de cenário (TASK-011), reduzir para 100 simulações (erro de cerca de 5 pontos na estimativa) ou guardar o resultado no save (TASK-012). Recomendação: thread mais save.
- **Mortes por moeda acima da meta:** com FOR 14, 31% das mortes do bot mediano são por moeda e 35% das do cuidadoso, contra a meta de 25%. Quase todas são no Golpe Mortal ou no Cruel do Coveiro, contra um bot que não se defende. A meta do §23 é sobre jogadores, que leem a intenção. Recomendação: manter assim até o playtest da TASK-006 e só então mexer na penalidade (fórmula, com ADR) ou na frequência.

## Alternativas

- **Meta de rota de 70%, como no exemplo do GDD:** suaviza quase todo mapa, custa mais tempo e deixa a Descida fácil demais para a meta do §23.
- **Calibrar o nível por camada ou o Poder:** as lutas comuns já estavam na meta (6,7 turnos, 97% de vitórias). O desequilíbrio era só no chefe.
- **Mudar a penalidade da moeda:** é fórmula do GDD §7. Fica para depois do teste de sensação.

## Consequências

- O `RULES_VERSION` sobe para 4. A checagem e a suavização mudam os mapas por semente, e o Coveiro mudou.
- O relatório do simulador fica em `reports/simulation.md`, fora do Git. É gerado por `tools/simulate.gd`, e um resumo vai para o arquivo da tarefa.
