# Direção visual do MVP jogável

| Campo | Valor |
| --- | --- |
| Status | Aceito (Orlando, 2026-11-19, ao reprovar a apresentação 2D da TASK-031) |
| Decisão | ADR-0036 |
| GDD | 5, 6, 12, 17, 18, 19 |

Este arquivo é o contrato visual. **Qualquer tarefa que desenhe tela lê este arquivo antes de escrever código** e só termina quando passa no "teste do print" (última seção). O GDD §17 e §18 continuam sendo a fonte das regras de arte; aqui estão as referências do Orlando, o que cada uma ensina e como isso vira tela.

## 1. O que o Orlando pediu (resumo fiel)

1. **Visão isométrica de tabuleiro, como Final Fantasy Tactics**: terreno com altura (degraus, muros, torres, pontes), objetos 3D, clima em partículas.
2. **O tabuleiro é o mapa.** Só uma parte dele aparece de cada vez. A pessoa vê **o caminho que pode seguir agora e o que a espera, mas ofuscado**, para dar ar de desafio. **Conforme ela avança de nó em nó, a tela acompanha (a câmera anda) e libera o resto do cenário.**
3. **A tela de combate** se inspira *levemente* em Fear & Hunger: um **plano de fundo que faz sentido com a masmorra e o tabuleiro onde a pessoa está**, personagens em primeiro plano, menu e painéis embaixo.
4. **Primeira versão com assets abertos (CC0)**, como já estava no GDD (§18, "MVP com assets abertos"). Se faltar modelo, usar o MCP do Blender.
5. **O protótipo cinza era só para testar mecânica.** O que existe hoje (retângulos, linhas e silhuetas desenhadas em código) não é "a versão com gráficos".

## 2. As sete referências

| # | Referência | O que mostra | O que adotamos | O que **não** adotamos |
| --- | --- | --- | --- | --- |
| 1 | **Hero Wars (anúncio)**, a origem do jogo | Masmorra isométrica em cortes de pedra e lava; herói no centro; **cada destino tem um número em bolha** (vermelho = inimigo e seu nível, azul = recompensa ou o nível do herói); baús com `+10`, `+5`, `+7`; item raro com `x4`; escadas, portas em arco, tochas e luz vermelha vinda de fora do quadro; **vários caminhos visíveis ao mesmo tempo** | O diorama em níveis ligados por escadas e portas; as **bolhas de número sobre cada destino** (nível do inimigo em vermelho, recompensa em dourado ou azul); o baú com valor visível; o brilho quente nos destinos disponíveis; o herói pequeno e legível no meio do cenário | Cores saturadas e estilo de desenho animado: o nosso é sombrio e dessaturado (regra do acento, GDD §18). Puzzles de somar números |
| 2 | **FFT: ponte de pedra e relva** (chuva, noite) | Torre de pedra com porta de madeira, ponte de lajes, **degraus de relva** com pedras aparentes nas bordas, fundo azul-noite liso, chuva fina; personagens pequenos de pixel art em cima de um **bloco de terreno flutuante** | O **terreno em blocos com altura**, bordas de pedra visíveis, o cenário como **diorama recortado flutuando no escuro**; chuva em partículas finas | Sprites 2D dos personagens (usamos modelos 3D de baixo polígono, GDD §18) |
| 3 | **FFT: castelo na neve** | Torres e muros de tijolo, passarela de madeira com neve, cantos de blocos, luz fria; **flocos de neve em primeiro plano com desfoque** (profundidade de campo); fundo em gradiente | Peças modulares de muro, torre e passarela; **neve, chuva e névoa** como camada de partículas à frente do cenário; leve desfoque de miniatura (tilt-shift) nas bordas | Neve como bioma do cenário 1 (a Cidade Abandonada tem chuva e névoa, GDD §17) |
| 4 | **Fear & Hunger (combate)** | Fundo **preto-quase-total com vinheta** e um cenário de silhueta atrás; **inimigo enorme e central**; grupo de costas embaixo; menu à esquerda (Attack, Skills, Guard, Item); painel do grupo (Body, Mind) com barras finas; ícones de status sobre o inimigo; **uma luz fraca no chão** destacando o palco | **Composição**: inimigo grande no centro, a Bibiana de costas ou de três quartos embaixo à esquerda, menu em painéis de bordas simples, ícones de status e de intenção sobre a cabeça do inimigo, vinheta forte, **luz no chão** | O fundo preto vazio: o nosso fundo **vem do nó onde a luta acontece** (rua, passagem, sala do chefe), escurecido |
| 5 | **FFT: combate com linha do tempo** | **Coluna de retratos à esquerda numerada 1 a 9** (ordem dos próximos turnos, o 5 em destaque); **painel inferior com retrato, HP, MP, CT, chance de acerto, e o dano previsto** (49) entre os dois combatentes; setas de altura; botão de ação "Attack" flutuando sobre o alvo | A **linha do tempo de turnos em coluna** (GDD §6, já pedida); o **painel de previsão** de dano e acerto entre os dois lados (já existe como texto; passa a ser painel); retratos com moldura colorida (azul aliado, vermelho inimigo) | Grade de movimento: o combate é 1 contra 1 (GDD §6) |
| 6 | **FF VII (batalha)** | Personagens 3D **de lado sobre o chão** com sombra, em frente a **um cenário pintado**; número de dano grande com brilho; painéis azuis embaixo com nome, HP, MP e barras de limite e tempo | **Número de dano grande e luminoso** sobre o alvo; **sombra projetada** no chão; barra de tempo/carga ao lado do HP | O azul clássico dos painéis (usamos pedra e bronze) |
| 7 | **Darkest Dungeon (acampamento)** | **O grupo sentado em volta da fogueira**, sombras longas, luz vermelha e quente, fundo de ruína; **painel inferior com retratos, atributos, inventário e skills de acampamento** em caixas escuras de borda fina | A **cena de fogueira**: a Bibiana junto ao fogo, luz quente oscilando, ruína ao fundo; as ações (Descansar, skills de fogueira, Galho Seco) em **cartões** embaixo, no estilo dos painéis de inventário | Grupo de 4: aqui é só a Bibiana |

### Padrões que se repetem (e viram regra)

1. **O cenário é o herói da imagem.** Em todas as referências o fundo ocupa a maior parte da tela e tem profundidade (camadas, altura, luz). Painéis de interface ocupam as bordas, nunca o centro.
2. **Luz dirigida.** Uma ou duas fontes quentes (fogo, lava, tocha) contra o resto frio e escuro. Nenhuma tela é iluminada por igual.
3. **Números e ícones sobre o mundo** (bolhas do Hero Wars, intenção do Fear & Hunger, dano do FF VII), não só em listas.
4. **Painéis de interface sóbrios**: fundo escuro, borda fina, texto claro, retrato à esquerda, barras finas.
5. **Clima e profundidade**: partículas em primeiro plano, névoa entre camadas, vinheta.

## 3. Tela do mapa (tabuleiro isométrico com visão parcial)

Esta é a tela mais importante do jogo. Regras:

1. **Câmera ortográfica isométrica** (yaw 45°, pitch cerca de 35° a 40°), fixa em ângulo, **móvel em posição**. O tabuleiro é muito maior que a tela.
2. **Terreno com altura.** Cada camada do grafo fica numa altura: a Descida **sobe ou desce** pelo cenário (escadas, rampas, pontes, degraus), como nas referências 1 a 3. O chefe fica no ponto mais alto ou mais fundo, **visível de longe** e coberto de névoa.
3. **O que se vê** (GDD §5, neblina de guerra):
   - **Nó atual:** a Bibiana, grande e legível, no centro da tela.
   - **Os 3 destinos disponíveis:** iluminados, com a **estrada visível** até eles e as **bolhas de número** da referência 1: **nível do inimigo (vermelho)**, **recompensa provável (dourado)**, e marca de elite, mutação, baú, fogueira ou evento. O inimigo aparece em miniatura 3D na praça do nó.
   - **O que vem depois:** o terreno continua aparecendo, mas **escurecido e coberto de névoa**; peças e silhuetas indistintas, sem tipo de nó. Dá para ver que **há** um caminho e **que algo espera**, não **o quê**.
   - **O que ficou para trás:** visível, mais escuro e com a névoa do "já visitado"; as estradas percorridas ficam marcadas.
4. **A câmera acompanha.** Ao escolher um destino, a Bibiana **caminha** pela estrada até a praça (1 a 2 s, pulável, GDD §6) e a câmera desliza junto. Ao chegar, **a névoa recua** em volta do novo nó (animação de 0,6 a 1 s: o escuro se dissolve e as peças novas "se acendem"). Ao tocar num destino ainda não escolhido, a câmera dá um pequeno puxão na direção dele (pré-visualização), sem se comprometer.
5. **Gerar o tabuleiro a partir do grafo** (GDD §17, "Geração do tabuleiro"): posições em grade, estradas por busca de caminho com curvas, praças com props que dizem o tipo (fogueira acesa, baú, forca, altar), preenchimento temático por pesos, **os 3 destinos sempre livres de obstáculos**.
6. **Legibilidade em retrato** (540×960): a Bibiana no terço inferior, os destinos no terço central, o que vem depois no terço superior, escurecendo para o topo. Toque mínimo de 48 px nos destinos (GDD §19).
7. **Clima** (chuva ou névoa do cenário 1) em partículas à frente, e a **mecha** da Bibiana no estágio do Poder, como único acento saturado além do ouro e do vermelho de perigo.

## 4. Tela de combate (inspirada levemente em Fear & Hunger)

1. **Fundo derivado do nó.** A luta acontece "naquele lugar": a praça, a passagem estreita ou a sala do chefe do tabuleiro, **escurecida, desfocada e com vinheta**, com o clima ativo (GDD §17, "Janela de combate"). Mesmo kit de peças do mapa, câmera próxima, **sem renderizar o mapa inteiro**.
2. **Composição em retrato** (GDD §6): metade de cima = palco (inimigo grande e central, a Bibiana de costas embaixo à esquerda, **luz no chão**, sombras projetadas), metade de baixo = painéis e menu.
3. **Topo:** coluna de retratos da **linha do tempo** (referência 5), ícone de **intenção** sobre a cabeça do inimigo (referência 4), e os ícones de status.
4. **Painel de previsão** entre os dois lados (referência 5): chance de acerto, crítico, dano previsto. É o que hoje aparece em texto nos botões.
5. **Moeda:** o lance acontece **no palco**, com a moeda 3D (ou medalhão) crescendo ao centro, vinheta que fecha, **silêncio** e tique (GDD §7, §19). Cara e Coroa diferentes por forma e símbolo.
6. **Número de dano** grande e luminoso sobre o alvo (referência 6), com hit-stop de 60 a 100 ms (GDD §19).
7. **Menu embaixo** na zona do polegar: Atacar, Habilidades, Defender, Item, Fugir, em painéis de borda fina (referência 4), botões de 48 px ou mais.

## 5. Fogueira, loja, baú e recompensa

- **Fogueira** (referência 7): cena própria com a Bibiana sentada junto ao fogo, luz quente oscilando, ruína ao fundo, partículas de brasa. Ações em **cartões** embaixo: Descansar, skills de fogueira (Brasas), armar com Galho Seco, tratar doença.
- **Loja:** o comerciante (modelo do kit) numa praça iluminada por lampião, mercadoria em **cartões** com seta verde ou vermelha de comparação (GDD §19). Botão "equipar e vender o antigo".
- **Baú:** o modelo do baú **abre em 3D** (referência 1), o ouro cai, e o multiplicador (Moeda da Sorte ou anúncio) aparece como `x2` sobre o baú.
- **Recompensa e fim:** retratos e atributos antes e depois, com o número `+` subindo; tela de fim com o cenário ao fundo.
- **Menu inicial e Santuário:** panorama do cenário com a Bibiana e a mecha em destaque; Santuário como cômodo em ruína com três estações (Biblioteca, Arsenal, Códice).

## 6. Como construir (decisões técnicas)

Ver ADR-0036. Resumo:

| Assunto | Decisão |
| --- | --- |
| Motor de cena | `Node3D` no Godot 4.7; câmera `Camera3D` ortográfica; **cada tela 3D numa cena própria** (`.tscn` só com o que é de cena; lógica em scripts) |
| Núcleo | Intacto. As cenas só leem eventos e `MapView`/`CombatSession` (regra 6 do `CLAUDE.md`); o `MapView` ganha a posição 3D de cada nó **na apresentação**, nunca no núcleo |
| Pixel-art em 3D | `SubViewport` com resolução interna baixa (480×270, ajustável), filtro `nearest`, ampliado em múltiplos inteiros; contorno e posterização por shader de pós-processamento (GDD §18). Se o contorno atrasar a primeira entrega, a primeira versão sai **sem contorno** e ele entra na TASK-039 |
| Assets | Kits CC0 do GDD §18: **Kenney** (Graveyard Kit, Modular Dungeon Kit, Mini Dungeon) para terreno e props; **KayKit Adventurers** para a Bibiana e humanoides; **Quaternius Ultimate Monsters** para os monstros. Cada pacote entra com registro em `assets/LICENSES.md` (pacote, autor, link, licença, data) |
| Blender | Para o que os kits não têm: mecha de cabelo da Bibiana, peças de ligação (escada, ponte) e **ajuste de escala e pivôs**. O servidor `blender` falhou ao conectar em 2026-11-18 (CONNECT_TIMEOUT); depende do addon aberto, ver `docs/MCP.md` |
| Entidades | O campo `modelo` (GDD §20) aponta para a cena por id; trocar arte = trocar arquivo, sem tocar nas regras |
| Névoa de guerra | Shader no chão e nas peças com um mapa de visibilidade por célula (revelado, visível, oculto); a TASK-036 define o formato |
| Áudio | O sintetizador procedural (`SoundFx`, ADR-0035) **fica** como substituto de efeitos; música e ambiente entram na TASK-039 com bibliotecas CC0 (Kenney Audio e afins), registradas em `LICENSES.md` |
| Desempenho | Metas do GDD §18 (60 mil triângulos no tabuleiro, 30 fps). **Medir no PC primeiro**; celular ao fim das tarefas (GDD §20) |

## 7. O que continua válido do trabalho anterior

- Todo o **núcleo** (regras, mapa, combate, economia, save, Santuário) e seus testes.
- O **`SoundFx`** (efeitos curtos) e a **paleta** (`VisualTheme`: cores da mecha, ouro, perigo), que servem de tema de interface.
- Os **controladores sem nós** (`MapView`, `CombatSession`, `RunPanels`): a nova camada 3D os usa.
- As telas 2D atuais ficam como **modo de depuração e de teste** (`GameScreen`), até a nova camada cobrir tudo. Elas **não são** a versão com gráficos.

## 8. O teste do print (definição de pronto visual)

Tarefa de tela só fecha quando o agente **abre o jogo com janela, tira um print de cada tela alterada e o anexa à tarefa** (`docs/tasks/prints/TASK-NNN-*.png`), e responde por escrito, olhando o print:

1. Existe **cenário com profundidade** (altura, camadas, luz dirigida), não retângulos nem desenho vetorial chapado?
2. A tela se parece com **a referência citada na tarefa** em composição (o que ocupa o centro, onde ficam os painéis)?
3. No mapa: dá para ver **os três caminhos e o que vem depois ofuscado**? A câmera acompanha o movimento?
4. Há **modelos 3D de kit CC0** (ou do Blender), com contorno ou sombra, e **clima** em partículas?
5. Os números e ícones estão **sobre o mundo** (bolhas, intenção, dano)?
6. Funciona em **retrato 540×960**, com toque de 48 px?

Se qualquer resposta for "não", a tarefa **não está pronta**, mesmo com a suíte verde. O Orlando faz a aprovação final olhando o jogo, não o relatório.

Como tirar o print (o modo headless não desenha): rodar o Godot **com janela** e um script `SceneTree` que salva `get_viewport().get_texture().get_image()` em PNG (`HANDOFF.md`, "Telas"); a TASK-035 entrega `tools/screenshot.gd` e `tools/screenshot.ps1` para isso.
