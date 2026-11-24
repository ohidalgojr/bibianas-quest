# Guia de Arte e UI: Bibiana's Quest (dark fantasy tático, mobile retrato 540x960)

| Campo | Valor |
| --- | --- |
| Autor | Direção de arte/UI sênior (revisão sobre o build testado pelo Orlando + `painted_map_screen.gd`) |
| Status | Proposta para aprovação do Orlando; vira ADR (sugestão: ADR-0055 "Guia de arte e UI mobile") quando aceita |
| Subordinado a | `docs/ART-DIRECTION.md`, `ADR-0042`, `docs/design/IDENTIDADE-VISUAL.md` (este guia detalha e corrige; não revoga) |
| Público | (a) agente de código sem talento artístico: implementa **só** o que está escrito aqui; (b) Orlando: gera assets no Gemini com os prompts da §11 |
| Regras do GDD §18 | Prompts nunca citam jogos, personagens ou artistas. Sem mecha colorida no cabelo (F-024). Sem texto dentro das imagens (todo texto é renderizado pelo motor) |
| Nada aqui altera regra do núcleo, fórmula ou `RULES_VERSION` | |

Convenções: **px** = pixels lógicos do viewport 540x960 (o celular real renderiza a 2x: todo asset novo é entregue a **2x**, ver §0.4). "Tela" = cena Godot. Nomes de arquivo em `snake_case`, minúsculos, sem acento.

---

## 0. Diagnóstico, princípios e as 10 regras inegociáveis

### 0.1 Veredito sobre o build testado (o que o Orlando viu) e causa de cada queixa

| # | Queixa do Orlando | Causa real (verificada nos prints/código) | Correção (seção) |
| --- | --- | --- | --- |
| 1 | Asset mal recortado | Sprites HD-2D saem de `tools/make_sprite.py` com borda de fundo `#10131A` residual (halo escuro) e sem alfa suave; pílulas e sprites cortam na moldura; 3D Kenney recortado pela câmera | §0.4 (recorte), §4.7 (margem segura), §11 (entrega a 2x com alfa limpo) |
| 2 | Vitória/level up "toscos": moeda, poção e Bibiana 3D soltos num losango | `reward`/`result` ainda montam o diorama 3D antigo (`focal_set.gd`/`scene3d_backdrop.gd`) sob um painel de texto; nenhum objeto tem relação com os outros | §7: quadro pintado + painel de relicário, **zero 3D solto** |
| 3 | Selecionar inimigo no mapa não foca, tudo cortado, sem indicador até o nó | `_focus_on(node_id)` em `painted_map_screen.gd` rola o mundo para pôr o **nó selecionado em y=670**, exatamente onde ficaria a Bibiana: o herói sai de quadro por baixo, o card de prévia (y 770-944) cobre o chão, e **não existe seta nem trilha**; o sprite de 226 px do chefe estoura o topo | §4.4 (enquadrar herói **e** alvo, trilha tracejada, seta pulsante, anel) |
| 4 | Ícones toscos; "Fugir" é um furacão | `IconRegistry` usa o pacote CC0 de 34x34 (gnola14): estilo pixel colorido de RPG genérico, chapéu de bruxo roxo para "Capuz de Peste", coração rosa, tornado roxo (`S_Wind01`) para Fugir. Fora de paleta e de linguagem (o resto do jogo é pintura sombria) | §3: **substituição completa**, painel pintado 96 px, auditoria item a item |
| 5 | Loja sem sentido, boneco 3D mal feito | A tela de loja ainda usa o diorama 3D com mercador-modelo; **já existe** a arena pintada `arena-loja.jpg` (alcova com lampião, mesa, balança) e o sprite `shop_keeper.png`, sem uso | §8: alcova pintada + sprite do mercador; grade de itens com ícone |
| 6 | Miniaturas dos inimigos no mapa borradas | Sprites de ~224-260 px de altura ampliados 2x pelo celular, com filtro linear, mais o `RIM_SHADER` que amostra `TEXTURE_PIXEL_SIZE*1.5` e suaviza; na versão 3D anterior, 270x480 esticado | §0.4 (2x, mipmaps, filtro), §4.6 (tamanhos), retrato-busto de 96 px |
| 7 | Mapa quase todo cinza, nada se vê | Fundo (arenas) + `dim 0.22` + vinheta + névoa pintada somam ~85% de pixels na mesma faixa de luminância; os discos de nó são **ovais pretos** com "?" cinza; só 2 acentos quentes; as estradas viram linhas retas cruzando a arte | §1 (regra de luminância), §4 (cor por tipo de nó, discos de pedra, ícones, névoa com forma) |

### 0.2 Avaliação do mapa pintado novo (`painted_map_screen.gd`, `map3d_preview passos=2`)

Nota 6/10: **é a melhor tela depois do combate** (rua gótica coerente, chuva, lampião, fogueira animada, rato e zumbi legíveis, chefe visível no topo), mas ainda reprova:

- **Acertos a manter:** fundo pintado contínuo; sombra de contato; luz âmbar nos destinos; fogueira como nó; chefe permanente no alto; 3 destinos.
- **Falhas:** (a) nós futuros são **ovais pretos + "?"** (parecem buracos); (b) estradas desenhadas por `draw_polyline` (laranja fino sobre cinza) cortam a pintura em "X" sem relação com o calçamento; (c) pílulas só texto ("Nv 3", "ouro", "equip. raro") sem ícone, 14 px, que cortam em `x≈535` quando o sprite é largo; (d) a Bibiana é a pintura **frontal** de 150 px, igual aos inimigos em tamanho: sem destaque; (e) lampiões/tumbas decorativos nas bordas (`_build_decor`) são soltos e mal ancorados; (f) HUD (barras + 7 slots de 44 px) colado ao topo sobre a arte; (g) emendas das 3 arenas repetem a imagem (`ARENAS[mini(i, 2)]`); (h) sem nenhum indicador de seleção/caminho (queixa 3); (i) chefe cortado pelo HUD.

### 0.3 Princípios (uma frase cada)

1. **A pintura é o herói; o motor só dá luz, névoa e movimento.** Sem 3D de kit em tela alguma do fluxo (mapa, combate, loja, fogueira, baú, recompensa, resultado).
2. **Uma luz quente por tela, sobre o sujeito.** O resto vive entre `#07080B` e `#4A5360`.
3. **Todo elemento interativo parece tocável** (borda bronze, tamanho ≥ 48, estado de pressão) e **todo elemento decorativo parece mundo** (sem borda, sem fundo chapado).
4. **Informação por ícone + número**, nunca por frase: o texto explica ao segundo toque.
5. **Cor tem significado fixo** (ouro = moeda/ganho, vermelho = perigo, âmbar = fogo/luz amiga, azul-aço = MP/gelo/neutro, veneno = veneno/doença, marfim = texto).
6. **Escala de pesadelo:** o inimigo é maior que o herói; a UI é menor que o palco.
7. **Nada cortado em linha reta**: o que sai da moldura some em névoa ou vinheta.

### 0.4 Regras técnicas de entrega (resolvem "recorte ruim" e "borrado")

1. **Todo sprite/ícone/UI nasce em 2x** (master) e é exibido a 1x lógico: ícone 96 px → exibido 48; sprite de inimigo comum 280 px de altura → exibido 140 (hoje: 224 px, borrado). Chefe master ≥ 520 px de altura.
2. **Recorte com alfa suave:** remover fundo `#10131A` por máscara de luminância + `erode 1 px` + `feather 0,8 px`, depois **decontaminar a borda** (substituir a cor dos pixels com alfa<1 pela cor do vizinho opaco). Nunca deixar halo escuro. Conferir sobre fundo claro `#D0D0D0` e sobre `#07080B` (se aparecer linha clara ou escura, refaça). Ferramenta: estender `tools/make_sprite.py` com `--decontaminate` e `--pad 8`.
3. Importação Godot: `Texture2D` com **mipmaps ligados** (`mipmaps/generate=true`), `texture_filter = LINEAR_WITH_MIPMAPS` para sprites/ilustrações; **`NEAREST` só para pixel-fonts (não usamos)**. Ícones: LINEAR.
4. Todo sprite com **pivô nos pés** e **8 px de margem transparente** em volta (nada encosta na borda do PNG).
5. Sombra de contato obrigatória sob todo sprite no chão: elipse preta alfa 0,55, largura 85% do sprite, altura 12%, desfoque 6 px (hoje é radial; trocar para elipse achatada).
6. Contorno de luz (rim): 2 px `#9FB4D0` só no lado do luar (esquerda-cima), alfa 0,7, **não** misturar brilho no corpo (o `brightness 1.28` do `RIM_SHADER` deve cair para 1.10 e o rim virar halo externo, para não borrar).
7. Resolução-alvo de tela: `Window` 540x960, `canvas_items` stretch, aspect `keep_height`, content scale **2.0** em dispositivos 1080x1920. Texto sempre vetorial.

### 0.5 As 10 regras inegociáveis (cada uma vem de um jogo-alvo; é o que ele ensina de concreto)

| # | Jogo | Regra inegociável para nós | Valores/medidas |
| --- | --- | --- | --- |
| R1 | **Sword of Convallaria** (nº 1) | Diorama artesanal com **pedra, madeira e ferro táteis**; luz quente direcionada sobre sombra fria; **UI em painéis de pedra/metal azul-ardósia com filete de metal, retrato grande do personagem em cartão recortado**; ícone de status pequeno colado ao sprite com mini-barra. Sprites pequenos mas arquitetura em volta densa | Painel: pedra `#15171C` + filete bronze 2 px; cartão de retrato 96x96 recortado (busto); barra mini 4 px sob sprite no mapa |
| R2 | **Tactics Ogre** | Seriedade medieval: proporções adultas, paleta mineral contida, **marcadores de posição/seleção em losango/anel de chão** e **linha de ordem de turno** nítida; texto de dado em tipografia serifada sóbria | Anel de seleção elíptico 1:0,42, 3 px; ordem de turno 4 retratos de 36 px |
| R3 | **Triangle Strategy** | **Contraste frio (ardósia) x tocha âmbar**; partículas em primeiro plano; **reticulado do caminho possível iluminado** e o resto apagado; setas/preview de resultado antes de confirmar | Caminho possível: dourado 3 px + brilho; resto a 45% de luz |
| R4 | **Octopath Traveler** | **Camadas de profundidade** (1º plano borrado/escuro, palco nítido, fundo em névoa) + **luz de volume** (feixes, bloom suave, tilt-shift) + sprites 2D de linha limpa sobre cenário em profundidade | 3 camadas obrigatórias em toda tela com cenário; feixe de luz com alfa 0,18 aditivo; blur 3 px no 1º plano |
| R5 | **Ragnarok Online** | **Verticalidade e escala arquitetônica** legíveis; o cenário "sobe"; marcadores de nome/nível flutuando sobre alvos sem cobrir a cabeça | Rótulo flutuante a 6 px acima da cabeça, nunca sobre o rosto; ≥ 2 elementos verticais por tela de cenário |
| R6 | **Buriedbornes** | **UI escura de pouquíssimo ruído**, ícones de ação grandes e fortes em molduras brancas/bronze finas, **cartões de nó com ícones de conteúdo (monstro + baú)** em vez de texto; fundo lateral gótico decorativo | Cartão de nó 72 px com 1-2 ícones de 28 px; máx. 1 linha de texto por elemento |
| R7 | **Bloodborne** (prioridade máxima) | **Ogiva, ferro forjado, paralelepípedo molhado, lampião solitário, neblina densa, luar frio**; silhuetas verticais; decadência (praga) em tudo; vermelho-sangue só como acento | Névoa `#0B0E14` a 70% nas distâncias; todo cenário com ≥ 1 ogiva e ≥ 1 agulha; vermelho só `#B82824` |
| R8 | **Dark Souls** | **Fogueira como único refúgio quente** (espiral de brasa); cantaria monumental enegrecida; **mensagem curta e seca** ("VOCÊ MORREU" grande, letras espaçadas, fade lento) | Fogueira = única tela com ≥ 20% de pixels quentes; título de morte Cinzel 40, tracking +8%, fade 1,2 s |
| R9 | **Fear & Hunger** | **Combate com a protagonista de costas**, inimigo enorme e central, fundo escuro com vinheta, menu em painéis simples embaixo, **luz fraca no chão** | Inimigo ≥ 55% da altura do palco; Bibiana 32-36%; vinheta 30% |
| R10 | **Octopath + Sword of Convallaria (animação)** | **Animação procedural contida**: respiração do idle (1-2 px), recuo de golpe, tremor curto, brasas; **nada de tween elástico "de app"**; hit-stop 60-100 ms | Idle: escala Y ±1,2% a 0,5 Hz; hit-stop 80 ms; shake 6 px/160 ms; ease-out cúbico |

### 0.6 O que cada jogo ensina de concreto (resumo operacional)

- **Paleta:** Bloodborne e Dark Souls = ardósia/carvão + 1 acento quente; Convallaria = mesma ideia com mais saturação nas luzes; Octopath = luz de volume; Buriedbornes = preto + ciano/laranja de acento (nós **não** usamos ciano).
- **Contraste/silhueta:** Buriedbornes e Fear & Hunger deixam o monstro **mais claro/saturado que o fundo** ou com contorno; Tactics Ogre usa halo de seleção. Nós: contorno de luz + inimigo mais claro que o chão (§1.3).
- **UI/tipografia:** Convallaria (serifa com filete metálico), Buriedbornes (monoespaçada pequena): nós usamos **Cinzel** (títulos, botões ≤ 3 palavras) e **Alegreya** (corpo).
- **Escala de sprite:** Triangle Strategy/Octopath = personagem 7-9% da altura da tela no mapa (≈ 70 px em 960); no combate F&H = 55-70% do palco.
- **Névoa:** Bloodborne/Octopath = névoa **com forma** (silhuetas de telhado/agulha atrás), nunca preto chapado.
- **Animação:** F&H e Dark Souls = parada, peso, pausa antes do golpe (telegraph de ≥ 400 ms); nada saltitante.

---

## 1. Paleta oficial e regras de contraste

### 1.1 Paleta (tokens; já existem em `DarkTheme`: usar os nomes)

| Token | Hex | Papel | Onde NÃO usar |
| --- | --- | --- | --- |
| `ABYSS` fundo | `#07080B` | vinheta, vãos, fundo de painel profundo, contorno de ícone | texto |
| `SLATE_DEAD` | `#1B2029` | sombra fria, chão fora da luz, fundo de slot | |
| `STONE_PANEL` pedra | `#15171C` | painéis, botões (já `DarkTheme.STONE`) | chão |
| `STONE_WET` | `#4A4E54` | lajes, muros no ponto mais claro permitido do chão | |
| `STONE_LIGHT` | `#23262E` | botão em foco/hover, cabeçalho de painel | |
| `BRONZE` | `#8A6A3A` | moldura de painel e botão (filete 2 px) | preenchimento grande |
| `BRONZE_DARK` | `#4A3A24` | sombra interna da moldura, divisores | |
| `GOLD` ouro | `#D9AA32` (UI de destaque `#E5B84A`) | moeda, ganho, foco/seleção, título | perigo |
| `AMBER_LAMP` âmbar | `#E08A30` | **a** luz quente: fogo, lampião, brasa, halo de nó disponível | texto corrido |
| `BLOOD` sangue | `#B82824` (escuro `#7E1C1A`) | perigo, intenção do inimigo, HP inimigo, derrota | recompensa |
| `VENOM` veneno | `#6E8F3F` (escuro `#3E5424`) | veneno, doença, HP da Bibiana (fundo escuro `#2F4A22`, topo `#4F7A3A`) | cenário |
| `STEEL_BLUE` azul-aço | `#5B7FA6` (escuro `#3B5C86`) | MP, gelo, buffs neutros, rim de luar `#9FB4D0` | |
| `IVORY` marfim | `#E8DFC8` | texto principal, números, sprite de osso | fundo |
| `IVORY_DIM` | `#A39B88` | texto secundário, desabilitado a 100% (ou IVORY a 45%) | |

Regras duras de cor:
1. **Zero verde vivo, rosa, lavanda, ciano.** `VENOM` é o único verde permitido e só em UI de veneno/HP.
2. Ouro e vermelho nunca aparecem juntos como ícone único (confunde ganho com perda).
3. Texto: `IVORY` sobre `STONE_PANEL` = contraste 12:1 (ok). `IVORY_DIM` só ≥ 16 px. **Nunca** texto sobre arte sem painel ou contorno de 3 px `#000000cc`.
4. Cada tela tem **no máximo 1 foco âmbar grande**; halos de nó (pequenos) podem repetir.

### 1.2 Faixas de luminância (resolvem "mapa cinza")

Medir no print com conta-gotas (luminância relativa Y, 0-1):

| Elemento | Y permitido |
| --- | --- |
| Vão/vinheta | 0,00-0,015 |
| Chão e fundo fora de luz | 0,02-0,06 |
| Chão **dentro** da luz quente (raio do nó) | 0,10-0,20 |
| Inimigo/herói (média do sprite) | **0,10-0,22**; nunca o objeto mais claro do quadro depois da luz |
| Halo âmbar no pico | 0,45-0,60 |
| Texto principal | ≥ 0,55 |
| Rim de luar | 0,35-0,45 (só 2 px) |

### 1.3 Regras de legibilidade do sujeito

1. **Sujeito ≥ +0,06 de Y acima do chão que o cerca** (ex.: chão 0,04, inimigo média ≥ 0,10). Se o sprite for escuro (cão de peste), subir a luz do halo âmbar atrás dele (raio = 0,8x altura) em vez de clarear o sprite.
2. **Contorno de luz** 2 px `#9FB4D0` no lado do luar + **halo traseiro** radial âmbar ou azul-aço alfa 0,35 atrás da silhueta (aditivo).
3. **Sombra de contato** (§0.4-5) sempre.
4. **Teste de silhueta:** pintar o sprite de `#07080B` sobre o fundo real: deve ser reconhecido; se fundir com o chão, mova a luz, não o sprite.
5. **Teste cinza:** converter o print para escala de cinza e reduzir a 1/4: o sujeito, o caminho possível e o botão primário devem continuar identificáveis. Se tudo vira uma mancha, a tela reprova.
6. Atenuação do fundo pintado: `dim` global **máx. 0,12** (hoje 0,22) + vinheta só nos 12% das bordas. O que escurece o mapa é a **névoa por distância** (§4.8), não um véu uniforme.

---

## 2. Tipografia e UI Kit (medidas para 540x960)

### 2.1 Tipografia

| Uso | Fonte | Tamanho (px) | Cor | Extra |
| --- | --- | --- | --- | --- |
| Título de tela (VITÓRIA, LOJA) | Cinzel 700 | 34 (máx. 1 linha; se > 16 caracteres, 28) | `GOLD` | tracking +4%, sombra 2 px preta, **alinhado ao centro só se for 1 linha** |
| Título de painel/seção | Cinzel 700 | 24 | `GOLD` | |
| Botão primário | Cinzel 700 | 20 (caixa-alta) | `IVORY` | ≤ 3 palavras |
| Botão secundário | Cinzel 600 | 17 | `IVORY` | |
| Corpo | Alegreya 500 | 18 (mínimo 16) | `IVORY` | entrelinha 1,3; **alinhado à esquerda**; largura útil ≥ 400 px |
| Legenda/dado | Alegreya 500 | 15 (mínimo 14) | `IVORY_DIM` | |
| Número de dano | Cinzel 800 | 44 (crítico 64) | branco `#FFF3D6`, contorno 4 px preto | |
| Número em barra | Alegreya 700 | 14 | `IVORY` + contorno 3 px | |
| Preço | Cinzel 700 | 20 | `GOLD` | ícone de moeda 24 px à esquerda |

Regras: (1) **proibido texto centralizado em coluna estreita** (< 320 px) com mais de 2 linhas: o que hoje está em `reward`/`result`/`shop`. Parágrafo = esquerda, em painel largo, ou vira lista com ícone. (2) Todo `Label` longo tem `autowrap_mode = WORD_SMART`. (3) Números alinhados à direita com `tabular` (Alegreya tem números lining; usar `font_features`). (4) Nunca mais de 3 tamanhos de fonte por tela.

### 2.2 Grade e zonas seguras

- Margem lateral **16 px**; margem superior segura **24 px** (barra do sistema); inferior segura **24 px**; espaçamento padrão 8/12/16 (múltiplos de 4).
- Alvo de toque mínimo **48x48**; recomendado 56 (secundário), 64 (primário); espaço mínimo entre alvos 8 px.
- Zona do polegar: y 620-936. Ações frequentes aí; informação no topo/centro.

### 2.3 Molduras de pedra/bronze (painel base `ui_panel_stone`)

Construção (StyleBoxTexture 9-slice, margem 24 px; ou `StyleBoxFlat` equivalente enquanto o asset não chega):
- Fundo: gradiente vertical `#1A1C23` → `#101116` + ruído de pedra 6% (textura `ui_noise_stone.png` 128x128 tileável).
- Borda externa 2 px `#000000`; filete bronze 2 px `BRONZE`; realce interno 1 px `#3A3326` no topo e esquerda; sombra interna 4 px `#00000066`.
- **Cantos chanfrados 6 px** (não arredondados "de app"); em painéis grandes, ornamento de canto (rebite de bronze 10 px nos 4 cantos).
- Painel de bottom sheet: topo com **alça** (barra bronze 48x4, y=8) e leve ogiva central (ornamento 64x12) opcional.
- Variantes: `panel_stone` (padrão), `panel_dark` (fundo `#0B0C10`, sem rebites, para tooltips), `panel_parchment` (pergaminho `#2A241A` com borda `BRONZE_DARK`, só recompensa/evento).

### 2.4 Botões (estados)

| Tipo | Tamanho | Normal | Foco/hover | Pressionado | Desabilitado | Sem recurso |
| --- | --- | --- | --- | --- | --- | --- |
| Primário (Atacar, Continuar, Nova Descida) | h 64, largura ≥ 200 | fundo `#23262E`→`#181A20`, borda bronze 2 px, ícone 40 + rótulo | borda `GOLD` 2 px, fundo +8% claro, brilho âmbar 6 px externo | escala 0,96 em 60 ms, fundo `#101116`, borda `BRONZE_DARK` | alfa 0,40, sem borda dourada | n/a |
| Secundário (Itens, Tático, Voltar) | h 56 | igual, ícone 28 | igual | igual | alfa 0,40 | |
| Cartão de ação (habilidade, item de loja) | h 64-108 (ver telas) | idem | borda ouro | idem | alfa 0,40 + cadeado | custo em `BLOOD`, ícone dessaturado, motivo em 1 linha de 14 px |
| Ícone-botão (som, fechar) | 48x48 | só ícone 28 sobre disco `#15171Ccc` com filete bronze | borda ouro | escala 0,92 | | |

Regras: ícone sempre à esquerda do rótulo (gap 12); rótulo nunca quebra linha em botão (se precisar, vira cartão); **há sempre um botão primário por tela** (o único com seta/brilho âmbar leve de "respiração" 0,3 Hz). Vibração 12 ms ao tocar (já existe).

### 2.5 Barras

| Barra | Altura | Moldura | Preenchimento | Texto |
| --- | --- | --- | --- | --- |
| HP inimigo (topo do combate) | 26 | 2 px bronze, fundo `#2A0F0F` | gradiente `#B82824`→`#7E1C1A`, brilho superior 1 px `#E5645F` | "72 / 72" 14 px centralizado |
| HP Bibiana | 26 | idem, fundo `#14210F` | `#4F7A3A`→`#2F4A22` | idem |
| MP | 26 (ou 18 se secundário) | idem | `#5B7FA6`→`#3B5C86` | idem |
| XP/Poder | 10 | filete 1 px | `GOLD` `#D9AA32`→`#8A6A22` | "Nv 1" 14 px acima à esquerda |
| Barra de rastro | | | segunda camada `IVORY` alfa 0,7 que desce 0,4 s depois do dano (`trail_bar.gd` já existe) | |
| Mini-barra de sprite (mapa/combate futuro) | 4 | sem moldura, sombra 1 px | idem cor | sem texto |

Marcas: tiques a cada 25% (linhas `#00000055`); em inimigo elite, tampas de bronze nas pontas.

### 2.6 Bottom sheet (gavetas de combate, loja detalhada, inventário)

- Folha **sobreposta** (nunca redimensiona o palco): altura 320 px (ou 60% em loja), ancorada embaixo, `panel_stone` com alça. Escurece o resto a **35%** (`#000000a6` → 0,35 alfa) e fecha por: toque fora, arrastar para baixo > 60 px, ou botão ✕ 48 px no canto.
- Anima: sobe 0,22 s `EASE_OUT` cúbico; desce 0,18 s.
- Conteúdo rolável; **rodapé fixo** com 1-2 botões (nunca rola).
- Última linha visível parcialmente com **fade de 24 px** (dica de rolagem), jamais cortada seca.

### 2.7 Tooltip (segundo toque / segurar 350 ms)

Cartão `panel_dark` ≤ 320 px de largura, ancorado ao elemento (acima, ou abaixo se faltar espaço), seta 10 px, margem 12; título Cinzel 17 `GOLD`, corpo Alegreya 15; linha de dado em `IVORY_DIM`; some ao soltar/tocar fora; nunca cobre o ícone que o originou.

### 2.8 Selos de intenção (inimigo)

Selo **56x56** (moldura hexagonal bronze, fundo `#15171C`), ícone 40 px, número do dano previsto embaixo **dentro** de um chip 24x16. Cor da borda por tipo: golpe = `BLOOD`; debuff/veneno = `VENOM`; defesa = `STEEL_BLUE`; golpe de moeda = `GOLD`; Golpe Mortal (chefe) = `BLOOD` + caveira + pulso 1 Hz. Posição: **a 6 px acima da cabeça do inimigo, deslocado 40 px para o lado oposto à Bibiana**; se cobrir o rosto do chefe, canto superior direito do palco (x=444, y=88). Aviso de golpe perigoso (um turno antes): borda pulsa a 1,6 Hz + som grave curto. Texto só no toque ("Golpe pesado: 18-22 dano").

### 2.9 Chips e pílulas

Chip de dado: altura 24, cantos 4 px chanfrados, fundo `#00000099`, borda 1 px da cor semântica, ícone 16 + número 14 px. Chip de preço: fundo `#2A220F`, borda `GOLD`. Chip de nível "Nv N": fundo `BLOOD` escuro, ícone de caveira 14.

### 2.10 Setas de comparação (loja/equipamento)

▲ (ganho) `#8FBF6A` **somente aqui** (único verde claro permitido, 14 px de triângulo); ▼ (perda) `BLOOD` claro `#D9534F`; = `IVORY_DIM`. Sempre com o número ("+5 FOR"). Nunca só cor (acessibilidade): a forma do triângulo carrega o sentido.

---

## 3. Iconografia completa

### 3.1 Estilo oficial dos ícones (substitui o pacote gnola14)

- **Pintura sombria, não pixel-art.** Master 192x192 (gerado em folha, recortado), **entregue 96x96, exibido 48x48** (nitidez 2x). Variante pequena 56x56 só se necessário (chips 24: exportar 48).
- **Moldura de ícone** (código, não pintada na imagem): disco/quadrado chanfrado de `SLATE_DEAD` com filete `BRONZE` 2 px; borda por raridade: comum `BRONZE_DARK`, incomum `STEEL_BLUE`, raro `GOLD`, maldito `BLOOD`. A imagem do ícone fica **sem moldura** e sem fundo (alfa).
- **Linguagem:** silhueta grossa e única (legível em 32 px), contorno `#07080B` de 3% da largura, grão de pincel, material gasto (metal escurecido, couro rachado, osso amarelado), **1 acento** `AMBER_LAMP` ou `GOLD` pequeno por ícone (exceto status, que usam a cor semântica). Luz fria de cima-esquerda + rim quente fino embaixo-direita. Vista 3/4 frontal.
- **Proibido:** brilho neon, rosa, roxo, verde vivo, gradiente plástico, estrela/sparkle decorativo, olho de desenho animado, chapéu de bruxa, coração de cartão.
- **Alvo de arquivo:** `assets/ui/icons/<categoria>/<id>.png` (96x96 RGBA). Categorias: `action/`, `skill/`, `status/`, `item/`, `node/`, `ui/`, `intent/`. `IconRegistry` passa a ler `assets/ui/icons/` (tabelas por id inalteradas; só o diretório e o sufixo mudam).

### 3.2 Ações de combate e UI geral (folha ICO-A)

| Arquivo | Ícone ideal (forma, cor, metáfora) |
| --- | --- |
| `action/attack.png` | **Espada longa em diagonal ↗ cortando**, lâmina aço escurecido, 3 riscos de corte vermelho-escuro atrás; sem faísca |
| `action/defend.png` | **Escudo redondo de madeira com aro de ferro**, visto de frente, rachadura, 1 rebite âmbar |
| `action/skills.png` (aba) | **Livro aberto com página rasgada e uma chama pequena âmbar** (grimório de guerra); não estrela |
| `action/items.png` (aba) | **Bolsa de couro com fivela**, uma garrafa saindo da boca |
| `action/tactical.png` (aba) | **Bússola/rosa dos ventos de ferro** (decisões) |
| `action/flee.png` | **Bota de couro correndo para fora de uma porta ogival entreaberta** (rastro de poeira atrás da bota). Metáfora: sair pela porta. **Não** é furacão, vento nem seta |
| `action/speed_1x.png` / `speed_2x.png` | Ampulheta de ferro com areia parada / com 2 chevrons `»` dourados à direita |
| `ui/gold.png` | Moeda de ouro **gasta e achatada**, efígie de coroa rachada, borda serrilhada |
| `ui/embers.png` | **Três brasas** incandescentes sobre cinza (âmbar), não chama de desenho |
| `ui/firewood.png` | **Feixe de galhos secos amarrado com corda** |
| `ui/luck.png` | **Moeda com trevo de quatro folhas gravado** em relevo, ouro velho (não trevo verde) |
| `ui/echoes.png` | **Sino pequeno rachado com ondas** em marfim (ecos = badalo) |
| `ui/power.png` | **Punho fechado em manopla** com 3 riscos ascendentes |
| `ui/hp.png` | **Gota de sangue** escura dentro de um frasco achatado (não coração) |
| `ui/mp.png` | **Gota azul-aço/cristal** de vidro (éter) |
| `ui/xp.png` | **Chama-guia** fina dourada sobre ponta de espada (opcional) |

### 3.3 Skills do Guerreiro (folha ICO-B)

| Arquivo (id) | Ícone ideal |
| --- | --- |
| `skill/shield_bash.png` | Escudo de lado batendo, 3 linhas de impacto, lasca voando |
| `skill/charge.png` | **Ombro e lança de investida**: silhueta curvada com lâmina à frente e poeira |
| `skill/bulwark.png` (Muralha) | **Muro de pedra/escudo-torre** de frente, sólido, com uma bandeira rasgada |
| `skill/whirlwind.png` (Golpe Giratório) | **Espada desenhando um arco circular** (traço de corte curvo em 270°, sem tornado) |
| `skill/war_cry.png` | **Boca aberta gritando em elmo** de perfil, 3 ondas de som |
| `skill/second_wind.png` | **Peito/pulmão com sopro** ou caneca de água e fôlego; **gota + seta circular** sutil |
| `skill/sharpen_blade.png` | Pedra de amolar sobre lâmina, 2 fagulhas âmbar |
| `skill/reinforce_shield.png` | Escudo com **tira de ferro nova** e martelo pequeno |
| `skill/sharpen_edge.png` | Adaga sendo afiada, fio com brilho (fogueira) |

### 3.4 Selos de intenção (folha ICO-B, linhas 3-4)

`intent/attack.png` (garra/lâmina descendente), `intent/heavy.png` (martelo/machado erguido, vermelho escuro), `intent/debuff.png` (gota de veneno sobre espiral fraca), `intent/defend.png` (escudo escuro), `intent/coin.png` (moeda dividida ao meio, ouro: golpe de moeda), `intent/deadly.png` (caveira coroada: Golpe Mortal), `intent/unknown.png` (olho fechado/interrogação gravada).

### 3.5 Status e doenças (folha ICO-C), cor semântica obrigatória

| Arquivo | Ícone | Cor |
| --- | --- | --- |
| `status/defending.png` | Escudo meia-lua | azul-aço |
| `status/bulwark.png` | Torre/muralha com chevron ↑ | azul-aço + ouro |
| `status/armor_down.png` | **Peitoral rachado em dois** | vermelho |
| `status/slowed.png` | Lesma/âncora ou **pé preso em corrente** | azul-aço frio |
| `status/poison.png` | Gota verde-musgo escorrendo de caveira pequena | veneno |
| `status/weakened.png` | Braço caído com seta ↓ | marfim + vermelho |
| `status/empowered.png` | Punho com chama âmbar | âmbar |
| `status/blinded.png` | Olho com venda/faixa preta | cinza + vermelho |
| `status/cursed.png` | Runa/marca torta num crânio, **fumaça escura** (sem roxo vivo: grafite `#3A3340` + vermelho) | grafite |
| `status/silenced.png` | Boca costurada | marfim |
| `status/disease.png` (+ `leptospirosis`) | Rato pequeno + gota de veneno | veneno |
| `status/bleeding.png` | Gota com corte | vermelho |

### 3.6 Tipos de nó do mapa (folha ICO-G, ver §4.5 para uso)

`node/start.png` (portão ogival), `node/battle.png` (**crânio de lado com espada cruzada**), `node/ambush.png` (olhos na sombra / garra saindo de fresta), `node/elite.png` (crânio com **chifre/coroa de ferro**, borda ouro), `node/chest.png` (baú de ferro fechado, fresta âmbar), `node/event.png` (**olho de pergaminho ou página com ponto de interrogação em âmbar**), `node/bonfire.png` (espada fincada em brasas), `node/shop.png` (balança de ossos), `node/mini_boss.png` (caveira grande de ferro, olhos vermelhos), `node/boss.png` (coroa de espinhos sobre caveira, vermelho), `node/fog.png` (nuvem de névoa com "?" gravado fraco), `node/visited.png` (marca de verificação riscada em pedra), `node/lock.png`, `node/danger.png`.

### 3.7 Itens e equipamento (folhas ICO-D, E, F) — 38 itens + 6 espaços vazios

Cada item: forma, material, acento. Arquivo `item/<id>.png`.

**Armas (D):** `sword_and_shield` (espada reta curta atrás de escudo redondo), `worn_longsword` (espada longa de lâmina com mossas, guarda simples), `bone_dagger` (adaga de osso amarelado, cabo enrolado em tira), `rusty_axe` (machadinha de cabo curto, fio enferrujado), `spiked_mace` (maça de cabeça redonda cravejada), `reaper_sickle` (foice curta de camponês, cabo torto), `bellringer_blade` (lâmina larga com **sino de bronze no pomo**), `executioner_axe` (machado largo de carrasco, lâmina em meia-lua, mancha escura), `blood_stiletto` (estilete fino negro com **filete âmbar-sangue**).

**Armaduras (E):** `old_chainmail` (cota de malha cinza em cabide), `dented_plate` (peitoral amassado), `leather_vest` (colete de couro rachado com cordões), `reinforced_mail` (malha com ombreiras de ferro), `warden_plate` (placa pesada com **chave de carcereiro** gravada), `soaked_cloak` (manto encharcado, gotas), `bone_cuirass` (couraça de costelas), `penitent_armor` (armadura enferrujada com **corda de penitente**).
**Cabeça/mão secundária (E):** `plague_hood` (**capuz de couro com bico de máscara de peste**, não chapéu de bruxa), `bellringer_helm` (elmo com forma de sino), `thorn_crown` (coroa de espinhos de ferro, 1 gota de sangue), `rotten_shield` (escudo de madeira podre com musgo seco), `traveler_lantern` (**lanterna de ferro com chama âmbar pequena**), `torn_prayer_book` (livro rasgado com cruz queimada).

**Relíquias (F):** `worn_charm` (amuleto de osso e fio), `iron_ring` (anel de ferro grosso sem gema), `sharp_claw` (garra curva marfim), `grave_bell` (sino pequeno de bronze verde-cinza), `giant_rat_tooth` (**dente**, não pinça de escorpião), `glass_eye` (olho de vidro com veia âmbar), `hanged_rope` (laço de corda), `penitent_medal` (medalhão de latão com cruz torta).
**Consumíveis (F):** `murky_potion` (**frasco largo de vidro turvo** com líquido verde-musgo escuro, rolha de cera), `dirty_ether` (frasco fino azul-aço turvo), `lucky_coin` (igual `ui/luck`), `firewood` (igual `ui/firewood`), `rotting_bread` (pão com mofo), `rancid_elixir` (frasco vermelho-vinho escuro), `sage_smoke` (maço de sálvia seca amarrado, fiapo de fumaça).

**Espaços vazios (D, linha final):** `slot_weapon`, `slot_armor`, `slot_head`, `slot_offhand`, `slot_relic`, `slot_consumable`: silhueta **gravada em baixo-relevo** `#2A2D33` sobre fundo transparente (sem cor).

### 3.8 Auditoria dos ícones atuais (arquivo → o que é → nota → troca)

Tudo é gnola14 34x34. **Nota geral 3/10**; ícone aprovado só se nota ≥ 7 e dentro de paleta. Troca = ícone novo da §3.2-3.7.

| Arquivo atual | Usado como | O que é | Nota | Troca sugerida |
| --- | --- | --- | --- | --- |
| `S_Wind01` | Fugir | tornado cinza-roxo | **1** | `action/flee` bota+porta |
| `S_Sword02` / `S_Buff02` | Atacar / Defender | espada azul-gelo com faíscas / silhueta laranja | 3 | `action/attack`, `action/defend` |
| `S_Buff01`,`S_Buff03`,`S_Buff05`,`S_Buff04` | Muralha, Reforçar, Grito, Poder | silhuetas de boneco coloridas (laranja/azul/verde) | 2 | `skill/*` próprios |
| `S_Sword01`,`S_Sword03`,`S_Sword05` | Golpe de Escudo, Investida, Afiar | espadas com chama/folha verde | 3 | `skill/*` |
| `S_Axe01` | Giratório | machado + haste | 4 | `skill/whirlwind` |
| `S_Holy01` | Segundo Fôlego | **coração rosa** | 1 | `skill/second_wind` |
| `S_Shadow01..12` | status e nós (armor_down, blinded, cursed, ambush, mini_boss, boss) | rodamoinhos roxos idênticos | 2 | `status/*`, `node/*` distintos |
| `S_Ice01`,`S_Poison01`,`S_Fire01` | slowed, poison, empowered | cristais/bolhas de cor viva | 3 | `status/*` |
| `P_Green01`,`P_Blue01`,`P_Red03`,`P_Yellow03` | poções | frascos de cartoon, líquidos neon | 3 | `item/*` |
| `C_Hat01`,`C_Hat02` | Capuz de Peste, Coroa de Espinhos | **chapéus de bruxo** roxo/preto | **1** | `plague_hood`, `thorn_crown` |
| `A_Armour02` (2 itens), `A_Armour01` | placas | armadura branca de brinquedo / marrom | 3 | `item/*` (ícone repetido em 2 itens: proibido) |
| `I_ScorpionClaw` | Dente de Rato | pinça laranja | 2 | `giant_rat_tooth` |
| `I_Bottle03` | Lanterna | garrafa branca | 1 | `traveler_lantern` |
| `I_Chest01`,`I_Key01`,`I_Scroll`,`S_Fire03` | nós baú, partida, evento, fogueira | laranja chapado | 4 | `node/*` |
| `I_GoldCoin`,`I_Clover`,`S_Fire05`,`E_Wood01` | UI | aceitáveis só como placeholder (moeda 5, trevo verde vivo 2, escudo de madeira para "galhos": **errado**) | 3 | `ui/*` |
| `I_Eye` | Ecos / Olho de Vidro | olho cartoon com cauda | 2 | `ui/echoes`, `item/glass_eye` |

Regra de implementação: ids duplicados entre itens (ex.: `penitent_armor` e `warden_plate` ambos `A_Armour02`) são **bug visual**; cada id tem arquivo próprio.

### 3.9 Prompts Gemini por LOTE de ícones

Gerar **uma folha por vez**. Se o Gemini não respeitar a grade 4x4, gere **tiras 4x1** (4 chamadas por folha) com o mesmo bloco. Depois fatiar em células de igualdade (`tools/slice_sheet.py` a criar, §13 tarefa 2) e remover fundo `#10131A` (§0.4). O prompt completo é **BLOCO-ICONE + LINHAS da folha** (§11 traz as linhas).

**BLOCO-ICONE (copiar inteiro):**

```text
Hand-painted dark-gothic RPG icon sheet, 4 columns by 4 rows, sixteen separate icons laid out on a perfectly even grid, each icon centred in its own square cell with a wide empty margin, flat solid background colour #10131A across the whole image, no cell borders, no grid lines, no labels. Every icon: bold simple readable silhouette that still reads at 32 pixels, thick near-black outline, visible painterly brush grain, weathered worn materials (darkened metal, cracked leather, yellowed bone, rough cloth), muted desaturated palette of charcoal, slate-blue, aged bronze and bone ivory, with ONE small warm amber (#E08A30) or old-gold (#D9AA32) accent per icon only. Soft cold moonlight from the upper left and a thin warm rim light at the lower right. Slight three-quarter front view, adult and serious tone, hand-crafted game-art finish. No text, no numbers, no letters, no frames, no cast shadows outside the icon, no sparkles.
Negative: text, letters, numbers, watermark, logo, frame, border, cute, chibi, cartoon, anime, neon, glossy plastic 3D, bright saturated colours, pink, purple, bright green, cyan, gradient background, drop shadow, multiple styles in one sheet.
```

---

## 4. Mapa

### 4.1 Composição (retrato 540x960, rolagem vertical)

Ordem de cima para baixo (valores em tela, com o herói em repouso):

| y (px) | Zona | Conteúdo |
| --- | --- | --- |
| 0-64 | HUD | Tira escura `#07080Bcc` 64 px: HP (200x18) + MP (120x18) + ouro com ícone 24; **slots de equipamento saem** daqui e vão para o botão "Mochila" (ícone-botão 48 px, canto direito, abre bottom sheet). Hoje 7 slots de 44 px poluem a arte |
| 64-300 | Futuro distante | chefe/torre em névoa, silhuetas (agulhas, telhados) em névoa 60-80% |
| 300-520 | Destinos | 3 destinos (camada +1) com sprites e discos de pedra; camada +2 em névoa 40% |
| 520-700 | Herói | Bibiana em **y 640 (pés)**, disco de pedra, anel pulsante |
| 700-900 | Passado | 1-2 camadas passadas escuras 55% (estradas percorridas marcadas) |
| 900-960 | Margem | respiro / primeiro plano escuro (grade de ferro, névoa baixa) |

Sempre visíveis: 1 camada passada, a atual, **2 futuras nítidas** (+1 dados completos, +2 só ícone de tipo e "?" aceso a 40%), a 3ª em névoa (silhueta sem tipo). Margem lateral segura **24 px** para sprites e pílulas.

### 4.2 Câmera (resolve "não foca, tudo cortado")

Estados:

| Estado | Regra | Detalhe |
| --- | --- | --- |
| Repouso | herói a **y=640** | `HERO_SCREEN_Y 670 → 640`, deixa 320 px acima para os destinos |
| **Selecionou destino** (1º toque) | **enquadrar herói e alvo juntos**: o ponto médio entre eles fica em y≈480 e o alvo nunca abaixo de y=330 nem acima de y=190 (para caber a cabeça do chefe: `top = alvo_y − altura_sprite ≥ 80`) | ex.: alvo a 150 px do herói → alvo em y≈400, herói em y≈550 (acima do bottom sheet que começa em 700). `_focus_on(node_id)` passa a receber `(hero_id, target_id)` |
| Zoom de foco | `_world.scale` 1,00 → **1,08** em 0,35 s, pivô no alvo; sprite do alvo 1,12x extra com "respiro" 0,6 Hz | nunca > 1,12 (borrar) |
| Dim dos outros | demais destinos, decoração e o fundo vão a **modulate 0,55** em 0,25 s; o alvo permanece 1,0 | foco de olhar |
| Caminhar | herói segue `road_points` 0,8 s; câmera acompanha mantendo herói em y 640; ao chegar, **névoa recua** (§4.8) | |
| Voltar/cancelar | câmera retorna a y=640 em 0,3 s, dim volta a 1,0 | |

### 4.3 Painel de prévia (substitui o mini-card atual)

**Bottom sheet** de 200 px (y 744-944, margens 16), `panel_stone`, **não cobre o herói nem o alvo** (por isso o enquadramento acima). Layout:
- Esquerda: **retrato-busto 96x96** do inimigo (recorte do sprite, moldura bronze, borda vermelha se elite, ouro se chefe), ou ícone de tipo 96 (baú/fogueira/evento).
- Direita: linha 1 nome Cinzel 22 `GOLD` + chip "Nv N"; linha 2 até 4 chips: **ameaça** (1-5 caveiras de 14 px), **HP estimado**, mutação, "emboscada"; linha 3 **recompensa provável** em ícones 28 px (moeda, relíquia, baú) com número.
- Rodapé: `Voltar` (secundário, 40% da largura) + **`Caminhar`** (primário 64 px, 60%).
- Tocar fora do painel/no herói = voltar.

### 4.4 Seta e caminho traçado (indicador visual até o nó)

Obrigatório ao selecionar:
1. **Trilha tracejada dourada** do herói ao alvo, seguindo a curva real (`road_points`): traço 3 px `GOLD` com sombra 2 px preta, dashes 14/10 px, **marcha animada** (offset +40 px/s rumo ao alvo). Substitui a linha lisa laranja.
2. **Chevrons ao longo da trilha** a cada 48 px (pequenos `›` 10 px, alfa 0,8) apontando no sentido da marcha.
3. **Seta pulsante sobre o alvo**: chevron duplo `⌄⌄` 28x28 `GOLD`, flutuando 8 px (senoide 1,2 Hz) **acima do rótulo, nunca sobre o rosto**; se o sprite for tão alto que a seta saia do quadro (< y 64), a seta vira indicador na borda superior com a distância.
4. **Anel no chão** do alvo: elipse 1:0,42, 3 px `GOLD`, raio 54 px, pulsando 0,8-1,0 (1 Hz), mais um segundo anel expandindo e sumindo.
5. **Estradas não escolhidas** apagam a 25%; estradas dos demais destinos continuam visíveis (finas, `STONE_WET` alfa 0,5) para manter a leitura da estrutura.
6. **Estrada visual:** trocar `draw_polyline` por **faixa de calçamento**: textura `road_cobble_tile.png` (128x64, tileável, 4 variações) desenhada ao longo da curva com bordas irregulares e sombra; as estradas **seguem a perspectiva** da arte (convergem para cima, largura 40 px perto, 26 px longe). Estrada ativa = pedras com **junta dourada** (brilho aditivo 0,35).

### 4.5 Nós, ícones e rótulos

Cada nó disponível = **disco de pedra** (`ui_node_disc`, 5 variações 192x96 px, elipse 1:0,42, borda desgastada, **não oval preto liso**) de 96 px (offered) / 72 px (outros) + **sprite** + **rótulo**.

- **Cor do disco/halo por tipo** (acaba com o cinza): luta = halo `BLOOD` alfa 0,45; elite = halo `BLOOD` + borda ouro; chefe/mini = halo vermelho 120 px pulsante 0,8 Hz; baú = halo `GOLD`; fogueira = `AMBER_LAMP`; evento = halo `STEEL_BLUE` frio; loja = `GOLD` pálido; emboscada = vermelho piscando 2x ao aparecer.
- **Rótulo** (substitui as pílulas só-texto): **chip único** de altura 28, ícone de tipo 20 + "Nv 3" 14 px; recompensa vira **ícone** 20 (moeda, relíquia, baú), não palavra. "equip. raro" = ícone de espada com borda dourada. Posição: centro acima do sprite, y_topo − 30, **clamp em [24, 516 − largura]**; se encostar, ancorar à esquerda e alinhar o texto à direita.
- **Toque:** alvo invisível de 96x96 centrado no disco+sprite (hoje depende do sprite).
- **Nó atual:** anel branco-marfim pulsante 0,5 Hz + disco com selo gravado. **Visitados:** apagados a 45% com `node/visited` pequeno. **Futuros +2:** ícone de tipo em 40% de opacidade + névoa. **Futuros ≥ +3:** `node/fog` sem tipo.
- **Chefe:** sempre visível, com luz vermelha no alto e ícone `node/boss` 40 px num selo de 72.

### 4.6 Escala dos sprites (px na tela; master 2x)

| Item | Altura | Largura máx. | Observação |
| --- | --- | --- | --- |
| Bibiana (costas, §5.2) | **150** | 130 | maior que inimigos comuns de **mesma** altura: destaque pelo anel e rim quente |
| Inimigo comum | 140 (cão, rato, corvo: largura até 170) | 170 | master 280 px |
| Elite | 176 | 200 | |
| Mini boss | 196 | 220 | |
| Chefe | 240 (cabeça nunca acima de y=84; se estourar, escalar) | 260 | |
| Props de nó | baú 84; fogueira 96 (animada); lápide 90 | | |
| Retrato-busto | 96x96 (recorte dos ombros para cima, a 2x = 192) | | |
- **Sem cortes:** todo sprite é limitado por **altura E largura** e por `top ≥ 84`; se o chefe estourar, o mapa **desloca o enquadramento** (4.2), não escala abaixo de 200.
- **Nada de miniatura 3D.** O mapa usa só sprites pintados + discos.

### 4.7 Fundo pintado em camadas (como gerar e montar)

Três camadas de fundo + primeiro plano + FX:

1. **Fundo contínuo (parallax 0,35x):** uma faixa vertical por segmento, **9:16 real** (1536x2752), mesma luz e paleta, **com topo e base que se encaixam** (a base da faixa N é igual ao topo da N+1: gere cada faixa com "continues seamlessly" e, para as emendas, **pegue os 15% inferiores da faixa N como imagem de referência** e peça ao Gemini para "continuar acima" via edição: `[envie o recorte] extend this scene upward`). Segmentos: `map_strip_01_rua` (avenida molhada de entrada, lampiões), `map_strip_02_praca` (praça com poço/forca, igreja ao fundo), `map_strip_03_escadaria` (escadaria e portão da torre do chefe, vitral vermelho), opcional `map_strip_04_catedral`.
2. **Palco (camada de jogo):** estradas e discos (§4.4-4.5).
3. **Primeiro plano (parallax 1,25x, desfocado 3 px, alfa 0,85):** `map_fg_ironfence` (grade de ferro e galhos, transparente, 540x240) nos cantos inferiores; névoa baixa em loop; chuva (`WeatherLayer`).
4. **Faixas de névoa pintada** entre segmentos (não só gradiente): `map_mist_band` (PNG com forma de névoa), 540x240, alfa animado ±0,1.
5. **Gerar faixas verticais:** 3-4 chamadas com o mesmo prompt-base (§11) trocando só a linha SCENE; manter semente de estilo repetindo o parágrafo de luz. Cortar a 1080x1920 e ajustar tom no Godot (`CanvasItemMaterial`/shader `hue/sat`) por segmento para dar identidade de cor: rua azul-ardósia, praça com âmbar de lampiões, escadaria com avermelhado do chefe. **Corrige "cinza"**: cada segmento tem tonalidade própria e **uma mancha quente**.

### 4.8 Névoa de guerra com forma

- **Passado:** `modulate #8A93A8 a 0,55`, sem névoa pintada, estrada percorrida com brasa dourada fraca.
- **Atual+1:** nítido. **+2:** `0,6` de luz, ícone de tipo a 40%. **+3 e mais:** mancha de névoa `map_mist_band` com **silhueta** do que está atrás (agulha, telhado) a 70% de opacidade.
- **Revelação ao chegar:** a névoa do novo nó dissolve em 0,8 s (alfa 0,7→0) com **brilho único âmbar** no disco (flash 0,2 s) e som de sino curto.
- Bloqueado: nunca preto chapado: `#0B0E14` com ruído e alfa máx. 0,8.

### 4.9 Ordem e cobertura de props

`_build_decor` atual solta postes e lápides nas bordas. Substituir por **cenografia ancorada**: lampião só encostado a muro/arco **da própria pintura** (já tem lampiões pintados); props de sprite só nos nós. Limite: no máx. 2 props decorativos por tela, sempre com sombra de contato e halo (lampião: raio 90 px âmbar).

---

## 5. Combate

### 5.1 Palco e zonas (refinar o layout já aprovado de CRITICA-DIRETOR (d))

| y (px) | Zona | Conteúdo |
| --- | --- | --- |
| 0-64 | Cabeçalho | nome + "Nv N" (Cinzel 20), HP inimigo 26 px, ícones de status 28 px à direita |
| 64-640 | Palco 576 | arena pintada; ordem de turnos (4 retratos 36 px, horizontal **sob** a barra, à esquerda); selo de intenção; números de dano; luz no chão |
| 640-684 | Faixa de previsão | `panel_dark` 44: "Atacar  14-17 · 87% · crít 5% · +2 MP", números `GOLD` |
| 684-722 | Barras Bibiana | HP 26 + MP 26 lado a lado |
| 730-810 | Ações | **Atacar** (60%) e **Defender** (40%), 80 px, ícone 40 |
| 818-874 | Abas | Habilidades, Itens, Tático (56 px, ícone 28 + rótulo) |
| 874-960 | Margem | respiro; bottom sheets sobem sobre esta zona |

Regras: palco **nunca** muda de tamanho; a **faixa "ATAQUE Ataque"** some (a intenção é o selo); texto de narrativa ("Cão de Peste prepara: Ataque") vai para uma linha de 15 px `IVORY_DIM` na base do palco com fundo `#00000088`, 1 linha.

### 5.2 Bibiana de costas (resolve estética Fear & Hunger)

- **Substitui a pintura frontal em todo o jogo** (uma só Bibiana, mesma armadura): mapa, combate, fogueira, baú, home. De 3/4 só em retratos de painel.
- **Poses (todas de costas, fundo `#10131A`, 2x, prompt na §11):** `bibiana_back_idle`, `_attack`, `_defend`, `_hurt`, `_defeat`, `_walk` (4 frames), `_sit_fire` (de costas sentada olhando o fogo), `_item` (levanta frasco), `_victory`.
- **Enquadramento:** centro em x≈180 de 540, pés em y≈600 do palco, altura **190 px** (33% do palco), pés sempre visíveis (nunca cortados pela borda). Inclinada 10-15° à esquerda mostrando a lâmina e a borda do escudo.
- **Entrada:** caminha de fora do quadro (de baixo) até a marca em 0,8 s; poeira de 6 partículas; câmera "respira" +3%.
- **Animação procedural:** idle respiração escala Y ±1,2% 0,5 Hz + balanço da capa (rotação ±1,5° 0,4 Hz); ataque: avanço 36 px em 0,12 s + recuo 0,25 s + hit-stop 80 ms no impacto; defender: escudo sobe (troca de frame) e escala 1,03; dano: recuo 14 px + flash branco 80 ms + tremor 6 px/160 ms; derrota: frame `defeat`, dessatura 100% em 1 s.

### 5.3 Inimigos

- Sprites atuais (HD-2D de 3/4 virado à esquerda) servem; reentregar a **2x** (§0.4). Altura no palco: **comum ≥ 55%** do palco (≥ 320 px), elite 62%, chefe 70% (≥ 400 px) **com a cabeça ≥ 56 px abaixo do topo do palco**; largura ≤ 88% do palco (limite por altura E largura, como pede a crítica).
- Sombra de contato (§0.4-5) e **piso a 6 px abaixo dos pés**; sprite **pairando é proibido**.
- Respiração idle: escala Y ±1% 0,35 Hz; **telegraph** (golpe perigoso): inimigo recua 10 px e fica 1,15x mais claro em 0,4 s (brilho âmbar-vermelho na silhueta) antes do ataque; ataque: avança 60 px em 0,14 s sobre a Bibiana; golpe de moeda: halo dourado atrás.
- Morte: dissolução por **mancha de cinza** (shader dissolve 0,8 s) + queda de 8 px; sem explosão.

### 5.4 Selo de intenção, previsão e números

Selo conforme §2.8. Previsão no toque (1º toque seleciona e mostra o chip no inimigo; 2º confirma). **Número de dano:** surge a 40 px acima do ponto de impacto, sobe 36 px em 0,7 s com ease-out e some nos últimos 0,2 s; branco para dano normal, **`GOLD` + escala 1,4 e contorno vermelho para crítico**, **`VENOM`** para veneno, `STEEL_BLUE` para bloqueio ("0" cinza), "ERROU" `IVORY_DIM` 22 px. Cura: `VENOM` claro `#8FBF6A` com "+".

### 5.5 Efeitos (partículas e frames)

| Efeito | Arte | Duração | Detalhe |
| --- | --- | --- | --- |
| Hit/corte | `fx_slash_sheet` 6 frames 256x256 (arco branco-marfim com borda âmbar) | 0,18 s | rotação alinhada ao ataque; hit-stop 80 ms |
| Impacto de escudo | `fx_block_sheet` 5 frames (faíscas âmbar) | 0,15 s | 8 fagulhas |
| Crítico | shake 10 px/220 ms + flash `#FFF3D6` alfa 0,35 em 60 ms + `fx_crit_burst` raios dourados | 0,3 s | |
| Moeda | ver §6 | | |
| Veneno | bolhas `VENOM` sobem do alvo (8 partículas, 1 s), tinta verde-musgo alfa 0,15 sobre a silhueta | por turno | |
| Sangramento | 6 gotas `BLOOD` caem (0,6 s) | | |
| Cura | 10 partículas âmbar subindo, aura 0,4 s | | |
| Chuva | `WeatherLayer`: 120 gotas, ângulo 12°, alfa 0,35 | contínuo | primeiro plano maior (blur 3 px) |

### 5.6 Menus, gavetas e estados

- **Habilidades (bottom sheet 320 px):** lista de 1 coluna, cartão h 64: ícone 40 | nome 17 | custo MP `STEEL_BLUE` à direita | previsão `GOLD` em 14 px abaixo ("dano 22-26 · 87%"). Máx. 4 visíveis + rolagem. Estados: normal, foco (borda ouro), **sem MP** (alfa 0,5, custo `BLOOD`, cadeado 16), **recarga/turno** (cinza + motivo).
- **Itens:** grade 3 colunas, célula 88x88: ícone 56 + quantidade `x2` num chip no canto; estoque 0 = alfa 0,4.
- **Tático:** linha de 2 botões 56 px: **Fugir** (ícone bota+porta, mostra a chance de fuga num chip) e **Velocidade 1x/2x** (alternância com ícone de ampulheta, estado persistente).
- **Não é o turno do jogador:** Atacar/Defender a alfa 0,40 com **arco de carga** (cronômetro circular fino 3 px `GOLD`) no ícone, em vez de cinza morto.
- **Confirmação** apenas para ações custosas (Fugir se HP > 50%, item raro).
- **Estados globais:** Vitória (fade para recompensa 0,6 s com palco escurecendo a 40%), Derrota (§7.4).

---

## 6. Tela de moeda (cara ou coroa, GDD §7)

Acontece **no palco**, sem trocar de cena:

1. **Preparo (0,4 s):** vinheta fecha de 30% para 55%; música cai a 20%; **silêncio** de 150 ms; palco escurece a 45% (`#000000`).
2. **Medalhão central:** `coin_heads`/`coin_tails` (512 px master, exibido 176 px) em y≈300 do palco; luz âmbar de baixo (halo 220 px alfa 0,5); sombra no chão.
3. **Giro (0,9 s):** 8 frames de rotação 3D falsa (escala X cos θ) + subida de 60 px e queda; som de metal; **tique** em cada passagem por face.
4. **Revelação (0,5 s):** a face final cresce a 1,15 e para; a face vencedora pulsa dourada ("Cara!" / "Coroa!" Cinzel 36, sob a moeda); a perdedora **racha** (linha dourada). Efeito do resultado (golpe de moeda do inimigo, bônus) aparece em um chip de 40 px sob a moeda com o ícone do efeito.
5. **Escolha do jogador:** botões **Cara** e **Coroa**, lado a lado, **96 px de altura**, cada um com mini-moeda 48, nome e **a chance** em chip (GDD §7, sem trapaça: aparece 50%, com Moeda Viciada mostrar o %). Cores: Cara = ouro quente; Coroa = marfim-prata frio.
6. **Aparência das moedas:** **Cara** = redonda, borda **serrilhada**, relevo de **rosto de penitente velado de perfil**, ouro amarelado `#D9AA32`; **Coroa** = redonda de borda **lisa e mais larga**, relevo de **coroa de espinhos**, ouro frio-prata `#B9B4A0`. Diferença **por forma e símbolo** (não só cor).
7. **Moeda da Sorte/Viciada:** moeda com **borda âmbar fina** e um **trevo gravado**; ao ser usada, 1 raio dourado liga o inventário à moeda.
8. Timeout do giro pulável com toque (acessibilidade); modo 2x reduz a 0,45 s.

---

## 7. Recompensa, level up, vitória, derrota, resultado

### 7.1 Tela de recompensa / level up: "o Relicário" (substitui o diorama 3D)

Fundo: **o cenário da luta, pintado e escurecido a 60%** (reaproveitar a arena do combate) com **feixe de luz** vindo de cima (aditivo, alfa 0,2) e brasas subindo. **Nenhum 3D, nenhuma moeda ou poção flutuando.**

Composição (540x960):

| y | Elemento |
| --- | --- |
| 40-120 | **Faixa-título** (ribbon `ui_banner` 460x72, bronze envelhecido): "SUBIU DE NÍVEL" (ou "VITÓRIA") Cinzel 34 `GOLD`; ao lado esquerdo selo `ui/power` |
| 130-420 | **Quadro do herói:** medalhão circular 200 px com **busto da Bibiana** (recorte do sprite) em moldura bronze com 4 rebites; à direita, **"Nv 0 → 1"** Cinzel 44 (0 em `IVORY_DIM`, 1 em `GOLD`), abaixo **barra de XP/Poder 10 px** que **enche com animação 0,8 s** e **faísca dourada** ao estourar |
| 440-640 | **Ledger de ganhos** (`panel_parchment`, 508x200): 3-4 linhas, cada uma h 44: ícone 40 | rótulo | `antigo → novo` (antigo `IVORY_DIM`, novo `GOLD` + ▲ 14 px). Ex.: `poder 1,00 → 1,40 ▲`; `HP 130 → 135 ▲`; `ouro +9 (total 9)` |
| 650-790 | **Fileira de butim:** até 4 **slots 88x88** (`ui_slot_frame`, borda por raridade) com ícone 64 e quantidade; entram em cascata (delay 120 ms, subida 12 px, "tilintar"); vazios não aparecem |
| 810-880 | Linha de crônica 15 px `IVORY_DIM`: "Cidadão Infectado (nv 1) tombou. Inimigos derrotados: 1." (1 linha, esquerda) |
| 880-944 | **Continuar** (primário 64 px, largura total 508) |

Animações: contagem de ouro (rolagem 0,6 s com "tique"), brilho de moldura ao subir nível (halo `GOLD` 1 s), som de sino grave. Pular: toque em qualquer ponto antes do botão acelera tudo.
Level up com nova habilidade: **cartão de escolha** (3 cartões 156x220 com ilustração-ícone grande 96, nome, custo; padrão de "escolha uma recompensa" de cartas, em `panel_parchment`), nunca texto corrido.

### 7.2 Vitória (fim da Descida/chefe)

Fundo: arena de chefe escurecida + **luz do amanhecer fria** (azul pálido no topo, 15%). Título "VITÓRIA" Cinzel 44 com **tracking +8%** e subtítulo "O chefe caiu" 20 px. **Bibiana de costas**, espada baixa (`bibiana_back_victory`), pés em y≈520, altura 220.
Ledger "Registro da Descida" em duas colunas (`panel_stone` 508x230): coluna ícone+rótulo (Camadas, Nível, Poder, Ouro, Nós, Inimigos, Chefes) × valor à direita `GOLD` 20 px; **Ecos ganhos** em linha de destaque com `ui/echoes` 40 e "+10" Cinzel 30. Texto "Nenhuma Descida se perde" vira **chip** de 14 px.
Botões **fixos no rodapé**, empilhados com 8 px: **Outra Descida** (primário 64), **Santuário** e **Início** (secundários 56, lado a lado). **Nada pode ficar cortado:** o ledger rola, os botões não (resolve "Início cortado").

### 7.3 Derrota

Fundo: arena do combate **dessaturada 70% + vinheta vermelha** `#7E1C1A` nos 20% das bordas. Título "VOCÊ CAIU" Cinzel 40, `BLOOD`, tracking +8%, **fade-in lento 1,2 s** com 1 s de silêncio antes. Sprite `bibiana_back_defeat` ajoelhada, 200 px, no chão, luz âmbar mínima (lampião caído). Ledger resumido (nível, nós, inimigos, **Ecos que ficam**) e botão primário **Voltar ao Santuário**; secundário **Nova Descida**. Sem confete, sem som alegre: sino único e vento.

### 7.4 Resultado (resumo)

Mesma estrutura de 7.2/7.3; **uma só tela** com variante por estado. Painel com `max-height 62%` + `ScrollContainer`, rodapé fixo. Linha "Semente 7" vai para um chip pequeno no canto (14 px), não para o corpo.

---

## 8. Loja (alcova do mercador)

**Fundo:** `arena_loja.jpg` já existente em tela cheia (a alcova com lampião é a imagem certa), escurecida a 15% apenas fora do halo; **mercador = sprite `shop_keeper.png`** (recorte a 2x) atrás da mesa, 260 px de altura, base alinhada ao tampo (pé oculto pela mesa, sombra sobre a mesa), levemente "respirando"; luz do lampião balançando ±3%. **Bibiana de costas** (`_idle`) no canto inferior esquerdo, 150 px, **inteira** (não cortada pelo painel). Nenhum modelo 3D.

**Layout (y):**

| y | Elemento |
| --- | --- |
| 0-64 | Faixa: "LOJA" (Cinzel 28, esquerda) + chip de ouro (ícone 28, valor 20 `GOLD`) + chip "Mochila 3/8" (ícone bolsa) à direita |
| 64-420 | Alcova (arte visível; mercador fala em balão de 1 linha 15 px: "Pague e vá embora.") |
| 430-880 | **Bottom sheet fixo** `panel_stone` 508x450: grade 2 colunas rolável |
| 888-944 | Rodapé fixo: **Atualizar (ícone + 15 ouro)** secundário 56 / **Seguir** primário 56 |

**Cartão de item** (228x112; 2 por linha, gap 12):
- Slot de ícone 64x64 à esquerda (moldura por raridade; ícone 48).
- Linha 1: nome Alegreya 17 `IVORY`, **1 linha** com reticências.
- Linha 2: chip de tipo (Arma, Armadura...) 12 px + **atributo-chave com comparação**: `FOR +5 ▲`, `PRE +4 ▲`, `DEF −2 ▼` (14 px, setas §2.10). Máx. 2 atributos; o resto no tooltip.
- Linha 3 (direita embaixo): **chip de preço** (ícone moeda 20 + "150" 18 `GOLD`).
- Estados: **comprável** (borda bronze), **sem ouro** (cartão 60%, preço em `BLOOD`, cadeado 14 no canto; **sem a frase "ouro insuficiente"**), **selecionado** (borda `GOLD`, glow), **equipado** (selo "EQUIPADO" 11 px marfim no canto), **vendido** (carimbo `BLOOD` diagonal 40% "VENDIDO" no cartão, desabilitado), **maldito** (borda `BLOOD`, ícone com aura).
- Toque 1: seleciona e abre **tooltip/folha de detalhe**: ícone 96, descrição curta, tabela de comparação com o equipado (`atual → novo` com ▲▼), botão **Comprar** (64 px, "Comprar · 150") e, para equipamento, **"Equipar e vender o antigo"**. Toque 2 = confirma só no botão.
- **Última linha da grade nunca cortada seco:** fade de 24 px + scrollbar fina visível.

Mercador: **sprite**, nada de bonecos 3D. Preço em ouro destacado. Música: laúde baixo, sino de balança ao comprar (som `coin_drop` + `scale_ding`).

---

## 9. Fogueira, baú, evento, Home/Santuário, classe

### 9.1 Fogueira (acesa e apagada)

- **Apagada:** fundo `arena_fogueira_apagada` (nova) com poço de pedra e **brasa mínima visível** (3 pontos âmbar 8 px pulsando 0,3 Hz, Y de pico 0,08), cinza, **fumaça fina**; Bibiana de costas de pé; texto "A fogueira está apagada" vira linha única; ação **Acender (gasta 1 Galho Seco · ícone `ui/firewood` x1)** como botão primário.
- **Acesa:** fundo `arena_fogueira_acesa` (já existe, excelente) + **chama animada** (`fx_flame_sheet` 8 frames 256x256, 10 fps, aditiva) sobre o poço + **OmniLight 2D** (`PointLight2D` raio 380 px, cor `#E08A30`, energia 1,2, cintilação ±12% a 6 Hz) + brasas (24 partículas subindo 80 px) + sombras longas dinâmicas. **Bibiana de costas sentada** (`bibiana_back_sit_fire`, 200 px) à esquerda do fogo, rosto/lateral iluminados.
- **Painel:** bottom sheet **≤ 38% (360 px)**, `panel_stone`; título "FOGUEIRA" 28 + chips HP/MP/Brasas (ícones 24); **cartões de ação 3 colunas** 156x150: ícone 56 grande, nome 17 (1 linha), custo em chips (ícone brasa x1), estado desabilitado com motivo. Ações: **Descansar** (ícone bola de fogo+lua), **Afiar o Fio**, **Tratar doença**, **Trocar habilidades** (livro), **Seguir** (primário 64 no rodapé fixo).
- **Estado inicial do preview** deve ser **acesa** (primeira impressão).

### 9.2 Baú

Cenário: arena da rua ao fundo, escurecida; **sprite `iron_chest` 200 px** no centro; ao tocar: tampa abre (3 frames), **luz dourada sai de dentro** (`PointLight2D` `#D9AA32` + raios aditivos), **16 moedas pequenas (24 px)** jorram em arco e somem (não 3 moedas gigantes). "+114" Cinzel 44 `GOLD` sobe do baú; multiplicador: badge `×2` 56 px sobre a tampa. Painel: **Usar Moeda da Sorte (n)** (ícone `ui/luck`) e **Anúncio opcional** como cartões 64 px, **Seguir** primário. Bibiana de costas ao lado (150 px).

### 9.3 Evento (cartas/ilustração)

Estrutura: **ilustração em cartão** 508x290 (`event_<id>.jpg`, moldura `ui_frame_illustration` de bronze com cantos góticos), título Cinzel 26 `GOLD` sobre faixa; descrição em `panel_parchment` 3-5 linhas **alinhada à esquerda** (Alegreya 18); **opções** como cartões empilhados 64-72 px, ícone 40 à esquerda + texto 1-2 linhas + **chips de consequência** (ex.: `−10 HP`, `+20 ouro`, `Veneno`) em cor semântica; sem opção "óbvia" colorida (neutro). Cada evento do JSON tem ilustração própria: `weeping_bell`, `plague_wagon`, `blind_herald`, `fountain_of_ash`, `gallows_tree`, `abandoned_armory`. **Bug:** `tela=event` mostra o texto de vitória (verificar `game_preview.gd`).

### 9.4 Home / Santuário

- **Home:** `arena_home_santuario` em tela cheia, **Bibiana de costas** (`idle`) em y≈520 de altura 260 diante da escadaria, lampiões do cenário com halo; **título "BIBIANA'S QUEST"** Cinzel 44 (texto do motor, com **gradiente ouro `#E5B84A→#8A6A22` e sombra de relevo**, tracking +6%, y=120) e subtítulo "A Cidade Abandonada" 18. Botões (rodapé, margem 16): **Nova Descida** (primário 72 px, ícone espada), linha secundária **Santuário** (56) + **Classe** (56) lado a lado, **Continuar Descida** (se existir save) primário acima. Ecos/Descidas como chips na faixa superior. **Sem painel centralizado de texto**.
- **Santuário** (`sanctuary_interior` 9:16, cômodo de catedral em ruína com **três estações iluminadas**): **Biblioteca** (estante e livro, esquerda), **Arsenal** (bancada e armas, direita), **Códice** (púlpito com livro aberto, centro-fundo). Cada estação = **hotspot de toque 140x140** com halo âmbar pulsando e rótulo-chip (ícone 24 + nome); toque abre **bottom sheet** com a lista (cartões como na loja, com ícone, custo em Ecos `ui/echoes`, estado desbloqueado/bloqueado/comprável). Chip de Ecos fixo no topo.
- **Códice:** grade 4 colunas de **cartões de inimigo** (retrato-busto 96 em moldura; não descoberto = silhueta `#2A2D33` + "?"), toque abre ficha em sheet (retrato, fraquezas ícone, golpe perigoso).

### 9.5 Seleção de classe

4 cartões **carrossel horizontal** 232x400 (snap) sobre a arena da Home escurecida: **corpo inteiro do sprite** (Guerreiro disponível; demais **silhueta `#14161B` com cadeado** e "Em breve"), nome Cinzel 24, 3 barras de atributo (HP, FOR, DEF 8 px) e a passiva em 1 linha com ícone. Botão **Escolher** (primário 64) só no cartão ativo. Sem texto longo.

---

## 10. Transições, partículas, animação e áudio de interface

### 10.1 Transições

| De → para | Efeito | Duração |
| --- | --- | --- |
| Qualquer tela | **Fade por névoa**: faixa de névoa `map_mist_band` cruza a tela (esquerda→direita) e escurece a `#07080B` | 0,35 s + 0,35 s |
| Mapa → combate | Câmera dá zoom 1,08 no inimigo, vinheta fecha, **corte seco** para a arena, entrada da Bibiana | 0,5 s |
| Combate → recompensa | Palco escurece a 40%, feixe de luz desce, painel sobe | 0,6 s |
| Bottom sheet | sobe/desce (§2.6) | 0,22/0,18 s |
| Nó revelado | §4.8 | 0,8 s |
Proibido: elástico/bounce, slide lateral estilo app, fade-branco.

### 10.2 Partículas (todas 2D, `GPUParticles2D`/`CPUParticles2D`)

Chuva (120), brasas (24, fogueira), poeira de passo (6), fagulhas de impacto (8), bolhas de veneno (8), gotas de sangue (6), cinza flutuante (20, alfa 0,2, mapa), vaga-lumes âmbar fracos (4, só fogueira). **Orçamento:** ≤ 250 partículas simultâneas; desligáveis em `GfxSettings`.

### 10.3 Animação procedural (sem spritesheet pesada)

Respiração (escala Y), balanço de capa (rotação ±1,5°), pulso de halo (alfa senoide), marcha de dash, chevron flutuante, shake de câmera (decai exponencial), hit-stop (`Engine.time_scale` 0,05 por 80 ms ou pausa de `_process`), dissolve de morte (shader `noise threshold`).

### 10.4 Áudio de interface (sugestões; CC0 + `SoundFx`)

`ui_tap` (pedra batendo madeira, 40 ms), `ui_confirm` (sino curto grave), `ui_back` (couro), `ui_error` (ferro surdo), `ui_sheet_open/close` (corrente curta), `node_reveal` (sino + vento), `step_stone` (loop de passo), `coin_flip` (metal girando) + `coin_tick`, `coin_land_heads` (tilintar claro) / `coin_land_tails` (batida grave), `level_up` (sino + coral curtíssimo), `gold_count` (tique repetido), `shop_buy` (moedas + balança), `fire_loop` (fogueira), `defeat_bell` (sino único + vento), `intent_warning` (grave de 200 ms). Música: **ambiente** por tela (mapa: vento e sino distante; combate: tambor baixo e drone; fogueira: lareira e violoncelo solo), sempre abaixo de -18 LUFS, silêncio na moeda.

---

## 11. LISTA DE ASSETS A PRODUZIR (com prompt Gemini)

**Como usar os prompts.** Prompt final = **BLOCO** + linha da tabela. **Sem nomes de jogos, personagens ou artistas; sem mecha colorida; sem texto na imagem.** Gerar em `2752x1536` (sprites/ícones) ou `1536x2752` (9:16); o que for menor, ampliar com IA a 2x. Salvar em `docs/design/refs/<tipo>/` (original) e processar para `assets/...` pelo recorte da §0.4. Prioridade: **P0** = bloqueia a queixa do Orlando; **P1** = completa o jogo; **P2** = acabamento.

**Blocos:**

**BLOCO-ICONE:** ver §3.9 (cole inteiro) e acrescente "Row 1: ... Row 4: ..." com as linhas abaixo.

**BLOCO-SPRITE-COSTAS (Bibiana):**
```text
Painterly dark-gothic HD game character sprite, full body, seen from directly behind with a slight three-quarter turn to the left, single figure only, centred, filling 85% of the image height with clean margin all round, flat solid background colour #10131A, no ground, no shadow, no fog, no frame, no text. A young woman warrior in dark worn steel plate armour: scratched, soot-stained pauldrons, vambraces and cuirass back-plate, rust at the edges, faded dark-wine leather straps. A tattered deep-wine cloak from the shoulders to the knees, torn at the hem. Dark brown hair tied in a short low knot, no colour streaks, natural hair only. Right hand holds a plain battered longsword; left arm carries a round wooden shield with iron rim seen edge-on. Adult proportions, serious readable silhouette, never cute or chibi. Cold blue-grey moonlight from the upper left with a thin warm amber rim light on the right. Dense hand-painted texture on metal and cloth.
Negative: multiple figures, turnaround sheet, two views, front view, scenery, floor, cast shadow, fog, vignette, gradient background, border, text, watermark, chibi, cute, cartoon, anime, neon, glossy 3D plastic, bright saturated colours, coloured hair streak, cropped feet, cropped weapon.
```
(linha de pose = acrescentar uma frase)

**BLOCO-CENARIO-9x16:** usar o bloco de arena de `docs/design/PROMPTS-LOTE-HD2D.md` §16 (estágio vazio, 3 camadas, gótico, paleta ardósia) + a linha SCENE abaixo. Negative: `characters, people, monsters, silhouettes of people, UI, HUD, bars, buttons, text, numbers, watermark, logo, bright daylight, cheerful green trees, vibrant saturated colours, cartoon, anime, smooth sterile 3D CGI, grid overlay`.

**BLOCO-UI-TEXTURA:**
```text
Hand-painted dark-gothic game interface texture, flat orthographic view, no perspective, weathered carved stone and aged oxidised bronze with fine rivets, subtle moss-dead grime in the crevices, colours limited to near-black charcoal (#15171C), slate, aged bronze (#8A6A3A) and bone ivory, no glow, perfectly symmetrical where asked, plain solid #10131A outside the object, no text, no letters, no numbers, no logo.
Negative: text, letters, numbers, watermark, logo, cartoon, plastic, glossy, neon, bright colours, perspective, shadow outside the object.
```

**BLOCO-FX-SHEET:**
```text
Sprite-sheet of N frames in one horizontal row, equal square cells, flat solid background #10131A, hand-painted dark-gothic game visual effect, no characters, no text, no frame, the effect centred in each cell with margin, consistent scale across frames.
Negative: characters, text, watermark, background scenery, cartoon, neon.
```

### 11.1 Tabela mestra de assets

Tamanhos = master gerado → entrega. "LINHA" = frase a colar depois do BLOCO.

| id (arquivo alvo) | Descrição | Tamanho (master→entrega) | Onde é usado | Prio | Prompt (LINHA após o BLOCO) |
| --- | --- | --- | --- | --- | --- |
| `ico_a_actions` → `assets/ui/icons/action,ui/*` | folha 4x4: atacar, defender, habilidades, itens, tático, fugir, vel. 1x, vel. 2x, ouro, brasas, galhos, trevo, ecos, poder, HP gota, MP gota | 2752x1536 → 16x 96 | menu combate, HUD, tudo | **P0** | `Row 1: a longsword raised diagonally with three dark red slash marks behind it; a round wooden shield with iron rim and one amber rivet; an open tattered spellbook with a tiny amber flame; a leather satchel with a bottle poking out. Row 2: an iron compass rose; a worn leather boot running out of a half-open pointed-arch door with dust trailing behind; an iron hourglass with still sand; an iron hourglass with two golden chevrons. Row 3: a worn flat gold coin with a cracked crown relief; three glowing amber embers on grey ash; a tied bundle of dry twigs with rope; a coin with an engraved four-leaf clover in old gold. Row 4: a small cracked bronze bell with sound waves; a gauntleted clenched fist with three rising lines; a dark blood drop inside a flat glass vial; a blue-steel crystal teardrop of glass.` |
| `ico_b_skills_intent` | folha: 9 skills + 7 selos de intenção | → 16x 96 | gaveta de habilidades, selo de intenção | **P0** | `Row 1: a shield striking sideways with three impact lines and a flying chip; a hunched shoulder and forward-pointing lance blade with dust; a solid stone shield-tower seen from the front with a torn flag; a sword drawing a curved 270-degree slash arc (no tornado). Row 2: an open mouth shouting inside a helmet in profile with three sound waves; lungs or chest with a breath and a drop and a faint circular arrow; a whetstone over a blade with two amber sparks; a shield with a fresh iron strap and a small hammer. Row 3: a dagger being sharpened with a gleam on the edge; a downward claw slash; a raised heavy axe, dark red; a poison drop over a weak spiral. Row 4: a dark shield; a coin split in half, gold; a crowned skull; a closed eye with an engraved question mark.` |
| `ico_c_status` | 12 status/doenças | → 12x 96 | barras de status, selo | **P0** | `Row 1: a half-moon shield in steel blue; a stone tower with an upward chevron in gold; a breastplate cracked in two, red; a foot chained and slowed, cold steel blue. Row 2: a drop of dark moss-green poison dripping from a tiny skull; a drooping arm with a downward arrow, ivory and red; a fist with an amber flame; an eye covered by a black blindfold. Row 3: a skull with a crooked rune and dark graphite smoke (no purple); a stitched shut mouth; a small rat with a moss-green drop; a drop with a cut, dark red. Row 4: leave the four cells empty.` |
| `ico_d_weapons_slots` | 9 armas + 6 slots vazios | → 15x 96 | loja, equipamento | **P0** | `Row 1: a short straight sword in front of a round wooden shield; a worn longsword with dents and a plain guard; a yellowed bone dagger with a wrapped hilt; a short rusty hatchet. Row 2: a round-headed studded mace; a short crooked peasant sickle; a broad blade with a small bronze bell on the pommel; a wide half-moon executioner axe with a dark stain. Row 3: a thin black stiletto with a blood-amber edge line; then five grey carved bas-relief empty slot silhouettes: weapon, armour, helmet, off-hand, relic, drawn as engraved shapes of colour #2A2D33 on transparent-looking plain background. Row 4: one empty slot silhouette of a consumable bottle, and three empty cells.` |
| `ico_e_armor_head` | 8 armaduras + 6 cabeça/mão | → 14x 96 | loja, equipamento | **P0** | `Row 1: a grey chainmail shirt on a hook; a dented breastplate; a cracked leather vest with laces; chainmail with iron shoulder plates. Row 2: a heavy plate with an engraved jailer key; a soaked heavy cloak with dripping drops; a cuirass made of ribs; rusty armour with a penitent rope. Row 3: a leather hood with a long beak plague-doctor mask (not a witch hat); a helmet shaped like a bell; a crown of iron thorns with one blood drop; a rotten wooden shield with dried moss. Row 4: an iron lantern with a small amber flame; a torn prayer book with a burnt cross; two empty cells.` |
| `ico_f_relics_consum` | 8 relíquias + 7 consumíveis | → 15x 96 | loja, inventário | **P0** | `Row 1: a bone and thread amulet; a thick plain iron ring without a gem; a curved ivory claw; a small green-grey bronze bell. Row 2: a single large rat incisor tooth; a glass eye with an amber vein; a hangman noose of rope; a brass medallion with a crooked cross. Row 3: a wide cloudy glass flask with moss-green liquid and a wax stopper; a thin cloudy steel-blue flask; a coin with a clover engraving; a tied bundle of dry twigs. Row 4: a mouldy loaf of bread; a dark wine-red flask; a bundle of dried sage with a wisp of smoke; one empty cell.` |
| `ico_g_nodes` | 14 ícones de nó | → 14x 96 | mapa, prévia, chips | **P0** | `Row 1: a pointed-arch gate; a skull in profile with crossed swords; glowing eyes in a dark crack with a claw; a skull with an iron horn-crown and gold rim. Row 2: a closed iron chest with an amber slit; a parchment eye with an amber question mark; a sword planted in embers; a balance made of bone. Row 3: a large iron skull with red eyes; a thorn crown over a skull, red; a cloud of fog with a faint question mark; a stone-carved check mark. Row 4: a padlock; a skull-warning triangle in dark red; two empty cells.` |
| `coin_heads` / `coin_tails` | duas faces da moeda grande | 1024x1024 cada → 512 | tela de moeda | **P0** | `A single large old-gold coin seen straight on, ONE coin only, flat background #10131A, hand-painted worn metal. HEADS: round serrated edge, embossed relief of a veiled penitent in profile, warm yellow gold (#D9AA32). / TAILS: round smooth wide edge, embossed crown of iron thorns, cold silver-gold (#B9B4A0). No text, no letters.` |
| `bibiana_back_idle` | de costas, guarda | 2752x1536 → 480 px alt. | combate, mapa, home | **P0** | BLOCO-SPRITE-COSTAS + `Knees slightly bent, weight forward, guarded stance, sword low and slightly forward.` |
| `bibiana_back_attack` | investida e golpe | idem | combate | **P0** | `Sword raised overhead mid-swing, body twisting, cloak flaring.` |
| `bibiana_back_defend` | escudo à frente | idem | combate | **P0** | `Shield raised in front, seen from behind her shoulder, sword tucked back, braced.` |
| `bibiana_back_hurt` | recuo | idem | combate | **P0** | `Recoiling backwards from a blow, shoulders hunched, one foot sliding back.` |
| `bibiana_back_walk` (4 frames em linha) | caminhada | 4 quadros → 4x 360 alt. | mapa | **P0** | BLOCO-SPRITE-COSTAS + `A horizontal row of four frames of a walk cycle away from the camera, mid-stride, cloak swaying, same scale, even spacing.` (sem "single figure") |
| `bibiana_back_sit_fire` | sentada olhando o fogo | idem | fogueira | **P0** | `Sitting cross-legged on the ground seen from behind, head slightly lowered, sword laid beside her, weight relaxed, warm light on her left side.` |
| `bibiana_back_defeat` | ajoelhada | idem | derrota | **P0** | `Kneeling on one knee, head lowered, sword planted in the ground, shield dropped beside her.` |
| `bibiana_back_victory` | espada baixa | idem | vitória | P1 | `Standing upright, sword lowered point-down in the right hand, shoulders relaxed, head slightly raised.` |
| `bibiana_back_item` | levanta frasco | idem | combate | P1 | `Raising a small glass flask to her lips with the left hand, sword in the right hand lowered.` |
| `map_strip_01_rua` | avenida molhada de entrada com lampiões | 1536x2752 → 1080x1920 | mapa (fundo) | **P0** | BLOCO-CENARIO-9x16 + `SCENE: a wide rain-slicked cobblestone avenue entering a plague-abandoned gothic city at night, seen from a high three-quarter isometric angle looking up the street, narrow gothic townhouses on both sides, three solitary wrought-iron lamps casting warm amber pools on the cobblestones, a low iron fence at the bottom corners, distant cathedral spires in fog at the top edge, the bottom edge fades into dark wet stone and the top edge fades into slate fog so another image can continue above it. Dominant colours slate-blue with a few amber pools.` |
| `map_strip_02_praca` | praça com poço/forca, igreja ao fundo | idem | mapa | **P0** | BLOCO-CENARIO-9x16 + `SCENE: a ruined town square at night: a dry stone well, a wooden gallows with a hanging lantern at the right, wrecked market stalls, a gothic church facade with a dark rose window at the top, broken fountain edges, cold blue moonlight with a warm amber lantern glow in the centre; same high three-quarter angle as the avenue; the top and bottom edges blend into fog for continuation. Dominant colours slate-blue with warm umber accents.` |
| `map_strip_03_escadaria` | escadaria e portão da torre do chefe | idem | mapa | **P0** | BLOCO-CENARIO-9x16 + `SCENE: a long worn stone staircase climbing to a huge iron-bound gothic gate beneath a tall bell tower; a faint deep-red glow leaks from the tower's stained window high above; broken statues and iron fences on the sides; fog gathers on the stairs; bottom edge continues the square, top edge ends in black cloud. Dominant colours charcoal and slate with dark red only at the tower.` |
| `map_fg_ironfence` | primeiro plano: grade de ferro e galhos (transparente) | 1536x640 → 1080x440 | mapa (parallax 1º plano) | P1 | `Foreground silhouette only: twisted wrought-iron fence spikes and bare dead branches along the bottom edge, near-black #07080B, solid #10131A above, hand-painted. No text.` |
| `map_mist_band` | faixa de névoa pintada | 1536x512 → 1080x360 | mapa, transições | P1 | `A horizontal band of dense cold fog with soft torn edges and faint silhouettes of roof tips and spires inside it, colours #0B0E14 to #3A4252, solid #10131A beyond the band edges, painterly.` |
| `road_cobble_tile` | calçamento tileável para estradas | 1024x512 → 256x128 x4 | mapa (estrada) | P1 | BLOCO-UI-TEXTURA + `Top-down tileable irregular wet cobblestones in dark slate with thin gold-dust seams, seamless edges.` |
| `ui_node_disc` (5 var.) | disco de pedra para nó | 1536x768 → 192x96 | mapa | **P0** | BLOCO-UI-TEXTURA + `A flat worn round stone slab viewed from a high angle (a flattened ellipse 2:1), chipped edge, cracks, tiny moss-dead grime, five different slabs in one row on the plain background, no characters.` |
| `ui_panel_stone` | painel 9-slice com cantos e rebites | 1024x1024 → 96x96 | todos os painéis | **P0** | BLOCO-UI-TEXTURA + `A square panel frame in carved dark stone with a thin aged bronze inner line and a bronze rivet in each corner, empty dark stone centre, perfectly symmetrical, chamfered not rounded corners.` |
| `ui_slot_frame` (4 raridades) | moldura quadrada de slot | 1024x256 → 4x 96 | loja, butim, mochila | **P0** | BLOCO-UI-TEXTURA + `Four square item slot frames in a row, chamfered corners, dark stone centre; frame colours from left to right: dark bronze, steel blue, old gold, dark blood red; centres empty.` |
| `ui_banner_ribbon` | faixa-título de recompensa | 1536x384 → 480x120 | recompensa, vitória | **P0** | BLOCO-UI-TEXTURA + `A horizontal banner of weathered bronze with swallow-tail ends, riveted edges and a darker stone centre, empty, symmetrical.` |
| `ui_frame_illustration` | moldura de ilustração de evento | 1536x1024 → 508x340 | evento | P1 | BLOCO-UI-TEXTURA + `A wide landscape picture frame in carved dark stone and bronze with small pointed gothic arches at the top corners, empty dark centre, symmetrical.` |
| `ui_divider` / `ui_noise_stone` | divisor ornamental e ruído de pedra tileável | 1024x128 / 512x512 | painéis | P2 | BLOCO-UI-TEXTURA + `A thin horizontal ornamental divider of bronze with a central pointed-arch motif and two spikes, symmetrical. / Seamless dark stone noise texture, tileable, very low contrast.` |
| `arena_fogueira_apagada` | fogueira apagada (poço frio, brasa mínima) | 1536x2752 | fogueira | **P0** | BLOCO-CENARIO-9x16 + `SCENE: the same ruined gothic chapel courtyard as a campfire refuge but the fire pit is cold: a ring of stones filled with grey ash and a few black logs with three tiny amber embers barely glowing, thin smoke rising, pale blue moonlight through arches, no flame, no warm light elsewhere.` |
| `arena_cidade_chefe` | arena do chefe (cemitério e capela) | 1536x2752 | combate chefe, vitória | P1 | usar o prompt nº 18 de `PROMPTS-LOTE-HD2D.md` |
| `bg_reward_shrine` | nicho de relicário iluminado por feixe de luz | 1536x2752 | recompensa/level up | **P0** | BLOCO-CENARIO-9x16 + `SCENE: an empty dark stone reliquary chapel seen straight on: a pointed-arch niche in the centre third with a narrow shaft of pale moonlight falling from the top onto an empty carved stone altar, floating dust and a few embers, flanking pillars and iron candle-stands with three small amber flames, deep shadow elsewhere.` |
| `bg_defeat` | cenário da derrota (rua vazia, lampião caído) | 1536x2752 | derrota | **P0** | BLOCO-CENARIO-9x16 + `SCENE: an empty rain-slicked gothic street at night, one iron lantern fallen on the cobblestones with a nearly dead amber flame, thin red-tinted fog at the edges, desaturated, oppressive, heavy arches above, no characters.` |
| `sanctuary_interior` | Santuário com 3 estações (biblioteca, arsenal, códice) | 1536x2752 | Santuário | P1 | BLOCO-CENARIO-9x16 + `SCENE: a ruined cathedral side-hall used as a hideout, seen straight on: left a tall shelf of old books with a candle, right a workbench with a racked sword and a whetstone and an oil lamp, centre back a stone lectern with a huge open book lit by a lantern, three separate warm amber pools of light each isolated in the dark, pointed arches above.` |
| `event_weeping_bell` … `event_abandoned_armory` (6) | ilustração por evento (sino rachado, carroça do boticário, arauto cego, fonte de cinza, forca da encruzilhada, forja fria) | 1536x1024 → 1016x580 | evento | P1 | `Painterly dark-gothic scene illustration, landscape, dramatic chiaroscuro, muted slate palette with one amber light, no characters in the foreground, no text: ` + (uma frase por evento: "a fallen bronze bell on wet cobblestones still resonating", "an overturned apothecary cart with broken flasks and a locked iron strongbox beside dead rats", "an old man with sewn-shut eyes holding a bone balance in an alley", "a fountain flowing over salt stones in a plaza, ash on the water", "a dry oak gallows with three ropes at a crossroads", "a burnt guard post with a pedal grindstone and strips of tanned leather on a workbench") |
| `fx_flame_sheet` | chama de fogueira 8 quadros | 2048x256 → 8x 256 | fogueira, mapa | **P0** | BLOCO-FX-SHEET + `N=8: a campfire flame loop, warm orange and yellow core, dark red edges, with a few rising sparks, from small to tall and back, centred at the bottom of each cell, additive-ready on a dark background.` |
| `fx_slash_sheet` | corte (6 quadros) | 1536x256 | combate | **P0** | BLOCO-FX-SHEET + `N=6: a curved sword slash arc in bone-ivory with an amber edge, growing and fading frame by frame.` |
| `fx_coin_flip_sheet` | giro da moeda (8 quadros) | 2048x256 | moeda | **P0** | BLOCO-FX-SHEET + `N=8: an old gold coin rotating around its vertical axis, from face-on through edge-on to the back face, constant size, warm light from below.` |
| `fx_block_sheet` / `fx_crit_burst` / `fx_poison_sheet` | faíscas de bloqueio, explosão crítica, nuvem de veneno | 1280x256 / 256x256 / 1536x256 | combate | P1 | BLOCO-FX-SHEET + `N=5 amber sparks hitting a shield / one burst of golden rays / N=6 rising moss-green poison bubbles and thin smoke.` |
| `enemy_bust_<id>` (17) | busto 96x96 (192) de cada inimigo | gerado por recorte (script) | prévia, ordem de turnos, códice | **P0** | **sem Gemini:** `tools/make_sprite.py --bust` recorta ombros-cabeça do sprite existente (caixa 0..38% da altura) |
| `*_2x` (reentrega dos 17 sprites de inimigos, shop_keeper, props) | os sprites atuais em 2x, com recorte sem halo | 2752x1536 já existe (usar o master original com `--height` dobrado e `--decontaminate`) | todo o jogo | **P0** | **sem Gemini:** rodar `tools/make_sprite.py` com alturas dobradas (ex.: comum 280, elite 350, chefe 520) nos jpgs de `docs/design/refs/` |
| `campfire_lit` / `campfire_cold` (props pequenos) | prop de fogueira para o mapa | 1536x1024 → 192x128 | mapa (nó fogueira) | P1 | `A small stone-ringed fire pit with a ring of rounded stones and charred logs; one lit with a flame, one cold with grey ash; two separate props side by side, flat #10131A, hand-painted, no scenery.` |

Sprites já prontos e **a manter** (reprocessar a 2x): `bibiana_warrior` (apenas retratos de painel/códice), 14 inimigos do cenário 1, `shop_keeper`, `grave_scavenger`, `iron_chest`, `plague_lamppost`, `gothic_tombstone`, `gallows_post`, arenas rua/praça/fogueira acesa/loja/home.

### 11.2 Contagem

- **P0:** `ico_a`, `ico_b`, `ico_c`, `ico_d`, `ico_e`, `ico_f`, `ico_g` (7), `coin_heads/tails` (1), Bibiana de costas idle/attack/defend/hurt/walk/sit_fire/defeat (7), `map_strip_01/02/03` (3), `ui_node_disc`, `ui_panel_stone`, `ui_slot_frame`, `ui_banner_ribbon` (4), `arena_fogueira_apagada`, `bg_reward_shrine`, `bg_defeat` (3), `fx_flame`, `fx_slash`, `fx_coin_flip` (3), `enemy_bust_*` (script), reentrega 2x (script) = **30 itens P0**: 28 gerados no Gemini (7 folhas de ícones + 1 moeda + 7 poses + 3 faixas de mapa + 4 texturas de UI + 3 cenários + 3 folhas de FX; as folhas de ícones rendem ~100 ícones) e 2 por script (bustos e reentrega 2x).
- **P1:** `bibiana_back_victory/item`, `map_fg_ironfence`, `map_mist_band`, `road_cobble_tile`, `ui_frame_illustration`, `arena_cidade_chefe`, `sanctuary_interior`, `event_*` (6), `fx_block/crit/poison`, `campfire_lit/cold`.
- **P2:** `ui_divider`, `ui_noise_stone`, retratos de classes bloqueadas, variações de arena.

---

## 12. Checklist de aceite por tela ("teste do print") e anti-padrões

Cada tarefa visual anexa **um print 540x960 do jogo rodando** em `docs/tasks/prints/` e responde passa/falha. Reprova com 1 falha de itens marcados **(R)**.

### 12.1 Checklist universal (toda tela)

1. **(R)** Existe **pintura** como cenário (não 3D de kit, não losango, não fundo chapado).
2. **(R)** Uma única fonte quente dominante e ela ilumina o **sujeito**.
3. **(R) Teste cinza:** em escala de cinza 1/4, sujeito, caminho possível e botão primário se distinguem.
4. **(R)** Nenhum asset cortado em linha reta pela moldura; nada passa de `x∈[16,524]` sem névoa/vinheta.
5. **(R)** Todo ícone vem de `assets/ui/icons/` (pintado); nenhum ícone do pacote gnola14; nenhum ícone repetido para ids diferentes.
6. **(R)** Alvos de toque ≥ 48x48; 1 botão primário; rodapé de ações **fixo e inteiro**.
7. Texto: ≥ 16 px (corpo), ≤ 3 tamanhos, **sem parágrafo centralizado em coluna estreita**, sem texto sobre arte sem painel/contorno.
8. Sprites com sombra de contato, sem halo de recorte (conferir sobre `#D0D0D0`), nítidos a 2x.
9. Paleta: nenhum pixel de verde vivo, rosa, lavanda, ciano fora de UI de veneno/▲.
10. Profundidade em 3 camadas (1º plano escuro/borrado, palco, fundo em névoa) e ≥ 1 elemento vertical gótico.
11. Bibiana **de costas** (exceto retratos).
12. Zero mecha colorida; zero nome de jogo/artista em prompts; zero texto dentro de imagem.

### 12.2 Por tela (adicional)

| Tela | Passa se... |
| --- | --- |
| Mapa | herói visível e enquadrado com o alvo ao selecionar; **trilha tracejada + seta + anel** presentes; ≥ 3 destinos com **cor de halo por tipo**; rótulos com ícone dentro da margem; chefe visível sem cortar; HUD ≤ 64 px; discos de pedra (não ovais pretos); névoa com silhueta |
| Combate | inimigo ≥ 55% do palco, cabeça ≥ 56 px abaixo do topo; palco 576 px fixo; selo de intenção 56 px sem cobrir o rosto; **sem faixa "ATAQUE Ataque"**; gaveta como folha sobreposta |
| Moeda | vinheta fechada, moeda ≥ 176 px, Cara e Coroa diferentes por forma, botões 96 px com chance |
| Recompensa/level up | quadro pintado + faixa-título + medalhão com busto + ledger com ícones e `antigo → novo`; **0 objetos 3D**; Continuar visível sem rolagem |
| Vitória/derrota | herói de costas; título Cinzel espaçado; ledger em 2 colunas; botões fixos inteiros |
| Loja | arena_loja + sprite do mercador; cartões com ícone 48, 1 linha de nome, preço dourado, ▲▼; sem frase "ouro insuficiente"; grade com fade de rolagem, rodapé fixo |
| Fogueira | acesa por padrão com chama animada e luz; Bibiana sentada de costas; painel ≤ 38%; cartões com ícone 56 |
| Baú | baú de ferro com luz interna; ≤ 16 moedas pequenas; badge ×2 |
| Evento | ilustração própria em moldura; opções com chips de consequência |
| Home | cenário pintado + Bibiana de costas + título com gradiente; botão primário 72 px; sem painel de texto no meio |

### 12.3 Anti-padrões proibidos (reprovação imediata)

1. **3D solto sobre losango** (moeda, poção, Bibiana 3D flutuando num piso vazio).
2. Ícone **genérico** ou de pacote de pixel colorido; **ícone de metáfora errada** (furacão para Fugir; coração rosa para cura; chapéu de bruxo para capuz).
3. **Cinza uniforme**: tela inteira na mesma faixa de luminância; só 1 acento minúsculo.
4. **Texto centralizado em coluna estreita**; parágrafo de status em vez de lista com ícones.
5. **Ovais pretos** como nó; **linha reta laranja** cortando a pintura como estrada.
6. Botão ou cartão **cortado** pela borda ou pelo rodapé (Início, Seguir, "Galhos Secos" pela metade).
7. Sprite **flutuando** sem sombra; halo de fundo no recorte; sprite borrado (1x ampliado).
8. Painel que **encolhe o palco** ao abrir.
9. Bibiana de frente em combate; duas versões da heroína no jogo.
10. Pílula só-texto como informação principal; "?" cinza chapado.
11. Verde vivo, rosa, lavanda, cor "de brinquedo"; mecha colorida.
12. Moedas gigantes, objetos em escala de desenho animado.
13. Seleção sem indicador (herói fora de quadro, sem trilha, sem seta).
14. Fogueira apagada ilegível como primeira impressão; tela de evento mostrando texto de outra tela.

---

## 13. Ordem de implementação recomendada (tarefas pequenas, 1 commit cada)

Cada tarefa abre `docs/tasks/TASK-NNN-*.md` (regra 1 do `CLAUDE.md`), tem print anexo e atualiza o HANDOFF. Dependências entre colchetes. **Código só consome assets que já existem**; enquanto o Gemini não entrega, usar o placeholder indicado.

| # | Tarefa | Escopo | Depende de assets | Placeholder |
| --- | --- | --- | --- | --- |
| 1 | **Câmera de seleção + trilha + seta + anel no mapa** (queixa 3) | `painted_map_screen.gd`: `_focus_on(hero, target)` (§4.2), dim dos outros, `PathOverlay` tracejado animado, chevrons, anel, painel de prévia como bottom sheet de 200 px; HERO_SCREEN_Y 640; clamp de pílulas; `top ≥ 84` do chefe | nenhum | busto = sprite recortado por código |
| 2 | **Ferramentas de asset:** `make_sprite.py --decontaminate --pad --bust`, `tools/slice_sheet.py` (folhas 4x4), reprocessar sprites a 2x; mipmaps no import (queixas 1 e 6) | tools + `.import` | nenhum | — |
| 3 | **Tokens e UI kit em código** (`DarkTheme`): cores §1.1, botões/estados §2.4, barras §2.5, chip, tooltip, bottom sheet reutilizável `BottomSheet` | `dark_theme.gd`, nova cena de componente | nenhum | `StyleBoxFlat` até chegar `ui_panel_stone` |
| 4 | **Ícones novos** (queixa 4): trocar `IconRegistry` para `assets/ui/icons/`, corrigir ids duplicados, gerar folhas A, B, C, G | `icon_registry.gd`, teste de cobertura | **ICO-A, B, C, G** | gnola14 só onde faltar, com marca de TODO |
| 5 | **Ícones de itens** (loja/equipamento): folhas D, E, F | idem | **ICO-D, E, F** | idem |
| 6 | **Mapa: nós** — discos de pedra, halos por tipo, chips com ícone, névoa com silhueta, estrada em calçamento, HUD 64 px + botão Mochila (queixas 6 e 7) | `painted_map_screen.gd` | `ui_node_disc`, `ico_g`, `map_mist_band` (P1) | discos desenhados por código |
| 7 | **Mapa: fundo em 3 faixas + parallax + primeiro plano** | `_build_backdrop` | `map_strip_01..03` | arenas atuais |
| 8 | **Bibiana de costas** em combate/mapa/fogueira/home (substitui a frontal) | `model_registry.gd`, `combat3d_stage.gd`/palco 2D | `bibiana_back_*` | frontal espelhada |
| 9 | **Combate: layout fixo**, selo de intenção 56 px, previsão, gaveta sobreposta, estados, números de dano, sombra de contato | `combat_screen.gd` | ícones B/A; fx_slash | — |
| 10 | **Moeda** (§6): sequência e botões 96 px | `combat_screen.gd` ou cena própria | `coin_*`, `fx_coin_flip` | disco dourado desenhado |
| 11 | **Recompensa/level up** em quadro pintado (queixa 2): faixa, medalhão, ledger, butim | `run_panel_screen.gd`/nova tela | `ui_banner`, `ui_slot_frame`, `bg_reward_shrine`, busto | painel `StyleBoxFlat` |
| 12 | **Vitória, derrota e resultado** com rodapé fixo (§7.2-7.4) | `run_panel_screen.gd` | `bg_defeat`, `bibiana_back_defeat/victory` | — |
| 13 | **Loja** em alcova pintada (queixa 5) (§8) | `run_panel_screen.gd` | `arena_loja` (já), ícones D/E/F, `ui_slot_frame` | — |
| 14 | **Fogueira, baú, evento** (§9.1-9.3) | `run_panel_screen.gd` | `arena_fogueira_apagada`, `fx_flame`, `event_*` (P1) | arte existente |
| 15 | **Home, Santuário, classe** (§9.4-9.5) | `sanctuary_screen.gd`, `main.gd` | `sanctuary_interior` (P1) | arena_home |
| 16 | **Transições, partículas, áudio de UI** (§10) | `fx/*`, `SoundFx` | sons | `SoundFx` procedural |

Ordem sugerida de execução: **1 → 2 → 3 → 4 → 6 → 8 → 9 → 11 → 13 → 7 → 10 → 12 → 14 → 5 → 15 → 16**. As tarefas 1, 2 e 3 não dependem de nenhum asset novo e resolvem sozinhas as queixas 1, 3 e parte da 6.

**Definição de pronto de cada tarefa:** teste de núcleo intacto (suíte verde), print 540x960 anexado, checklist de §12 respondido item a item, HANDOFF atualizado, executável de teste informado ao Orlando.
