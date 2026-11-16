# ADR-0022: drops de inimigos e equipamento

| Campo | Valor |
| --- | --- |
| Status | Aceito, com 1 ponto de calibração em aberto |
| Data | 2026-11-16 |
| Tarefa | TASK-018 |
| GDD | 10, 15 |

## Contexto

Pedido do Orlando (F-004 em `docs/FEEDBACK.md`): drops de inimigos como mecânica básica de roguelike RPG. O GDD §10 já dá as chances de equipamento (12% comum, 35% elite) e a raridade; a venda é a 40% (§15).

## Decisão

1. **Equipamento:** comum 12% e elite 35% (GDD §10). Chefe não solta (dá Alma, fora do protótipo). Sorteio no fluxo de loot, logo depois do ouro.
2. **Raridade por pesos** (valores do protótipo): comum 30% gasto, 55% comum, 15% incomum; elite 30% comum, 45% incomum, 25% raro. O raro vem só de elites, como diz o GDD, e **não entra na loja**.
3. **Consumível de cura** (proposta minha, o GDD não fala): comum 30%, elite 50%, se a mochila (8) tiver espaço. Só consumíveis que curam HP, porque o Éter Sujo ainda não tem uso em combate.
4. **Decisão na hora:** o drop fica pendente na fase da loja e a recompensa pergunta Equipar ou Vender. Equipar vende o item trocado a 40% e vender paga 40% do drop. Sair da loja vende o drop pendente. Não há inventário reserva (o GDD prevê 6): decidir na hora mantém o fluxo curto no celular.
5. **Itens novos:** 9 equipamentos em arma, armadura e relíquia, de comum a raro. Relíquia entra como um espaço (o GDD prevê dois).
6. **Bots:** equipam o drop se a raridade for maior que a do item do espaço; senão vendem.
7. `RULES_VERSION` sobe para 6 (a loja mudou, o fluxo de loot consome mais sorteios).

## Verificação no simulador

200 Descidas por bot, regras v6 (`reports/simulation.md`):

| Bot | Vitória do cenário 1 | Mortes por moeda | Turnos por combate comum |
| --- | --- | --- | --- |
| Mediano (meta 55% a 65%) | 65,5% (era 56,0%) | 29,0% de 69 mortes (meta até 25%) | 6,3 |
| Cuidadoso | 78,5% (era 74,5%) | 20,9% | 6,3 |

Os drops somam cerca de 9 pontos de vitória ao mediano, no limite da meta. A parcela de mortes por moeda subiu porque há menos mortes no total (69 contra 88), então o número pesa mais; não é sinal de mais golpes de moeda.

**Ponto em aberto:** as TASK-019 (ganho de status) e TASK-020 (skills na loja) vão somar poder de novo. Recalibrar o Coveiro (HP, FOR ou golpes) uma vez, depois das três, com o simulador, e registrar em ADR.

## Alternativas

- **Inventário reserva de 6 e venda na loja:** mais profundidade de escolha, mais tela e mais custo; fica para depois do teste de sensação.
- **Equipar automático:** tira a decisão, que é parte do prazer do drop.
