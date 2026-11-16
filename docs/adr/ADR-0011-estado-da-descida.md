# ADR-0011: estado da Descida, leituras do GDD §4, §9, §12 e §15

| Campo | Valor |
| --- | --- |
| Status | Aceito (decisão técnica dentro da tarefa; números do protótipo calibrados na TASK-008) |
| Data | 2026-11-16 |
| Tarefa | TASK-007 |
| GDD | 4, 5, 9, 10, 12, 15 |

## Contexto

O núcleo já tem mapa, combate e dados, mas nada que ligue uma luta à outra. O GDD dá as fórmulas de Poder e de ouro, a fogueira e a loja. Ficam em aberto vários pontos: o que persiste entre lutas, o nível de cada nó, o que fazem baú, evento e emboscada no protótipo e como equipamentos e buffs entram no combate.

## Decisão

**Fórmulas (sem mudança, só ligadas)**

1. **Poder** ao vencer: `0,15 × N × m_tipo` (GDD §9). **Ouro** ao vencer: `round(6 × N × U(0,8; 1,2) × m_tipo)` (§15), com o `U` sorteado no fluxo de loot. m_tipo é 1 para comum e emboscada, 1,5 para elite, 2,5 para mini boss e 4 para chefe. Fugir não dá Poder nem ouro.

**Estado**

2. **HP e MP persistem** entre os nós. Quando o Poder sobe, o HP máximo sobe e o HP atual ganha a mesma diferença, ou seja, o crescimento não cura nem fere. O MP não cresce com o Poder (§9).
3. **A Maré de azar e os fluxos de sorteio** atravessam a Descida inteira: o `RunState` guarda um único `RngStreams` e um único `CoinState`.
4. **Descida = lista de cenários dos dados.** Vencer o chefe passa ao próximo cenário, com mapa novo do fluxo do mapa. Sem próximo, é vitória. O protótipo tem só o cenário 1. Ecos e telas de fim ficam para a TASK-011.

**Mapa**

5. **Nível de cada nó.** É interpolado de forma linear entre o nível mínimo e o máximo do cenário, pela camada: `min + round((max - min) × (camada - 1) / camadas)`. O chefe fica no máximo. A elite ganha +1, limitado ao máximo. O inimigo de cada nó de luta é sorteado do grupo do cenário no fluxo do mapa, logo depois da geração, para o jogador ver inimigo e nível antes de escolher (§5, neblina).
6. **Eventos fora do protótipo.** O peso de evento é 0 no protótipo e o sorteio se redistribui entre os outros tipos (ADR-0007, item 8). O roteiro deixa eventos fora do MVP. Voltam com ADR quando houver dados de eventos.
7. **Emboscada** é uma batalha comum por enquanto: os status iniciais (sangramento, pavor) não existem no combate.
8. **Baú** dá só ouro: `round(6 × N × U(0,8; 1,2)) × k`, com k sorteado entre 1 e 3 (§15, "1 a 3 vezes o ouro de uma batalha comum"). Item e armadilha com moeda entram com os drops.

**Fogueira (§12)**

9. **6 Brasas.** Descansar custa 3 e recupera 40% do HP e do MP máximos. As skills de fogueira do Guerreiro custam 2 Brasas cada (o GDD diz "1 a 2"). O buff vale nas próximas 3 lutas e não acumula: usar de novo renova a contagem. As lutas contam ao começar.
10. **Afiar Lâmina (+15% de dano)** entra como FOR × 1,15. O dano é proporcional ao ATK, então o efeito é o mesmo sem mexer no motor. **Reforçar Escudo (+15% de DEF)** entra como DEF × 1,15.

**Loja (§15)**

11. **Abre depois de cada vitória**, exceto contra o chefe. O chefe leva à loja de skills de fim de cenário, que fica fora do MVP. A loja tem 2 equipamentos e 2 consumíveis sorteados no fluxo de loot dos itens com preço. O item especial fica fora até existirem malditos e utilidades. Atualizar custa 15 moedas, mais 10 a cada nova atualização no mesmo nó.
12. **Equipamento comprado é equipado na hora** e substitui o do slot. Não há reserva nem venda no protótipo. Os modificadores entram somados depois do crescimento por Poder. Os buffs de fogueira multiplicam o total.
13. **Consumíveis:** até 8 (§10). A Descida começa com 2 Poções Turvas, o mesmo número do protótipo de combate (ADR-0010). Os itens usados numa luta são descontados do inventário a partir dos eventos dela.

**Transições**

14. Fases: escolher nó, em luta, loja, fogueira, vitória e derrota. Uma ação fora da fase certa é rejeitada e não muda nada. Cada mudança gera um `RunEvent` para a apresentação.
15. **O bot de regras** que completa uma Descida fica em `tests/support/run_bot.gd`. É ferramenta de teste e de simulação, não regra do jogo. A TASK-008 pode movê-lo para o simulador.

## Alternativas

- **HP cheio a cada luta:** mais simples, mas esvazia a fogueira (Descansar) e as poções.
- **Nível do nó sorteado numa faixa:** mais variado, mas é número sem fonte no GDD. A interpolação é previsível e fácil de calibrar.
- **Buff de dano como multiplicador novo no motor:** exigiria mudar a fórmula do §6 com ADR e subir `RULES_VERSION` sem necessidade.

## Consequências

- `RULES_VERSION` sobe para 3: a Descida é regra nova, e o peso de evento 0 muda os mapas do cenário 1 em relação ao gerador padrão.
- Os números do protótipo (níveis por camada, 2 Brasas por skill, poções iniciais, loja sem especial) são as primeiras alavancas da TASK-008.
