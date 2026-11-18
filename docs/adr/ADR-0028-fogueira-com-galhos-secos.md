# ADR-0028: fogueira com Galhos Secos

| Campo | Valor |
| --- | --- |
| Status | Aceito (reescrito em 2026-11-18 depois de o Orlando corrigir a leitura de D2) |
| Data | 2026-11-17 |
| Tarefa | TASK-023 |
| GDD | 12, 15 |

## Contexto

D2 do ADR-0025. A primeira implementação deu **uma única fogueira por Descida inteira** (1 lenha no começo) e deixou a segunda fogueira do mapa, na prática, apagada. O Orlando corrigiu: o mapa deve **sempre ter mais de um lugar para armar fogueira**; o jogador recebe, **garantidos por mapa**, os itens para **uma** fogueira; para armar mais, precisa de itens extras, raros (drop de inimigo, mini boss e chefe, ou compra na loja a preço alto). O objetivo é um recurso escasso e uma escolha de estratégia: quem sacrifica ouro e coleta para ter mais uma fogueira antes do chefe chega bem, e quem não precisou usou o recurso em outra coisa. Com fogueira infinita, o jogador chegaria ao chefe sempre cheio.

## Decisão

1. **O item da fogueira se chama Galhos Secos** (`firewood`); as Brasas continuam sendo o recurso das ações do acampamento (descansar e skills). Armar a fogueira gasta 1 Galho Seco e dá as 6 Brasas; entrar no nó e sair sem armar não gasta nada.
2. **Garantidos por mapa:** ao entrar em cada mapa (cenário) a Descida recebe 1 Galho Seco (`FIREWOOD_PER_MAP`). Galhos que sobraram do mapa anterior ficam: poupar é uma estratégia.
3. **Mais Galhos são raros:** inimigo comum 5%, elite 20%, baú 15% (mais SORTE em cada chance), chefe sempre 1 (vale para o mapa seguinte) e, quando existir, mini boss; ou compra na loja a **120 moedas**, entre os consumíveis sorteados, bem acima de uma poção (30) e do Éter (25).
4. **Mais de um lugar para armar:** o número de fogueiras no mapa acompanha a profundidade: 1 até 5 camadas; de 6 em diante, uma a cada 3 camadas, com ao menos 2 (`MapConfig.bonfire_count`: 6 e 7 camadas, 2; 8 a 10, 3; 11 e 12, 4). A penúltima camada continua sempre oferecendo uma. As outras ficam a pelo menos 2 camadas de qualquer fogueira, para nunca ficarem ligadas entre si.
5. **Equilíbrio esperado:** com 2 fogueiras e 1 Galho garantido, o jogador escolhe em qual das duas armar, ou paga o preço de um segundo Galho para armar as duas, por exemplo uma antes do chefe.
6. A concessão do Galho do mapa acontece **antes** de gerar o mapa, porque a checagem de vencibilidade (GDD §5) simula o bot com os consumíveis da Descida e precisa contar com ele.
7. `RULES_VERSION` sobe para 11.

## Verificação no simulador

Coveiro com HP 205 e FOR 16 (HP 225 deixava o mapa sem rota vencível com a fogueira escassa; a criação da Descida chegou a 686 s). Resultados em `reports/simulation.md` (150 Descidas por bot, 30 mapas com 40 simulações): bot mediano 68,7% de vitória (meta 55% a 65%), cuidadoso 84,0%, mortes por moeda 19,1%, 0 de 30 mapas sem rota vencível, 1,1 s para criar a Descida. Os bots não escolhem entre as duas fogueiras e quase nunca compram o segundo Galho; um jogador esperto pode se sair melhor ou pior, e só o `telemetry.log` dele diz.

## Alternativas

- **Uma fogueira por Descida inteira** (primeira versão): escassa demais para os mapas longos e sem escolha de estratégia.
- **Fogueira sempre gratuita no nó garantido, extras caras:** o jogador nunca decide entre armar ou guardar.
- **Número fixo de fogueiras por mapa:** não acompanha a profundidade, que o Orlando quer justa.

## Consequências

- Os bots acendem quando têm Galhos e compram um quando sobra ouro; o bot não escolhe entre as duas fogueiras, então o simulador subestima um jogador esperto.
- A cura de doenças (TASK-025) usa Brasas, não Galhos.
