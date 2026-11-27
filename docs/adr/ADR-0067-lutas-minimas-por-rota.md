# ADR-0067: nenhuma rota do mapa passa por menos de 2 lutas

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-27 |
| Tarefa | TASK-081 |
| GDD | 5, 6, 9 |

## Contexto

A revisão de game design jogou 12 Descidas e viu que a rota só de baú, fogueira e evento ganhou o chefe em 4 de 5 tentativas, duas delas com uma única luta. O jogador chega ao chefe sem Poder e sem ter aprendido o combate, e a Descida deixa de ser um desafio.

## Decisão

1. O gerador de mapa garante que a rota mais pobre em lutas (batalha, emboscada, elite, mini boss) tenha pelo menos 2 antes do chefe (`MapGenerator.MIN_FIGHTS_PER_ROUTE`).
2. O reparo é determinístico, sem sorteio: enquanto a rota mais pobre tiver menos que o mínimo, o primeiro baú ou evento dela vira batalha comum. Fogueiras não mudam.
3. A suavização da vencibilidade não pode trocar uma batalha por baú se isso deixar uma rota abaixo do mínimo.
4. `RULES_VERSION` sobe para 24 (as sementes mudam). O mapa de 4 camadas do primeiro cenário continua curto.

## Alternativas

- Exigir luta em cada camada: descartado, tiraria a escolha de rota e o respiro do baú e da fogueira.
- Subir o peso de batalha no sorteio: descartado, não dá garantia.

## Consequências

Menos Descidas sem desafio; um pouco menos de baús e eventos nas primeiras camadas. A calibração dos pesos de nó fica para depois do playtest do Orlando (simulador suspenso).
