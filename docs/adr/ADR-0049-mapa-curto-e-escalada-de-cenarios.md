# ADR-0049: cenário 1 curto (4 camadas) e escalada gradual dos cenários

| Campo | Valor |
| --- | --- |
| Status | Aceito (diretriz F-020 do Orlando, 2026-11-19; implementação pedida em 2026-11-22) |
| Data | 2026-11-22 |
| Tarefa | TASK-052 |
| GDD | 4, 5, 17, 23 |

## Decisão

1. O cenário 1 passa de 6 para 4 camadas mais o chefe: um tutorial-gancho ágil. Os inimigos, níveis (1 a 6) e recompensas não ficam mais fracos.
2. `MapConfig.SCENARIO_LAYERS = [4, 6, 7, 8, 10]`: cenários seguintes crescem de forma gradual em extensão.
3. Com menos lutas a Bibiana chega ao chefe com menos Poder (2,78 contra cerca de 4). O simulador mostrou vitória do mediano em 44% e 11% de mapas sem rota vencível; a alavanca escolhida, entre as do GDD §23, foi o Coveiro: HP 175 para 158 e FOR 16 para 15.
4. Resultado (150 Descidas): mediano 64,7% (meta 55% a 65%), 1ª Descida 42% (35% a 55%), mortes por moeda 11,3%, 0 mapas sem rota em 100.
5. As garantias da primeira Descida (ADR-0031) continuam: Cidadão Infectado na camada 1, baú na 2, elite na 3 ou 4.
6. `RULES_VERSION` sobe para 21: saves antigos são recusados.

## Consequências

A dificuldade dos cenários 2 a 5 (elites, mutações, pressão de recursos) fica para quando houver um segundo cenário.
