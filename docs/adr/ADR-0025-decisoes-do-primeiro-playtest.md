# ADR-0025: decisões do primeiro playtest (D1 a D6)

| Campo | Valor |
| --- | --- |
| Status | Aceito (decisões do Orlando, 2026-11-16); implementação nas TASK-021 a TASK-025 |
| Data | 2026-11-16 |
| Tarefa | nenhuma (decisão); as tarefas abaixo implementam |
| GDD | 6, 7, 10, 12, 15, 16, 21 (cada tarefa atualiza o GDD no mesmo commit do código) |

## Contexto

O Orlando jogou uma Descida completa e deu 12 pontos de feedback (`docs/FEEDBACK.md`, F-005 a F-017). Seis decisões dependiam dele (D1 a D6). Este ADR registra as respostas, com as palavras dele resumidas, e o que cada uma significa para o código. As regras do GDD só mudam junto com o código de cada tarefa (CLAUDE.md, regra 3); até lá, vale este ADR sobre o texto antigo do GDD.

## Decisões

### D1. A moeda é cara ou coroa, 50% e sem número; a sorte vai para o resto do jogo

- "A moeda é CARA OU COROA": são só dois resultados, então mostrar "chance de acertar" confunde. A chance do lance é **sempre 50%** e **não é exibida**. Saem da moeda: SORTE (+1 por ponto), Maré de azar (+10), trapaça (+20 por anúncio e Moeda Viciada +35) e o teto de 90%.
- **SORTE, Maré de azar e outros eventos passam a influenciar o encontro:** raridade e chance dos drops, qualidade do baú, inimigos mais difíceis (elites e mutados), emboscadas e eventos. O modelo exato é parte da TASK-021 (e da TASK-025 para inimigos mais difíceis).
- **A re-jogada da moeda vira drop raro** de baú, mini boss, roaming boss, inimigo mutado e chefe (a Moeda da Sorte do GDD §10), usada depois do resultado do lance. Fica fora do Clérigo (passiva Providência) até a classe existir.
- Consequências: o ADR-0014 continua valendo para a escolha de lado (ritual); a chance de acerto some da tela e do aviso do inimigo. As relíquias com SORTE passam a valer por drops e encontros.

### D2. Uma fogueira garantida por Descida; as outras custam lenha

- O jogador começa a Descida com **uma fogueira garantida**, que ele acende no nó de fogueira. As demais precisam de **lenha**, recurso raro que cai de inimigos e baús e que se compra na loja **por um preço alto**. Quem quer descansar toda hora precisa ter lenha para acender várias vezes: é uma mecânica de risco.
- Com mapa de 6 níveis de profundidade, ele pode passar por duas fogueiras, mas só a primeira é de graça.
- Consequências: o nó de fogueira continua no mapa, mas acender passa a gastar a fogueira garantida ou uma lenha; o GDD §12 (nó seguro e gratuito) e a regra do mapa (ADR-0007, uma fogueira na penúltima camada) mudam; a distribuição das fogueiras no mapa (antes do chefe ou a cada X nós) fica na TASK-023.

### D3. Ouro com sorte, mas equipar o mínimo; mapas mais longos e balanceados

- O ouro é aleatório e depende do drop, mas o jogador **precisa conseguir se equipar minimamente** antes do desafio. Os mapas ganham nós conforme a profundidade (mais inimigos), e o jogador deve chegar **preparado** para cada desafio: balancear o mapa é central.
- Consequências (TASK-022): subir o ouro e os drops, ajustar preços, aumentar o comprimento do mapa e o número de lutas e baús, e calibrar com o simulador **e com o `telemetry.log` do Orlando**, não só com bots. Meta de partida: ao chegar no chefe o jogador deve ter podido comprar ao menos uma peça de equipamento e uma poção.

### D4. Design de inimigos como papel de agente, sem aprovação prévia

- Aceito: um papel de **design de inimigos** na pipeline (GDD §21), com uma ficha por inimigo em `docs/enemies/` (fantasia e medo, mecânica assinatura, golpe de moeda temático, aviso e contra-jogo, drops). **O Orlando não precisa aprovar antes**: o agente de design preenche a ficha e a implementa; se ficar ruim, o Orlando dá feedback depois de jogar.
- Consequências (TASK-025): cada inimigo comum, a elite e o chefe ganham identidade; golpes de moeda temáticos (por exemplo, o rato passa leptospirose e tira 15% do HP) pedem o sistema de doenças (GDD §11).

### D5. Baú com multiplicador aleatório e moderado

- O multiplicador do baú (por anúncio, Moeda da Sorte ou item) é **aleatório e limitado**: nada de recompensa absurda, e o valor é balanceado no simulador. Anúncio é sempre opcional (GDD §16).
- Consequências (TASK-022): o multiplicador sorteia entre faixas pequenas (por exemplo ×1,25 a ×2), com teto por baú.

### D6. Crítico fica como está, mas visível e manipulável

- A mecânica do crítico (CRIT 5%, ×1,5) **não muda**. Precisa ficar **visível** (previsão e aviso na tela) e **manipulável** por eventos de mapa, skills e itens, "como em todo RPG".
- Consequências (TASK-024): mostrar a chance de crítico na previsão de dano, itens e skills que somam CRIT, e ao menos um evento de mapa que mexa nele.

## Tarefas que decorrem (a abrir, uma por vez, na ordem)

| Tarefa | Entrega | Decisões |
| --- | --- | --- |
| TASK-021 | Moeda 50/50 sem número; SORTE e Maré de azar nos drops e baús; Moeda da Sorte como drop raro e uso depois do lance | D1 |
| TASK-022 | Economia e mapa: ouro, preços, comprimento do mapa, baú com multiplicador moderado | D3, D5 |
| TASK-023 | Fogueira com lenha: uma garantida, outras compradas ou dropadas | D2 |
| TASK-024 | Combate legível: descrição das skills, previsão de dano e acerto (Darkest Dungeon), crítico visível e manipulável, MP | D6, F-007, F-008 |
| TASK-025 | Identidade dos inimigos: fichas, golpes de moeda temáticos, doenças | D4 |

## Alternativas

- **Manter a chance variável e só esconder o número:** o jogador sentiria o resultado sem entender; a sorte ficaria invisível e a moeda deixaria de ser "só cara ou coroa".
- **Mudar tudo de uma vez:** arrisca o equilíbrio; uma tarefa por vez permite rodar o simulador e jogar entre elas.
