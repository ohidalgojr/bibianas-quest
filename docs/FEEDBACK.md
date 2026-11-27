# Feedback de playtest do Orlando

Registro cru do que o Orlando sentiu jogando, em ordem. Cada item tem um id, o que ele disse, o que o código faz hoje e para onde vai. Nada aqui muda regra sozinho: mudança de fórmula ou de regra do GDD exige ADR, GDD atualizado, `RULES_VERSION` e nova rodada do simulador (CLAUDE.md, regra 3). Quando virar tarefa, trocar "Aberto" por "Em TASK-NNN".

## 2026-11-16, depois de jogar as TASK-009 a 013

### F-001: o chefe lança ataques de moeda demais em sequência

- **Status:** atendido na TASK-016 (ADR-0020), falta o Orlando confirmar jogando: intervalo mínimo de 2 golpes entre golpes de moeda, sem exceção para chefes; a exceção da fase final foi removida e o Coveiro ficou com 1 golpe de moeda por fase de 5 golpes, mais os dois novos golpes de debuff. Fica mais evidente desde a TASK-015, porque agora o jogador escolhe o lado em cada lance.
- **Hoje:** o GDD §7 e o ADR-0008 proíbem dois golpes de moeda seguidos, exceto na fase final de chefe; o ADR-0012 calibrou o Coveiro com 2 golpes de moeda em 4 na fase final, e mesmo antes disso o ciclo dele tem vários. Mortes por moeda no simulador: 31% e 35%, acima da meta de 25% (pendência 5 do HANDOFF).
- **Direção:** tirar a exceção dos chefes ou limitar a um golpe de moeda a cada 3 turnos; recalibrar o Coveiro com o simulador. Exige ADR, GDD §7 e `RULES_VERSION`.

### F-002: o chefe precisa de ataques com debuff por probabilidade; senão a moeda decide tudo

- **Status:** atendido na TASK-016 (ADR-0020), falta o Orlando confirmar jogando: golpes `debuff` (Toque Podre com Veneno 60%, Maldição do Coveiro com Fraqueza 70%), chance própria no fluxo de combate, aviso DEBILITA com a chance e Defender cortando pela metade. Falta: Sangramento, doenças, itens e skills que curam, e debuffs em inimigos comuns.
- **Hoje:** todo golpe especial do inimigo é "moeda e dano maior" (Pesado, Cruel, Mortal). O Golpe Cruel deveria dar debuff ou risco de doença na Coroa (GDD §7), mas o ADR-0008 (decisão 8) deixou isso para depois; doenças e debuffs de inimigo ainda não existem. Resultado: a única variável de risco é a moeda.
- **Direção:** golpes com efeito (veneno, sangramento, Lentidão, Guarda aberta, doença do GDD §11) que acertam por chance própria (fluxo de combate, não o da moeda), visíveis com ícone e chance no aviso, e que o jogador possa mitigar (Defender, itens). A moeda continua para os golpes de risco, mas não é o único. Precisa de sistema de efeitos no inimigo e no jogador; provável ADR de efeitos e doenças.

### F-003: matar inimigos não dá senso de progressão

- **Status:** em andamento. A TASK-017 (ADR-0021) entregou o retorno visual: a recompensa lista quem caiu e cada atributo antes e depois, o mapa mostra FOR, DEF, VEL e inimigos derrotados, e a luta ganhou números de dano e animação de abate. **Achado:** com o Poder subindo 0,15 por nível de inimigo, uma luta comum no começo muda só 1 ou 2 de HP e nada nos demais atributos. O retorno agora aparece, mas é pequeno. A causa é a economia (GDD §9), não a tela. Decisão do Orlando pendente: drops de equipamento dos inimigos, marcos por camada ou mudar a curva do Poder (qualquer um exige ADR e nova calibração).
- **Hoje:** a vitória só rende Poder (invisível durante o mapa, sem barra), ouro e a loja; o único retorno é um texto na tela de recompensa. Não há dropes, nível visível, nem sensação de a Bibiana ficar mais forte entre uma luta e outra.
- **Direções a avaliar (propostas, não decididas):** mostrar o Poder como progresso da Descida (barra e ganho de atributos explícito, "FOR 14 → 16"); drops de itens e equipamentos dos inimigos, com a raridade do GDD §10; marcos por camada; efeito e texto de abate; a Bibiana ganhando algo permanente por inimigo-tipo (códice, §11). Pede conversa com o Orlando antes de virar tarefa, porque mexe no laço central do jogo.

## Como isso entra no roteiro

Propostas, a decidir com o Orlando depois da TASK-014 (portão da Fase 1):

1. **TASK-016, ajuste do laço de combate:** F-001 e F-002 (ritmo de moeda do chefe, efeitos e debuffs por probabilidade), com ADR e nova rodada do simulador.
2. **TASK-017, progressão visível:** F-003, depois de definir a direção.

## 2026-11-16, depois da TASK-017

### F-004: faltam as mecânicas básicas de um roguelike RPG: ganho de status, drops e magias na loja

- **Status:** atendido nas TASK-018, 019 e 020 (ADR-0022, 0023 e 0024); falta o Orlando confirmar jogando. Escolhida pelo Orlando como direção do F-003 (drops dos inimigos) e ampliada.
- **Pedido (três pontos):** (1) ganho de status que se sinta, (2) drops de inimigos, (3) novas magias (skills) para comprar na loja.
- **Plano, uma tarefa por ponto, nesta ordem:**
  1. **TASK-018, drops e equipamento:** inimigos soltam equipamento e consumíveis; a recompensa pergunta "Equipar ou Vender"; novos itens de arma, armadura e relíquia, com raridade.
  2. **TASK-019, ganho de status:** a Bibiana sobe de nível de forma discreta, com ganho de atributos que se vê.
  3. **TASK-020, skills na loja:** novas skills do Guerreiro à venda, com mais espaços de skill no combate.

## 2026-11-16, primeira jogada completa (depois da TASK-020)

**Congelamento:** o Orlando pediu só documentar. Nenhum item abaixo foi implementado; todos estão com status "Aberto". Os pontos precisam ser decididos e corrigidos antes de qualquer tarefa nova (a TASK-014, de exportação, também espera). As falas estão registradas como ditas; as seções "Hoje" e as observações são da leitura do código, do GDD e do simulador.

### F-005: o dinheiro está escasso, mal dá para comprar algo na loja

- **Status:** aberto.
- **Hoje:** ouro por luta = 6 × nível × U(0,8 a 1,2) × m_tipo. Uma luta de nível 1 a 2 dá de 6 a 21 moedas. Preços: Poção Turva 30, Éter Sujo 25, equipamento comum de 90 a 140, incomum de 150 a 190, skills de 100 a 140. O relatório do simulador mostra 173 a 194 de ouro no fim da Descida, mas isso inclui o chefe (6 × 6 × 4 = cerca de 144); antes do chefe sobram perto de 40 a 60, menos que o item mais barato da loja. O mapa tem baús (de 1 a 3 vezes o ouro de uma luta comum), mas só 2 a 3 lutas por Descida.
- **Relação:** F-016 (fraco no chefe), F-015 (baú), GDD §15 ("o jogador nunca consegue comprar tudo", meta de ouro para cerca de 60% do que se quer comprar ao fim do cenário). Hoje é bem menos que isso.
- **Direções:** subir o ouro por luta e por baú, baratear itens, ou aumentar o número de lutas e baús por mapa. Qualquer uma pede ADR e nova rodada do simulador.

### F-006: os golpes de moeda são simplórios (só dano alto); deveriam causar debuffs

- **Status:** aberto.
- **Hoje:** Pesado (Coroa: dano +50%), Cruel (Coroa: dano +100%) e Mortal (Coroa: dano +150%) só mudam dano. O GDD §7 prevê debuff ou risco de doença na Coroa do Cruel; o ADR-0008 (decisão 8) deixou isso para depois. A TASK-016 criou golpes de debuff com chance própria (Veneno, Fraqueza), mas fora da moeda e só no Coveiro.
- **Relação:** F-012 (moedas temáticas por inimigo), F-013 (inimigo único), F-002 (atendido em parte).
- **Direção do Orlando:** a moeda deveria carregar efeito, não só número.

### F-007: o MP do Guerreiro está curto, e as skills não têm descrição nem números

- **Status:** aberto.
- **Hoje:** o Guerreiro tem 20 de MP, que não cresce com o Poder (o GDD §9 só escala HP, FOR, MEN, DEF, RES e VEL). Defender devolve 10% do MP máximo, ou seja 2. Cada skill custa de 4 a 8. O Éter Sujo (restaura 50% do MP) existe na loja, mas não tem uso em combate. Os botões de skill mostram só "Nome (custo MP)"; não há tooltip de efeito, dano ou chance.
- **Relação:** F-008 (dano e chance visíveis).
- **Direções:** MP máximo crescendo com o Poder ou com equipamento, retorno de MP por ação, uso do Éter em combate, e uma descrição curta em toda skill.

### F-008: mostrar o dano aproximado da skill e a chance de acertar (inspirado em Darkest Dungeon)

- **Status:** aberto.
- **Pedido:** exibir faixa de dano (exemplo: 20-40) e chance de acerto antes de escolher a ação.
- **Hoje:** o motor já calcula tudo: acerto = PRE (90 de base mais bônus) menos ESQ do alvo, variação de dano de 0,9 a 1,1, crítico ×1,5 e defesa do alvo. A tela não mostra nada disso. O motor precisa de uma função de "previsão" (mínimo, máximo, chance de acerto, chance de crítico) sem sortear, para a tela só ler.
- **Relação:** F-007 (descrição das skills), F-011 (crítico), GDD §7 (sem números escondidos).

### F-009: poder se curar na fogueira; analisar se ela deve aparecer antes do chefe ou a cada X nós

- **Status:** aberto; precisa de análise de distribuição.
- **Hoje:** a fogueira já cura: Descansar custa 3 das 6 Brasas e recupera 40% de HP e MP (GDD §12, ADR-0011). Mas a regra do mapa (GDD §5, ADR-0007) só garante uma fogueira na penúltima camada, em pelo menos uma das três opções, e nunca duas ligadas. Uma rota que não escolhe a fogueira nunca a vê, e o jogador pode chegar ao chefe sem ter passado por uma. Falta confirmar se, na jogada, a fogueira apareceu e se ficou claro que Descansar cura.
- **A analisar:** quantas fogueiras por mapa, em quais camadas ("antes do chefe" ou "a cada X nós") e quanto cada uma cura. Usar o simulador e o `telemetry.log` do Orlando.

### F-010: ligar a fogueira a um recurso raro (drop de inimigo ou baú), também à venda, mas caro

- **Status:** aberto; é decisão de design e mexe no GDD.
- **Pedido:** para compensar ter mais fogueiras, o uso delas deve depender de um item raro, que cai de inimigos ou baús e também pode ser comprado na loja a preço alto. A fogueira vira um recurso pensado.
- **Hoje:** o GDD §12 trata a fogueira como nó seguro e gratuito, com Brasas limitadas por visita. As Brasas já são o recurso, mas vêm de graça com o nó.
- **Conflito a decidir:** o item substitui as Brasas, é a "chave" para acender o nó, ou só amplia as Brasas?

### F-011: implementar mecânica de ataque crítico

- **Status:** aberto; verificar o que o Orlando percebeu.
- **Hoje:** o crítico já existe no motor: chance igual ao atributo CRIT (5% do Guerreiro), dano ×1,5 (GDD §6), linha no registro ("crítico!") e número dourado com "!" na luta. Na prática 5% quase não aparece, e o jogador não tem como aumentar a chance (só a Adaga de Osso e a Machadinha Enferrujada dão CRIT).
- **Direções:** é questão de visibilidade (efeito mais forte, chance na previsão do F-008) e de acesso (mais fontes de CRIT, skills que crítam), não de criar do zero.

### F-012: os golpes de moeda devem ser temáticos por inimigo

- **Status:** aberto.
- **Exemplo do Orlando:** o rato pode passar leptospirose e reduzir o HP em 15%.
- **Hoje:** os golpes de moeda são genéricos (Pesado, Cruel, Mortal), com a mesma consequência em todo inimigo. Doenças (GDD §11) ainda não existem no código.
- **Relação:** F-006, F-013. Exige o sistema de doenças e debuffs de combate (Veneno e Fraqueza já existem; falta persistência entre lutas e cura).

### F-013: cada inimigo deve ser único ("puts, o inimigo X de novo"), inspirado forte em Fear & Hunger

- **Status:** aberto.
- **Pedido:** cada inimigo causa um medo diferente, para o jogador reconhecer e odiar cada um. O Orlando sugeriu deixar uma tarefa para um agente de design de inimigos enriquecer o processo, ou outra forma dentro da pipeline.
- **Hoje:** os 4 inimigos comuns, a elite e o chefe diferem em números e no ciclo de golpes, mas todos usam os mesmos golpes genéricos; não há identidade mecânica, de aviso nem de texto por inimigo.
- **Proposta de processo (a decidir):** um papel de design de inimigos na pipeline do GDD §21, como parte da etapa 1 de cada inimigo: uma ficha `docs/enemies/ENEMY-NN-nome.md` (modelo a criar), com fantasia e medo, mecânica assinatura (golpe de moeda temático, debuff, regra própria), aviso e contra-jogo, drops, texto de aviso e ícone. Um agente de design preenche a ficha, o Orlando aprova, e só então abre-se a tarefa de código. Não mexe no GDD sem ADR.

### F-014: a moeda não deve mostrar chance; seria sempre 50% cara ou coroa; o reroll vira drop raro

- **Status:** aberto; **conflita com o GDD §7 e com o ADR-0014**, precisa de decisão do Orlando.
- **Pedido:** tirar a chance de acerto da tela e fixar 50/50. Transformar o reroll da moeda em drop raro de baú, mini boss, roaming boss, inimigo mutado e chefe.
- **Hoje:** chance = 50 + SORTE (até +15) + mods, limitada a 15 a 85; Maré de azar (+10 depois de 3 perdas); trapaça de +20 (anúncio) ou +35 (Moeda Viciada) até 90. O GDD §7 pede "a chance real aparece em um tooltip, sem números escondidos". A re-jogada é passiva do Clérigo e item Moeda da Sorte (GDD §7 e §10). As relíquias com SORTE (Amuleto Gasto +4, Sino do Coveiro +8) existem por causa da chance variável.
- **O que quebra se for 50/50:** SORTE, a Maré de azar, a trapaça e as relíquias de SORTE perdem o sentido ou precisam de outro papel (por exemplo, SORTE melhorar drops). O princípio "sem números escondidos" também muda. Se a chance fica fixa, não há o que mostrar.
- **O que combina:** a re-jogada como item raro (a Moeda da Sorte já está no GDD §10) dá peso a cada lance e valor aos itens de baú.

### F-015: mais mecânicas de loop viciantes; o baú poderia multiplicar o loot com anúncio, Moeda da Sorte ou item

- **Status:** aberto.
- **Hoje:** o GDD §16 já prevê "dobrar o ouro do baú" por anúncio opcional (sem limite fixo), e o §26 lista ganchos de hábito (morte que ensina, votos, descida diária, Brasa Acesa). Nada disso está implementado; o baú do protótipo só dá ouro.
- **Pedido novo:** o baú multiplicar o loot (não só o ouro), com anúncio, Moeda da Sorte ou item parecido. Cuidado com o GDD §16: anúncio é sempre opcional e nada pago dá poder exclusivo.

### F-016: a Bibiana chega bem fraca ao chefe; o caminho talvez esteja curto

- **Status:** aberto; é a leitura de causa do F-005 e do F-015.
- **Hipótese do Orlando:** pobreza de loot e dinheiro para equipar, e poucos nós para acumular experiência.
- **Dados:** o mapa tem 5 camadas e o bot passa por cerca de 5 a 6 nós por Descida (menos de 3 lutas antes do chefe). O GDD prevê 5 a 9 nós e 8 a 12 minutos por cenário. O simulador diz que o bot mediano vence o chefe 65% das vezes, mas o bot não joga como uma pessoa (gasta o ouro de outro jeito, não lê o aviso). O resultado humano diverge do simulado.
- **Relação:** F-005, F-009, F-015. A calibração deve usar o `telemetry.log` do Orlando como referência, não só o bot.

### F-017: as jogadas de moeda estão muito frequentes

- **Status:** aberto.
- **Hoje:** o inimigo usa um golpe de moeda com ao menos 2 golpes de intervalo (TASK-016), mas há outras fontes de moeda: o Golpe de Escudo do jogador (moeda a cada uso, escolha de lado obrigatória) e o Fugir. Cada moeda exige escolher o lado e esperar o giro de 1,2 s, então de 3 a 5 moedas numa luta de chefe cansam.
- **Relação:** F-001 (ritmo do chefe), F-014 (peso de cada lance). Menos moedas, com mais peso por moeda, é coerente com a ideia do reroll raro.

## Conflitos com o GDD e decisões que dependem do Orlando

| # | Pergunta | Itens | O que muda |
| --- | --- | --- | --- |
| D1 | A chance da moeda fica fixa em 50%, sem exibir? E o que acontece com SORTE, Maré de azar e trapaça? | F-014 | GDD §7 e §10, ADR-0014 e as relíquias de SORTE |
| D2 | A fogueira passa a exigir um item raro? O item substitui as Brasas, é a chave do nó ou amplia as Brasas? | F-009, F-010 | GDD §12 e a regra de mapa (ADR-0007) |
| D3 | Quanto de ouro e quantos nós por cenário? | F-005, F-016 | GDD §5, §15 e a meta de 60% do ouro desejado |
| D4 | Aceita um papel de design de inimigos na pipeline, com ficha por inimigo? | F-013 | GDD §21 (novo papel) e `docs/enemies/` |
| D5 | Baú com multiplicador por anúncio, Moeda da Sorte ou item: com que limite? | F-015 | GDD §16 e §26 |
| D6 | Crítico: só visibilidade e mais fontes de CRIT, ou mecânica nova? | F-011 | GDD §6 |

## Agrupamento proposto em tarefas (nada aberto ainda)

A abrir só depois de o Orlando decidir D1 a D6:

1. **Economia e ritmo da Descida** (F-005, F-016, F-015): ouro, preço, número de nós e baús.
2. **Legibilidade do combate** (F-007, F-008, F-011): descrição das skills, previsão de dano e chance, crítico visível, MP.
3. **Fogueira como recurso** (F-009, F-010): distribuição no mapa e item raro.
4. **Moeda: peso e frequência** (F-014, F-017, F-001): 50/50, reroll como drop raro, menos lances.
5. **Identidade dos inimigos** (F-006, F-012, F-013): processo de design de inimigos, ficha, golpes de moeda temáticos e doenças.

## Para analisar com dados reais

O Orlando joga com `telemetry.log` ligado (build de depuração). Se ele enviar o arquivo (em `%APPDATA%\Godot\app_userdata\<nome do projeto>\telemetry.log`), dá para medir moedas por luta, ouro por Descida, nós percorridos e a causa de cada morte, e calibrar F-005, F-016 e F-017 com jogada de pessoa, não só com bot.

## Respostas do Orlando às decisões D1 a D6 (2026-11-16)

Registradas e decididas no **ADR-0025**. Resumo:

- **D1:** a moeda é cara ou coroa, 50% fixo e sem número. SORTE, Maré de azar e eventos passam a influenciar drops raros, baús, inimigos mais difíceis e emboscadas. A re-jogada vira drop raro (baú, mini boss, roaming boss, mutado, chefe).
- **D2:** uma fogueira garantida por Descida; as demais exigem lenha (rara, cai de inimigos e baús, cara na loja).
- **D3:** ouro aleatório mas suficiente para o mínimo de equipamento; mapas mais longos e balanceados para o jogador chegar preparado.
- **D4:** design de inimigos aceito como papel de agente, sem aprovação prévia do Orlando.
- **D5:** multiplicador de baú aleatório e moderado, sem recompensa absurda.
- **D6:** crítico como está, mas visível e manipulável por eventos de mapa, skills e itens.

O congelamento acabou: as tarefas TASK-021 a TASK-025 (tabela no ADR-0025) seguem em ordem, uma por vez.

## 2026-11-16, nova rodada de jogo

### F-018: o gameplay está um pouco chato; as jogadas de moeda são repetitivas, sem ansiedade, e os inimigos parecem não ter inteligência

- **Status:** aberto (só anotado, sem implementação).
- **Fala do Orlando:** "gameplay um pouco chato, jogadas de moeda muito repetitivas, não tem aquela ansiedade pra ocorrer esse tipo de evento, parece que os inimigos não tem o mínimo de inteligência".
- **O que isso aponta, lendo o código:**
  - **Moeda repetitiva e sem ansiedade:** o lance é sempre o mesmo ritual (escolher o lado, girar 1,2 s, resultado), sem variação de consequência por inimigo e sem expectativa antes do lance. O aviso de um turno antes diz "MOEDA" e nada mais. A ansiedade de Fear & Hunger vem de o jogador saber o que está em jogo e não poder prever o resultado; hoje a aposta é só "+50% de dano".
  - **Inimigos sem inteligência:** a IA é um ciclo fixo de golpes com 25% de variação (GDD §6), que não olha o estado da luta. O inimigo não reage a vida baixa do jogador, a Defender, a debuffs, a poções, à própria vida nem ao jogador estar em Fúria. Os golpes são genéricos e o mesmo golpe aparece em inimigos diferentes.
- **Relação:** F-006 (moeda só dano), F-012 (moedas temáticas), F-013 (inimigo único), F-017 (frequência da moeda), F-014 (moeda 50/50 e re-jogada). Reforça a TASK-025 (identidade dos inimigos), que deve incluir IA reativa, e pede revisão do **ritmo e da apresentação da moeda** (TASK-024 ou nova tarefa).
- **Direções a avaliar (propostas, não decididas):**
  - **IA com regras de reação:** cada inimigo ganha 2 ou 3 condições próprias (por exemplo: cura quando abaixo de 40% de vida; golpe forte quando o jogador está fraco; tenta contra-atacar quando o jogador usa Defender duas vezes seguidas; foge ou chama reforço). As condições entram na ficha de cada inimigo (F-013) e são avisadas no ícone de intenção.
  - **Tensão da moeda:** poucas moedas, mas cada uma com consequência única e visível antes do lance ("Leptospirose: -15% do HP máximo até a fogueira"), mostrar o risco concreto, variar a apresentação por inimigo (som, animação, tempo de espera), e dar ao jogador algo a decidir antes do lance (Defender, Moeda da Sorte, item).
  - **Variedade:** alternar entre moeda do inimigo, moeda de evento do mapa e moeda de baú, em vez de sempre o mesmo lance de combate.

### Correção do Orlando sobre D2 (2026-11-18)

A primeira leitura da fogueira com lenha estava errada: dava **uma fogueira para a Descida inteira**. O que o Orlando quer: o mapa sempre tem **mais de um lugar para armar fogueira** (número justo, proporcional à profundidade); os itens para **uma** fogueira vêm **garantidos por mapa**; para armar mais, o jogador precisa de itens extras que são **raros** (drop de inimigo, de mini boss e de chefe) ou **caros** (loja). É um recurso escasso: quem sacrifica ouro e coleta para ter mais uma fogueira antes do chefe pagou o preço; quem não precisou usou o recurso em outra coisa. Fogueira infinita faria o jogador chegar ao chefe sempre cheio. As Brasas continuam sendo o recurso das skills de acampamento; o item de armar a fogueira é separado (galho seco). Corrigido na TASK-023 (ADR-0028).

## Situação dos pontos depois das TASK-021 a TASK-025 (2026-11-18)

Tudo abaixo está **implementado e testado, mas ainda não jogado pelo Orlando**: o status final de cada ponto depende da jogada dele.

| Ponto | Tarefa | O que foi feito |
| --- | --- | --- |
| F-005 dinheiro escasso | TASK-022 | ouro 10 por nível, baús 14%, preços mantidos |
| F-016 fraco no chefe, caminho curto | TASK-022 | mapa de 6 camadas, mais lutas e baús |
| F-015 baú e loops viciantes | TASK-022 | baú multiplicável ×1,25 a ×2 por Moeda da Sorte ou anúncio simulado |
| F-009, F-010 fogueira | TASK-023 | Galhos Secos (1 garantido por mapa, extras raros ou caros), fogueiras proporcionais à profundidade |
| F-014 moeda 50/50, reroll raro | TASK-021 e 027 | moeda sem número, Moeda da Sorte como drop raro (baú, mutado, elite, chefe), SORTE e Maré nos drops, mutados e emboscadas |
| F-007, F-008, F-011 combate legível, crítico | TASK-024 | previsão de dano, acerto e crítico; descrição das skills; atacar devolve MP; Éter em combate; crítico por item e skill |
| F-006, F-012, F-013, F-018 inimigos únicos, moeda temática, IA | TASK-025 | fichas por inimigo, consequência da coroa, Leptospirose, reações |
| F-017 moeda frequente | TASK-016 e 025 | intervalo de 2 golpes; o Corvo agora usa moeda (mais lances contra ele) |
| Eventos de mapa, D6 (CRIT) e mini boss | TASK-028 | 6 eventos na Cidade Abandonada (com moeda e modificador de CRIT), mini boss Carcereiro do Sino anunciado com raro + Galhos Secos + Moeda da Sorte |

**Ainda aberto:** roaming boss, anúncio de verdade, e calibrar tudo com o `telemetry.log` do Orlando.

## 2026-11-18, pedido de design

### F-019: a primeira Descida tem que ser chamativa

- **Status:** atendido na TASK-026 (ADR-0031), falta o Orlando confirmar jogando: primeira Descida (`runs_played == 0`) com Cidadão Infectado garantido na camada 1, baú na camada 2 com item incomum e Moeda da Sorte, elite no meio com drop raro e Moeda da Sorte, chefe visível de longe no mapa ("O Coveiro te espera"), Ecos em dobro e tela final "Morte que ensina" (inimigo e % de vida restante, conquistas, dica tática e o que ficou para a próxima). Simulador: 52,7% de vitória e 98,0% de chegada ao chefe na primeira Descida.
- **Fala do Orlando:** "a primeira descida tem que ser chamativa, dar um gostinho da dificuldade e recompensa pra fazer a pessoa ter vontade de continuar jogando".
- **O que isso pede:** a primeira Descida de quem nunca jogou (`runs_played == 0`) precisa entregar, em poucos minutos: (1) um **gostinho da dificuldade** (um encontro tenso e justo, com a moeda e um golpe temático avisado, sem ser injusto), (2) uma **recompensa que se vê** (um item raro ou uma skill forte que mude o jogo, um nível subindo) e (3) um **motivo para a próxima** (Ecos, desbloqueio ou mistério que ficou, "o Coveiro me espera").
- **Hoje:** a primeira Descida é igual às outras: mapa sorteado, recompensa aleatória, nenhum momento garantido. Quem tem azar de drops vê pouco.
- **Direções a avaliar (propostas, não decididas):** elementos garantidos na primeira Descida (um baú nas primeiras camadas com item bom, um elite no meio com drop raro e a Moeda da Sorte, um primeiro encontro que demonstra a moeda e o aviso); o chefe mostrado de longe no mapa (aviso "O Coveiro te espera"); Ecos em dobro na primeira Descida, mesmo ao morrer; uma tela final que diga o que a pessoa conquistou e o que ficou para a próxima. A regra de ouro: a primeira Descida pode ser mais generosa, mas não pode ser fácil ao ponto de não ter tensão, nem tão difícil que ninguém chegue ao chefe.
- **Restrições:** nada pode quebrar a vencibilidade do mapa (GDD §5) nem as regras de justiça da moeda; vale um ADR, porque muda regra para um caso (primeira Descida), e uma rodada do simulador com o perfil "primeira Descida".

## 2026-11-19, diretriz de progressão de mapas

### F-020: primeiro mapa curto como gancho (sem deixar fácil) e dificuldade crescente nos demais

- **Status:** em `TASK-052` (instrução registrada; aguarda implementação com ADR próprio e incremento de `RULES_VERSION`).
- **Fala do Orlando:** "Adicione uma instrução para que o primeiro mapa seja curto, como se fosse um tutorial para chamar a atenção dos jogadores. Não deixe o mapa fácil, só mais curto. Os demais mapas começam a ficar gradativamente mais dificeis."
- **Hoje:** o cenário 1 (`abandoned_city`) possui 6 camadas mais o chefe (`game/data/scenarios.json`, `ADR-0027`, com `MapConfig.for_scenario` escalando 6..10 nos cenários 1..5), inclusive na primeira Descida (`ADR-0031`).
- **Direção:** encurtar a extensão do primeiro mapa (proposta inicial: 3 a 4 camadas mais o chefe) para entregar combate, moeda, baú/loja, fogueira e encontro com o chefe em poucos minutos como tutorial-gancho, **sem reduzir a dificuldade dos inimigos nem suavizar o chefe**; os mapas/cenários seguintes (2 a 5) crescem gradativamente tanto em extensão quanto em dificuldade (nível, elites, mutações e pressão de recursos).

### F-021: algoritmo de cenários coerentes (sem elementos aleatórios sem sentido)

- **Status:** em implementação na `TASK-053` (`ADR-0041`).
- **Fala do Orlando:** "Criar ou utilizar um algoritmo próprio para que os cenários sempre façam sentido. Hoje está com vários elementos sem sentido no cenário. Exemplo de inspiração em anexo" (diorama isométrico estilo *Final Fantasy Tactics*: edificação coesa ao fundo sobre terraço gramado/úmido elevado, arcos e escadarias conectadas em pedra, relevo em platôs escalonados sem obstáculos na frente dos personagens).
- **Diagnóstico técnico:**
  - `Map3DLayout` / `Map3DScreen` espalhavam props avulsos (`stone-wall-damaged.glb`, `iron-fence-damaged.glb`, `lightpost-single.glb`, `pine-crooked.glb`, `pine-fall.glb`, `gravestone-*`, `candle-multiple.glb`, `grave.glb`) aleatoriamente pelo barro, desenhavam muros de borda pontilhados de 2 em 2 células, duplicavam postes em `OPTION`, geravam poças isoladas de água por ruído 4×4 descontínuo, colocavam escadas ambíguas de quina e deixavam ruínas sem telhado nem nivelamento sobre desníveis.
  - `Combat3DStage` e `Scene3DBackdrop` tinham pisos planos sem terraços, cercas quebradas flutuando sem parede, pinheiros verdes dentro de pátios de pedra, poste bloqueando a porta na tela inicial e o chefe `gravedigger` atuando como mercador na loja.
- **Direção:** substituir o scatter aleatório pelo pipeline **Terrace-Grammar-Constraint** (`ScenarioBlueprint` -> `ScenarioGenerator` -> `ScenarioValidator` -> `ScenarioRenderer`) no tabuleiro 3D e nos dioramas focais (combate, fogueira, loja, baú, evento, recompensa, menu, vitória, derrota), garantindo 12 invariantes estruturais e regra de não-oclusão de câmera isométrica.

## 2026-11-21, diretriz visual e atmosférica canônica

### F-022: referências canônicas atualizadas de gráficos, profundidade e atmosfera gótica (obrigatórias em todo asset)

- **Status:** Aceito e formalizado no `ADR-0042` (`docs/ART-DIRECTION.md`, `CLAUDE.md`, `AGENTS.md`, `docs/GDD.md`, `docs/REVIEW-CHECKLIST.md`); obrigatório na criação ou ajuste de **qualquer tipo de asset**.
- **Fala do Orlando:** "Algumas das referências de atmosfera e gráficos que eu mais gostei: buried bones, sword of convallaria (arte linda, subiu muito na lista de referências), tactics ogre, triangle strategy, octopath traveler, ragnarok online. São exatamente esses gráficos, atmosfera e cenários (profundidade também) que eu quero, só que com a atmosfera bem dark como em dark souls, bloodborne (atmosfera gótica me ganha MUITO, é uma das atmosferas que eu mais gostaria de ter de inspiração). Tome nota dessas referencias atualizadas, elas devem ser levadas em consideração SEMPRE que qualquer tipo de asset for criado"
- **Nota de identificação:** *"buried bones"* refere-se a **Buriedbornes** (*Buriedbornes / Buriedbornes2*, já estudado e arquivado em `docs/design/refs/ui/ui-buriedbornes2.jpg` e `docs/design/refs/ui/ui-buriedbornes2-mapa.jpg`).
- **Direção fechada em dois eixos (ADR-0042):**
  1. **Eixo 1 — Gráficos, Craft, Cenários e Profundidade Espacial:** **Sword of Convallaria** (nº 1 de arte, iluminação e craft tático), *Tactics Ogre*, *Triangle Strategy*, *Octopath Traveler*, *Ragnarok Online* e *Buriedbornes*, somados à base estrutural isométrica/em terraços de *Final Fantasy Tactics* e composição de combate de *Fear & Hunger* (`ADR-0036`, `ADR-0041`).
  2. **Eixo 2 — Filtro Atmosférico Obrigatório (Dark Fantasy & Horror Gótico):** **Bloodborne** (prioridade máxima de atmosfera gótica: verticalidade opressiva, arcos ogivais, ferro forjado, lampiões na neblina, luar frio e decadência de cidade em praga) e **Dark Souls** (melancolia de mundo morrendo, cantaria monumental gasta, fogueiras como raro refúgio quente contra a escuridão).
- **Abrangência e originalidade:** vale para modelos 3D (Blender, adaptações CC0, TRELLIS.2/Meshy), texturas, cenários, props, personagens, inimigos, itens, ícones, retratos, UI/HUD, iluminação, partículas e pós-processamento. Respeitando o GDD §18, os prompts de IA **nunca citam nomes de jogos, personagens ou artistas** — usam apenas a Matriz de Descritores Originais registrada no `ADR-0042` e em `docs/ART-DIRECTION.md`.

### F-023: conceito visual do Roaming Boss (guerreiro negro corrompido com crânios, maça brutal e espada quebrada)

- **Status:** em verificação na `TASK-054` (`docs/design/ROAMING-BOSS-perseguidor-coroado.md`).
- **Fala do Orlando:** pediu usar o Nano Banana no máximo para criar o **roaming boss** (GDD §13): um senhor da guerra imponente com elmo-coroa vertical pontiagudo, armadura toda negra com detalhes de crânios humanos visivelmente se desmanchando e expondo carne podre por baixo (aspecto corrompido e assustador), empunhando uma maça brutal em uma mão e uma espada pesada quebrada ao meio e super afiada na outra, tudo sob a atmosfera dark gótica do `ADR-0042`.
- **Restrição aplicada:** em conformidade estrita com o GDD §18 e o `ADR-0042`, nenhum prompt enviado ao gerador citou jogos, personagens ou artistas reais — todas as inspirações mencionadas foram traduzidas em descritores originais de silhueta, corrosão anatômica, forja negra e arquitetura gótica.

## 2026-11-23, pivot para sprites 2D HD-2D e remoção da mecha colorida

### F-024: remover por completo a mecânica de mecha colorida da Bibiana e gerar pacote de prompts em lote no estilo HD-2D dark gótico

- **Status:** Aceito (Orlando, 2026-11-23). Documentação canônica atualizada e pacote completo de 33 prompts IA-friendly entregue em `docs/design/PROMPTS-LOTE-HD2D.md` e `docs/design/prompts-lote-hd2d.json`; remoção dos vestígios de código legado 2D (`visual_theme.gd` / `map_screen.gd`) pendente na próxima tarefa de apresentação.
- **Fala do Orlando:**
  1. Pivot visual (`ADR-0052` no branch do Claude): modelos 3D procedurais ficaram toscos; personagens e inimigos passam a ser **sprites 2D HD-2D** sobre cenário com profundidade (estilo *Sword of Convallaria*, *Tactics Ogre*, *Triangle Strategy*, *Octopath Traveler*, *Ragnarok Online* e *Buriedbornes*, sob atmosfera dark gótica de *Bloodborne* e *Dark Souls*, `ADR-0042`).
  2. Remoção da mecha: *"A mecha verde no cabelo da Bibiana ficou bem tosca. Vamos retirar e remover por completo essa mecanica de cor do cabelo."* A prancha de teste com mecha verde foi descartada; Bibiana passa a ter cabelo castanho-escuro natural gasto de sobrevivente, sem mecha colorida em nenhum estágio de Poder.
  3. Geração em lote: *"Crie prompts completos de todas as imagens que você quer gerar. Eu vou gerá-las em outro algoritmo a parte. Além disso, a arte não deveria acompanhar o estilo dos jogos de referencia que definimos? Defina os prompts o mais completo possíveis e AI-friendly pra eu gerar as imagens em lote."*
- **Correção de estilo aplicada nos prompts:** trocado o descritor anterior *"3D character concept"* (que gerava CGI liso) por **ilustração/sprite tático 2.5D artesanal de alta densidade pictórica/pixel-painterly com contorno de silhueta sutil, pincelada tátil, chiaroscuro gótico e zero brilho plástico 3D**, traduzido 100% em descritores originais sem citar nomes de jogos ou artistas (`GDD §18`, `ADR-0042`).

## 2026-11-27, sensação das animações de combate e caminhada

### F-025: animação de ataque muito rápida/estranha e falta de caminhada visível até o inimigo

- **Status:** Em TASK-074 (ADR-0061).
- **Fala do Orlando:** *"O jogo tá ficando legal, finalmente. Porém, a animação de ataque tá muito rápida e ficou estranha. O personagem não tem animação nenhuma de caminhar até o inimigo, me parece que será necessário criar (se for o caso, anote para o gemini criar)."*
- **Diagnóstico técnico:**
  - `Combat3DStage` usava `STRIKE_APPROACH = 0.2s`, `STRIKE_WINDUP = 0.05s` e `STRIKE_RECOVER = 0.06s`, sem fase de bote/golpe nem peso de passada — o movimento até o inimigo e o retorno ocorriam rápidos demais para leitura.
  - Os 4 quadros em `assets/bibiana/sprites/bibiana_warrior_walk_0..3.png` tinham postura quase estática de pernas/capa, fazendo o sprite parecer deslizar no lugar (no combate e no `Map3DScreen`, que ainda só tocava `ModelRegistry.play(..., "walk")`, sem efeito em `Sprite3D`).
- **Direção:**
  1. Ajustar a cadência no código (`STRIKE_APPROACH`, `STRIKE_WINDUP`, novo `STRIKE_LUNGE`, `STRIKE_RECOVER`, `STRIKE_RETURN`) com passada procedural em `_hero_sprite` (balanço vertical de passo, inclinação, squash/stretch na pisada e poeira nos pés) tanto no combate quanto no tabuleiro 3D (`Map3DScreen`).
  2. Anotar duas novas pranchas de animação em `docs/design/PROMPTS-LOTE-HD2D.md` (§34–35) e `docs/design/CATALOGO-ASSETS-HD2D.md` para geração no Gemini assim que a cota semanal destravar (`bibiana-guerreira-walk-v2-sheet.jpg` e `bibiana-guerreira-strike-sheet.jpg`).
