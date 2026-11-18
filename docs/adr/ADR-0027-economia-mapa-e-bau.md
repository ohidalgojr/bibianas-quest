# ADR-0027: economia, mapa mais longo e baú com multiplicador

| Campo | Valor |
| --- | --- |
| Status | Aceito, com 1 ponto de calibração em aberto |
| Data | 2026-11-17 |
| Tarefa | TASK-022 |
| GDD | 5, 12, 15, 16 |

## Contexto

D3 e D5 do ADR-0025: o dinheiro estava escasso, o personagem chegava fraco ao chefe e o caminho era curto. O Orlando pediu mapas mais longos conforme a profundidade, ouro suficiente para o jogador se equipar minimamente e um baú multiplicável de forma aleatória e moderada.

## Decisão

1. **Mapa:** o cenário 1 passa de 5 para 6 camadas (níveis 1 a 6); a escala por cenário vira 6, 7, 8, 9 e 10. Mapas de 6 camadas ou mais têm **2 fogueiras** (a segunda a ao menos 2 camadas da penúltima). A lenha que governa a segunda fogueira entra na TASK-023.
2. **Frequência dos nós:** baú de 8 para 14 em 100; batalha de 55 para 49.
3. **Ouro:** ΔOuro por inimigo = round(10 × N × U(0,8; 1,2) × m_tipo), antes 6. Baús continuam de 1 a 3 vezes o ouro de uma batalha comum, com o bônus de SORTE (ADR-0026).
4. **Baú multiplicável (D5):** o baú abre num painel; o jogador pode multiplicá-lo **uma vez**, com uma Moeda da Sorte ou com um anúncio opcional. O multiplicador é sorteado no fluxo de loot: ×1,25 (50%), ×1,5 (35%) e ×2 (15%); o ×2 também rende uma Poção Turva. No protótipo o anúncio é **simulado** (não há SDK de anúncios); a regra de ser sempre opcional vem do GDD §16.
5. **Coveiro:** HP 215 → 225 e FOR 16 (era 215/16 pela TASK-019, que tinha 150/14 antes). Com mais ouro e mais lutas, o jogador chega mais forte.
6. `RULES_VERSION` sobe para 10.

## Verificação no simulador

Regras v10 (`reports/simulation.md`, 2026-11-17), 150 Descidas por bot e 60 mapas com 40 simulações por checagem:

| Coveiro | Mediano (meta 55% a 65%) | Cuidadoso | Mapas sem rota vencível | Tempo para criar a Descida |
| --- | --- | --- | --- | --- |
| 215/16, sem recalibrar | 78,0% | 88,7% | 0 de 100 | 0,5 s |
| 240/17 | 68,0% | 88,0% | 3 a 4 de 60 a 100 | 5,7 s |
| **225/16 (adotado)** | **76,7%** | 88,7% | **0 de 60** | 1,6 s |

Mortes por moeda em 17,1% (mediano). O ouro médio do mediano ao fim é de 264; antes do chefe sobram cerca de 70, depois de comprar equipamento e poções, então a meta "chegar com ao menos uma peça e uma poção" é atendida.

**Conflito entre duas metas do GDD:** a faixa de 55% a 65% para o jogador mediano e a garantia de que todo mapa tem rota vencível (GDD §5) só cabem juntas num intervalo estreito. Com o Coveiro mais forte, o mediano chega perto da faixa (68%), mas 5% a 7% dos mapas passam a não ter rota vencível e a criação da Descida fica lenta (5,7 s no PC, pior no celular). Adotei o Coveiro mais fraco: o mediano fica acima da faixa (76,7%), mas a garantia do mapa e o tempo de criação se mantêm.

**Ponto em aberto:** o jogador humano chegou fraco ao chefe na primeira jogada, ao contrário dos bots. Antes de endurecer o Coveiro, calibrar com o `telemetry.log` do Orlando nesta versão.

## Alternativas

- **Endurecer os inimigos comuns em vez do chefe:** cabe em outra rodada se a telemetria mostrar que as lutas comuns ficaram fáceis.
- **Anúncio de verdade:** depende de escolher o SDK e do GDD §16; o botão simulado mantém o fluxo testável.
