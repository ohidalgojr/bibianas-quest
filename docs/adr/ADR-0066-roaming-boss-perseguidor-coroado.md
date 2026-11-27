# ADR-0066: Roaming boss O Perseguidor Coroado (alarme, perseguição e encontro forçado)

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-27 |
| Tarefa | TASK-080 |
| GDD | 5, 6, 7, 13, 21 |

## Contexto

O GDD §13 descreve o roaming boss estilo Nemesis, mas nada existia em código. O Orlando entregou o sprite e o dossiê (`TASK-054`). O primeiro mapa é curto e serve de tutorial-gancho (F-020), então ele não deve ganhar uma ameaça nova.

## Decisão

1. Mecânica pura em `RoamingRules` e `RunState`, só com contadores determinísticos (sem sorteio, sem nós): medidor de alarme (fugir +2, descansar +1, derrotar elite +1; limite 4), entrada a 3 nós atrás da Bibiana a partir da camada 2, avanço de 1 nó a cada nó escolhido, parada quando o destino é fogueira, encontro forçado que intercepta o próximo movimento.
2. O Perseguidor só existe em cenários com a flag `roaming_boss` nos dados. O cenário 1 fica sem a flag (tutorial intocado); a mecânica entra com os cenários 2 em diante. Testes e depuração ligam por `RunState.roaming_override`.
3. Novo tipo de inimigo `roaming_boss`: sem fuga, sem Golpe Mortal, multiplicador de Poder e ouro ×3 (já no GDD §9 e §15). Ciclo e números na ficha `ENEMY-20`.
4. Recompensa: Poder ×3, ouro, drop da tabela de elite, Moeda da Sorte e loja. Derrotado, não volta na mesma Descida.
5. O save guarda `alarm`, `pursuer_distance`, `pursuer_pending` e `pursuer_defeated`. `RULES_VERSION` sobe para 23.

## Alternativas

- Ligar no cenário 1: descartado, mudaria o fluxo do primeiro mapa sem decisão do Orlando.
- Distância em graus do grafo: descartado por ora; a contagem de nós escolhidos é equivalente numa Descida linear em camadas e mais simples de mostrar.

## Consequências

Mecânica pronta e testada, mas invisível na Descida atual (só há o cenário 1). Promoção por patentes, Cemitério de Rivais, Incenso de Cinzas e Alma (Forja) ficam para tarefas seguintes (GDD §13, itens 4 e 5).
