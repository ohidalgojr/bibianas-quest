# Estrutura do tabuleiro gótico: a cidade que sobe até a igreja

Escrito na TASK-073 (ADR-0060) por um agente de estrutura de tabuleiros. Complementa o `docs/ART-DIRECTION.md`, o `ADR-0041` (algoritmo de cenários) e o GDD §17. Os prints citados estão em `docs/tasks/prints/TASK-073-antes-*.png` e `TASK-073-depois-*.png`.

## 1. O que foi estudado

- **Código:** `game/presentation/scenario/` (`scenario_blueprint.gd`, `scenario_generator.gd`, `scenario_validator.gd`, `scenario_renderer.gd`), `game/presentation/map3d/map3d_layout.gd` e `map3d_screen.gd` (câmera, névoa por linha, horizonte pintado `map-strip-02-praca.jpg`).
- **Referências do repositório:** `docs/design/refs/estetica/` (Sword of Convallaria, Tactics Ogre, Triangle Strategy, Octopath, Vagrant Story cidade, FFT Ivalice, Bloodborne, Dark Souls) e `docs/design/refs/arenas/` (`map-strip-01..03`, `arena-cidade-*`). Leitura estrutural, sem copiar arte:
  - Nas referências táticas o chão jogável é **uma superfície contínua e legível** (laje, calçada, madeira) com **borda de pedra aparente**; o que está fora dele é parede, casa ou água. Nunca há "chão cinza solto".
  - Cada terraço tem **um motivo para existir**: arrimo de um canal, base de uma casa, patamar de escada. A diferença de altura é sempre vencida por **escada ou rampa visível**.
  - **Casas ocupam quarteirões inteiros**, com porta na rua, telhado de duas águas e janelas acesas; a luz quente pontual guia o olhar no azul frio (Triangle Strategy, Tactics Ogre noturno).
  - A **fachada da catedral fica ao fundo, no eixo da rua principal** (a pintura `map-strip-02-praca.jpg` e `map-strip-03-escadaria.jpg`: portão de ferro entre pilares, adro com campo-santo, escadaria larga).
  - Em FFT/Tactics Ogre as peças altas ficam **atrás** (norte/oeste) e as baixas **na frente** (sul/leste), para não esconderem os personagens.
- **Pesquisa na web (resumo):** cidades medievais têm poucas portas na muralha, ruas estreitas e sinuosas, **praça de mercado central**, **igreja ao lado da praça com adro (parvis) e cemitério junto**, bairros com centro próprio e canais/fossos nas bordas. Fontes: [Medieval Towns and Cities](https://historycrunch.com/medieval-towns-and-cities/), [Urban Fortifications and Public Places](https://www.encyclopedia.com/history/news-wires-white-papers-and-books/urban-fortifications-and-public-places), [medieval towns](https://www.thehistoryofart.org/architecture/urban-planning/medieval-towns/). Para tática isométrica: elevação decide o combate e o tabuleiro é desenhado para mostrar altura ([Hardcore Gaming 101](https://www.hardcoregaming101.net/tactics-ogre/), [Unity: isometric](https://docs.unity3d.com:443/2020.1/Documentation/Manual/Tilemap-Isometric.html)).

## 2. Diagnóstico: por que o tabuleiro não fazia sentido

Prints: `TASK-073-antes-s7-passo0.png`, `-passo4.png`, `TASK-073-antes-s5-passo3.png`, planta `TASK-073-antes-planta-s7.png` e `-antes-iso-s7.png`.

| # | Problema | Evidência | Causa no código |
| --- | --- | --- | --- |
| 1 | **Grade rígida de 16 praças** (4 colunas × 4 camadas) ligadas por faixas de estrada em "ladrilho"; parece um tabuleiro de jogo de mesa, não uma cidade. | `antes-planta-s7` | `_cell_of_node` em retângulo; A* ligava tudo em linhas retas. |
| 2 | **Terraços sem lógica**: o relevo vinha de ruído suave + média das praças, então havia placas cinza a alturas arbitrárias, sem escada nem arrimo. | `antes-s7-passo0` | `_fill_smooth_terrain` (IDW + ruído + 2 passes de média). |
| 3 | **Nada guia o olhar para a igreja**: o eixo do tabuleiro (-Z) sobe para a *direita* da tela, e a igreja pintada fica fixa no *centro* do topo; o chefe aparece à direita da igreja. | `antes-s7-passo4` | Camadas avançavam só em Z; a câmera olha de +X +Z. |
| 4 | **Um bloco preto gigante** (a "catedral 3D" do chefe) cobria a lateral e brigava com a igreja pintada. | `antes-s7-passo4`, canto direito | `_render_cathedral` com paredes de 11 de altura. |
| 5 | **Construções soltas**: criptas espalhadas por sorteio, a 1 célula da rua, sem porta voltada para ela; massas cinza aleatórias (`_render_gothic_mass`) preenchiam o resto. | `antes-planta-s7` | `_place_map_compounds` por varredura de grade + massa por hash. |
| 6 | **Muros sem função**: parapeitos só nas bordas N e O, sem relação com ruas, casas ou desníveis. | `antes-iso-s7` | `_build_retaining_wall_runs` sobre silhueta irregular com jitter. |
| 7 | **Nós sem lugar**: baú, fogueira e evento eram só um sprite numa laje igual às outras. | `antes-s5-passo3` | Nenhuma cenografia por tipo de nó. |
| 8 | **Água sem motivo**: poças em "baixios" e um canal arbitrário. | `antes-iso-s7` | `_carve_water_and_bridges` por pontuação. |

## 3. A gramática da cidade gótica jogável

O tabuleiro é **uma cidade murada que sobe, em socalcos, da porta de entrada até o adro da igreja**. Da partida (sul, base da tela) ao chefe (norte, topo da tela):

```text
                     [ igreja pintada, no horizonte ]
              muro do adro com PORTÃO DE FERRO  (eixo do chefe)
        campo-santo |        ADRO (pátio de pedra)        | campo-santo
                    |      [ praça do CHEFE, nível 5 ]    |
                          ESCADARIA monumental (3 de largura)
                    patamar (nível 4)  ───  travessa (rua que une as ruas)
              rua ─── praça ─── rua ─── praça ─── rua ─── praça       camada N
                        │         │         │
                  (casas de empena, quintais, ruínas)
             ======= CANAL (2 de largura) com PONTES nas ruas =======    desnível
              rua ─── praça ─── rua ─── praça ───                       camada 1
                          portão em ruína + estrada de chegada
                                  [ PARTIDA ]
```

### 3.1 Zonas

| Zona | O que é | Como o algoritmo faz |
| --- | --- | --- |
| **Portão / entrada em ruínas** | Dois pilares baixos e restos de muro ao sul da partida; uma estrada de chegada de 4 células. | `_place_city_gate` (composto `COMPOUND_CITY_GATE`). Tudo baixo: fica na frente da câmera. |
| **Rua principal** | O caminho pelas colunas centrais, da partida ao chefe. Lajeado mais claro e postes primeiro. | `_mark_main_road` marca `main_road`; `_lamp_order` acende ela antes. |
| **Ruas e travessas** | Cada aresta do grafo vira uma rua em Z: sobe da praça, corre ao longo da **travessa** do intervalo e sobe de novo. Ruas do mesmo nó dividem o tronco (T). | `_route_streets`, `_street_path`, `_bus_offset` (uma travessa por intervalo entre camadas). |
| **Becos** | Vão de 1 célula entre casas (probabilidade de pular um lote). Dão onde pôr poste e barril. | `_try_house` (6% de lotes vazios do lado alto). |
| **Praças** | 3×3, uma por nó, no mesmo nível por camada (socalco). Ganham cenografia por tipo de nó (seção 5). | `_stamp_plazas`, `_dress_node_plazas`. |
| **Casas de empena** | Corpo + telhado de duas águas, porta em arco para a rua, janelas âmbar. Alta (≈2,3) no lado dos fundos, baixa (≈1,5) onde só esconderia o 1º passo. | `COMPOUND_HOUSE`, `COMPOUND_COTTAGE`. |
| **Ruínas / quintais** | Pátio com muros caídos, barril e entulho, **na frente** das ruas (sul e leste), onde uma casa esconderia a rua. | `COMPOUND_RUIN_HOUSE` (altura 0,72). |
| **Muros de arrimo e muralha** | Parapeitos contínuos (≥2 células) nas bordas norte e oeste, onde há queda ≥2 ou vazio. Fazem a muralha da cidade. | `_build_retaining_wall_runs`. |
| **Escadarias** | Uma por desnível, **colada na praça mais alta**; a do chefe tem 3 células de largura e patamar. | `_route_streets` (altura da rua), `_place_stairs`, `_prepare_boss_approach`. |
| **Canal e pontes** | Um canal de 2 células que cruza a cidade onde as ruas **descem**; toda rua que o cruza vira ponte de 2 células. Margens em arrimo. | `_carve_canal_and_bridges` (`canal_layer`). |
| **Adro e campo-santo** | Pátio de pedra entre a praça do chefe e o portão; dois cemitérios com grade nos lados. | `_build_boss_precinct`. |
| **Fachada / portão da igreja** | Muro com portão de ferro entre pilares, no eixo da escadaria. Atrás dele, a **igreja pintada do horizonte**. | `COMPOUND_CHURCH_GATE`. A igreja não é modelada em 3D (ver seção 8). |

### 3.2 Regras de coerência (todas verificadas pelo `ScenarioValidator`)

1. **A rua principal sempre leva ao destino**: `main_road` é contínua da partida ao chefe e termina na escadaria do chefe (`test_main_road_is_continuous_from_start_to_boss`).
2. **Escadarias ligam níveis**: toda diferença de altura entre células caminháveis é de no máximo 1, vencida por degrau `stairs` com 1 vizinho mais alto e `yaw` para ele. A rua fica no nível da origem até o último trecho junto da praça mais alta ("degrau diante da praça").
3. **O chefe fica no ponto mais alto, de frente para o norte**: nenhuma rua nem nó chega ao nível 5; a escadaria sobe para o norte e o portão do adro fica ao norte do chefe, no mesmo X.
4. **Construções com porta voltada para a rua**: a célula à frente da porta é sempre rua ou praça, no nível do piso; nunca há prédio sem porta nem bloco solto.
5. **Parede alta nunca esconde rua**: a câmera olha de +X +Z e o raio sobe 0,82 por passo diagonal. Uma parede de ≈2,3 esconde as 2 células da diagonal sudeste de qualquer célula caminhável; uma casa baixa (≈1,5) esconde só a 1ª; ruínas (0,72) não escondem nada. `occluding_cells(bp, max_k)` calcula o conjunto e o validador confere.
6. **Praças planas, nós livres, chefe sem oclusão**: invariantes herdados do ADR-0041.
7. **Props com função**: entulho junto às casas, pedras no arrimo, lápides só em cemitério; nada de peça estrutural solta.
8. **Água só onde faz sentido**: um canal, só no desnível, sempre com pontes; nenhuma poça (componente ≥ 6 células).
9. **Determinismo**: mesma semente, mesma cidade (`test_city_blueprint_is_deterministic_by_seed`).

## 4. Orientação do tabuleiro em relação à câmera

A câmera (`Map3DScreen`) é ortográfica e fica em `(+1, 0,82, +1) × 22` olhando para `(-X, -Z)`. Consequências:

- **A vertical da tela é a diagonal `(-X, -Z)`**. Avançar só em `-Z` sobe *para a direita*; avançar só em `-X` sobe *para a esquerda*.
- O horizonte pintado (`map-strip-02-praca.jpg`) é uma imagem **fixa na tela**: a igreja está sempre no centro do topo.
- Logo, para o caminho "ir em direção à igreja", **cada camada deve avançar o mesmo tanto em `-X` e em `-Z`**. É o `NORTH_SHEAR` (= `LAYER_STEP`): o nó da camada `L` fica em `x = MARGIN + (L_total-1-L)·SHEAR + coluna·COLUMN_STEP` e `z = MARGIN + (L_total-1-L)·LAYER_STEP`.
- As **3 opções** de um nó ficam, na tela, à esquerda, no centro e à direita (deslocamento `dx - dz` = −7, 0, +7 células), e as colunas de uma camada formam uma fileira na diagonal de 30° típica de tática isométrica.
- O chefe (coluna central) fica a ±2 células do eixo vertical da tela quando a Bibiana está na camada anterior: **a igreja pintada fica logo acima dele** (`TASK-073-depois-s7-passo4.png`).
- A névoa do `Map3DScreen` continua por **linha de Z** (`layer_at_row`); por isso os nós de uma camada ficam sempre na mesma linha e o desvio é só em X (a "inclinação" do tabuleiro é feita em X). Um teste (`test_board_advances_along_the_camera_diagonal_toward_the_church`) trava essa relação.
- Silhueta: uma **faixa diagonal em degraus de `LAYER_STEP`** que acompanha a rua principal (sem retângulo vazio nos cantos).

## 5. Como cada tipo de nó vira um lugar

O centro da praça fica livre para o sprite do nó (baú, fogueira, lápide, inimigo). A cenografia é o `plaza_dress` do `ScenarioBlueprint`, nos lados norte e oeste (os dos fundos da câmera) e em peças baixas na frente.

| Tipo de nó | Lugar na cidade | Cenografia (peças CC0) |
| --- | --- | --- |
| Luta comum | Largo com restos | entulho (`graveyard/debris`) nos cantos |
| Emboscada | Largo estreito com cobertura | barris (`mini_dungeon/barrel`) nos flancos |
| Elite | Praça de armas | grade de ferro (`iron-fence-border`) ao norte e a oeste, dois braseiros |
| Baú | **Casa em ruínas**: sala de muros ao norte e a oeste, abertura onde a rua chega | `stone-wall` (alto onde não esconde rua, baixo e caído onde esconde), barril |
| Evento | **Campo-santo menor** (adro pequeno) | lápides e cruz (`gravestone-*`, `cross-column`) |
| Fogueira | **Praça abrigada**: muros em L, banco e barril | `stone-wall`, `bench`, `barrel` |
| Mini boss | Praça de armas, mesma gramática da elite | idem elite |
| Chefe | **Adro** no ponto mais alto, escadaria monumental, portão e campo-santo | `COMPOUND_CHURCH_GATE`, 2 `COMPOUND_CEMETERY`, balaustradas |
| Partida | **Portão em ruína** com estrada de chegada | pilares baixos, `stone-wall-damaged`, entulho |

## 6. Escala com o número de camadas (primeiro mapa curto)

- Parâmetros: `LAYER_STEP = 8`, `COLUMN_STEP = 6`, `MARGIN = 8`, `NORTH_SHEAR = 8`. A planta cresce em `rows = (camadas+1)·8 + 17` e `cols = (largura-1)·6 + (camadas+1)·8 + 17`.
- **Cenário 1 (4 camadas, curto, GDD §17 e F-020)**: 75 × 57 células, socalcos nos níveis 2 a 4 (chefe no 5), 1 canal e ≈25 a 30 casas e ruínas. Continua sendo um mapa curto, mas **denso e sem facilitar**: cada passo mostra uma rua e um lugar novos.
- **Mapas maiores (6, 8, 10 camadas)** reaproveitam a mesma gramática: a rampa sobe mais devagar (nível `2 + 2·L/(N)`), há um único desnível com canal, e a cidade ganha mais bairros em degrau. Varredura de 280 mapas (3, 4, 5, 6, 8, 10 e 12 camadas × 40 sementes): 0 violações, ≈135 ms por mapa. A 8 camadas a planta tem 113 × 89 células e a 12 camadas 145 × 121: aí vale **dividir em bairros** (ver seção 8).
- O canal fica entre as camadas `d-1` e `d`, com `d` sorteado entre 2 e `N-1` (nunca na primeira camada nem logo antes do chefe).

## 7. Tabela de peças

### 7.1 Peças CC0 já usadas

| Função | Peça | Onde |
| --- | --- | --- |
| Corpo da casa | `kenney/graveyard/crypt-large.glb` (porta em arco) | `COMPOUND_HOUSE`, `COTTAGE` (escalada à planta; 2 módulos se a frente tem 4) |
| Telhado de duas águas | `crypt-large-roof.glb` | idem |
| Agulha no telhado | `bibiana/scenery/spire.glb` | 1 em cada 3 casas altas |
| Muros baixos e de arrimo | `stone-wall`, `stone-wall-damaged`, `brick-wall` | ruínas, salas, muralha |
| Portão do adro | `iron-fence-border-gate`, `iron-fence-border`, `pillar-square` | `COMPOUND_CHURCH_GATE` |
| Campo-santo | `gravestone-*`, `cross-column`, `iron-fence-border`, `pillar-square` | `COMPOUND_CEMETERY` |
| Chão e arrimo | `mini_dungeon/dirt` (cubo), `floor` (laje), `stairs` | terreno, praças, estradas, escadas |
| Pontes | `dirt` escalado, `column`, `stone-wall` | `_render_bridges` |
| Postes | `graveyard/lightpost-single` | rua principal primeiro |
| Braseiros | `graveyard/fire-basket` (escurecido) + chama âmbar (2 quads) | adro, praça de armas |
| Mobília de praça | `bench`, `mini_dungeon/barrel`, `debris`, `rocks`, `stones` | baú, fogueira, luta |

### 7.2 O que falta (e o prompt para o Gemini)

Regras dos prompts (`GDD §18`, `ADR-0042`): nunca citam jogos, personagens ou artistas; atmosfera dark fantasy gótica, azul-ardósia dessaturada, luar frio, uma luz âmbar pontual. Texturas: `1024×1024`, tileáveis, sem texto. Sprites: fundo `#10131A` chapado, vista isométrica 3/4 de cima.

| Caminho do arquivo | Para quê | Prompt (Gemini) |
| --- | --- | --- |
| `assets/bibiana/textures/wall_plaster_timber.jpg` | Parede de casa de empena (hoje o corpo é a pedra da cripta) | "Textura tileável 1024×1024 de parede de casa medieval gótica em ruínas: reboco cinza-azulado manchado de umidade com vigas de madeira escura em cruz, rachaduras, musgo escuro nos cantos. Luz difusa e fria, sem sombras fortes, sem texto, sem personagens. Pintura digital detalhada, paleta dessaturada." |
| `assets/bibiana/textures/roof_slate.jpg` | Telhado de ardósia dos telhados de duas águas | "Textura tileável 1024×1024 de telhado de ardósia escura inclinado visto de cima em ângulo, telhas irregulares azul-ardósia com algumas quebradas e musgo, brilho molhado de chuva. Sem texto, sem personagens. Pintura digital, atmosfera gótica fria." |
| `assets/bibiana/textures/stone_retaining_wall.jpg` | Face dos arrimos e do canal (hoje usa a pedra de calçada) | "Textura tileável 1024×1024 de muro de arrimo de pedra cinza-escura em fiadas irregulares, juntas profundas, manchas de lodo e escorrimento de água, base molhada. Luz fria lateral. Sem texto. Pintura digital, dessaturada." |
| `assets/bibiana/textures/ground_rubble.jpg` | Chão de lote e quintal (terra batida, lajes quebradas) | "Textura tileável 1024×1024 de chão de quintal abandonado: terra batida escura com lajes de pedra quebradas, cascalho, poças rasas, poucas ervas mortas. Vista de cima, luz difusa fria. Sem texto. Pintura digital, dessaturada." |
| `assets/bibiana/sprites/house_door_arch.png` | Porta de madeira com batente de pedra para decalque nas casas | "Sprite de uma porta gótica de madeira escura reforçada com ferro dentro de um arco ogival de pedra, vista de frente, levemente iluminada por uma luz âmbar vinda de dentro, fundo chapado #10131A, sem texto, estilo pintura digital detalhada." |
| `assets/bibiana/sprites/house_window_lit.png` | Janela de empena com vidro âmbar | "Sprite de uma janela gótica estreita com caixilho de chumbo e vidro âmbar aceso por dentro, moldura de pedra desgastada, vista de frente, fundo chapado #10131A, sem texto. Pintura digital." |
| `assets/bibiana/sprites/well_stone.png` | Poço de pedra para a praça do evento | "Sprite isométrico 3/4 de um poço de pedra circular medieval com borda quebrada e roldana de madeira apodrecida, musgo, balde pendurado, fundo chapado #10131A, vista de cima em ângulo, sem texto. Pintura digital sombria." |
| `assets/bibiana/sprites/gallows_post.png` | Forca para o evento (3 cordas vazias, sem corpos) | "Sprite isométrico 3/4 de uma forca de madeira antiga com três cordas vazias penduradas e uma lanterna acesa, sem corpos, base de pedra, fundo chapado #10131A, sem texto. Pintura digital sombria." |
| `assets/bibiana/sprites/church_gate_iron.png` | Portão de ferro grande do adro (para sobrepor ao horizonte pintado) | "Sprite frontal de um grande portão de ferro forjado de duas folhas, pontas de lança, entre dois pilares de pedra com pináculos, ligeiramente aberto, névoa na base, fundo chapado #10131A, sem texto. Pintura digital gótica." |
| `assets/bibiana/sprites/stone_bridge_arch.png` | Ponte de pedra em arco sobre o canal (hoje é um tabuleiro reto) | "Sprite isométrico 3/4 de uma pequena ponte de pedra em arco sobre um canal escuro, parapeitos baixos de pedra, uma lanterna num pilar, água preta com reflexo âmbar, fundo chapado #10131A, sem texto. Pintura digital sombria." |
| `assets/bibiana/sprites/balcony_wood.png` | Sacada de madeira em balanço (silhueta de empena) | "Sprite de uma sacada de madeira escura em balanço com guarda-corpo e vigas de apoio, tábuas empenadas, uma roupa rasgada pendurada, vista de frente, fundo chapado #10131A, sem texto. Pintura digital sombria." |
| `docs/design/refs/arenas/map-strip-04-canal.jpg` | Faixa de horizonte alternativa para mapas com canal (cenário 3, Brejo) | "Ilustração vertical 9:16 de um canal estreito entre casas góticas de empena ao entardecer, névoa azul, uma ponte de pedra ao fundo e uma torre de igreja distante, uma lanterna âmbar, sem texto, sem personagens. Pintura digital sombria, paleta dessaturada." |

Também faltam como **modelos 3D** (hoje aproximados por peças existentes): chaminé, contraforte lateral, arco de portão da cidade, escadaria larga (`modular_dungeon/stairs-wide.glb` existe e pode substituir as 3 escadas lado a lado do chefe).

## 8. Limites desta rodada e próximos passos

- **A igreja continua pintada** (horizonte fixo na tela). O 3D só monta o adro, o portão e o eixo. Dá para o chefe ficar a ±2 células do centro, não ao pixel. Se o Orlando quiser a igreja modelada, o lugar é `COMPOUND_CHURCH_GATE` (levantar fachada atrás do portão) e o horizonte vira só céu.
- **Orçamento de primitivas:** passo 2 da semente 7 = ≈63,6 mil (era 51 mil; GDD §18 pede < 60 mil). Pesos: casas (crypt-large + telhado = 1.032 triângulos por módulo) e a grade de névoa do `Map3DScreen` (`cols × rows` quads, hoje 4.275 contra 1.218). Ajuste recomendado fora do escopo desta tarefa: compactar o `MultiMesh` da névoa só com células não-VOID e reduzir as casas (LOD ou módulo próprio de ~300 triângulos). O terreno e as fachadas já são separados em faixas de 12 linhas de Z (corte por tela).
- **Mapas de 8+ camadas**: a planta passa de 110 × 85 células; avaliar dividir em bairros com 2 canais e um segundo portão.
- **Não verificado:** celular real, desempenho fora do lavapipe, revisão cruzada por outro modelo.
