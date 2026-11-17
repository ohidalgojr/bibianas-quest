# Bibiana's Quest — Game Design Document (GDD)

Nov 15, 2026 · @Orlando

> **Cópia versionada do GDD.** Exportada em 2026-11-15 do artefato [Bibiana's Quest — Game Design Document (GDD)](https://claude.ai/artifact/2kk2GCnNBCkfX4x1knMVon), revisão 83. Os 4 diagramas embutidos não são exportados e aparecem como marcações em itálico. Regras e fórmulas deste arquivo só mudam com ADR (ver `docs/adr/ADR-0004-gdd-versionado.md`).

## 1. Visão geral

Bibiana's Quest (título de trabalho) é um RPG tático de turnos para celular, em dark fantasy medieval, onde cada descida por um reino doente é única, curta e perigosa. O jogador vê apenas três inimigos por vez, escolhe qual enfrentar, joga a moeda quando a sorte decide e tenta chegar vivo ao chefe.

| Item | Definição |
| --- | --- |
| Gênero | Roguelite tático em turnos: mapa em grafo (estilo Slay the Spire) + combate 1 contra 1 estilo JRPG |
| Plataforma | Android primeiro, em aparelhos médios; iOS depois |
| Motor | Godot 4 (seção 20) |
| Sessão | 1 batalha: 1 a 2 min. 1 cenário: 8 a 12 min. 1 Descida completa: 25 a 40 min, com save a cada nó |
| Público | Adultos que gostam de Soulslike, Fear & Hunger e Darkest Dungeon e jogam no celular em sessões curtas |
| Gancho em uma frase | "Três portas, uma moeda e uma fogueira: sobreviva só mais um nó." |

### Pilares de design

1. **Toda escolha custa algo.** Os três caminhos sempre trocam risco por recompensa, de forma legível.
2. **A sorte é visível e negociável.** Todo golpe de moeda é avisado antes; o jogador pode se defender, trapacear ou aceitar o destino.
3. **A morte ensina, não humilha.** Nada mata sem aviso. Recomeçar leva segundos e o mapa novo é diferente.
4. **Opressão com clareza.** O clima é sufocante, mas a interface e a leitura de combate são sempre limpas.
5. **Barato de produzir.** Arte modular, geração procedural e IA onde for possível, porque o autor não tem experiência em modelagem, pixel art ou animação.

### O que o jogo não é

- Não é idle nem auto-battler: toda ação de combate é decisão do jogador.
- Não é pay-to-win nem gacha: nada pago dá poder exclusivo nem sorteio pago (seção 16).
- Não é PvP: a primeira versão é totalmente offline para o jogador.

### Por que pode ser viciante e difícil ao mesmo tempo

- **Ciclo curto:** a morte devolve o jogador ao início em poucos segundos, com mapa novo.
- **Dilema constante:** cada nó oferece três opções com riscos diferentes (o "só mais um nó").
- **Progresso a cada vitória:** Poder, ouro, itens e a cor da mecha de cabelo mudam o tempo todo.
- **Variância controlada:** o acaso existe, mas é avisado e mitigável, então a derrota parece justa.

## 2. Referências: o que aproveitar de cada jogo

Cada referência entra no jogo como uma mecânica concreta, não como um clima vago. A tabela diz o que pegar, como adaptar ao Bibiana e o que deixar de fora. Os fatos sobre os jogos vêm das fontes listadas ao fim do documento.

| Referência | O que pegar | Como entra no Bibiana | O que não copiar |
| --- | --- | --- | --- |
| Fear & Hunger | Lance de moeda que decide vida ou morte. Ataques com moeda são telegrafados um turno antes e o comando Defender anula o efeito. No Termina, a "lucky coin" permite lançar duas vezes. Loot nunca é garantido | Cara ou coroa em golpes fortes, furto, fuga, stun e baús (seção 7). Defender e a re-jogada da moeda são as defesas. Moeda viciada é o item de trapaça | Morte instantânea sem aviso e jogo que exige perfeição. Aqui toda morte tem aviso e saída (Defender, item, fugir) |
| Darkest Dungeon | Fogueira com pontos limitados de descanso (12 por padrão), habilidades de acampamento únicas por classe, doenças que só se curam com dinheiro, estresse que vira aflição ou virtude ao chegar a 100 | Fogueira com Brasas e skills por classe (seção 12). Doenças caras de curar (seção 11). Medidor de Pavor como proposta opcional | Gestão de elenco de vários heróis: aqui há uma só personagem |
| Final Fantasy Tactics | Tabuleiro isométrico, ordem de turnos por Charge Time, altura e orientação que afetam dano, Brave e Faith como atributos que mudam em combate, clima | Mapa isométrico em 3D, linha do tempo de turnos por Ritmo, clima com efeito (seção 14) | Grade tática de movimento. O combate é 1 contra 1 em janela própria, para caber no celular |
| Slay the Spire (referência extra para o grafo) | Mapa ramificado com regras: sem elite e sem descanso nos primeiros andares, sem dois descansos seguidos. O jogador planeja a rota | Grafo com 3 opções por vez e regras de geração parecidas (seção 5) | Cartas: o combate é por comandos e habilidades |
| Dark Souls e Bloodborne | Fogueira que recupera a vida e faz inimigos comuns renascerem. Almas de chefe trocadas por armas. Risco de perder o que se carrega. Chefes com ataques únicos | Almas de chefe viram dinheiro ou equipamento exclusivo na Forja (seção 13). Perder itens ao morrer | Combate em tempo real e lore opaca demais |
| Hero Wars (anúncio do tipo "pull the pin") | Hook visual de escolher o caminho certo e ver a consequência | O grafo de três opções é o jogo real. A divulgação pode usar a jogabilidade verdadeira | Criativos enganosos: esse tipo de anúncio foi apontado como falso e piora avaliação nas lojas |
| Shadow of Mordor (Nemesis) | Inimigo que mata o jogador é promovido, ganha nome e volta mais forte | Roaming bosses com memória entre Descidas (seção 13) | Hierarquia de orcs e simulação de mundo aberto |
| Octopath Traveler, Breath of Fire IV, Ragnarok Online | Octopath: mundo 3D com profundidade de campo e tilt-shift que parece miniatura. BoF4 e Ragnarok: personagens legíveis em cenários ricos | Look de diorama: cenário 3D em pixel art, câmera fixa, luz dramática (seção 18) | Sprites desenhados à mão: exigem artista e animador |

## 3. Mundo, tom e Bibiana

O mundo está dominado por uma doença chamada aqui de "a Febre", e o tom é de escassez, silêncio e desesperança, sem humor e sem salvadores. As ideias abaixo são propostas de narrativa, abertas a mudança, porque o briefing não define história.

### Mundo

- **Premissa proposta:** a Febre dobra o caminho. Quem morre acorda no começo, mas a estrada nunca é a mesma. Isso explica dentro do mundo por que cada Descida gera um mapa novo.
- **Lore fragmentada:** a história aparece em descrições de itens, nas Almas de chefe e em pequenos eventos, como em Dark Souls. Nunca em diálogos longos.
- **Motivo visual e sonoro:** o sino rachado. Um sino que toca sozinho anuncia mini boss ou roaming boss. É um aviso que o jogador aprende a temer.
- **Cinco cenários** descendo do mundo visível até o coração da doença (seção 17).

### Bibiana

- Mulher adulta, sobrevivente, de cabelo curto castanho com uma mecha que muda de cor conforme o Poder. A mecha é o único ponto de cor saturada na paleta, então o jogador sempre acha a personagem na tela.
- A mecha segue nove estágios: castanho, verde claro, azul claro, azul escuro, vermelho claro, vermelho escuro, roxo claro, roxo escuro e branco. A tabela de limiares está na seção 9.
- Sem classe fixa: ela escolhe clérigo, guerreiro, mago ou ladino no início de cada Descida (seção 8).

### Tom e linguagem visual

- Luz baixa e dramática: fogo, velas e fresta de lua como únicas fontes quentes, azul-acinzentado frio no resto.
- Névoa, vinheta e silêncio. A música some nos momentos de tensão e volta no combate.
- Violência e doença sugeridas por silhueta, som e texto. Evitar gore explícito, porque isso reduz a classificação etária e as restrições nas lojas, e funciona melhor para o medo.
- Os inimigos devem parecer pessoas e criaturas deformadas pela Febre, não monstros genéricos.

## 4. Loop de gameplay

O jogo tem quatro laços aninhados: turno, nó, cenário e Descida. Cada um entrega uma recompensa e termina em uma decisão, o que mantém o jogador tentado a continuar.

| Laço | Duração alvo | O jogador faz | Recompensa |
| --- | --- | --- | --- |
| Turno | 10 a 20 s | Escolhe atacar, usar habilidade, defender, usar item, roubar ou fugir; joga a moeda quando exigido | Dano causado, risco evitado |
| Nó | 1 a 2 min | Escolhe 1 de 3 caminhos, luta, vê o loot e passa pela loja | Poder, moedas, itens |
| Cenário | 8 a 12 min | Percorre 5 a 9 nós, acende a fogueira, enfrenta o chefe | Alma de chefe, nova skill de fogueira ou de combate |
| Descida | 25 a 40 min | Atravessa 3 cenários no MVP (5 na versão completa) | Ecos para o meta-progresso, desbloqueios, mecha de cabelo mais avançada |

### Regras do ciclo

- **Escolha da classe** acontece no início da Descida. A cada morte o jogador pode trocar de classe.
- **Morte** devolve o jogador ao início da Descida e perde os itens carregados e o Poder. O mapa novo é gerado com outra semente. Antes disso, aparece a tela de reviver (seção 16).
- **O que persiste:** Ecos, desbloqueios de skills e itens, códice, Almas guardadas na Forja e a memória dos rivais (Nemesis).
- **Auto-save** a cada nó, para o jogador poder sair a qualquer momento.
- **Loja após cada batalha:** o jogador abre a loja, compra, vende e equipa o que dropou antes de escolher o próximo nó.

### Interpretação adotada

O briefing diz que a morte leva "ao início do desafio". Este GDD interpreta "desafio" como a Descida inteira. Uma alternativa mais branda, com checkpoint no início de cada cenário, fica como parâmetro de teste e como pergunta aberta (seção 25).

*[diagrama disponível só no artefato: loop de uma Descida]*

## 5. Mapa em grafo

Cada cenário é um grafo em camadas gerado a partir de uma semente. De qualquer nó, o jogador sempre enxerga exatamente três próximos destinos, e pelo menos um deles é vencível para um jogador mediano.

*[diagrama disponível só no artefato: exemplo de mapa · 5 camadas e chefe, largura 4]*

A Bibiana escolhe um de três destinos por camada, e só esses três mostram o tipo; as camadas seguintes ficam na névoa até chegar a vez delas.

### Estrutura

- O cenário tem N camadas de nós mais o chefe: 5 camadas no cenário 1, crescendo até 9 no cenário 5.
- Cada camada tem largura W (4 para 5 a 6 camadas, 5 para 7 a 9). Cada nó liga a 3 nós consecutivos da camada seguinte, em uma janela deslizante limitada às bordas. Assim há sempre 3 opções, e a rota escolhida muda quais 3 opções aparecem depois.
- As duas últimas camadas convergem para o portal do chefe. A penúltima sempre oferece uma fogueira em pelo menos uma das três opções.
- Caminhos ligam os nós no tabuleiro isométrico (seção 17); a Bibiana caminha por eles até o inimigo.

### Neblina de guerra

- Os três nós alcançáveis mostram tudo: inimigo, nível, mutação e dica de recompensa (ouro, equipamento, baú).
- As camadas seguintes aparecem como silhuetas escuras, com as ligações esmaecidas e sem revelar o tipo do nó.
- Mini bosses são anunciados: o sino toca e um aviso vermelho marca a rota que leva a ele.
- A Lanterna (item) amplia a visão em 1 camada por um cenário.

### Tipos de nó

| Nó | Frequência inicial | Regra |
| --- | --- | --- |
| Batalha | 55% | Inimigo comum, nível próximo do nível do cenário |
| Elite | 10% (sobe com o cenário) | Não aparece nos primeiros 30% das camadas. Mais Poder e melhor drop |
| Baú | 8% | Dinheiro, item ou armadilha com moeda. Nunca dois em sequência |
| Evento | 9% | Escolha com risco e recompensa; usa moeda em parte dos casos |
| Fogueira | Garantida (seção 12) | Nunca duas fogueiras ligadas entre si |
| Mini boss | 0 ou 1 por cenário (chance cresce com a profundidade) | Anunciado. Recompensa rara garantida |
| Chefe | 1 por cenário | Nó final |
| Inimigo emboscado | 18% (restante) | Batalha comum com um status inicial, como sangramento ou pavor |

Os valores são ponto de partida para o protótipo; a seção 23 explica como calibrar.

### Garantia de vencibilidade

A geração precisa provar que existe um caminho que um jogador mediano consegue vencer. O gerador faz isso em três passos:

1. Gera o grafo e atribui tipos de nó respeitando as regras acima.
2. Escolhe o caminho mais seguro (menor soma de nível esperado) e simula um bot de referência da classe escolhida, 200 vezes, nesse caminho.
3. Se a taxa de vitória do bot for menor que a meta do cenário (por exemplo 70% no cenário 1), reduz o nível dos inimigos desse caminho, troca uma batalha por baú ou fogueira e repete, até 5 tentativas. Se ainda falhar, descarta o mapa e usa outra semente.

```text
function gerar_cenario(seed, cenario, classe, poder_inicial):
  rng = Rng(seed)
  repeat ate 5 vezes:
    g = construir_grafo(rng, camadas=cenario.N, largura=cenario.W)
    atribuir_tipos(g, regras_do_cenario, rng)
    rota = caminho_mais_seguro(g)
    vitoria = simular_bot(rota, classe, poder_inicial, n=200)
    if vitoria >= cenario.meta_vitoria: return g
    suavizar(rota)   # baixa nivel, insere bau ou fogueira
  return gerar_cenario(rng.proxima_seed(), ...)
```

Regras adicionais de justiça:

- Nunca ofereça três elites ou três inimigos mutados em uma mesma camada.
- Sempre exista uma opção "segura" por camada, com nível igual ou menor que o Poder esperado do jogador.
- O mapa é determinístico por semente, o que permite testar, reproduzir bugs e criar uma Descida diária no futuro.
- Um teste automatizado gera milhares de mapas por cenário e falha se algum não tiver caminho vencível.

## 6. Combate em turnos

O combate é 1 contra 1, em janela própria, com ordem de turnos por Ritmo e toda intenção perigosa do inimigo avisada com um turno de antecedência. A profundidade vem de recursos, status, moedas e itens, não de número de unidades.

### Entrada e tela

- No tabuleiro, a Bibiana caminha até o inimigo (1 a 2 s, pulável) e a câmera muda para a janela de combate.
- Layout proposto em retrato: cena 3D na metade de cima, linha do tempo de turnos no topo, menu na zona do polegar embaixo. Orientação retrato ou paisagem é pergunta aberta (seção 25).
- A linha do tempo mostra os próximos 6 turnos. Cada inimigo exibe um ícone de **intenção** sobre a cabeça: ataque, ataque forte, debuff, cura, ou moeda (golpe com cara ou coroa no próximo turno).

### Ações do jogador

| Ação | Efeito | Custo | Moeda? |
| --- | --- | --- | --- |
| Atacar | Dano da arma equipada | Nenhum | Não |
| Habilidade | Skills da classe e as aprendidas | MP | Depende da skill |
| Defender | Reduz o dano em 50% até o próximo turno, devolve 10% do MP e reduz a penalidade de golpes de moeda (seção 7) | Nenhum | Não |
| Item | Cura, MP, remoção de debuff ou dano | 1 item | Não |
| Roubar | Skill de furto (a do Ladino ou "Truque de Mão" aprendido) | MP | Sim |
| Fugir | Sai do combate e perde o nó | Nenhum | Sim, base 50%; Ladino +25%. Chefes não permitem fuga |

### Ordem de turnos

- Cada unidade ganha Carga igual ao seu Ritmo (VEL) a cada tick. Ao chegar a 100, age. Isso faz unidades rápidas agirem mais vezes e mostra o futuro na linha do tempo, como no Charge Time de Final Fantasy Tactics.
- Algumas skills têm Preparo: atrasam o próximo turno de quem as usa em troca de efeito maior.

### Fórmulas iniciais (a calibrar)

```latex
\text{Dano} = ATK \times \text{mult\_skill} \times \frac{100}{100 + DEF} \times U(0{,}9;\,1{,}1) \times \text{crit} \times \text{elemento} \times \text{clima}
```

```latex
\text{Acerto}\,(\%) = \text{clamp}(90 + PRE - ESQ,\; 10,\; 98)
```

- ATK é FOR para armas físicas e MEN para magias.
- Crítico: base 5%, multiplicador 1,5 (Ladino chega a 2,5 com a passiva).
- Elementos: Fogo, Raio, Sagrado, Sombra e Físico. Fraqueza ×1,5, resistência ×0,5.
- Clima altera Acerto e o dano de elementos (seção 14).

### Atributos básicos

HP, MP, FOR, MEN, DEF, RES, VEL, PRE, ESQ, CRIT e SORTE. Equipamentos e Poder alteram todos (seções 9 e 10).

### IA dos inimigos

- Cada inimigo tem de 3 a 5 movimentos em um ciclo com variação: o padrão pode ser aprendido, mas não decorado.
- Nunca o mesmo ataque forte duas vezes seguidas. Entre dois golpes de moeda do inimigo há sempre ao menos 2 golpes de outro tipo, em todos os inimigos, chefes inclusive (ADR-0020).
- **Golpes de debuff:** causam dano e, se acertarem, aplicam um debuff (Veneno ou Fraqueza, seção 11) com a chance do próprio golpe, sorteada à parte da moeda. O aviso do turno anterior mostra o ícone DEBILITA, o efeito e a chance. Defender corta a chance pela metade. Assim o risco do chefe não depende só da moeda.
- Chefes têm 2 a 3 fases, que mudam o ciclo de ataques e o tipo de moeda.

### Fim do combate

1. Poder, moedas e drops são creditados (seções 9 e 15).
2. Tela de recompensa com equipar rápido.
3. Loja (seção 15) e escolha do próximo nó.

Opções de ritmo: velocidade 2x, pular animações e repetir o último comando. Isso mantém batalhas fáceis rápidas, para o jogo ser mais viciante.

## 7. Cara ou coroa

A moeda é a assinatura do jogo: decide momentos de risco, é sempre avisada antes, tem chance visível e nunca garante o resultado, nem para quem paga. A regra de ouro é o jogador poder agir antes do lance, então perder na moeda é consequência de uma escolha.

### Regras

**A chance do lance é sempre 50%** e não é exibida: a moeda é só cara ou coroa (ADR-0025, ADR-0026).

- O jogador **escolhe Cara ou Coroa antes de cada lance**, nunca automático. **Acertar o lado é o sucesso** e errar é a falha: a moeda cai no lado escolhido quando o lance dá sucesso e no outro quando dá falha. A escolha é ritual; a chance vem só da fórmula (ADR-0014).
- **SORTE não mexe na moeda.** Ela influencia o resto do jogo: +1 ponto na chance de equipamento por ponto de SORTE (até +15), raridade dos drops deslocada para o raro, mais ouro nos baús e mais chance de Moeda da Sorte. Inimigos mais difíceis e emboscadas também serão influenciados pela sorte (TASK-025).
- **Maré de azar:** depois de 3 lances perdidos seguidos, a próxima vitória com drop garante o equipamento com raridade melhor, e a maré zera. É o seguro contra o azar da moeda.
- **Moeda da Sorte (re-jogada):** item raro, fora da loja, que cai de baús, elites e chefes. O jogador a arma antes do lance; no primeiro lance que cair errado, ele é rejogado uma vez e a moeda é gasta. Nada de trapaça por anúncio nem por item: a chance fica em 50%.
- Animação de cerca de 1,2 s com som de tique, câmera lenta e vibração. É o momento de maior tensão, então merece polimento.

### Onde a moeda aparece

| Situação | Acertou o lado (sucesso) | Errou o lado (falha) |
| --- | --- | --- |
| Golpe Pesado do inimigo | Dano normal | Dano +50% |
| Golpe Cruel do inimigo | Dano -50% | Dano +100% e um debuff ou risco de doença |
| Golpe Mortal (só chefes) | Dano normal | Dano +150%. Nunca mata um jogador com mais de 60% de vida; abaixo disso, pode matar |
| Atordoar (Guerreiro) | Inimigo perde o próximo turno (em chefes, vira Lentidão) | Habilidade só causa dano |
| Furto (Ladino) | Item, ouro ou drop raro do inimigo | Inimigo fica Alerta: +15% de dano por 2 turnos |
| Fugir | Sai do combate | Perde o turno e o inimigo age |
| Baú trancado ou armadilhado | Abre sem custo | Dano, doença ou baú vazio |
| Evento | Resultado favorável | Resultado desfavorável |

### Defesas contra a moeda

- **Defender** reduz a penalidade de falha pela metade. O Guerreiro anula a penalidade por completo (passiva Veterano).
- **Re-jogada:** o Clérigo tem uma por combate (passiva Providência, inspirada na "lucky coin" de Fear & Hunger: Termina). O item Moeda da Sorte dá outra.
- **Esquiva:** o Ladino ganha esquiva automática no primeiro golpe de moeda de cada combate.
- **Interromper:** atordoar ou matar o inimigo antes do turno do golpe cancela a moeda.

### Limites de justiça

- Golpes de moeda do inimigo nunca ficam colados: ao menos 2 golpes de outro tipo entre eles (seção 6).
- Todo golpe de moeda é avisado com ícone no turno anterior. Sem exceção, exceto eventos marcados como emboscada, e mesmo esses mostram um aviso de uma tela antes.
- Nunca há morte imediata com a vida acima de 60%.
- A telemetria acompanha a parcela de mortes causadas por moeda (meta em torno de 25% ou menos, seção 23).

## 8. Classes

As quatro classes trocam segurança por potencial: Clérigo e Guerreiro são seguros, Mago e Ladino arriscam mais para ganhar mais. Cada uma muda a forma de lidar com a moeda, e não só o número de dano. As skills marcadas com (\*) vêm do briefing; as demais são propostas para fechar um conjunto mínimo de três por classe.

### Visão geral

|  | Clérigo | Guerreiro | Mago | Ladino |
| --- | --- | --- | --- | --- |
| Papel | Sustento e segurança | Equilíbrio entre ataque e defesa | Dano alto, depende de MP | Risco alto, recompensa alta |
| Arma inicial | Maça de Ferro | Espada e Escudo | Cajado Ressecado | Adaga Curta |
| Armadura inicial | Hábito Surrado (DEF baixa, RES média) | Cota de Malha Velha (a mais reforçada) | Manto de Aprendiz | Couro Gasto (DEF baixa) |
| Passiva | Providência: uma re-jogada de moeda por combate | Veterano: Defender anula a penalidade da moeda e protege 30% a mais | Ressonância: efeitos de clima do seu elemento +50%; Defender devolve +12% de MP | Sombras Longas: crítico ×2,5 e +10% de chance; fuga +25%; esquiva automática no 1º golpe de moeda |
| Fraqueza | Dano escala pouco | Pouco MP e pouco dano em magia | Vida baixa; fica indefeso sem MP | Defesa baixa; falha no furto custa caro |

### Atributos iniciais (Poder 1,0)

| Atributo | Clérigo | Guerreiro | Mago | Ladino |
| --- | --- | --- | --- | --- |
| HP | 90 | 130 | 70 | 85 |
| MP | 60 | 20 | 100 | 35 |
| FOR | 10 | 14 | 5 | 11 |
| MEN | 12 | 5 | 16 | 6 |
| DEF | 6 | 12 | 4 | 5 |
| RES | 12 | 6 | 10 | 5 |
| VEL | 8 | 7 | 8 | 12 |
| PRE / ESQ | 90 / 3 | 90 / 3 | 90 / 4 | 90 / 12 |
| CRIT / SORTE | 5 / 3 | 5 / 0 | 5 / 0 | 10 / 0 |

Valores de partida para o protótipo, a calibrar com simulação.

### Skills de combate

| Classe | Skill | Custo | Efeito |
| --- | --- | --- | --- |
| Clérigo | Luz Pálida (\*) | 8 MP | Cura 30% do HP máximo + 0,8×MEN e remove 1 sangramento |
| Clérigo | Castigo | 6 MP | Dano Sagrado 1,0×MEN; ×1,4 contra mortos-vivos e doentes |
| Clérigo | Purgar | 10 MP | Remove 1 debuff e dá imunidade a esse debuff por 3 turnos |
| Guerreiro | Golpe de Escudo (\*) | 6 MP | Dano 0,8×FOR + moeda: Cara atordoa o inimigo por 1 turno |
| Guerreiro | Investida | 8 MP | Dano 1,5×FOR; DEF -20% por 1 turno |
| Guerreiro | Muralha | 6 MP | 2 turnos: DEF +50% e reflete 20% do dano físico |
| Guerreiro (loja) | Golpe Giratório | 5 MP | Dano 1,3×FOR. Comprada na loja por 120 moedas (ADR-0024) |
| Guerreiro (loja) | Grito de Guerra | 4 MP | 3 turnos: FOR e MEN +25%. Loja, 100 moedas (ADR-0024) |
| Guerreiro (loja) | Segundo Fôlego | 6 MP | Recupera 25% do HP máximo. Loja, 140 moedas (ADR-0024) |
| Mago | Lança Arcana (\*) | 8 MP | Dano neutro 1,4×MEN |
| Mago | Raio Rachado (\*) | 14 MP | Dano de Raio 2,0×MEN; forte na chuva |
| Mago | Corrosão (\*) | 10 MP | Debuff: DEF e RES -25% por 3 turnos |
| Ladino | Furto (\*) | 5 MP | Moeda: Cara rouba item, ouro ou drop raro (seção 7) |
| Ladino | Corte Profundo (\*) | 7 MP | Dano 0,9×FOR + Sangramento (25% do ATK por turno, 3 turnos) |
| Ladino | Passo de Sombra | 6 MP | Esquiva garantida do próximo ataque normal e contra-ataque (recarga de 3 turnos) |

### Skills de fogueira

Cada classe começa com duas e pode aprender outras no fim dos cenários (seção 12).

| Classe | Skills iniciais | Efeito |
| --- | --- | --- |
| Clérigo | Oração na Chama; Vigília | Cura 30% de HP e uma doença leve de graça; +RES por 3 combates |
| Guerreiro | Afiar Lâmina; Reforçar Escudo | +15% de dano por 3 combates; +15% de DEF por 3 combates |
| Mago | Estudar Grimório; Destilar Éter | +20% de dano mágico por 3 combates; restaura todo o MP |
| Ladino | Forjar Veneno; Revistar Cinzas | Ataques aplicam Veneno por 3 combates; +20% de chance de drop e ouro por 3 combates |

### Equilíbrio entre classes

- Clérigo vence por sobrevivência: o dano baixo faz as batalhas durarem mais, e isso expande o risco de doença e de golpes de moeda.
- Guerreiro é a classe de entrada: Defender é forte e ensina o jogador a ler as intenções.
- Mago tem a maior velocidade de vitória, mas a pior reserva de vida e depende do clima.
- Ladino é a classe que o jogador veterano quer jogar: críticos pesados, fuga fácil e furtos que dependem da moeda.
- A meta é que todas as classes tenham taxa de vitória parecida entre jogadores do mesmo nível, e a diferença de risco apareça na variância, não na média.

## 9. Progressão

Dentro da Descida, a Bibiana cresce por Poder, um número contínuo que sobe a cada vitória e controla tanto os atributos quanto a cor da mecha. Entre Descidas, o meta-progresso abre opções novas sem tornar o jogador muito mais forte.

### Poder

```latex
\Delta Poder = 0{,}4 \times N_{inimigo} \times m_{tipo}
```

- m\_tipo: comum 1, elite 1,5, mini boss 2,5, roaming boss 3, chefe 4.
- Poder inicial: 1,0. Fugir de um combate não dá Poder.
- **Nível da Bibiana** é a parte inteira do Poder (Poder 2,4 é nível 2). É só um rótulo: aparece no mapa e a recompensa anuncia "Subiu de nível!". O coeficiente passou de 0,15 para 0,4 no protótipo (ADR-0023), porque com 0,15 uma luta comum mudava 1 ou 2 pontos de HP e a Bibiana não parecia crescer; o mapa do MVP tem poucas lutas por cenário.
- Atributos crescem de forma contínua com o Poder: HP +10% por ponto acima de 1; FOR e MEN +8%; DEF e RES +6%; VEL +2%. PRE, ESQ e SORTE vêm dos equipamentos e do clima, não do Poder.
- Comparando com o nível dos inimigos, uma Descida completa de 3 cenários termina com Poder em torno de 45 se o jogador vencer quase tudo. Valores de partida, a calibrar na seção 23.

### Evolução da mecha de cabelo

A cor é definida por faixas de Poder e vira um parâmetro do shader do cabelo, então não precisa de modelos novos. A transição entre cores dura 1 segundo, com brilho curto, para o jogador notar a conquista.

| Estágio | Cor da mecha | Poder mínimo | Marco aproximado em uma Descida |
| --- | --- | --- | --- |
| 1 | Castanho | 1 | Início |
| 2 | Verde claro | 3 | Primeiras vitórias do cenário 1 |
| 3 | Azul claro | 5 | Perto do chefe do cenário 1 |
| 4 | Azul escuro | 8 | Início do cenário 2 |
| 5 | Vermelho claro | 12 | Meio do cenário 2 |
| 6 | Vermelho escuro | 17 | Chefe do cenário 2 |
| 7 | Roxo claro | 23 | Início do cenário 3 |
| 8 | Roxo escuro | 30 | Meio do cenário 3 |
| 9 | Branco | 40 | Reta final, perto do chefe do cenário 3 |

Com 5 cenários, os limiares sobem proporcionalmente. Branco é reservado para o fim, e isso dá ao jogador uma imagem do quanto avançou.

### Meta-progresso no Santuário

O Santuário é o menu entre Descidas, em estilo de acampamento. Os Ecos ganhos por Descida (profundidade, chefes e rivais derrotados) compram itens abaixo.

| Parte do Santuário | O que faz |
| --- | --- |
| Biblioteca | Desbloqueia skills de combate e de fogueira no pool aleatório |
| Arsenal | Desbloqueia equipamentos e consumíveis no pool de drops |
| Códice | Bestiário, lore e conquistas |
| Forja de Almas | Troca Almas de chefe por equipamentos exclusivos (seção 13) |
| Cemitério de Rivais | Lista de roaming bosses que mataram a Bibiana (seção 13) |

Regras de segurança:

- Bônus numéricos permanentes somam no máximo +10%. O ganho principal é variedade, não poder.
- Dificuldades Pesadelo 1 a 5 (estilo ascensão) desbloqueiam depois da primeira vitória e adicionam modificadores, como mais mutações e golpes de moeda mais frequentes, com mais Ecos como recompensa.
- Modos futuros: Descida diária com semente fixa (Beta, seção 26) e Abismo (infinito, depois do lançamento).

## 10. Equipamentos e itens

Qualquer classe pode usar qualquer equipamento. Quem decide se um item serve é o atributo que ele escala, e não uma trava de vocação: um mago com espada bate fraco porque sua FOR é baixa, e não porque o jogo proibiu.

### Slots

- Arma, Mão secundária (escudo, foco, adaga extra ou vazia para armas de duas mãos), Corpo, Cabeça e duas Relíquias.
- Visualmente mudam no modelo da Bibiana: arma, mão secundária, corpo e cabeça. Relíquias só afetam atributos, para economizar arte.
- Afinidade suave (proposta): +10% no atributo principal ao usar o tipo preferido da classe. Não é trava.

### Armas

| Tipo | Mãos | Escala | Traço |
| --- | --- | --- | --- |
| Maça | 1 | FOR e um pouco de MEN | Contundente: ignora 10% da DEF; ×1,2 contra mortos-vivos |
| Espada | 1 | FOR | Equilibrada; boa com escudo |
| Adaga | 1 | FOR | CRIT +5; chance de golpe extra |
| Cajado | 2 | MEN | MP máximo +; reforça o elemento da arma |
| Machado | 1 | FOR | Chance de causar Sangramento |
| Martelo | 2 | FOR | Chance de atordoar; mais lento (VEL -1) |
| Besta | 2 | FOR e PRE | Ignora parte da ESQ; recarga como Preparo |

### Armaduras

| Peso | DEF | RES | Efeito colateral |
| --- | --- | --- | --- |
| Tecido | Baixa | Alta | VEL +1 |
| Couro | Média-baixa | Média | ESQ +3 |
| Malha | Média-alta | Baixa | Sem efeito |
| Placa | Alta | Baixa | VEL -2; sofre menos críticos |

### Raridades

| Raridade | Cor na interface | Regra |
| --- | --- | --- |
| Gasto | Cinza | Barato, atributos baixos |
| Comum | Branco | Padrão das lojas |
| Incomum | Verde acinzentado | +1 efeito pequeno |
| Raro | Azul | +1 ou 2 efeitos; vem de elites |
| Maldito | Roxo | Poder alto com custo (maldição). Não sai até passar na fogueira ou pagar |
| Alma | Dourado | Forjado com Alma de chefe (seção 13) |
| Relíquia de Rival | Vermelho | Dropa de roaming bosses promovidos |

Exemplos de malditos: Anel do Cobrador (+30% de dano, mas perde 5 de ouro por turno), Coroa de Espinhos (+8 de SORTE, mas sangramento ao receber um golpe de moeda), Elmo Mudo (+DEF alta, mas impede habilidades que custam MP).

### Consumíveis e itens especiais

| Item | Efeito |
| --- | --- |
| Poção Turva | Cura HP |
| Éter Sujo | Restaura MP |
| Bandagem, Antídoto | Cura sangramento, veneno |
| Água Benta, Garrafa Incendiária | Dano Sagrado, dano de Fogo |
| Pó Cego | Debuff de PRE no inimigo |
| Moeda da Sorte | Uma re-jogada de moeda, armada antes do lance. Drop raro de baú, elite e chefe; não vende na loja |
| Lanterna | +1 camada de visão no mapa |
| Incenso de Cinzas | Afasta um roaming boss por 3 nós (seção 13) |
| Chave | Abre baús trancados sem moeda |

### Drops e inventário

- Inimigos sempre dão moedas. Chance de equipamento: 12% comum, 35% elite, garantido raro em mini boss (valores iniciais).
- **No protótipo (ADR-0022):** inimigos comuns e elites soltam também um consumível de cura (30% e 50%). A raridade do equipamento sai de pesos: comum 30% gasto, 55% comum, 15% incomum; elite 30% comum, 45% incomum, 25% raro. O chefe não solta equipamento. Itens raros só caem; não entram na loja. O jogador decide na hora: Equipar (o item trocado é vendido a 40%) ou Vender o drop a 40% (seção 15); sair da loja vende o drop pendente.
- O nível do item acompanha o cenário. Qualidade vem de pesos de raridade que sobem com a profundidade.
- Inventário: 8 consumíveis e 6 equipamentos reserva. Passou disso, o jogador vende algo na hora.
- Ao morrer, o jogador perde tudo o que carrega na Descida. Nada do inventário vai para o Santuário, a não ser Almas e o que foi forjado.

### Observação de arte

Seis modelos de arma, três visuais de armadura (tecido, couro/malha, placa) e variações por cor e brilho de raridade cobrem a maioria dos itens sem criar um modelo novo por item.

## 11. Doenças, debuffs e mutações

Inimigos podem passar doenças que duram entre combates e só saem com dinheiro, fogueira ou itens. Cada cura na mesma Descida custa mais, então ignorar uma doença é uma escolha real. O sistema segue a ideia das doenças de Darkest Dungeon, que debilitam o herói até serem tratadas.

### Doenças

| Doença | Efeito | Fonte típica | Custo base de cura |
| --- | --- | --- | --- |
| Febre dos Sinos | PRE -10%; SORTE -3 | Cidadãos infectados | 50 |
| Tosse Escarlate | Perde 2% do HP máximo por nó percorrido (não mata) | Ratos e cães de peste | 60 |
| Podridão | Cura recebida -30%; sangramentos duram +1 turno | Mortos-vivos | 70 |
| Olhos de Vidro | ESQ -25%; CRIT -5 | Médicos da peste | 80 |
| Tremor | Chance da moeda -5 pontos; fuga -10 pontos | Elites | 90 |
| Veia Negra | Regeneração de MP -50%; skills custam +15% de MP | Bruxos | 100 |
| Pele de Cinza | DEF -15% | Chefes e mini bosses | 140 |

### Regras

- **Contágio:** golpes marcados com Contágio têm chance de 20% a 35% de infectar. A chance real é reduzida pela RES: chance = base × 100 / (100 + RES).
- **Incubação:** a doença aparece depois de 1 nó, com ícone de "incubando". O jogador tem tempo de usar um Antídoto ou procurar uma fogueira.
- **Limite:** no máximo 3 doenças ao mesmo tempo. Uma quarta substitui a mais antiga e piora em 1 nível.
- **Cura:** no Curandeiro da loja, pagando. O preço de cada cura na Descida é o custo base multiplicado por 1,5 elevado ao número de curas já feitas na Descida.
- **Outras curas:** a skill Oração na Chama do Clérigo cura doenças leves de graça; o item Unguento cura uma doença de custo até 80.
- Doenças nunca se acumulam entre Descidas.

### Debuffs de combate

| Debuff | Efeito | Duração | Cura |
| --- | --- | --- | --- |
| Sangramento | 25% do ATK por turno | 3 turnos | Bandagem, Luz Pálida |
| Veneno | 5% do HP máximo por turno | 4 turnos | Antídoto, Purgar |
| Queimadura | Dano de Fogo por turno; MP -5 | 3 turnos | Água, tempo |
| Atordoamento | Perde o turno | 1 turno | Automática; chefes resistem |
| Lentidão | VEL -30% | 3 turnos | Purgar |
| Fraqueza | ATK -25% | 3 turnos | Purgar |
| Cegueira | PRE -30% | 3 turnos | Pó de Sal, Purgar |
| Medo | Chance da moeda -10 pontos | 3 turnos | Vigília, Purgar |
| Silêncio | Não pode usar skills | 2 turnos | Purgar |
| Maldição | Dano recebido +20% | 3 turnos | Fogueira |

### Mutações de inimigos

Mutações são raras e deixam o inimigo mais forte, mas sempre visíveis antes da luta, para não punir demais. Um inimigo mutado dá ×1,5 de Poder e drops melhores.

| Cenário | Chance de mutação na escolha de nó |
| --- | --- |
| 1 | 0% |
| 2 | 4% |
| 3 | 8% |
| 4 | 12% |
| 5 | 15% |

- Exemplos: Inchado (+50% de HP, é lento), Espinhoso (reflete 15% do dano físico), Voraz (cura ao causar dano), Fantasma (50% de ESQ contra ataques físicos), Duplicado (age duas vezes a cada 4 turnos).
- Nunca mais de um inimigo mutado por camada do mapa e nunca nos primeiros dois nós de um cenário.
- **Metamorfose** (surpresa): em cenário 3 ou acima, um inimigo comum tem 2% a 3% de chance de mutar em combate abaixo de 50% de vida. Ele treme por um turno antes, para o jogador reagir, e isso nunca acontece com chefes.

## 12. Fogueira e skills de acampamento

A fogueira é o respiro do jogo: um nó seguro onde a Bibiana gasta Brasas limitadas em cura, buffs e curas de debuff, com skills únicas por classe. Segue o acampamento de Darkest Dungeon, em que cada habilidade custa pontos de descanso limitados.

### Regras

- Cada fogueira dá 6 Brasas (valor inicial). Ao entrar, o jogador escolhe ações até gastar as Brasas ou sair.
- Mapas de 5 camadas ou mais têm pelo menos 1 fogueira, na segunda metade, e a penúltima camada sempre oferece uma. Mapas de 8 camadas ou mais têm 2. (Interpretação do briefing, pergunta aberta na seção 25.)
- Roaming bosses não entram em fogueiras, mas o tempo continua passando (seção 13).

### Ações

| Ação | Custo | Efeito |
| --- | --- | --- |
| Descansar | 3 Brasas | Recupera 40% de HP e MP |
| Skill de fogueira da classe | 1 a 2 Brasas | Efeito único (seção 8); buffs duram 3 combates |
| Tratar debuff | 1 Brasa + item ou skill | Remove Maldição, Veneno ou doença leve |
| Remover item maldito | 2 Brasas + ouro | Libera o slot (seção 10) |
| Usar provisão | 1 Brasa | Buff pequeno de uma ração ou poção |

### Como aprender novas skills

- Ao fim de cada cenário, depois do chefe, uma loja oferece 3 skills aleatórias (de combate ou de fogueira), a preços de 80 a 250 moedas, escalando com o cenário.
- A Bibiana equipa até 4 skills de combate e 3 de fogueira ao mesmo tempo. Trocar só é permitido na fogueira.
- As skills disponíveis no sorteio dependem do que o jogador já desbloqueou na Biblioteca do Santuário (seção 9).

### Pavor (proposta opcional, fase 2)

O briefing não pede estresse, mas Darkest Dungeon mostra como um medidor de pressão psicológica reforça o medo. Proposta enxuta:

- Pavor vai de 0 a 100 e sobe com golpes de moeda perdidos, chefes, doenças e fogueiras puladas.
- Cada 25 pontos de Pavor reduz a chance da moeda em 3 pontos.
- Ao chegar a 100, o jogador tem 75% de chance de ganhar uma aflicção (por exemplo, uma skill que falha com 25% de chance) e 25% de chance de ganhar uma virtude (um bônus temporário). Os percentuais seguem o modelo de Darkest Dungeon e devem ser testados.
- A fogueira reduz o Pavor. Isso une moeda, fogueira e atmosfera em um único sistema.

Se o escopo apertar, o Pavor fica fora do MVP sem quebrar mais nada.

## 13. Chefes, mini bosses, roaming bosses e almas

Há três níveis de ameaça: o chefe do cenário, o mini boss anunciado e o roaming boss que persegue o jogador no estilo Nemesis. Todos deixam recompensa memorável, e os dois primeiros dropam Almas para a Forja.

### Chefes de cenário

- Ficam no nó final, não permitem fuga e têm 2 a 3 fases, com ciclos de ataque diferentes em cada uma.
- Cada chefe tem pelo menos um golpe de moeda de nível Cruel e, na fase final, um Golpe Mortal (seção 7), sempre avisado.
- Um chefe não é "um inimigo comum maior": cada um introduz uma regra nova (por exemplo, invoca ajudantes ou muda o clima da luta), como nos chefes de Dark Souls.
- Derrotar o chefe dá Poder ×4, uma Alma e a loja de skills do fim do cenário (seção 12).

### Mini bosses

- Entram no mapa com anúncio: o sino toca ao gerar o cenário e um aviso marca a rota. São opcionais.
- São desafios grandes com uma regra própria. Recompensa: equipamento raro garantido, Poder ×2,5 e fragmento de Alma.
- Não permitem fuga, para o risco ser uma decisão tomada antes de entrar.

### Roaming bosses (Nemesis)

Um roaming boss é uma ameaça móvel que atravessa o grafo atrás da Bibiana. A ideia vem do sistema Nemesis de Shadow of Mordor, em que quem derrota o jogador é promovido e volta mais forte.

1. **Alarme.** Um medidor sobe quando o jogador foge de combates, descansa na fogueira ou derrota elites. Ao encher, um roaming boss entra no mapa em uma camada atrás da Bibiana. O sino toca duas vezes.
2. **Perseguição.** A cada nó que o jogador conclui, o roaming boss avança 1 nó. A interface mostra os passos e a distância ("o Perseguidor está a 3 nós"). Ele nunca entra em fogueiras.
3. **Encontro.** Se alcança a Bibiana, a luta é forçada e sem fuga. Ele dropa uma Alma, Poder ×3 e uma relíquia rara.
4. **Evitar.** Itens raros (Incenso de Cinzas, drop raro ou compra) afastam o roaming boss por 3 nós. Existem também escolhas de rota que o deixam para trás.
5. **Memória.** Se o roaming boss mata a Bibiana, ele é promovido: ganha um nome, um título, uma mutação e +1 patente. Na Descida seguinte, ele pode voltar, mais forte e com recompensa maior. A lista fica no Cemitério de Rivais no Santuário.

A construção é barata: gerador de nomes por sílabas e epítetos, um conjunto de modelos-base com recolor e mutações, e cinco patentes.

### Almas e Forja

- Cada chefe, mini boss e roaming boss deixa uma **Alma**. Ela pode ser trocada por moedas na hora ou guardada no Santuário para a Forja de Almas.
- A Forja faz equipamentos exclusivos. Receita: 1 Alma + materiais (fragmentos dropados por inimigos do mesmo cenário) + moedas. Exige repetir o cenário até juntar tudo, de propósito (inspirado na troca de almas por armas em Dark Souls).
- **Atalho pago:** o jogador pode comprar Cinzas Refinadas para cobrir até metade dos fragmentos que faltam. Regra de ouro: o atalho economiza tempo e nunca dá um item que não possa ser feito sem pagar.
- Armas de Alma têm um efeito único e são fortes, mas não obrigatórias: o jogo deve ser vencido com equipamentos normais.

### Chefes propostos

| Cenário | Chefe | Regra de luta | Alma / arma de exemplo |
| --- | --- | --- | --- |
| 1. Cidade Abandonada | O Coveiro | Cava covas que invocam mortos; golpe de moeda com a pá | Alma do Coveiro: Pá do Coveiro (dano extra contra mortos-vivos) |
| 2. Catacumbas | A Viúva de Ossos | Reconstrói ossos; precisa de dano contundente | Alma da Viúva: Véu de Cinzas (RES alta) |
| 3. Brejo Doente | A Mãe do Brejo | Espalha doenças; chuva a fortalece | Alma da Mãe: Cajado do Lodo (veneno) |
| 4. Catedral dos Sinos | O Bispo Cego | Ataca pelo som; o sino marca os golpes de moeda | Alma do Bispo: Sino Rachado (re-jogada extra) |
| 5. Cidadela | O Rei Febril | Três fases com a Febre; golpe mortal na fase final | Alma do Rei: Coroa Febril (mecha branca brilhante) |

## 14. Eventos da natureza

Cada cenário pode receber um evento climático raro, com uma penalidade e uma vantagem que mudam a estratégia, visíveis no mapa e na luta. Em Final Fantasy Tactics o clima também afeta o combate, e aqui ele vira uma decisão de classe e de rota.

### Regras

- Chance de 10% por cenário (valor inicial), sorteada ao gerar o mapa. O evento dura o cenário inteiro; eventos únicos e mais raros (3%) podem chegar no meio do cenário, com aviso no HUD.
- O HUD mostra o ícone do clima, o efeito completo e a duração em nós.
- Os efeitos são sempre um pacote: um lado ruim e um lado bom, com valores parecidos para não decidir a partida sozinhos.
- O clima precisa ser perceptível: partículas, cor do céu, névoa e som no tabuleiro e na janela de combate.

### Eventos

| Evento | Penalidade | Vantagem | Sinais visuais e sonoros |
| --- | --- | --- | --- |
| Chuva | PRE -15% | Dano de Raio +15% | Gotas, poças, som de chuva, brilho molhado |
| Tempestade | VEL -10% | Dano de Raio +30%; Raio Rachado atinge duas vezes, 1 vez por combate | Relâmpagos, trovões, vento forte |
| Névoa | PRE -10% | ESQ +10% e fuga +15 pontos | Cenário com névoa densa e som abafado |
| Vento de Cinzas | Regeneração de MP -50% | Dano de Fogo +15% | Cinzas voando, céu cinza-alaranjado |
| Nevasca | VEL -15% | Crítico +10% (seus e dos inimigos) | Flocos, respiração em névoa, som seco |
| Lua de Sangue | Inimigos +10% de dano | Moedas e Poder +20% | Céu vermelho, sinos graves |
| Eclipse | Dano Sagrado -20% | Dano de Sombra +20% | Lua escurecida, sombras longas |

### Notas

- O Mago ganha mais com clima de elemento, pela passiva Ressonância. O Clérigo sofre no Eclipse. O Guerreiro é pouco afetado.
- A chuva reduz a PRE do Mago e do Guerreiro, mas aumenta o Raio, o que deixa a Raio Rachado muito mais forte.
- Cada cenário limita os eventos possíveis para manter o tema (por exemplo, Nevasca não ocorre na Cidade Abandonada).

## 15. Economia e loja

A economia deve ser apertada: o jogador nunca consegue comprar tudo o que quer, então cada compra é uma decisão. Existem três moedas internas, e dinheiro real não entra em nenhuma delas diretamente na primeira versão.

| Moeda | Fonte | Uso | Persiste após a morte? |
| --- | --- | --- | --- |
| Moedas | Inimigos (garantidas), baús, venda de itens | Loja, curandeiro, skills, remoção de maldições | Não |
| Almas | Chefes, mini bosses, roaming bosses | Trocar por Moedas ou forjar equipamento | Sim, se guardadas no Santuário |
| Ecos | Fim de cada Descida (profundidade, chefes, rivais) | Desbloqueios no Santuário | Sim |

### Fontes e valores iniciais

```latex
\text{Moedas por inimigo} = \text{round}(6 \times N_{inimigo} \times U(0{,}8;\,1{,}2) \times m_{tipo})
```

- m\_tipo: comum 1, elite 1,5, mini boss 2,5, chefe 4, roaming boss 3.
- Baús dão de 1 a 3 vezes o ouro de uma batalha comum do nível do cenário.
- Venda de itens paga 40% do valor.

### Loja após cada batalha

- 5 itens: 2 equipamentos, 2 consumíveis e 1 especial (maldito, skill rara ou item de utilidade como Lanterna).
- **No protótipo (ADR-0024):** o especial é uma skill de combate da classe que o jogador ainda não tem, sorteada a cada visita. Até 5 skills por Descida (as 3 iniciais mais 2 compradas). Itens raros não entram na loja (ADR-0022).
- Atualizar o estoque (reroll) custa 15 moedas na primeira vez, mais 10 em cada nova atualização no mesmo nó.
- O curandeiro (seção 11) aparece na mesma tela.
- Preços básicos: consumível 20 a 60; equipamento comum 60 a 150; raro 250 a 600, escalando com o cenário.

### Escalas e ralos

| Ralo | Efeito de design |
| --- | --- |
| Curandeiro (custo ×1,5 a cada cura) | Faz doenças serem decisões caras |
| Reroll da loja | Troca ouro por chance de achar o que falta |
| Skills de fim de cenário | Sorteio caro; obriga a escolher entre skill e equipamento |
| Remoção de maldição | Controla o poder dos itens malditos |
| Forja de Almas | Gasta moedas e fragmentos |

Meta de balanceamento: ao final de um cenário, o jogador deve ter acumulado ouro para cerca de 60% do que gostaria de comprar. Se esse número fugir, a simulação (seção 23) ajusta a fórmula de ouro antes dos preços.

## 16. Monetização

O modelo proposto é híbrido: anúncios premiados opcionais para o jogador que não paga, e compras diretas e determinísticas para quem quer conveniência. Nada vendido dá poder exclusivo, e nenhum item pago é sorteio. Isso protege a dificuldade, que é a razão de o jogo existir, e evita problemas legais no Brasil. Os ganchos de hábito que fazem o jogador querer voltar, e assim escolher assistir anúncios ou removê-los, estão na seção 26.

### Anúncios premiados (sempre opcionais)

Intersticiais e banners ficam fora, porque quebram a tensão do jogo. Dados de mercado indicam que jogadores que usam anúncios premiados compram mais e ficam mais tempo, mas isso só vale se o anúncio for uma escolha clara.

| Ponto | Oferta | Limite proposto |
| --- | --- | --- |
| Tela de morte | Reviver na mesma batalha com 50% de HP | 1 por cenário |
| Moeda (seção 7) | (sem oferta: a moeda é 50% fixo; o que o anúncio faz aqui é decisão de monetização futura) | n/a |
| Baú | Dobrar o ouro do baú | Sem limite fixo por Descida |
| Loja | Atualizar o estoque de graça | 1 por cenário |
| Santuário | Bônus diário pequeno (fragmentos de forja) | 1 por dia |

Boas práticas observadas na indústria: a Kongregate relata como referência cerca de 30% de engajamento com anúncios e uns 4 anúncios por jogador por dia; em um roguelike deles, deixar a tela de reviver mais clara subiu o engajamento de 6,5% para 17%. Neste jogo, a tela de reviver mostra as opções com o mesmo peso visual, incluindo "não, obrigado".

### Compras diretas (sem moeda premium na v1)

| Produto | O que é | Regra de justiça |
| --- | --- | --- |
| Pacote de Moedas da Sorte | Re-jogadas da moeda | A definir: a Moeda da Sorte é drop raro (ADR-0026); vender re-jogada precisa de decisão e de limite |
| Incenso de Cinzas | Afasta um roaming boss por 3 nós | Teto de 2 usos por Descida |
| Cinzas Refinadas | Cobre até metade dos fragmentos de forja | Nunca dá item que não possa ser feito sem pagar |
| Remover anúncios | Tira a oferta de anúncio e substitui por 1 Moeda da Sorte grátis por Descida | Não remove nenhuma regra de risco |
| Cosméticos | Penteados, esquema de cores de roupas, visual do tabuleiro | Sem efeito em jogo |
| Pacote inicial | Alguns consumíveis e cosméticos | Compra única |

### Limites legais e éticos

- **Brasil.** O ECA Digital (Lei 15.211/2025) está em vigor desde 17 de março de 2026 e veda caixas de recompensa (loot boxes) em jogos direcionados a crianças e adolescentes ou de acesso provável por eles. Por isso, o jogo não vende nenhum sorteio. Baús do jogo são conquistados, não comprados. A Moeda Viciada é um item determinístico, mas isso deve ser confirmado com um advogado antes do lançamento.
- **Classificação etária.** O tema (doença, violência) leva a classificação alta. Usar 16+ ou 18+ e implementar verificação de idade quando exigida reduz risco.
- **Design sem manipulação.** Sem notificações com apelo emocional para voltar a jogar, sem relógios artificiais e sem esconder a chance real da moeda.
- **Divulgação.** O gancho do grafo de três opções é o jogo real. Criativos de aquisição devem usar jogabilidade verdadeira. Anúncios do tipo "pull the pin" que não aparecem no jogo já foram classificados como enganosos (por exemplo, na decisão do ASA do Reino Unido sobre a Playrix) e pioram a avaliação do jogo nas lojas.

Estas notas não são aconselhamento jurídico. Antes do soft launch, revisar com um profissional as regras do ECA Digital, das lojas e dos países-alvo.

## 17. Cenários e biomas

Cada cenário é um tabuleiro isométrico gerado a partir do grafo do mapa, sempre dentro do tema do bioma e com peças 3D que compõem o diorama, como em Final Fantasy Tactics. O tabuleiro é o mapa: os nós são locais no cenário e a Bibiana caminha pelas estradas entre eles.

### Os cinco cenários

| # | Cenário | Camadas | Nível dos inimigos | Inimigos típicos | Clima possível | Chefe |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Cidade Abandonada | 5 | 1 a 6 | Cidadãos infectados, ratos grandes, corvos, cães de peste | Chuva, Névoa | O Coveiro |
| 2 | Catacumbas | 6 | 5 a 11 | Esqueletos, cultistas, ghouls, médicos da peste | Névoa, Eclipse | A Viúva de Ossos |
| 3 | Brejo Doente | 7 | 9 a 16 | Sanguessugas gigantes, lenhadores febris, bruxos | Chuva, Tempestade, Lua de Sangue | A Mãe do Brejo |
| 4 | Catedral dos Sinos | 8 | 14 a 22 | Fanáticos, gárgulas, coro de vozes | Eclipse, Vento de Cinzas | O Bispo Cego |
| 5 | Cidadela | 9 | 20 a 30 | Cavaleiros doentes, quimeras, gente da corte | Nevasca, Lua de Sangue, Vento de Cinzas | O Rei Febril |

O protótipo faz apenas o cenário 1; o MVP (Alpha) tem os cenários 1 a 3, e a versão completa chega a 5 no Beta (seção 22).

### Geração do tabuleiro

1. **Layout:** o grafo ganha posições em uma grade isométrica (camadas da esquerda para a direita ou de baixo para cima).
2. **Estradas:** caminhos entre nós são traçados com busca de caminho na grade, com curvas leves para não parecerem linhas retas.
3. **Praças:** cada nó vira uma praça com props que dizem o tipo (fogueira acesa, baú, forca, altar).
4. **Preenchimento temático:** o resto da grade recebe chão e props do bioma por regras de pesos e vizinhança (por exemplo, wave function collapse simples), com limite de altura dos props para não esconder nós.
5. **Legibilidade:** os três nós disponíveis sempre ficam livres de obstáculos e levemente mais iluminados. O resto fica na penumbra (neblina de guerra, seção 5).
6. **Variedade barata:** um kit modular de cerca de 25 peças de chão e 40 props por bioma, com variação de cor, rotação e luz.

### Janela de combate

A luta usa um fundo 3D menor, derivado do próprio nó (praça, passagem estreita ou sala do chefe), com a mesma câmera fixa e o clima ativo. Isso economiza arte e mantém o jogador no mesmo mundo.

### Identidade de cada cenário

- A paleta muda por bioma, mas a mecha da Bibiana continua como o ponto de cor mais saturado.
- Cada bioma tem uma música e um som ambiente próprios e um evento de natureza favorável ao tema.

## 18. Direção de arte e pipeline de assets com IA

Recomendação: modelos 3D de poucos polígonos renderizados em baixa resolução interna, com contorno e paleta reduzida, para ter um look de pixel art em 3D que o autor consegue produzir com IA e que roda em aparelhos médios. O autor não tem experiência em arte, então o estilo precisa ser fechado por regras, não por talento de mão.

### Duas rotas visuais

| Critério | A. 3D low-poly pixelizado (recomendada) | B. HD-2D com sprites 2D |
| --- | --- | --- |
| Como funciona | Modelos 3D renderizados em baixa resolução (por exemplo, 480×270 interno) com contorno e posterização | Sprites de pixel art em planos dentro de cenário 3D, com profundidade de campo e tilt-shift, como em Octopath Traveler |
| Animação | Rig, esqueleto e animações reaproveitáveis | Quadros desenhados à mão para cada ação e direção |
| Equipamento visível | Peças trocam no modelo; mecha por shader | Exige novas folhas de sprite por item |
| Geração com IA | Texto ou imagem para 3D já existe e está madura | Quadros de sprite consistentes e animados ainda são difíceis de gerar |
| Risco | Consistência de estilo entre modelos de ferramentas diferentes | Custo de artista e de animação |

A rota B fica como evolução futura se o jogo ganhar um artista.

### MVP com assets abertos (CC0)

Decisão: o MVP usa modelos prontos e livres, sem gerar arte com IA. O look decidido continua sendo a rota A (3D pixelizado) e o pipeline técnico é o mesmo; o que muda é que a arte vem de kits CC0 já modelados, rigados e animados. Assim a mecânica é validada primeiro e a arte só é refeita, com orçamento adicional, se o jogo passar do portão da Fase 2. Premissa: "sprites, personagens e tiles open source" foi lido como kits abertos de personagens, monstros e cenário; os kits 3D abaixo têm animação pronta e licença CC0, por isso entram no lugar de sprites 2D.

| Pacote | O que cobre | Licença e fonte | Cuidado |
| --- | --- | --- | --- |
| KayKit, Character Pack: Adventurers | Bibiana, aliados e humanoides: personagens rigados, 75 animações, mais de 25 armas e acessórios, textura única de 1024 px | CC0 ([Godot Asset Library](https://godotengine.org/asset-library/asset/2129)) | A página lista de 4 a 5 personagens; confirmar ao baixar se há um que sirva de Clérigo |
| KayKit, Character Animations | Mais de 100 animações humanoides, como golpe, golpe pesado, bloqueio, esquiva e derrota | CC0 ([itch.io](https://kaylousberg.itch.io/kaykit-character-animations)) | Funcionam em outros humanoides com retarget do Godot |
| KayKit, Dungeon Pack | Cavaleiro, Mago, Bárbaro e Ladino, armas, itens e peças de masmorra | CC0 na versão original ([OpenGameArt](https://opengameart.org/node/120659)) | Conferir a licença das versões Remastered e Skeletons na página de cada uma |
| Quaternius, Ultimate Monsters | 50 monstros com animações de ataque, morte, andar e outras | CC0 ([Sketchfab](https://sketchfab.com/3d-models/ultimate-monsters-pack-fd72e114d119488da71fe3a16f216c4f)) | Estilo próprio; unificar pelo shader |
| Quaternius, Modular Dungeon e Fantasy Props MegaKit | Mais de 45 peças modulares de masmorra e cerca de 200 props com 4 conjuntos de textura | CC0 ([masmorra](https://opengameart.org/content/lowpoly-modular-dungeon-pack), [props](https://opengameart.org/content/fantasy-props-megakit)) | Poucas texturas ajudam o orçamento de chamadas de desenho |
| Kenney, Graveyard Kit, Modular Dungeon Kit e Mini Dungeon | Cemitério com 90 modelos, entre eles esqueletos e zumbis, e peças de masmorra | CC0, crédito opcional ([Kenney](https://kenney.nl/assets/graveyard-kit), [itch.io](https://kenney-assets.itch.io/graveyard-kit)) | Bom para o cenário 1 e para o tema de morte |
| Alternativa 2D | Kenney, Isometric Miniature Dungeon: tiles isométricos 2D | CC0 ([OpenGameArt](https://opengameart.org/node/66688)) | Só se o 3D for abandonado; personagens 2D não foram pesquisados |

Como usar os kits no jogo:

- Classes: Guerreiro = Cavaleiro, Mago = Mago, Ladino = Ladino; o Clérigo fica pendente até confirmar um modelo adequado ou ser montado com cajado e recolorido. Como o equipamento não tem trava de classe (seção 10), as armas e acessórios dos kits viram peças trocáveis.
- Mecha da Bibiana: uma peça separada de cabelo (malha simples) com parâmetro de shader de cor (seção 9), adicionada no Blender ao modelo escolhido. A cor muda por parâmetro, sem novas texturas.
- Identidade visual: pacotes de autores diferentes só parecem um jogo juntos com o mesmo pós-processamento (contorno, posterização, paleta por cenário) e atlas de textura reduzido; o autor dos kits KayKit informa que a textura de 1024 px pode cair para 128 px. Esse trabalho é a etapa 6 do pipeline (seção 21).
- Registro de licença: assets/LICENSES.md com pacote, autor, link, licença e data do download. A página do KayKit pede para não revender cópias sem modificação, o que o jogo não faz.
- Troca de arte depois da validação: as entidades apontam para cenas por id (campo "modelo", seção 20), então trocar a arte é trocar arquivos, sem mexer nas regras. Decisão e orçamento no portão da Fase 2 (seção 22).

### Regras do estilo (resumo do Style Bible)

- **Resolução interna:** 480×270 (ajustável), ampliada em múltiplos inteiros para não borrar.
- **Contorno e realce** por shader de pós-processamento, com paleta reduzida por cenário (24 a 32 cores).
- **Luz:** baixa e dramática. Fontes quentes (fogo, vela) contra azul-acinzentado frio. Neblina e vinheta.
- **Câmera fixa isométrica,** com leve profundidade de campo e efeito de miniatura (inspirado no HD-2D) nos modos de maior desempenho.
- **Regra do acento:** só três elementos saturados na tela: a mecha da Bibiana, o ouro da moeda e o vermelho de perigo. O resto é dessaturado.
- **Formas legíveis:** silhuetas distintas para cada tipo de inimigo; ícones de intenção grandes e com formas diferentes, não só cores.

### Orçamento de desempenho (metas)

| Item | Meta |
| --- | --- |
| Chamadas de desenho por quadro | Abaixo de 100 (regra prática para aparelhos médios) |
| Triângulos na tela | Até cerca de 60 mil no tabuleiro; 8 mil por chefe; 2 a 4 mil por personagem |
| Texturas | Atlas de 128 a 256 px por kit, compressão VRAM (ETC2 ou ASTC) |
| Luz | Luz direcional única dinâmica; o resto baked ou falsa |
| Partículas | Até 200 simultâneas |
| Quadros | 30 fps mínimo; câmera fixa permite 60 em aparelhos melhores |

A documentação do Godot recomenda luz baked para dispositivos móveis e instancing de objetos repetidos; esses valores são metas a validar em aparelho real (seção 20).

### Pipeline de geração de assets

No MVP, as etapas 2 e 4 saem, porque os kits CC0 já vêm modelados, rigados e animados, e a etapa 3 se reduz a ajustes (mecha, paleta, escala). Style Bible, importação, kits modulares e refinamento continuam. A geração por IA descrita aqui volta na troca de arte depois da validação da mecânica.

1. **Style Bible e imagens-âncora:** gerar, escolher e fixar 10 a 15 imagens de referência (personagem, inimigo, tile, prop) para guiar todo o resto.
2. **Geração 3D por IA:** texto ou imagem para 3D com ferramentas como TRELLIS.2 (licença MIT, demo gratuita no Hugging Face) e Meshy ou Tripo nos planos gratuitos, em modo low-poly. Gerar várias opções e descartar silhuetas ruins antes de texturizar.
3. **Limpeza no Blender,** com MCP do Blender para automatizar: decimar, UV, remover lixo, ajustar escala e pivô, aplicar a paleta do bioma.
4. **Rig e animação:** um esqueleto humanoide padrão para a Bibiana e para humanoides inimigos, com animações de biblioteca reaproveitadas (idle, andar, ataque, dano, morte). Criaturas não humanoides usam animação simples por transformação (balanço, esticar e comprimir) mais flash, shake e hit-stop.
5. **Kits modulares:** 25 peças de chão e 40 props por bioma, 7 modelos de arma e 3 visuais de armadura (seção 10).
6. **Importação no Godot** com nomes e escalas padronizados e checagem automática de orçamento de triângulos.
7. **Refinamento humano** (etapa 6 do pipeline, seção 21): unificar paleta e luz, polir animações, timing de efeitos.

### Regras de segurança e licenças

- **Originalidade.** Os jogos citados são inspiração de mecânica e atmosfera. Os prompts não citam jogos, personagens ou artistas, e nenhum personagem, logo ou design conhecido é reproduzido.
- **Licença comercial.** Cada ferramenta tem regras próprias: por exemplo, o plano gratuito do Meshy usa CC BY 4.0, que permite uso comercial com crédito à Meshy; para o Tripo as fontes divergem, então conferir os termos atuais; o TRELLIS.2 tem licença MIT; o Hunyuan3D fica de fora porque sua licença não cobre União Europeia, Reino Unido e Coreia do Sul, e o roadmap prevê lançamento global. Registrar a ferramenta, a data e o plano de cada asset em um ADR ou planilha antes de usar em produção.
- Assets abertos (por exemplo, bibliotecas CC0) também passam por registro de licença: pacote, autor, link, licença e data do download em assets/LICENSES.md. KayKit, Quaternius e Kenney publicam seus pacotes como CC0, mas cada pacote novo ou remasterizado deve ser conferido na hora do download.

### Ferramentas com o orçamento atual (Gemini Pro e Claude Pro)

O autor tem Gemini Pro e Claude Pro e nenhuma outra assinatura, então o pipeline usa apenas ferramentas gratuitas além desses dois planos.

| Tarefa | Ferramenta | Uso e cuidado |
| --- | --- | --- |
| Arte do MVP | Kits CC0 (KayKit, Quaternius, Kenney) | Sem custo e sem geração por IA; Blender só para a mecha e a paleta. As ferramentas de IA abaixo ficam para a troca de arte |
| Imagens-âncora e conceitos | Nano Banana (Gemini Pro) | Usar como referência para o Style Bible e para o 3D, não como arte final: imagens do plano Pro mantêm marca visível, segundo [reportagem sobre o anúncio do Nano Banana Pro](https://horadecodar.com.br/imagem-gemini-uso-comercial/). Os termos do Gemini não reivindicam a propriedade da imagem, mas a proteção autoral de saídas de IA segue incerta ([análise dos termos](https://www.terms.law/ai-output-rights/gemini/)) |
| Modelo 3D a partir da imagem | [TRELLIS.2](https://huggingface.co/microsoft/TRELLIS.2-4B/blob/main/README.md) (licença MIT) | Usar a demo gratuita no Hugging Face ou um notebook do Colab. Rodar localmente pede GPU NVIDIA com muita memória, o que o autor não declarou ter |
| 3D alternativo | [Meshy no plano gratuito](https://docs.meshy.ai/en/webapp/pricing) | 100 créditos por mês, CC BY 4.0: uso comercial com crédito à Meshy na tela de créditos do jogo e na página da loja |
| Limpeza, rig e animação | Blender (gratuito) com Blender MCP | O Claude Pro ajuda com scripts de importação e checagem de orçamento de triângulos |
| Música | Lyria 3 no app Gemini | Faixas de 30 s no plano gratuito e até 3 min no Pro, com limite de 20 por dia no Pro ([fonte](https://www.androidauthority.com/gemini-lyria-3-pro-rollout-3652057)). Toda faixa leva a marca SynthID, inaudível. Gerar loops curtos por cenário e guardar o prompt e a data |
| Efeitos sonoros | Bibliotecas CC0 | Registrar a licença de cada arquivo |

Se os limites gratuitos apertarem, o primeiro gasto a considerar é o Meshy Pro (cerca de US$ 20 por mês segundo [um site de preços](https://aitoolsatlas.ai/tools/meshy-3d/pricing)), só depois do portão da Fase 1. Antes de publicar, confirmar nos termos atuais do Google se imagens e músicas do plano Pro podem ir no jogo vendido.

## 19. Áudio, interface e acessibilidade

O medo vem tanto do som quanto da imagem, e a interface precisa ser legível mesmo em um jogo escuro, com o polegar em uma mão só. Tudo o que pode matar deve ter um sinal claro de som, forma e texto.

### Áudio

- **Música adaptativa:** ambiente de drone no mapa, camadas esparsas no combate, tema próprio para chefes. Silêncio proposital antes de golpes de moeda.
- **Sinais sonoros:** o sino rachado anuncia mini boss (1 toque) e roaming boss (2 toques). A moeda tem um tique crescente.
- **Efeitos de combate:** curtos e secos, com hit-stop de 60 a 100 ms nos acertos para dar peso.
- **Origem:** música e efeitos podem vir de bibliotecas com licença ou ferramentas de IA; a licença comercial de cada uma precisa ser registrada (seção 18).

### Interface móvel

- Menu de combate na metade de baixo da tela, com botões de pelo menos 48 px de toque. Informação crítica (vida, ícones de intenção, linha do tempo) na metade de cima.
- Hierarquia clara: o que mata (intenção), o que cura, o que é recompensa.
- Tooltips curtos com números reais, incluindo a chance da moeda.
- Loja e inventário com comparação rápida (seta verde ou vermelha) e botão "equipar e vender o antigo".
- Mapa com os 3 caminhos sinalizados por brilho e ícone; as rotas com perigo ou mutação têm marca visível.

### Acessibilidade

- Lados da moeda diferentes por forma e símbolo, não só por cor. Ícones de intenção e de status com formas distintas.
- Opções: modo para daltônicos, reduzir flashes, desligar vibração, tamanho de texto, velocidade de animação, "pular animações".
- Opção de dificuldade: modo mais leve com golpes de moeda menos frequentes, para quem quer só a atmosfera.
- Idiomas: português do Brasil e inglês no lançamento; textos em arquivos separados desde o início.

## 20. Arquitetura técnica (Godot)

A regra central é separar as regras do jogo (combate, mapa, economia) da apresentação (cenas 3D, interface). Assim, o núcleo roda sem tela, pode ser testado e simulado milhares de vezes, e agentes de IA conseguem alterá-lo com segurança.

### Escolhas

| Tema | Escolha proposta | Motivo |
| --- | --- | --- |
| Motor | Godot 4.x | Leve, gratuito, exporta para Android; fluxo de trabalho bom para IA e texto |
| Renderizador | Compatibility (OpenGL ES 3.0) no início; avaliar Mobile (Vulkan) depois | Maior cobertura de aparelhos; 3D simples. Medir em aparelho real |
| Linguagem | GDScript tipado para jogo; sem C# na v1 | Iteração rápida e simples para agentes |
| Dados | Recursos (.tres) ou JSON validados por schema | Inimigos, itens, skills e eventos sem mudar código |
| Testes | GUT ou GdUnit4, mais simulação headless | Regras testadas sem abrir o jogo |
| Anúncios e compras | Plugin de anúncios premiados e Google Play Billing | Necessários só a partir da Alpha |
| Telemetria | Evento por nó, combate, moeda, morte e anúncio | Base para o balanceamento (seção 23) |

A documentação e guias do Godot recomendam, para móveis, evitar Forward+, usar luz baked e reduzir chamadas de desenho; esses pontos entram nos testes de desempenho (seção 18).

### Camadas

1. **Núcleo (sem nós do Godot):** estado da Descida, gerador de mapa, motor de combate, economia, doenças, moeda, IA dos inimigos.
2. **Dados:** definições de Inimigo, Skill, Item, Doença, Mutação, Evento, Bioma, Receita de Forja.
3. **Apresentação:** cenas 3D do tabuleiro e do combate, interface, efeitos, áudio.
4. **Serviços:** save, anúncios, compras, telemetria, localização.

A comunicação do núcleo para a apresentação usa eventos (por exemplo, "DanoCausado", "MoedaLancada"), para as animações e a lógica ficarem desacopladas.

### Aleatoriedade determinística

- Quatro fluxos de sorteio com sementes separadas: mapa, combate, loot e moeda.
- A mesma semente e as mesmas escolhas reproduzem a mesma Descida. Isso permite reproduzir bugs, testar balanceamento e fazer a Descida diária no futuro.
- O lance da moeda usa o fluxo de moeda, com chance fixa de 50%; a Moeda da Sorte só rejoga um lance errado, dentro do próprio lance.

### Entidades principais

| Entidade | Campos principais |
| --- | --- |
| Inimigo | id, nome, nível base, stats, ciclo de ações, resistências, drops, tags (morto-vivo, doente), modelo |
| Skill | id, classe, custo, alvo, fórmula, moeda (sim ou não), status aplicado, animação |
| Item | id, slot, raridade, stats, efeitos, maldição, preço base, modelo |
| Doença, Mutação | id, efeito, fonte, custo ou chance |
| Nó | id, camada, tipo, inimigo, mutado, recompensa, vizinhos |
| Bioma | id, camadas, níveis, pools de inimigos e eventos, kit de tiles |

### Salvamento e ciclo de vida

- Auto-save a cada nó e ao pausar ou fechar o app. O arquivo guarda semente, escolhas e estado, não só o resultado.
- Meta-progresso em arquivo separado, com versão de formato e migração.
- Salvamento na nuvem na fase de soft launch.

### Dispositivo alvo

Aparelho "médio" ainda precisa ser definido. Proposta inicial: Android com 3 GB de RAM e GPU de classe intermediária. O aparelho de teste atual é um Galaxy S23 Ultra, que é topo de linha e sozinho não prova desempenho em aparelhos médios. Até comprar um Android usado de entrada ou intermediário (antes do portão da Fase 2), testar com limite de 30 fps, resolução interna reduzida e sessões de 20 minutos para ver o aquecimento.

### Testar no PC, sem atualizar APK

O dia a dia roda no computador; o celular entra só para medir desempenho, aquecimento e sensação de toque.

- Rodar direto no desktop: o Godot executa o jogo em uma janela a partir do editor, sem exportar nada. Configurar a janela em retrato (por exemplo, base de 540×960) com estiramento que mantém a proporção, para a tela se parecer com a do celular ([documentação do Godot](https://docs.godotengine.org/en/latest/tutorials/viewports/multiple_resolutions.html)). O padrão do projeto é paisagem, então a orientação também precisa ser ajustada para retrato ([guia de toque](https://uhiyama-lab.com/en/notes/godot/touch-input-mobile-safe-area/)).
- Mouse como dedo: ligar emulate\_touch\_from\_mouse em Input Devices, Pointing; um clique vira toque. Só um dedo é criado, o que basta para esta interface de toque único. Manter emulate\_mouse\_from\_touch ligado (é o padrão) e desligar o primeiro antes de exportar para o celular ([guia de toque](https://uhiyama-lab.com/en/notes/godot/touch-input-mobile-safe-area/)).
- Atalhos de depuração, só em builds de desenvolvimento: escolher a semente, pular nó, dar ouro, forçar o lado da moeda, matar o inimigo. A simulação headless (seção 23) também roda no PC.
- Versão no navegador, para jogar e mostrar sem instalar: exportar com o preset Web. A exportação usa o renderizador Compatibility e, desde o Godot 4.3, é single-thread por padrão, sem cabeçalhos especiais ([VIVERSE](https://news.viverse.com/?p=10479)). Publicar em um host com link privado, como o itch.io, que aceita rascunho com link secreto ou acesso por senha, com limite de 500 MB e 1.000 arquivos ([guia](https://ziva.sh/blogs/godot-web-export)); abrir o link no navegador do celular dispensa o APK. Se a primeira abertura mostrar tela preta, recarregar uma vez. A carga inicial de um 3D grande pode passar de 30 MB ([guia](https://www.summerengine.com/zh/blog/godot-web-export-guide)), e o desempenho no navegador não representa o do APK.
- Instalar no celular com um clique: com o preset Android marcado como executável, o editor exporta, instala e roda em modo de depuração no aparelho conectado, por cabo USB ou por ADB sem fio (depuração sem fio nas opções do desenvolvedor, `adb pair` com o código e a mesma rede Wi-Fi) ([documentação do Godot](https://docs.godotengine.org/en/stable/tutorials/export/one-click_deploy.html)). Não há APK para baixar nem instalar à mão.
- Cadência: desktop em toda tarefa; celular ao fim de cada tarefa que mexa em interface, toque ou desempenho, e antes de cada portão, com uma sessão de 20 minutos para ver o aquecimento. O link web serve para os primeiros playtests com outras pessoas.

### Estrutura do repositório

- `docs/`: GDD, ADRs e notas (vault do Obsidian).
- `game/`: projeto Godot (`core/`, `data/`, `presentation/`, `services/`).
- `tools/`: simulador de balanceamento, scripts de importação, validação de dados.
- `assets_src/`: Blender e imagens-fonte.
- `tests/`.

## 21. Pipeline de produção em 8 etapas

Todo trabalho do jogo passa por oito etapas, em ordem, e nenhuma tarefa vai ao commit sem passar pelas anteriores. O objetivo é deixar o autor (arquiteto) no comando enquanto agentes de IA escrevem código e uma revisão cruzada pega erros.

| # | Etapa | Entrada | Saída | Critério para avançar |
| --- | --- | --- | --- | --- |
| 1 | Planejamento e registro (Obsidian, ADR) | Ideia ou problema | Nota de planejamento e ADR com decisão, alternativas e consequências | Decisão registrada e ligada à seção do GDD |
| 2 | Abertura de tarefa obrigatória (Agent Framework) | ADR ou item do roadmap | Arquivo de tarefa com ID, objetivo, critérios de aceitação, arquivos afetados e testes esperados | Sem tarefa aberta, nenhum agente escreve código |
| 3 | Desenvolvimento assistido por IA (Claude ou Gemini, Godot) | Tarefa | Código, dados e cenas na branch da tarefa | Cumpre os critérios; segue o guia de estilo do projeto |
| 4 | Revisão cruzada por agente externo | Diff da tarefa | Relatório de revisão com problemas e sugestões | O revisor é outro modelo que o autor; achados críticos resolvidos |
| 5 | Testes automatizados e validação de regras | Código revisado | Testes passando, simulações, validação de dados | Suite verde, regras do GDD respeitadas (por exemplo, mapa sempre vencível) |
| 6 | Refinamento humano (arte, polimento, animação) | Build funcional | Paleta, luz, animações e efeitos ajustados | Revisão visual e de sensação em aparelho real |
| 7 | Documentação contínua e atualização de Skills | Tarefa concluída | GDD, ADR e Skills dos agentes atualizados | Documentos refletem o que foi feito |
| 8 | Commit consolidado no Git por tarefa | Tudo anterior | Um commit (ou uma branch com squash) por tarefa, com ID | Mensagem com ID da tarefa e link do ADR |

### Detalhes por etapa

- **Etapa 1.** O vault do Obsidian tem pastas para GDD, ADRs, decisões de balanceamento, pesquisas e diário. O modelo de ADR tem Contexto, Decisão, Alternativas, Consequências e Status.
- **Etapa 2.** O Agent Framework exige uma tarefa por mudança. A tarefa inclui regras que o agente não pode quebrar (por exemplo, "não mudar fórmulas de dano sem ADR").
- **Etapa 3.** Os agentes carregam Skills do projeto: estilo de GDScript, estrutura de pastas, formato de dados, regras do GDD. A lógica do jogo fica no núcleo, sem nós do Godot (seção 20).
- **Etapa 4.** Quando Claude escreve, o Gemini revisa, e o contrário. O checklist cobre erros de regra, segurança de dados, complexidade e testes faltando.
- **Etapa 5.** Testes unitários de fórmulas (dano, moeda, economia), teste de propriedade do gerador de mapa e simulação de milhares de combates. Rodada de teste no desktop (janela em retrato, mouse como toque) em toda tarefa e exportação de teste para Android ao fim das tarefas de interface, como "smoke test".
- **Etapa 6.** Trabalho humano: aprovar a estética dos assets (no MVP, a unificação dos kits CC0 pelo shader; depois, os de IA), corrigir animações, polir a animação da moeda e o feedback de dano.
- **Etapa 7.** Se uma regra mudou, o GDD muda no mesmo dia. Skills dos agentes ganham o que o time aprendeu.
- **Etapa 8.** Mensagem de commit no formato `TAREFA-ID: resumo` com a referência do ADR.

### Definição de pronto de uma tarefa

- [ ] ADR ou nota de planejamento ligada
- [ ] Tarefa aberta com critérios de aceitação
- [ ] Código conforme o guia de estilo
- [ ] Revisão cruzada feita e achados críticos resolvidos
- [ ] Testes e simulações verdes
- [ ] Revisão humana visual e de sensação, quando houver mudança de arte ou animação
- [ ] GDD, ADR e Skills atualizados
- [ ] Um commit consolidado com o ID da tarefa

*[diagrama disponível só no artefato: pipeline de 8 etapas · 2 portões de qualidade]*

Revisão cruzada e testes são os dois portões: qualquer achado devolve a tarefa ao desenvolvimento antes do refino humano, da documentação e do commit.

## 22. Roadmap

O caminho vai do protótipo sem arte até o soft launch, com um portão de decisão ao fim de cada fase: o jogo só ganha escopo se a fase anterior provar que é divertida. As durações são estimativas para uma pessoa mais agentes de IA e devem ser recalibradas após a Fase 1.

| Fase | Duração estimada | Entrega | Portão de decisão |
| --- | --- | --- | --- |
| 0. Fundação | 2 semanas | Vault do Obsidian, ADRs iniciais, repositório, Agent Framework e pipeline de 8 etapas funcionando, Style Bible, esqueleto do Godot | Primeira tarefa passa pelas 8 etapas |
| 1. Protótipo cinza | 4 a 6 semanas | Combate 1 contra 1 com moeda, 1 classe, 1 conjunto de inimigos, mapa em grafo com 5 camadas, tudo com formas simples e sem arte | Teste de diversão: o jogador quer "só mais uma" depois de 3 Descidas |
| 2. Vertical slice | 8 a 10 semanas | Cenário 1 completo com os kits CC0 unificados pelo shader, 2 classes, chefe, loja, fogueira, doenças básicas, mecha de cabelo, tabuleiro gerado | Playtest com cerca de 10 pessoas; mecânica validada e decisão sobre a troca de arte; 30 fps no aparelho-alvo |
| 3. Alpha | 10 a 12 semanas | 4 classes, cenários 2 e 3, mutações, roaming boss, Forja de Almas, anúncios premiados, Santuário | Ciclo completo jogável de ponta a ponta; meta de vitória por cenário atingida em simulação |
| 4. Beta e soft launch | 8 semanas | Cenários 4 e 5, compras diretas, telemetria, balanceamento por dados, Descida diária | Retenção e mortes por moeda dentro das metas (seção 23) |
| 5. Lançamento | A definir | Lançamento global, Abismo | Estabilidade, avaliação nas lojas |

*[diagrama disponível só no artefato: roadmap · 6 fases e portões]*

Cada fase só começa depois do portão da anterior; as durações são estimativas.

Arte do MVP e troca de arte: até o portão da Fase 2 o jogo usa só kits CC0 (seção 18). Se a mecânica passar nos playtests, o orçamento adicional escolhe entre um artista 3D por contrato, o pipeline de IA da seção 18 ou a rota HD-2D. A troca é decidida nesse portão e só mexe em modelos, texturas e shader, porque as regras ficam no núcleo (seção 20). Os testes de dia a dia rodam no PC e o celular entra ao fim das tarefas e nos portões (seção 20).

### O que fica de fora do MVP

Pavor (seção 12), iOS, Descida diária, Abismo, placar online, cosméticos, traduções além de português e inglês e a rota visual B do HD-2D (seção 18).

## 23. Balanceamento e métricas

O balanceamento começa em simulação, antes de qualquer jogador, e só depois passa para telemetria. Todas as metas abaixo são hipóteses internas de partida, não benchmarks de mercado, e devem ser trocadas por dados reais no soft launch.

### Ferramentas

- **Simulador headless:** roda milhares de combates e Descidas com bots de referência (um "mediano" e um "cuidadoso") por classe, usando o mesmo núcleo do jogo (seção 20).
- **Planilha de curvas:** HP, dano, ouro e preços por nível, ligada aos arquivos de dados.
- **Telemetria no jogo:** eventos por nó, combate, lance de moeda, morte, anúncio, compra e doença.

### Metas de partida

| Métrica | Meta inicial | O que fazer se fugir |
| --- | --- | --- |
| Taxa de vitória do cenário 1 (jogador mediano) | 55% a 65% | Ajustar nível e ouro do cenário 1 |
| Taxa de vitória do cenário 2 | 30% a 40% | Idem |
| Taxa de vitória da Descida completa | 8% a 15% | Ajustar chefes e doenças |
| Diferença de vitória entre classes | Dentro de 10 pontos percentuais | Ajustar atributos iniciais e skills |
| Mortes causadas por moeda | 25% ou menos | Reduzir penalidade ou frequência |
| Mortes sem aviso | 0 | Corrigir telegraphs e interface |
| Duração média de combate comum | 6 a 10 turnos | Ajustar HP e dano dos inimigos |
| Tempo até morrer na primeira Descida | 5 a 10 min | Ajustar o início |
| Engajamento com anúncios premiados | A medir (referência da indústria: 30% dos jogadores ativos) | Revisar ponto e oferta |

### Alavancas de ajuste

1. Nível dos inimigos por camada (curva do cenário).
2. Frequência de elites, mutações e golpes de moeda.
3. Ouro por vitória e preços da loja.
4. Atributos iniciais e crescimento por Poder.
5. Brasas por fogueira e frequência de fogueiras.
6. Custo e frequência de doenças.

### Testes de playtest

- **Fase 1:** "quer jogar de novo?" depois de morrer, e quantas Descidas seguidas o jogador faz sem ser pedido.
- **Fase 2:** onde o jogador morre, quais nós ele evita, o que ele chama de injusto, e se entende cada ícone de intenção sem explicação.
- **Soft launch:** retenção no dia 1, 7 e 30, tempo de sessão e receita por usuário ativo, com metas definidas depois de ver os primeiros dados.

## 24. Riscos e mitigação

Os maiores riscos são escopo, consistência da arte feita por IA e frustração com a sorte. Cada um tem uma mitigação ligada a uma fase do roadmap.

| Risco | Probabilidade | Impacto | Mitigação |
| --- | --- | --- | --- |
| Escopo grande demais para uma pessoa | Alta | Alto | MVP com 3 cenários; portões de decisão por fase; Pavor e rota HD-2D fora do MVP |
| Estilo inconsistente em assets de IA | Alta | Médio | Style Bible com imagens-âncora, paleta por bioma, shader único de contorno, refinamento humano (etapa 6) |
| Kits CC0 de autores diferentes sem identidade visual | Alta | Médio | Shader único de contorno e posterização, paleta por cenário, atlas de textura reduzido, Style Bible; no MVP o objetivo é validar mecânica, não beleza |
| Troca de arte depois da validação custa mais do que o previsto | Média | Alto | Entidades apontam para cenas por id; teste de orçamento de triângulos; definir o orçamento adicional no portão da Fase 2 |
| 3D lento em aparelhos médios | Média | Alto | Orçamento de triângulos e chamadas; aparelho intermediário usado antes do portão da Fase 2 (até lá, S23 Ultra limitado a 30 fps); baked light; resolução interna baixa |
| Sorte frustrante | Média | Alto | Avisos, defesas, teto de 85%, Maré de azar, telemetria de mortes por moeda |
| Dificuldade faz o jogador desistir | Média | Alto | Cenário 1 fácil, mapa sempre vencível, modo mais leve opcional |
| Regulação (ECA Digital, lojas) | Média | Alto | Sem loot boxes; classificação etária adequada; revisão jurídica antes do soft launch |
| Licenças de assets (IA e kits abertos) | Média | Alto | Registro por asset (ferramenta ou pacote, data, plano, link); preferir modelos com licença clara; conferir a licença de cada pacote CC0 no download |
| Percepção de pay-to-win | Média | Médio | Moeda 50% fixa, itens pagos também dropam, nada exclusivo de pagamento |
| Cópia involuntária de jogos de referência | Baixa | Alto | Prompts sem nomes; revisão de originalidade na etapa 6 |
| Bugs de geração de mapa | Média | Médio | Teste de propriedade com milhares de sementes; sementes salvas em cada relatório de bug |
| Esgotamento do autor | Média | Alto | Tarefas pequenas, pipeline automático, marcos curtos com entregas visíveis |

## 25. Perguntas em aberto

O GDD segue em frente com uma premissa para cada ponto em aberto. Responder estas perguntas troca a premissa por uma decisão, e as seções ligadas mudam junto.

| # | Pergunta | Premissa usada | Seção |
| --- | --- | --- | --- |
| 1 | O jogo deve ser em retrato (uma mão) ou paisagem? Decidido: retrato. | Retrato | 6, 19 |
| 2 | Ao morrer, volta ao início da Descida inteira ou ao início do cenário atual? Decidido: início da Descida. | Início da Descida (3 cenários no MVP) | 4 |
| 3 | "Mapa de 5 nós" significa 5 camadas no caminho? E uma fogueira por mapa a partir de 5 camadas? | Sim; 1 fogueira a partir de 5 camadas e 2 a partir de 8 | 5, 12 |
| 4 | O Poder se perde ao morrer? | Sim; só persistem Ecos, desbloqueios e Almas guardadas | 9 |
| 5 | O meta-progresso pode dar bônus numérico permanente? | Sim, até +10% somado | 9 |
| 6 | O combate é sempre 1 contra 1, ou elites e chefes podem trazer ajudantes? | 1 contra 1, com chefes que invocam ajudantes de vez em quando | 6, 13 |
| 7 | Os anúncios premiados e as compras que você imaginou podem seguir os limites da seção 16 (teto de 90% na moeda, sem sorteio pago)? Decidido: sim. | Sim | 7, 16 |
| 8 | Qual a classificação etária alvo e o mercado de lançamento (Brasil primeiro)? | 16+ ou 18+, Brasil e depois global | 16 |
| 9 | O Pavor (medidor de pressão psicológica) entra na primeira versão ou fica para depois do MVP? | Fora do MVP | 12 |
| 10 | Você aceita a premissa de lore (a Febre dobra o caminho) e os nomes propostos para chefes e cenários? | Sim, como rascunho | 3, 13, 17 |
| 11 | Qual aparelho Android você tem como pior caso de teste? Decidido: o aparelho do autor é um Galaxy S23 Ultra (assumido a partir de “S3 Ultra”). | Meta de 3 GB de RAM e GPU intermediária, validada em um aparelho usado antes do portão da Fase 2; até lá, testar no S23 Ultra com 30 fps e resolução reduzida | 18, 20 |
| 12 | Há orçamento para ferramentas pagas de IA 3D, imagem e música, ou só gratuitas? Decidido: só Gemini Pro (Nano Banana, Lyria) e Claude Pro. | Nenhum gasto extra: 3D em planos gratuitos, imagem com Nano Banana e música com Lyria 3 (seção 18) | 18 |
| 13 | Você prefere o look 3D pixelizado (recomendado) ou HD-2D com sprites? Decidido: 3D pixelizado como look final; no MVP, kits 3D CC0 prontos (seção 18). | 3D pixelizado; MVP com kits CC0 | 18 |
| 14 | O MVP pode usar sprites, personagens e tiles open source e ser jogado no PC, sem atualizar o APK a cada teste? Decidido: sim. | Kits 3D CC0 no MVP; troca de arte só após a mecânica validada; testes no desktop, versão web para compartilhar e instalação no celular por um clique | 18, 20, 22 |

## 26. Retenção e hábito: voltar por vontade, sem manipulação

O jogo vira hábito quando toda morte já deixa uma razão para tentar de novo e quando anúncios e compras entregam algo útil; nenhuma mecânica abaixo pune quem não paga nem esconde regra.

O mercado aponta na mesma direção. Em uma pesquisa com jogadores citada pela Mobidictum, sequências diárias (64%) e eventos ou desafios (50%) são os principais motivos para voltar ([fonte](https://mobidictum.com/loyalty-design-long-term-growth-mobile-games/)). Quem assiste anúncios premiados tende a reter mais, mas isso reflete em parte que já são os jogadores mais engajados ([fonte](https://appsamurai.com/blog/rewarded-ads-in-mobile-games-strategy-data-and-best-practices/)), então a conta só fecha se a recompensa for boa.

### Regras de ouro

- Tudo o que um anúncio dá também sai jogando, só que mais devagar.
- Anúncio é sempre escolha do jogador, com botão claro e recompensa visível ([boa prática de anúncios premiados](https://docs.unity3d.com/Packages/com.unity.ads@3.6/manual/MonetizationResourcesBestPracticesAds.html)).
- Faltar um dia nunca zera nada: a sequência só perde um nível, para a recompensa ser convite e não castigo ([guia de recompensas diárias](https://bugnet.io/blog/how-to-design-daily-rewards-that-arent-manipulative)).
- Sem energia que limita Descidas, sem temporizador falso, sem chance escondida e sem sorteio pago.
- Nada pago dá poder exclusivo (regra da seção 16).

### Ganchos de jogabilidade

| Mecânica | Como funciona | Fase |
| --- | --- | --- |
| Morte que ensina | Uma tela pós-morte mostra o que causou o dano, o que faltou (por exemplo, “o chefe ficou com 12% de vida”), uma dica e o botão “Outra Descida”. Os Ecos são sempre creditados pela profundidade, então nenhuma Descida é perdida | Alpha |
| Votos da Descida | Antes de entrar, o jogador aceita até 3 votos opcionais (vencer o cenário 1 sem usar itens, evitar todos os elites). Cada voto cumprido dá Ecos extras | Alpha |
| Desbloqueio gotejante | Nas 5 primeiras Descidas há sempre algo novo (skill, item ou classe); depois, a cada 3 Descidas. O Santuário mostra o próximo desbloqueio e quanto falta | Alpha |
| Códice e maestria | Bestiário, itens e conquistas completos por etapas. Cada classe tem nível de maestria que libera cosméticos (variações da mecha, como uma mecha de brasa) e passivas alternativas sem poder extra. Isso empurra o jogador a tentar as 4 classes | Alpha e Beta |
| Descida diária | Mesma semente para todos no dia (a arquitetura da seção 20 já permite). Uma tentativa grátis por dia com Ecos bônus. Sem ranking online na v1: recorde pessoal e código de semente para comparar com amigos | Beta |
| Brasa Acesa (sequência gentil) | Dias jogados em seguida dão um bônus pequeno com teto (por exemplo, até +10% de Ecos). Faltar um dia desce 1 nível, e há 1 dia de folga automático por semana | Beta |
| Rival da Semana | Um roaming boss nomeado, gerado pela semente da semana, com recompensa cosmética e uma relíquia leve na primeira vitória semanal | Beta |
| Semana temática | Um evento de natureza forçado por semana (Lua de Sangue, Nevasca) com Ecos bônus e risco maior; reaproveita os sistemas da seção 14, sem arte nova | Beta |

### Anúncios que o jogador quer ver

Além dos pontos da seção 16, estas ofertas aparecem em momentos de pausa e dão ajuda concreta, para o anúncio fazer parte do ritmo e não parecer castigo.

| Ponto | Oferta | Limite proposto |
| --- | --- | --- |
| Fogueira | Soprar as Brasas: +1 Brasa nesta fogueira | 1 por fogueira, 2 por Descida |
| Mapa | Lanterna do Viajante: revela o tipo de 1 nó na névoa | 1 por cenário |
| Pós-chefe | Dobrar as moedas da Alma vendida | 1 por chefe |
| Antes da Descida | Trocar um voto | 1 por Descida |
| Descida diária | Segunda tentativa | 1 por dia |

- Teto geral de cerca de 6 anúncios por Descida, com contador visível (“Anúncios desta Descida: 2 de 6”), para evitar fadiga.
- A oferta aparece como botão com a recompensa escrita, nunca como pop-up que bloqueia a tela, e “Não, obrigado” tem o mesmo peso visual.
- Medir a taxa de aceite por ponto: abaixo de cerca de 30% costuma indicar recompensa fraca, não jogador avesso a anúncios ([fonte](https://appsamurai.com/blog/rewarded-ads-in-mobile-games-strategy-data-and-best-practices/)). Comparar também a retenção de D1 e D7 com um grupo de controle sem a oferta, porque aceite alto pode esconder perda de jogadores ([guia de posicionamento](https://www.applixir.com/?p=4336)).

### Remover anúncios sem perder a graça

- **Peregrino sem Anúncios (compra única):** some qualquer oferta de anúncio e cada uma vira 1 uso gratuito com os mesmos limites. Não dá poder novo, só tira o atrito.
- **Momento da oferta:** depois da primeira Descida concluída ou de cerca de 10 anúncios assistidos; aparece uma vez, pode ser dispensada e só volta após 14 dias.
- **Pacote do Peregrino:** remover anúncios, Moedas da Sorte e um cosmético. Pacotes iniciais que removem anúncios e entregam utilidade real reduzem o arrependimento de compra e o tempo até a primeira compra ([fonte](https://mobidictum.com/loyalty-design-long-term-growth-mobile-games/)). O preço fica para o soft launch.
- Quem nunca paga nem assiste anúncios continua com o jogo completo.

### O que fica de fora de propósito

- Caixas de recompensa, energia ou vidas por tempo, sequência que zera ao faltar e eventos exclusivos de quem paga.
- Anúncio forçado após a morte e atalhos pagos para pular dificuldade.
- Notificações de culpa. Pode haver no máximo 1 por dia, com opt-in, e só para avisar que a Descida diária está pronta.
- Um lembrete discreto de pausa após cerca de 90 minutos seguidos de sessão (valor a testar), que sugere descansar na fogueira.

### Como medir

Acompanhar retenção de D1, D7 e D30, Descidas por sessão, taxa de aceite por ponto de anúncio e parcela de jogadores que removem anúncios. Metas só depois dos primeiros dados do soft launch (seção 23).

## Fontes

Consultadas em 15/11/2026 por busca na web. Foram lidos os trechos de resultado de cada página, não as páginas inteiras; confirmar os detalhes importantes antes de depender deles. Os valores de balanceamento, preços e metas do GDD são propostas deste documento, não dados das fontes.

- Fear & Hunger: [Game Mechanics (wiki)](https://fearandhunger.wiki.gg/wiki/Game_Mechanics), [Fear & Hunger 2: Termina (TV Tropes)](https://www.tvtropes.org/pmwiki/pmwiki.php/VideoGame/FearAndHungerTermina), [discussão sobre moedas na Steam](https://steamcommunity.com/app/1002300/discussions/0/4032473196481772263)
- Darkest Dungeon: [Camping (wiki)](https://darkestdungeon.wiki.gg/wiki/Camp), [Camping Skills (wiki)](https://darkestdungeon.wiki.gg/wiki/Camping_skills), [Glossary (wiki)](https://darkestdungeon.wiki.gg/wiki/Glossary), [guia sobre estresse](https://earlyguides.pages.dev/darkest-dungeon/beginners-guide)
- Slay the Spire: [Map Generation Guide](https://kosgames.com/slay-the-spire-map-generation-guide-26769/)
- Final Fantasy Tactics: [Final Fantasy Tactics (wiki)](https://finalfantasy.fandom.com/wiki/Final_Fantasy_Tactics), [sistema de batalha (Game8)](https://game8.jp/fft-tic/721362)
- Nemesis: [Shadow of War e o sistema Nemesis (Twinfinite)](https://twinfinite.net/ps4/5-ways-shadow-of-war-improves-upon-predecessor/2/)
- Dark Souls: [Why Dark Souls is the friendliest game (GamesRadar)](https://gamesradar.com/why-dark-souls-friendliest-most-benevolent-game-its-generation)
- Anúncios do tipo pull the pin: [PocketGamer.biz](https://www.pocketgamer.biz/the-evolution-of-pull-the-pin-why-is-this-a-good-thing-for-the-games-industry), [Mobile Matters](https://mobilematters.gg/guides/gaming/mobile-games-that-look-nothing-like-their-ads)
- Anúncios premiados: [AppSamurai](https://appsamurai.com/blog/rewarded-ads-in-mobile-games-strategy-data-and-best-practices/), [Kongregate](https://blog.kongregate.com/best-practices-in-game-ads)
- ECA Digital: [Agência Senado](https://www12.senado.leg.br/noticias/materias/2026/03/17/eca-digital-para-protecao-on-line-de-criancas-e-adolescentes-entra-em-vigor), [Confidata](https://confidata.com.br/blog/eca-digital-o-que-muda-empresas)
- HD-2D: [Wikipedia](https://en.wikipedia.org/wiki/HD-2D)
- IA 3D e Blender MCP: [linha do tempo de geradores 3D (Cinevva)](https://app.cinevva.com/guides/ai-3d-model-generation-timeline-2026), [comparação Meshy, Tripo e outros (Stray Spark)](https://www.strayspark.studio/blog/generative-3d-tools-comparison-meshy-rodin-tripo-csm-2026), [Blender MCP para jogos](https://www.summerengine.com/blender-mcp-for-games)
- Godot: [Optimizing 3D performance (documentação)](https://docs.godotengine.org/en/stable/tutorials/performance/optimizing_3d_performance.html), [otimização para móveis](https://slicker.me/godot/mobile-optimization.html), [3D pixel art no Godot](https://davidholland.netlify.app/articles/3d-pixel-art-rendering)

Fontes adicionadas na atualização das seções 18 e 26 (também lidos apenas como trechos de resultado):

- Ferramentas 3D e licenças: [Meshy: planos e licenças](https://docs.meshy.ai/en/webapp/pricing), [TRELLIS.2 no Hugging Face](https://huggingface.co/microsoft/TRELLIS.2-4B/blob/main/README.md), [licença do Hunyuan3D](https://huggingface.co/tencent/Hunyuan3D-2/blob/main/LICENSE)
- Gemini: [Lyria 3 Pro no app](https://www.androidauthority.com/gemini-lyria-3-pro-rollout-3652057), [música no Gemini](https://gemini.google/au/overview/music-generation/), [imagem do Gemini e uso comercial](https://horadecodar.com.br/imagem-gemini-uso-comercial/), [termos do Gemini](https://www.terms.law/ai-output-rights/gemini/)
- Retenção e anúncios premiados: [Mobidictum](https://mobidictum.com/loyalty-design-long-term-growth-mobile-games/), [recompensas diárias sem manipulação](https://bugnet.io/blog/how-to-design-daily-rewards-that-arent-manipulative), [AppSamurai](https://appsamurai.com/blog/rewarded-ads-in-mobile-games-strategy-data-and-best-practices/), [Applixir](https://www.applixir.com/?p=4336), [Unity Ads](https://docs.unity3d.com/Packages/com.unity.ads@3.6/manual/MonetizationResourcesBestPracticesAds.html)
- Kits CC0 do MVP: [KayKit Adventurers](https://godotengine.org/asset-library/asset/2129), [KayKit Character Animations](https://kaylousberg.itch.io/kaykit-character-animations), [Quaternius Ultimate Monsters](https://sketchfab.com/3d-models/ultimate-monsters-pack-fd72e114d119488da71fe3a16f216c4f), [Kenney Graveyard Kit](https://kenney.nl/assets/graveyard-kit)
- Teste no PC: [toque emulado pelo mouse no Godot](https://uhiyama-lab.com/en/notes/godot/touch-input-mobile-safe-area/), [exportação web e itch.io](https://ziva.sh/blogs/godot-web-export), [one-click deploy](https://docs.godotengine.org/en/stable/tutorials/export/one-click_deploy.html)
