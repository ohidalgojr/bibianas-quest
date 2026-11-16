# ADR-0007: mapa em camadas, interpretações do GDD §5 e o que fica para o bot

| Campo | Valor |
| --- | --- |
| Status | Aceito (decisão técnica dentro da tarefa; o Orlando pode revogar na revisão) |
| Data | 2026-11-16 |
| Tarefa | TASK-003 |
| GDD | 5, 12 |

## Contexto

O GDD §5 descreve o mapa, mas deixa pontos em aberto que o código precisa fixar. Além disso, a prova de vencibilidade pede um bot que luta, e o combate só chega na TASK-004 (roteiro aprovado em 2026-11-16).

## Decisão

Nenhum número do GDD muda. As leituras adotadas:

1. **Ponto de partida.** Existe um nó de partida antes da camada 1, que oferece 3 colunas vizinhas sorteadas. Com largura 4, um nó da camada 1 fica fora de alcance naquela Descida.
2. **"As duas últimas camadas convergem para o chefe".** Todos os nós da última camada levam só ao chefe; ali o jogador tem 1 destino, e não 3.
3. **Fogueira da penúltima camada.** Fica em uma coluna que aparece nas 3 opções de qualquer nó da camada anterior (colunas 1 ou 2 com largura 4; coluna 2 com largura 5). Assim, todo jogador vê uma fogueira antes do chefe.
4. **Segunda fogueira** (mapas de 8 camadas ou mais, GDD §12). Fica na segunda metade, até a camada N - 3, em coluna sorteada. Nunca encosta na primeira, e pode não estar na rota do jogador.
5. **"Elite não aparece nos primeiros 30% das camadas".** Arredonda para cima: 2 camadas sem elite em mapas de 5 e 6, 3 camadas em mapas de 7 a 9.
6. **"Nunca três elites em uma mesma camada".** No máximo 2 elites por camada. Como cada nó vê 3 colunas, isso também garante uma opção que não é elite.
7. **"Baú: nunca dois em sequência".** Um baú nunca leva diretamente a outro baú.
8. **Tipos barrados redistribuem o peso.** Onde elite ou baú não podem aparecer, o sorteio é feito entre os outros tipos, na proporção dos pesos deles.
9. **Fogueira só nas posições garantidas.** Ela não entra no sorteio (o GDD a lista como "Garantida").

Adiado, com gancho pronto:

- **Bot de vencibilidade e "opção segura por nível"** (TASK-008). O grafo expõe `safest_route(custo)`, que recebe uma função de custo por nó. O roteiro falava em uma classe `RouteEvaluator`; uma função basta e é mais simples.
- **Mini boss** (o GDD não dá a chance), **mutações, nível e inimigo de cada nó**: entram com os dados do cenário.
- **"Elite 10% (sobe com o cenário)"**: o GDD não diz quanto sobe; fica 10 em todos os cenários até a calibração.

`MapRules.find_violations` confere as regras depois da geração, e `CoreVersion.RULES_VERSION` sobe para 1.

## Alternativas

- **Sortear tudo e descartar mapas inválidos:** mais simples de escrever, mas gasta sorteios de forma imprevisível e pode enviesar as frequências. Cumprir as regras por construção é determinístico e barato.
- **Bot simplificado agora:** daria uma "vencibilidade" com números inventados, que seria refeita na TASK-008.
- **Arredondar os 30% para baixo:** deixaria elite na camada 2 de um mapa de 5, logo no começo da Descida.

## Consequências

- A garantia "sempre existe caminho vencível" do GDD §5 **ainda não está provada**; hoje só as regras estruturais estão. Ela é critério de aceite da TASK-008.
- Eventos são sorteados com 9%, como no GDD. O roteiro deixa eventos fora do MVP; a configuração do cenário 1 do protótipo decide isso na TASK-005 ou 007, com ADR.
- Mudar qualquer leitura acima muda os mapas de todas as sementes: exige ADR novo e subir `RULES_VERSION`.
