# Identidade visual de Bibiana's Quest: diagnóstico, gancho e régua de aprovação

| Campo | Valor |
| --- | --- |
| Autor | Direção de arte (revisão crítica, 2026-11-22) |
| Status | Proposta para o Orlando aprovar; vira ADR quando aceita |
| Base | `ART-DIRECTION.md`, ADR-0042, ADR-0036, `FEEDBACK.md` F-013/F-021/F-022/F-023, estudo `ESTUDO-ui-mobile-inimigos-estetica.md` (partes 3, 5, 6), prints reais em `docs/tasks/prints/_antes/` (540x960) |

O projeto não tem falta de documento de arte. Tem excesso de lista de referências e falta de **uma regra visual que o código obedeça**. O ADR-0042 diz "Sword of Convallaria + Bloodborne + Dark Souls + Triangle Strategy + Octopath + Ragnarok + Buriedbornes". Seis estéticas em lista não são uma identidade, são um moodboard. Este arquivo escolhe, e a escolha é verificável em print.

---

## A. Diagnóstico brutal (o que os prints mostram)

**Causa-raiz única:** a câmera, a luz e a escala estão de acordo com um *tabuleiro tático visto de longe*, mas o jogo é um *duelo 1x1* e um *mapa de 3 escolhas*. Tudo o que o Orlando quer (inimigo assustador, cenário com sentido) exige câmera perto e luz com intenção. Hoje o jogo mostra o mundo pequeno e uniformemente esmaecido.

### A.1 Combate (`combate-gravedigger.png`, `combate-plague_hound.png`)

1. **O inimigo não é o herói do quadro.** O Coveiro (chefe!) ocupa cerca de 55 px de largura por 150 px de altura num palco de 510x400: uns 8% da área do palco. O Cão de Peste mede uns 110x70 px, 3% da área. O Fear & Hunger de referência (`ui-fear-and-hunger.jpg`) dá ao inimigo 70% da altura do palco. O nosso é um boneco num estacionamento.
2. **O piso é a tela.** Mais de 60% do palco é laje rosa-bege sem nada: um losango claro, liso, com a mesma textura de ponta a ponta. É a primeira coisa que o olho vê e não tem informação. O inimigo, escuro e fino, perde o contraste para um chão mais claro que ele.
3. **A luz está invertida.** O chão está mais iluminado que o inimigo. Em qualquer referência boa (Bloodborne, Labyrinth, Vagrant Story) a luz revela a *criatura* e o chão cai para o escuro. Aqui o ponto mais claro é a laje vazia entre os dois, e o tom é rosa-lavanda (exatamente o "lilás lavado" que o ADR-0042 proíbe, e que continua lá).
4. **Cenário de papelão.** Muro de fundo cortado em linha reta, um prédio de costas cortado pela moldura, um poste verde (verde Kenney vivo, fora de paleta) cortado na borda esquerda. Não há rua, nem arco, nem fonte de luz diegética que explique a luz. O poste é o único lampião e não ilumina nada.
5. **Os dois combatentes são pequenos e brigam em pontos opostos de um campo vazio.** A Bibiana está embaixo à esquerda, de costas, com a cabeça de boneco (capacete cinza-azulado gigante) maior que o corpo. O inimigo está lá em cima. Distância entre os dois = 40% da altura do palco de espaço morto. Não há tensão de proximidade.
6. **UI invade o palco.** Barra de HP do inimigo, faixa cinza "ATAQUE Ataque" translúcida (que come 70 px do topo da cena), coluna de retratos e faixa de previsão no rodapé tomam cerca de 25% do palco. A faixa "ATAQUE Ataque" é texto duplicado e cinza chapado sobre pixel art: é a coisa mais "app genérico" da tela.
7. **Os dois inimigos de print são o mesmo desenho:** silhueta vertical fina + cor de pele clara. O Coveiro é um cone cinza com dois pauzinhos claros (a pá). O cão é um osso-de-esqueleto cor de bege. Nenhum tem um ponto emissivo, uma cabeça exagerada ou um motivo reconhecível. Quem os vê em 150 px lê "boneco".
8. **Pós-processo borra em vez de dar grão.** O dithering é pontilhado fino sobre a laje, o que dá "textura de impressão" e não de pedra suja; o contorno escuro não existe de verdade nas peças claras.

### A.2 Mapa (`mapa-inicio.png`, `mapa-meio.png`)

1. **Escala errada.** `CAM_SIZE = 27` num viewport de 270x480: a Bibiana tem uns 25 px de altura, os inimigos 30 px. O jogador toma decisões sobre três figuras do tamanho de formigas. Em Triangle Strategy (`estetica-triangle-strategy.jpg`) as figuras são pequenas, mas a **arquitetura em volta tem massa e detalhe que justificam a escala**. Aqui não tem.
2. **Não existe cidade, existe um tabuleiro de xadrez azul.** Losangos de azul-ardósia e preto alternados, sem rua, sem edifício coeso, sem fachada. Os "prédios" são três blocos pequenos nas bordas (jazigo no canto esquerdo, igreja de telhado liso no meio-direita) sem relação entre si. Cercas de ferro soltas, uma fonte/tumba gradeada no rodapé, postes verdes espalhados: **props sem lógica espacial**, exatamente o F-021 que ainda não foi resolvido na prática.
3. **O que importa não brilha.** Os três destinos têm uma mancha laranja do tamanho do pé do personagem; o resto é um azul parelho. Não há feixe, não há caminho aceso. As bolhas "Nv 1 / ouro" são o elemento mais forte da tela e são UI chapada, não mundo.
4. **Metade da tela é vazio.** O terço inferior do `mapa-inicio.png` (de y=620 a 960) é preto-azulado sem nada, e o topo (y<250) é névoa sem forma. A parte "ofuscada, mas dá pra ver que algo espera" (ART-DIRECTION §3.3) não existe: não há chefe visível, torre, catedral ao longe.
5. **Cabeçalho de depuração.** Quatro linhas de texto cinza e uma fileira de ícones de slot vazios no topo. Parece um protótipo.
6. **O telhado do `mapa-meio.png` (a "casa" de pedra à direita)** é um polígono lilás-cinza sem textura, com uma carcaça de osso/animal em cima. Em 270 px de largura é um borrão.

### A.3 Fogueira e loja (`campfire.png`, `shop.png`)

1. **A fogueira é um capacete verde.** O objeto central é um bloco verde-água com uma luz amarela no meio: não parece fogo, parece um item de jogo mobile. Fogueira em Dark Souls é espiral de espada em brasas; aqui não há labareda, nem lenha, nem halo quente no chão. Um **verde vivo** domina o único ponto focal.
2. **O painel de ações come 55% da tela** (y=445 a 940) e o diorama fica em 45%. Metade do painel é preto vazio (fogueira: 280 px de nada embaixo de uma única opção).
3. **Loja: o mercador é um senhor de chapéu verde com bigode, estilo taverna de RPG de celular.** A mesa laranja e as vasilhas brilhantes são o objeto mais quente da tela: parece mercearia, não bruxo do cemitério. O prédio atrás é uma caixa cinza vazada. Barril azul-laranja de Kenney sem sujeira.
4. **O herói aparece cortado atrás do painel** (a Bibiana na loja é só uma cabeça).
5. **Cartões da loja com texto cinza-escuro sobre preto** ("ouro insuficiente" apaga tudo), sem ícone grande, sem preço em ouro destacado. Legibilidade zero.

### A.4 O que as telas têm em comum

- **Paleta:** ardósia-lavanda uniforme + laranja pontual + verde-Kenney. Sem ponto de luz dominante, sem preto verdadeiro, sem acento de cor com significado.
- **Sem vertical.** Gótico é vertical (agulhas, arcos, contrafortes). Todas as telas são horizontais: lajes, cercas baixas, blocos. A única "agulha" é o poste de luz.
- **O que o Orlando gosta nos kits Kenney** (modelos limpos, cores reconhecíveis, silhuetas boas, peças que encaixam) não é a **cor** deles, é a **forma grossa e legível**. Nós os usamos tingidos de cinza sem corrigir a forma e sem a luz que lhes daria vida.

---

## B. A identidade: o gancho de uma frase

> **"Uma moeda de luz âmbar numa catedral de pedra morta: tudo no quadro é frio e quase preto, exceto aquilo que a Bibiana ilumina e aquilo que quer matá-la, e o inimigo é sempre maior que a luz."**

Em regra de produção (cada item é testável):

1. **Regra do foco quente único.** Cada tela tem **uma** fonte quente dominante (lampião, fogueira, brasa no peito do inimigo) e ela ilumina **o sujeito da tela**, nunca o chão vazio. Todo o resto vive entre `#07080B` e `#4A5360`. Se tirar a cor quente e a tela ainda lê igual, está errada.
2. **Regra da escala de pesadelo.** No combate o inimigo ocupa **no mínimo 55% da altura do palco** e ultrapassa a moldura de cima (cabeça cortada ou cabeça quase tocando o topo). A Bibiana é pequena e de costas, no terço inferior. A luz do herói (lampião ou brasa) é menor do que o corpo do monstro: ele nasce da escuridão, a luz é a ilha.
3. **Regra da rua gótica.** Todo cenário é **um lugar só** (um pátio de catedral arruinada, uma rua de paralelepípedo entre duas fachadas, uma nave). Nunca há peças soltas. Fundo é *parede alta com ogiva e agulha* se perdendo em névoa para cima.
4. **Regra do vermelho/ouro como linguagem.** Ouro `#D9AA32` = o que a Moeda decide e o que dá recompensa. Vermelho `#B82824` = perigo/intenção do inimigo. Nenhum outro acento saturado existe (a mecha da Bibiana é o terceiro, por GDD §18).

Por que esta é a assinatura e não "HD-2D gótico" genérico: quase todo dark fantasy mobile tem escuro + laranja. O que torna **este** jogo reconhecível é que a luz é a mecânica narrativa (a Moeda, o lampião da Bibiana, a brasa do inimigo) e que a **câmera de duelo é um close de diorama** (profundidade de campo de miniatura com figura gigante), não um tabuleiro distante. Pense: *a profundidade de camadas de Octopath/Triangle Strategy, o craft de pedra e madeira de Sword of Convallaria, a crueldade de silhueta de Buriedbornes e a arquitetura vertical do Bloodborne, tudo filtrado por uma única lanterna.*

### B.1 Paleta fechada (máximo 8 cores; nada fora delas, exceto a mecha)

| Nome | Hex | Uso |
| --- | --- | --- |
| Abismo | `#07080B` | fundo, vinheta, vãos de porta, 40% a 60% da área de qualquer tela |
| Ardósia Morta | `#1B2029` | sombra fria de pedra, ambiente (energia baixa) |
| Pedra Úmida | `#4A4E54` | lajes, muros, paralelepípedos (nunca mais claro que isto no chão) |
| Luar de Aço | `#7E8FA8` | única luz fria direcional, rim-light de silhueta, névoa iluminada |
| Lama e Madeira Podre | `#3A3128` | terra, madeira, couro, panos do inimigo |
| Âmbar de Lampião | `#E08A30` | **a** luz quente: lampião, fogueira, brasa, vitral aceso, olho do inimigo (um por cena) |
| Perigo | `#B82824` | intenção do inimigo, sangue, barra de HP inimigo, golpe de Coroa |
| Ouro de Moeda | `#D9AA32` | moeda, recompensa, destino com ouro |

Proibido: verde saturado (postes, pinheiros, fogueira-capacete), lavanda/rosa no chão, azul-ciano de UI, laranja de madeira Kenney sem multiplicar por Lama. Cor viva de kit é multiplicada por `#3A3128` ou `#4A4E54` antes de entrar (ver D.5).

### B.2 Regras de iluminação (valores de partida; ajustar no print, nunca no Blender)

1. Ambiente: `#1B2029`, energia 0.30 a 0.38 no combate e nos focais; 0.45 no mapa. O valor atual (`atmosphere.gd` 0.46 em cor `0.17,0.2,0.28`) é alto demais para o combate.
2. Uma `DirectionalLight3D` fria `#7E8FA8`, energia 0.5, ângulo baixo (-35 graus a -45 graus) **vindo de trás e do lado do inimigo** (rim-light que recorta a silhueta). Sombra ligada.
3. Uma luz quente `#E08A30` (`SpotLight3D` ou `OmniLight3D` curta, raio 4 a 5 unidades) **colocada perto do inimigo ou entre os dois, na altura do peito/cabeça**, nunca centrada no chão. Cintilação ±12% a 6 Hz.
4. O chão fora do cone quente deve cair a `#1B2029` em 1.5 unidade. O cone quente tem borda dura o suficiente para lê-lo a 540x960.
5. Névoa exponencial baixa, `#0B0E14`, densidade 0.04 a 0.06 no combate; engole o fundo a 2/3 da profundidade. Vinheta fechando 30% das bordas.
6. Brilho emissivo: **um** ponto por inimigo (olho, relicário, chaga, lanterna), `#E08A30` ou, nos de doença, `#8A834C` (febre).

---

## C. Composição (specs concretas)

### C.1 Tela de combate (viewport 3D interno 270x300, SHRINK 2 = palco de 540x600; hoje a UI cobre parte dele)

**Meta:** o monstro é uma presença, a Bibiana é uma figura pequena diante dele, e o resto da tela é arquitetura gótica caindo no escuro.

| Item | Spec |
| --- | --- |
| Câmera | Ortográfica continua (mantém pixel-art e o diorama), mas **muito mais perto e mais baixa**: `CAM_SIZE` de 6.6 para **3.6 a 4.0**; offset de `(1,0.8,1)*16` para pitch de 22 a 26 graus acima do horizonte (`Vector3(1,0.45,1)*16`), yaw 35 a 40 graus. Isso transforma o "tabuleiro visto de cima" em "duelo visto de uma altura de cintura": o inimigo se lê de pé, não achatado. |
| Alvo da câmera | Ponto a 55% da altura do inimigo, não o centro do piso. |
| Escala do inimigo | Altura do modelo = **2.8 a 3.2 unidades** (comum), **3.6** (elite), **4.2** (chefe/mini boss). Hoje: 1.9/2.1/2.4 "pela maior dimensão", o que diminui criaturas altas e infla criaturas baixas. Normalizar por **altura de pé** e deixar o cão grande ser largo, não alto. Em tela, no print 540x960: **inimigo comum >= 280 px de altura, chefe >= 380 px** (palco útil de 560 px). Cabeça do chefe pode encostar no topo do palco. |
| Escala da Bibiana | 1.3 a 1.5 unidade (hoje 1.9: cabeça de boneco maior que o necessário), de costas/três quartos, canto **inferior esquerdo, cortada ligeiramente pela borda inferior** (o corpo entra no quadro por baixo, como câmera sobre o ombro). Ocupa no máximo 30% da altura do palco. Razão inimigo:herói de **2.2:1 (comum) a 3:1 (chefe)**. |
| Posições | Inimigo no terço superior-central com os pés a ~62% da altura do palco; Bibiana nos pés no 88%. Distância entre eles = **menos de 1.2 unidades de piso**, para ver o monstro se inclinar sobre ela. |
| Camada 1 (primeiro plano, 10% da altura, escuro) | Silhueta de corrimão/balaústre de pedra ou grade de ferro no canto inferior direito e garrafa/poça; **fora de foco** (a mesma blur de `PostFx.COMBAT_BLUR`), `#07080B` a 85%. Partículas de chuva/cinza aqui, maiores. |
| Camada 2 (palco) | Piso de paralelepípedo molhado, 3 a 4 lajes de largura, **só até onde a luz quente alcança**. Poças (reflexo `Luar de Aço`), uma laje quebrada, uma vala. Nada de laje clara uniforme. |
| Camada 3 (fundo) | **Duas fachadas góticas que formam um corredor** convergindo (rua entre prédios, ou nave com colunas): ogivas cegas, contrafortes, uma agulha que sobe e some na névoa. Uma janela com vitral quebrado `#E08A30` a 25% de brilho no fundo longínquo (promessa de luz). Gradiente para `#07080B` no topo. |
| Luz | Spot quente `#E08A30` **na cabeça do inimigo ou no lampião ao lado dele**, banhando o peito e o rosto. Rim-light fria atrás dele. A Bibiana recebe só luz fria de lado (ela é a figura menos iluminada; o jogador lê a vida pelo HUD, não pela luz). Chão **mais escuro que o inimigo**. |
| Enchimento do piso vazio | Nunca piso liso. Obrigatório: (a) 2 poças com reflexo frio, (b) 1 objeto narrativo do nó (caixão aberto na rua do Coveiro, carroça tombada, cadeira do carcereiro), (c) névoa baixa rasteira em movimento lento, (d) sombra longa do inimigo alcançando a Bibiana. |
| UI | Faixa "ATAQUE Ataque" **eliminada** (a intenção vira um ícone/balão âmbar sobre a cabeça do inimigo, 48 px). Barra de HP do inimigo fina (10 px) sobre o palco, topo. Coluna de retratos reduzida a 3 itens 40 px. Previsão (dano/acerto) vai para dentro do bloco de ações. O palco é **>= 58% da altura da tela (560 px)**. |

### C.2 Mapa (viewport 270x480)

**Meta:** ver uma *rua gótica que sobe*, com três saídas iluminadas e uma catedral ao longe, não um tabuleiro de xadrez.

| Item | Spec |
| --- | --- |
| Câmera | `CAM_SIZE` de 27 para **13 a 15** (a Bibiana e os três destinos passam a medir **60 a 80 px** de altura em 540x960, não 25 a 30). Isso mostra ~3 camadas por vez, o que é o desejado (ofuscar o resto). Pitch ~30 graus. |
| Leitura | Bibiana no terço inferior (y 70% a 85%), três destinos no terço central, ruas visíveis como **fitas claras de paralelepípedo** `#4A4E54` contra o resto em `#1B2029`. O que não é caminho cai a 40% da luz. |
| Narrativa do cenário | Cada camada é **uma praça de uma única cidade**: avenida de entrada com lampiões; pátio de igreja com cemitério murado; ponte com rio escuro; adro com escadaria; e ao fundo, **a catedral/torre do chefe permanentemente visível** (volume escuro com vitral âmbar a 20%) no topo da tela, sobre névoa. Props de uma praça = um conjunto coeso (poço, carroça, forca; não 12 props aleatórios). |
| Vertical | Ao menos **2 estruturas altas** (agulha, torre de sino, fachada de 3 andares) em qualquer janela do mapa, projetando sombra longa sobre as ruas. Hoje o mais alto é um poste. |
| Destinos | Cada destino com luz própria: brasa para fogueira, vitral âmbar para evento, brilho dourado para baú, **luz vermelha pulsando para inimigo/elite**. A bolha `Nv 1` fica **sobre o monstro de verdade em miniatura 3D com 1.5x de escala**, não flutuando sozinha sobre um boneco de 30 px. |
| Neblina | Passado em `#0B0E14` a 70%, futuro em névoa que sobe de baixo, 3 níveis (visitado, visível, oculto) como já previsto, mas o **oculto precisa sugerir massa** (silhuetas de telhado e agulha), não só escuridão. |
| Cabeçalho | Texto de 4 linhas de depuração sai. Fica: HP/MP em barras finas no topo, ouro com ícone e os slots de item, 44 px no total. |

### C.3 Dioramas focais (fogueira, loja, baú, evento, recompensa)

**Regra geral:** o diorama é uma **vinheta de um canto da cidade** (3 x 3 lajes de piso elevadas como bloco recortado flutuando no escuro, como o FFT de `estetica-fft-combate`), com 1 parede de fundo gótica e 1 objeto focal que é a fonte da luz. Câmera `CAM_SIZE` ~4.5, mesmo pitch do combate (22 a 26 graus), painel de ações limitado a **38% da altura** (360 px), com altura mínima e o resto do espaço para o diorama.

- **Fogueira** (cripta de ruína): a fogueira é uma **pira de lenha torta com espada fincada e labareda animada** (partículas `#E08A30` + `OmniLight` com cintilação), 0.9 unidade de altura, no centro, brasas subindo. A Bibiana sentada **de frente para o fogo, de perfil**, rosto iluminado de baixo. Fundo: arco ogival cego de uma capela caída, ao fundo, 2 colunas quebradas; chão: laje quebrada, ossos, uma cruz de pedra inclinada. Nada de verde. O fogo é o **único** quente e o chão ao redor 3 laje se acende por 1.5 unidade.
- **Loja:** o mercador é um **vulto encapuzado e curvado** (capuz `#3A3128`, olhos `#E08A30`, mãos longas) atrás de uma **carroça-barraca de madeira escura** com 3 mercadorias claras (frasco, lâmina, relicário), iluminadas por 1 lampião pendurado `#E08A30` sobre ele. Fundo: porta gótica de uma casa emparedada com uma janela acesa. O modelo atual (senhor de chapéu verde com bigode) sai, é ele que torna a loja "mobile genérico".
- **Baú / evento / recompensa:** mesmo molde. O objeto (baú, altar, relicário) fica no centro, **a luz vem de dentro dele** (ouro `#D9AA32` ou febre), o resto do diorama escuro.
- **Home/menu:** a Bibiana de costas diante da silhueta da catedral gigante com a luz da moeda/lampião; título sobre a névoa.

---

## D. Regras de modelagem para inimigos neste render

Render: 270 px de largura internos, ampliado 2x nearest, depois posterizado e dithered. O inimigo comum, na composição C.1, terá **140 a 160 px de altura no viewport interno** (ou 280 a 320 px no print). Mas o desenho deve **funcionar em 64 px de altura** (retrato da linha do tempo e ícone do mapa).

### D.1 O que lê a 150 px (obrigatório)

1. **Silhueta primeiro.** O recorte preto do monstro, sem cor, deve ser reconhecível e diferente dos outros 7 inimigos. Teste: pintar tudo de `#07080B` sobre `#4A4E54` e mostrar a alguém. Um sino na cabeça, uma gaiola no peito, uma roda nas costas, uma maca de ossos, um pescoço de 1.5x o normal.
2. **Cabeça e mãos exageradas.** Cabeça 25% a 35% da altura total (mais, se for monstro grotesco), mãos/garras com 1.5x a 2x a escala real. É o que os olhos leem primeiro, e é onde mora o medo (rosto velado, boca costurada, mãos longas).
3. **2 a 3 faixas de valor, não mais.** Luz (peito/rosto/ombros), meio (panos/pele), escuro (pernas, sombra, cavidades). Cada faixa ocupa no mínimo 12 px a 150 px. Textura entre as faixas é para dar sujeira, não faixa nova.
4. **Um único foco emissivo `#E08A30`** (ou febre `#8A834C`): olho, relicário aberto, chaga, lanterna, sino. Mínimo de 6x6 px a 150 px, no terço superior do corpo. É o "olho do monstro" que o jogador procura.
5. **Formas grossas.** Nenhum membro, haste, arma ou lâmina com menos de **8% da largura do corpo** (12 px a 150 px). Se quer lâmina fina, ela vira lâmina larga; se quer corrente, a corrente fica **espessa e curta**.
6. **Cor por vértice e textura pintada, não geometria.** Rasgos de pano, ferrugem, sangue, fuligem, rachadura: pinte (vertex color + 1 textura 64x64 sujada) e **não modele**. Panos são 1 malha com pregas largas, não 20 cubos.
7. **Pose e peso.** Assimetria obrigatória: ombro caído, coluna curva, uma perna mais baixa, uma mão que arrasta algo. Postura a favor do centro de massa (inclinado para a Bibiana).
8. **Proporção adulta e sóbria (Tactics Ogre):** nada de olhos grandes, cabeça redonda lisa de brinquedo, tudo-arredondado. Cantos duros, ombros largos, pescoço longo ou ausente.

### D.2 O que NÃO lê e deve ser evitado (reprovação)

- Hastes finas (cajado, pá, lança) com menos de 8% da largura do corpo: viram dois pixels e somem no dithering (exatamente a pá do Coveiro hoje).
- Rebites, fivelas, dentes, dedos individuais, pregos: detalhe de 1 a 3 px some ou vira ruído.
- **Cor pálida lavada** (cinza-bege claro de pele, osso `#C8B89C`): o inimigo sai mais claro que o chão e desaparece; é o que acontece com o cão e o Coveiro hoje. Pele/osso do inimigo fica entre `#4A4E54` e `#7E8FA8`, nunca acima. Contraste: o inimigo deve ser **o objeto mais escuro ou o mais quente**, não o mais claro.
- **Empilhamento simétrico de primitivos** (cilindro + esfera + cubo + 2 cilindros de braço): o "quadradão" que o estudo §4.10 já diagnosticou. Todo inimigo precisa de pelo menos **uma malha orgânica** (pano com queda, ombro assimétrico, membro curvo).
- Verde, azul-celeste ou rosa em qualquer parte (inclusive "toque de cor").
- Figura estreita e alta num quadro largo: sem volume lateral não ocupa o frame. Lateral mínima: largura >= 45% da altura (capa, manto, ombreira, arma grande).

### D.3 Orçamento

| Item | Triângulos | Observação |
| --- | --- | --- |
| Inimigo comum | **1.500 a 2.500** | gasta em silhueta e cabeça, 60% do orçamento no torso+cabeça |
| Elite / mini boss | 2.500 a 3.500 | segunda arma ou segunda cabeça |
| Chefe / roaming boss | 3.500 a 5.000 (máx.) | o único que pode ter peças rígidas decorativas |
| Props de cena de palco (cada) | 200 a 800 | grandes e simples; um prop de 2.000 tris é erro |
| Cena de combate inteira | <= 25.000 | já tem folga no GDD §18 (60.000 no mapa) |
| Texturas | 1 de 128x128 (comum) a 256x256 (chefe) por inimigo, filtro nearest | + vertex color |
| Altura em modelo | Normalizada ao pé=0, 1 unidade = 1 m; reescalada pelo palco | pivô nos pés |

### D.4 Procedimento de modelagem em 4 passos (ordem obrigatória)

1. **Silhueta 2D** em 3 tamanhos (64, 150, 300 px) chapada em preto sobre cinza. Se não reconhece em 64 px, volta.
2. Blocar em 3 volumes grossos (cabeça, torso, arma/mão) e posar assimétrico.
3. Pintar valor em 3 faixas + 1 foco emissivo (vertex color).
4. **Render no jogo** na composição C.1 com a luz de B.2 e capturar 540x960. A aprovação é pelo print (seção E), nunca pela prévia do Blender.

### D.5 Como usar Kenney/Quaternius/KayKit como base (o que o Orlando gosta)

O Orlando gosta dos kits porque as **formas são grossas, simples e reconhecíveis**. A estratégia é manter essas formas e mudar **cor, luz e proporção**, não substituir por geometria nova ruim.

1. **Mantenha a malha, troque o material:** multiplicar `albedo` do kit pela paleta B.1 (Pedra Úmida, Lama, Ardósia). Nunca usar a cor original do Kenney. Adicionar `vertex_grime` (base escura nos pés, ferrugem nas arestas) via `tools/blender/kit.py`.
2. **Kit como corpo, parte feita à mão como cara:** do Quaternius Ultimate Monsters ou KayKit Skeleton, usar o corpo e a pose; trocar **cabeça e mão** por versões ampliadas (1.4x a 2x) e adicionar **1 prop de silhueta** (sino, gaiola, relicário, capuz torto) feito simples no Blender. Isso dá identidade com 80% do trabalho já feito.
3. **Cenário 100% a partir dos kits modulares** (Kenney Graveyard, Modular Dungeon): muros, colunas, arcos, lajes, grades, caixões, lampiões, **mas montados por `ScenarioGenerator` como uma rua/pátio coerente** (C.1/C.2). Se falta a peça ogival, fazer **uma** ogiva (arco pontiagudo de pedra, 300 tris) e instanciar 20 vezes. Aumentar escala vertical dos muros do kit em 1.6x (pé-direito alto, gótico).
4. **Trocar:** pinheiros verdes (remover), poste verde (retingir para ferro `#2A2D33`), fogueira-capacete (substituir), barril colorido (multiplicar).
5. **Não** tentar esculpir orgânico complexo se o kit já tem o corpo: o ganho vem da cabeça, da luz e do foco emissivo.

---

## E. Checklist de aprovação (12 itens, todos verificáveis no print 540x960 no jogo)

Cada item é **passa/falha** e vale para novo inimigo, prop ou cena. Eu só aprovo com **12/12**. A aprovação é feita sobre `docs/tasks/prints/TASK-NNN-*.png` capturado **no jogo, em escala real**; prévia do Blender não conta.

1. **Escala:** inimigo comum >= 280 px de altura (elite >= 330, chefe >= 380); inimigo e Bibiana na razão >= 2.2:1; a figura do inimigo ocupa >= 12% da área do palco.
2. **Primeiro olhar:** em 1 segundo, o ponto de maior contraste/brilho do quadro é o inimigo (ou o foco quente sobre ele), **não** o chão, o poste nem a UI.
3. **Chão:** nenhum trecho liso de piso maior que 80x80 px sem poça, quebra, sombra, objeto ou névoa; o chão fora do cone quente é mais escuro que o inimigo.
4. **Silhueta:** pintando o inimigo de preto em cima do print, ele é identificável e distinto dos outros 7 do bestiário.
5. **Valor:** 2 a 3 faixas de valor legíveis no corpo; nenhuma parte do inimigo mais clara que `#7E8FA8`.
6. **Foco quente:** exatamente um ponto emissivo `#E08A30` (ou `#8A834C`) com >= 6x6 px, no terço superior do corpo (ou no objeto focal da cena), e existe **uma** fonte quente dominante por tela.
7. **Espessura:** nenhuma haste, arma, corrente ou membro com menos de 12 px de largura no print; nenhum detalhe depende de 1 a 3 px.
8. **Paleta:** nenhum pixel de verde saturado, rosa, lavanda ou azul-ciano fora de UI; cor de kit sempre multiplicada pela paleta (conferir com conta-gotas: 95% dos pixels do palco dentro de matiz azul-ardósia/marrom + luz âmbar).
9. **Cenário com sentido:** o fundo é **um lugar** reconhecível (rua/pátio/nave), com pelo menos 1 elemento vertical gótico (ogiva, agulha, contraforte) e **nenhum prop solto** que não esteja encostado em parede, calçada ou grupo narrativo; nada cortado em linha reta pelo quadro sem névoa que o justifique.
10. **Profundidade:** três camadas distinguíveis (primeiro plano escuro e borrado, palco nítido, fundo em névoa); sombra projetada do inimigo e da Bibiana visíveis.
11. **Gótico e adulto:** nenhuma forma arredondada de brinquedo ou olho grande; pelo menos 1 sinal de decadência visível (rachadura, ferrugem, sujeira) a olho nu em cada peça nova.
12. **UI não invade:** palco >= 58% da altura em combate (>= 45% em fogueira/loja); sem texto duplicado ou faixa translúcida cinza sobre a cena; HP, intenção e previsão legíveis a 100% de zoom.

Reprovação automática (basta um): inimigo menor que o limite do item 1; piso claro e uniforme dominante; qualquer verde vivo; ponto de luz quente mais forte no chão do que no sujeito.

---

## F. As 10 mudanças de maior impacto (ordem de aplicação)

| # | Mudança | Esforço | Onde |
| --- | --- | --- | --- |
| 1 | **Aproximar a câmera do combate e baixar o pitch:** `CAM_SIZE` 6.6 para ~3.8, `CAM_OFFSET` com pitch 22 a 26 graus, alvo da câmera a 55% da altura do inimigo. Sozinho resolve metade do "inimigo pequeno". | baixo | `game/presentation/combat3d/combat3d_stage.gd` (`CAM_SIZE`, `CAM_OFFSET`, `CAM_TARGET`, `_aim_camera`) |
| 2 | **Escala por altura, não por maior dimensão**, com alvos 2.8/3.6/4.2 (inimigo) e 1.4 (Bibiana); reposicionar `ENEMY_POS`/`PLAYER_POS` para a distância de C.1. | baixo | `combat3d_stage.gd` (`_spawn_actors`, `ENEMY_POS`, `PLAYER_POS`); `game/presentation/stage/model_registry.gd` |
| 3 | **Reacender a cena:** ambiente 0.32, cor `#1B2029`, luar de aço de trás, spot âmbar na cabeça do inimigo, piso escurecido (multiplicar o `floor-detail` por `#4A4E54` e por gradiente radial). Eliminar o lilás. | médio | `combat3d_stage.gd` (`_build_environment`, luzes); `game/presentation/fx/atmosphere.gd` (`AMBIENT_*`, `FOG_*`); `post_fx.gd` |
| 4 | **Cenário de combate como rua gótica convergente:** substituir o muro reto + prédio cortado + poste verde por duas fachadas com ogivas e agulha, poças e prop narrativo; remover pinheiros e verdes. | médio-alto | `game/presentation/scenario/scenario_blueprint.gd`, `scenario_generator.gd`, `scenario_renderer.gd` (modo "duelo"); `combat3d_stage.gd` (`_build_*`) |
| 5 | **Tirar a faixa "ATAQUE Ataque", mover a intenção para um ícone sobre a cabeça do inimigo** e liberar o palco (>= 58%). | médio | `game/presentation/combat/combat_screen.gd`, `combat_texts.gd`; `game/presentation/fx/dark_theme.gd` |
| 6 | **Redesenhar os inimigos pelo D:** começar pelos 3 que mais aparecem (Cidadão Infectado, Cão de Peste, Coveiro). Silhueta, cabeça 30%, um foco emissivo, panos largos; corpo do kit + cabeça e prop novos. | alto | `tools/blender/` (kit.py com `skin_limb`, `draped_cloth`, `bevel_displace`, `vertex_grime`), `assets/`; `model_registry.gd` |
| 7 | **Mapa: `CAM_SIZE` de 27 para ~14, destinos com luz própria, catedral do chefe permanente ao fundo, 2+ estruturas altas por janela.** | médio | `game/presentation/map3d/map3d_screen.gd` (`CAM_SIZE`, `CAM_OFFSET`), `map3d_layout.gd`; `scenario_*.gd` |
| 8 | **Mapa: geração por praça coesa (rua, pátio, ponte, adro)** em vez de props aleatórios; ruas como fitas claras, resto escuro; remover cercas e postes soltos e o tabuleiro de losangos alternados. | alto | `map3d_layout.gd`, `scenario_generator.gd`, `scenario_validator.gd` (regra nova: "nenhum prop solto") |
| 9 | **Fogueira e loja:** pira de lenha torta com labareda e brasas (substitui o capacete verde); mercador encapuzado com carroça e lampião (substitui o senhor de chapéu); painel de ações <= 38% da altura. | médio | `game/presentation/camp3d/scene3d_backdrop.gd` (fogueira, `_build_shop`; hoje usa `"gravedigger"` como mercador), `game/presentation/run/*` (painel), `fx/weather_layer.gd` (brasas) |
| 10 | **PostFx e tema:** dithering Bayer antes da quantização, contorno por profundidade mais sutil, vinheta 30%, remover contorno preto duro; UI com pedra negra e filete de bronze, cabeçalho de depuração do mapa substituído por barras e ícones. | médio | `game/presentation/fx/post_fx.gd`, `dark_theme.gd`, `visual_theme.gd`; `map3d_screen.gd` (`_header`) |

**Ordem de execução recomendada:** 1, 2, 3 num único dia (só números e luz: o Orlando verá a diferença no mesmo print); em seguida 5 e 4; depois 6 (bestiário) em paralelo com 7 e 8 (mapa); 9 e 10 por último. Cada passo é aprovado por print contra a seção E antes do commit (regra do `CLAUDE.md`: uma tarefa por commit, `HANDOFF.md` atualizado).

## G. Como este arquivo entra no processo

- Vira ADR (proposta: ADR-0050, "Identidade visual: foco quente único, escala de pesadelo e régua de print") e é citado em `ART-DIRECTION.md` §8 como a nova régua de aprovação: o checklist E substitui as 7 perguntas subjetivas do "teste do print".
- Toda tarefa visual anexa um print 540x960 do jogo e preenche os 12 itens de E com "passa/falha"; sem isso a tarefa não fecha, mesmo com a suíte verde.
- Nada aqui altera regra do GDD, fórmula do núcleo ou `RULES_VERSION`.
