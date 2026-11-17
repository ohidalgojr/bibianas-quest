# ADR-0026: moeda 50/50, sorte nos drops e Moeda da Sorte

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-16 |
| Tarefa | TASK-021 |
| GDD | 7, 10, 16 |

## Contexto

D1 do ADR-0025: "a moeda é cara ou coroa", só dois resultados; mostrar chance confunde. SORTE, Maré de azar e eventos devem influenciar itens raros, inimigos mais difíceis e emboscadas. A re-jogada vira drop raro.

## Decisão

1. **Moeda:** `CoinRules.chance()` é sempre 50. Saem da moeda a SORTE, a Maré de azar, a trapaça (+20 por anúncio, +35 com Moeda Viciada) e os limites de 15 a 85 e 90. A tela não mostra chance da moeda. O sorteio continua no fluxo da moeda, um por lance.
2. **SORTE nos drops** (valores do protótipo): +1 ponto na chance de equipamento por ponto de SORTE (teto +15) e, por ponto, 2 pontos de peso movidos da raridade mais baixa para a mais alta da tabela do tipo de inimigo. No baú, +3% no ouro por ponto de SORTE e +1 ponto na chance de Moeda da Sorte por ponto.
3. **Maré de azar:** depois de 3 lances de moeda perdidos seguidos (contador na Descida, entre combates), a **próxima vitória com drop** garante o equipamento e desloca 10 pontos de peso para a raridade mais alta; o contador zera. É o seguro contra o azar da moeda, pago em achados.
4. **Moeda da Sorte** (`lucky_coin`, consumível raro, fora da loja): fontes de baú 6%, elite 8% (mais SORTE) e chefe garantida. O jogador a arma no combate; no primeiro lance que cair errado, a moeda é rejogada uma vez e gasta (se o primeiro lance acerta, nada se gasta). O núcleo não precisa parar no lance: armar antes e decidir dentro do lance mantém o motor atômico.
5. **Evento da moeda:** `CombatEvent.COIN` continua trazendo o resultado final; `extra` passa a valer 1 quando houve re-jogada (antes era o bônus da Maré).
6. **Inimigos mais difíceis e emboscadas por sorte** ficam para a TASK-025 (identidade dos inimigos), porque dependem de variantes dos inimigos.
7. **Monetização:** a trapaça por anúncio e a Moeda Viciada à venda saem do GDD §7, §10 e §16. O que o anúncio de moeda vira (por exemplo, uma re-jogada limitada) é decisão de monetização futura, não do protótipo.
8. `RULES_VERSION` sobe para 9.

## Alternativas

- **Re-jogada decidida depois do resultado:** exige pausar o motor entre o lance e o dano (ADR-0014 já anotava isso). Fica para quando houver trapaça ou eventos que peçam pausa.
- **Maré de azar como bônus de HP ou de moeda:** o jogador não sentiria o seguro; um achado melhor aparece na recompensa.

## Consequências

- Os testes de fórmula da moeda mudam (50 fixo).
- Relíquias com SORTE passam a valer por drops e baús.
- O simulador roda de novo (drops com SORTE e Maré de azar).

## Verificação no simulador

150 Descidas por bot, regras v9 (`reports/simulation.md`, 2026-11-16): mediano 64,7% de vitória (meta 55% a 65%), cuidadoso 76,7%; mortes por moeda 15,1% (mediano) e 20,0%; combate comum de 6,5 a 6,6 turnos. Com 10 simulações por checagem e 100 mapas, 1 mapa ficou sem rota vencível; a rodada anterior, com os mesmos parâmetros, teve 0. Parece ruído do teste rápido (o jogo usa 200 simulações), mas fica como ponto a repetir com a configuração completa na TASK-022, que mexe no mapa. Os bots não usam a Moeda da Sorte.
