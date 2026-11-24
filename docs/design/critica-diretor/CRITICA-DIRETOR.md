# Crítica do diretor: estado do jogo no commit c986ffa

Capturado de verdade (Godot 4.7.2, Vulkan lavapipe, 540x960). Todos os PNGs estão nesta pasta. Nenhuma captura falhou. O erro `ERR_CANT_OPEN` e os avisos ALSA do log são ruído de áudio/ambiente e não afetaram o print. As gavetas de combate saíram de um script próprio (`/tmp/claude-0/-home-user-bibianas-quest/3fd7410c-415e-59ce-b4f4-16fdb4e0bb87/scratchpad/drawers.gd`, fora do projeto) que chama `_select_drawer`.

Régua: `ART-DIRECTION.md`, ADR-0042, regras do dono em `IDENTIDADE-VISUAL.md` (nada fofo, nada tosco), mockup `refs/ui/bibiana-mockup-combate-mobile.jpg`, Fear & Hunger de costas.

## (a) Notas por tela

| Tela | Print | Nota | Justificativa |
| --- | --- | --- | --- |
| Mapa, passo 0 | `mapa-passos0.png` | 2,5 | 45% da tela de baixo é preto vazio. Três inimigos cinza sobre piso cinza-azulado, sem contraste. A pílula "ouro" da direita sai da tela. O mapa é uma maquete de blocos Kenney com chuva, não um lugar. |
| Mapa, passo 2 | `mapa-passos2.png` | 3 | Dá para ler o lampião e o cão grande, mas o resto é lajes azuis escuras iguais. Pílula "equip." cortada. Metade inferior é nada. |
| Mapa, passo 4 | `mapa-passos4.png` | 3 | O chefe é um vulto preto contra fundo preto. Só a casa vermelha do canto tem forma. O bom: a luz vermelha da casa sugere perigo. |
| Combate comum (cidadão, rato, corvo, lodo) | `combate-*.png` | 6,5 | A arena pintada é a melhor coisa do jogo: clima, chuva, lampião, ogivas. Os inimigos grandes têm presença. Mas a Bibiana está de FRENTE e pequena, e o inimigo "flutua" sem sombra de contato. |
| Combate elite/chefe (cão, costurado, coveiro, mãe das ratazanas) | idem | 6,5 | O Coveiro é imponente, mas a cabeça é cortada pelo selo "ATAQUE" e pelo topo. A cauda do rato e a mãe das ratazanas encostam na borda direita. |
| Gavetas de combate | `combate-gaveta-*.png` | 4 | Funciona, mas a abertura empurra o palco para cima e o encolhe (reflow). Botões sem hierarquia. Habilidade sem previsão de dano. |
| Fogueira | `tela-campfire.png` | 2,5 | Apagada, quase preta. Não se vê nada além de uma silhueta. O fundo é um bloco azul ilegível. Painel com 40% de espaço morto. |
| Loja | `tela-shop.png` | 4,5 | O vendedor está legível e a luz é boa. Mas a grade de itens é cortada ("Galhos Secos" pela metade), texto longo e centralizado, sem ícone com tamanho de toque claro. |
| Baú | `tela-chest.png` | 4 | O baú aberto brilha (bom), mas é o modelo Kenney azul e laranja, fora da paleta. As moedas gigantes ao redor lembram brinquedo. |
| Evento | `tela-event.png` | 3 | O preview mostra o texto de vitória do chefe, não um evento (provável bug da cena de preview ou do mapeamento de `tela=event`; confira). Cenário vazio, só a heroína. |
| Recompensa | `tela-reward.png` | 4 | Moeda e poção em 3D recortado sobre losango cinza. Legível, mas sem peso de recompensa. |
| Home | `tela-home.png` | 3,5 | Título bonito em dourado, mas a cena é um losango vazio e a heroína minúscula. "Santuário" e "Classe" desalinham. 25% da tela embaixo é preto. |
| Resultado | `tela-result.png` | 3 | O painel estoura a tela: o botão "Início" é cortado no rodapé. Muito texto corrido para uma vitória de chefe. |

Elogio merecido: (1) as arenas pintadas e o enquadramento do inimigo ocupando 55 a 70% do palco no combate; (2) a tipografia serifada dourada dos títulos; (3) os sprites recortados de props e NPCs (baú de ferro, lampião, forca) estão no nível certo e ainda NÃO são usados no mapa.

## (b) Problemas por prioridade

### P0 (bloqueiam o gancho do jogo)

1. **Mapa: tudo escuro e sem contraste, inimigos ilegíveis.** Tela: mapa 0, 2, 4. Causa: `map3d_screen.gd` `_build_environment`: `ambient_light_energy = 2.2` com cor `1B2029`, `adjustment_brightness = 0.92`, `adjustment_saturation = 0.56`, luar `light_energy = 0.95`; viewport interno 270x480 (`_viewport.size`) esticado 2x; inimigos viram sprites cinza sobre piso cinza. Correção: ver especificação (c). Em resumo, piso a 25% de luminância máxima, inimigo ganha aro de luz rim quente e sombra de contato, ambiente +40%, névoa só nos nós futuros.
2. **Mapa: metade da tela vazia.** Tela: mapa 0 e 4. Causa: `CAM_OFFSET`/`CAM_SIZE = 18` e `CAM_LOOKAHEAD (0,0,-2.5)` centram o herói no meio, mas o grafo cresce para cima; embaixo não há nada. Correção: herói a 70% da altura (y≈670 de 960), não 50%; mostrar 2 camadas para trás e 3 para frente.
3. **Mapa: assets precisam ser refeitos (queixa do dono confirmada).** O chão e os blocos são Kenney (`K_MINI`, `K_GRAVE` em `map3d_screen.gd`: baú, `fire-basket.glb`, `altar-stone.glb`), os inimigos usam `ModelRegistry` com `factor 1.7/2.3`. Em paralelo existem props 2D HD-2D prontos que não entram. Correção: trocar baú, fogueira, evento por `iron_chest`, fogueira pintada e `gothic_tombstone`; lampiões por `plague_lamppost`; forca por `gallows_post`.
4. **Bibiana entra de FRENTE no combate.** Tela: todos os combates. Causa: `bibiana_warrior.png` é frontal; `combat3d_stage.gd` usa `PLAYER_YAW = 225`. O dono quer de costas (Fear & Hunger). Correção: ver (e).
5. **Pílulas de nó cortadas na borda (assets cortados).** Mapa 0 e 2: "ouro" e "equip." saem da tela em x≈535. Causa: `_pill()` posicionada por projeção sem clamp. Correção: clamp em `[8, 532 - largura]` e, perto da borda, inverter o lado do rótulo para a esquerda do ícone.
6. **Inimigos e chefe cortados no combate.** Coveiro: cabeça sob o selo "ATAQUE" e passando do topo do palco; rato e mãe das ratazanas tocam a borda direita; `PAINTED_HEIGHT_BOSS = 2.9` e `PAINTED_HEIGHT_ELITE = 2.6` não respeitam largura. Correção: limitar por altura E largura (sprite ≤ 88% da largura do palco e topo ≥ 56 px abaixo do alto), recuar `ENEMY_POS` e subir `CAM_TARGET` até caber.
7. **Painel de resultado e loja estouram a tela.** `tela-result.png` (botão "Início" cortado), `tela-shop.png` (grade cortada). Correção: painel em `ScrollContainer` com altura máxima de 62% da tela e botões de ação fixos no rodapé, sempre inteiros.

### P1

8. **Inimigo flutua; falta sombra de contato.** Todos os combates. O cão e o corvo não tocam o piso. Correção: elipse de sombra escura (alfa 0,55, largura 70% do sprite, altura 12%) colada à base do sprite, e subir o piso 6 px sob os pés (`FLOOR_Y`/`shadow.pixel_size` em `combat3d_stage.gd`).
9. **Selo de intenção cobre o rosto do chefe e é só texto.** `_show_intent`/`_anchor_intent` (`combat_screen.gd`). Correção: mover para o canto superior direito do palco com 56x56 px, ícone (espada, garra, boca, relâmpago) + número do dano previsto e cor por tipo (vermelho golpe, âmbar debuff, azul-cinza defesa); o texto vai só no toque.
10. **Gavetas fazem o palco encolher.** `combate-gaveta-*`: o palco passa de 650 px para 530 px de altura quando abre, e a arte pula. Correção: gaveta como folha sobreposta (bottom sheet) que cobre o rodapé e não redimensiona o palco; palco fixo.
11. **Botões de habilidade/item sem previsão e sem estado.** `combate-gaveta-skills.png`. Correção na especificação (d).
12. **Fogueira ilegível e apagada como primeira impressão.** `tela-campfire.png`. Causa: `focal_set.gd`/`scene3d_backdrop.gd`. Correção: o preview deve mostrar a fogueira ACESA com luz âmbar (energia 3,5, alcance 5 unidades), arco ogival ao fundo e a heroína de costas sentada; o estado "apagada" mostra brasa mínima visível.
13. **Heroína em duas versões.** Combate usa a pintura frontal clara; mapa, fogueira, baú, recompensa e resultado usam outro modelo escuro (com brilho verde na capa em `tela-event`/`tela-result`). Quebra de identidade. Correção: uma só Bibiana (armadura de aço escurecida, capa vinho), usada de costas em todo o jogo e de 3/4 só em retratos.
14. **Baú e moedas fora da paleta.** `tela-chest.png`: azul Kenney + laranja saturado. Correção: `iron_chest.png` com luz âmbar saindo da fresta; moedas reduzidas a 40% e em quantidade menor.
15. **Home vazia.** `tela-home.png`. Correção: arena `arena-home-santuario.jpg` como fundo pintado, heroína de costas diante do portão, título maior; botões "Nova Descida" 64 px de altura.

### P2

16. **Texto da loja** centralizado em colunas estreitas com nome, tipo, atributos e preço empilhados em 5 linhas. Correção: ícone 48 px à esquerda, nome em 1 linha, atributos em 1 linha pequena, preço em dourado à direita, estado "Ouro insuficiente" como cadeado e cor, não frase.
17. **Linha de previsão** (`Atacar dano 14-17 · acerto 87% · crít 5% · +2 MP`) em azul-marinho chapado (cor fora da paleta) com fonte 15 (`_forecast`). Correção: pedra escura `#15171C`, fonte 16, números em dourado.
18. **Coluna de retratos de turno** (30x30 px) é pequena e cobre a arte à esquerda. Correção: 36x36 px, movida para uma faixa horizontal sob a barra do inimigo, só 4 próximos turnos.
19. **Barras de HP/MP** com texto de 13 px dentro de 22 px de altura, ilegíveis. Correção: 26 px de altura, fonte 14, contorno preto.
20. **Cena `tela=event`** mostra texto de vitória. Verificar `game_preview.gd`.
21. **Nenhum tela de dica de controle** do mapa (arrastar/tocar). Correção: no primeiro mapa, pulso suave no nó alcançável mais próximo.

## (c) Especificação do mapa novo

**Princípio:** o mapa é uma cena pintada em camadas, vista de cima em perspectiva isométrica, e não uma pilha de cubos. Deve ser lido como uma rua morta que sobe em direção ao chefe.

1. **Formato:** retrato 540x960, rolagem vertical. Sempre visíveis: 2 camadas passadas, a atual e 3 futuras (a mais distante em névoa). Herói em y≈670. Margem lateral segura de 24 px para pílulas e sprites (nada corta).
2. **Camadas de arte (de trás para frente):**
   - Fundo: pintura vertical contínua (rua gótica, torre do sino ao topo), escurecida, em parallax de 0,3x. Gere com o mesmo estilo das arenas (`refs/arenas/arena-cidade-rua.jpg`, `arena-cidade-praca.jpg`) em formato 540x1920, três segmentos que encadeiam: rua molhada, praça com fogueira, escadaria até o portão do chefe. É pintado porque o 3D de blocos Kenney é o que está feio; o 3D só serve para a luz e a névoa por cima.
   - Palco: lajes largas desenhadas (estrada em S) com 3 trilhas por camada, cada nó sobre um disco de pedra de 96 px de diâmetro.
   - Primeiro plano (parallax 1,3x, desfocado): grade de ferro, galhos, chuva, névoa baixa.
3. **Escala dos sprites (em px na tela, altura):** Bibiana 120; inimigo comum 120 a 140 (cão, rato e corvo: largura 150); elite 170; mini boss 190; chefe 230 com silhueta que se vê desde longe, mesmo na névoa (lanterna vermelha acesa em cima). Props de nó: `iron_chest` 84 de altura; `plague_lamppost` 150; `gothic_tombstone` 90 (evento); `gallows_post` 170 (nó de elite ou decoração); fogueira 80 com chama animada; `grave_scavenger`/`shop_keeper` 130 (nó de loja). Tudo com sombra elíptica de contato (alfa 0,5).
4. **Contraste e luz:** fundo e piso em luminância 12 a 25% (valores entre `#10141C` e `#2A3340`). Cada nó alcançável ganha uma luz pontual quente (âmbar `#E8A04C`, raio 150 px, energia ~2,5) e o inimigo ganha contorno de luz fria `#8FA4C4` de 2 px no lado do luar, para destacá-lo do piso. Inimigo nunca na mesma luminância do piso: se o piso é 20%, o inimigo central precisa de média 45% ou mais, com a silhueta mais clara. Lampiões diegéticos a cada duas camadas, com halo e feixe de luz. Ambiente +40% do atual (`ambient_light_energy` 2,2 para ~3,1) para que nada fique no preto total, mas vinheta fechada nos 12% de borda.
5. **Ícones e informação dos nós (alvo de toque 56x56 px, mínimo 48):**
   - Luta: crânio pequeno sobre selo vermelho escuro + "Nv N". Elite: crânio com chifre, borda dourada. Mini boss e chefe: selo grande 72 px com pulso.
   - Baú: chave ou tampa dourada. Fogueira: chama. Evento: olho ou interrogação em âmbar. Loja: moeda e balança.
   - Rótulo: pílula única de 13 a 14 px, num só ícone ao lado, nunca texto longo ("equip." vira ícone de espada). Sempre dentro da margem segura.
   - Nó atual: anel branco pulsante. Nós já feitos: apagados e riscados. Nós futuros: ícone visível mas com 60% de névoa.
6. **Neblina de guerra (GDD §5):** camadas passadas a 55% de visibilidade (já visitadas), camada atual e próxima a 100%, camadas 2 a 3 à frente de 60% a 30% com ícone de interrogação até se aproximar, chefe sempre com a luz vermelha visível. Em vez de uma folha 3D (`FOG_*` em `map3d_screen.gd`), usar faixas de névoa pintadas com alfa animado.
7. **Câmera:** ortográfica fixa; ao andar, desliza 0,6 s com ease-out e o herói volta a y≈670. Quando o chefe aparece, ele entra com um breve tilt para cima.
8. **Heroína no mapa:** sprite de costas (ver (e)), 120 px, subindo a rua, com passos curtos e balanço de capa.
9. **HUD do topo:** barra de HP e MP e ouro em 40 px de altura em tira escura (hoje cola em cima da arte); inventário rápido com ícones de 44 px.

## (d) Especificação do menu de combate (540x960)

Estrutura vertical fixa (palco nunca encolhe):

| Zona | y (px) | Altura | Conteúdo |
| --- | --- | --- | --- |
| Cabeçalho | 0 a 64 | 64 | Nome + nível; barra de HP do inimigo 26 px com texto 14 px; ícones de status 24 px à direita |
| Palco | 64 a 640 | 576 | Arena pintada, inimigo grande, Bibiana de costas, selo de intenção, números de dano |
| Faixa de previsão | 640 a 684 | 44 | "Atacar 14-17 · 87% · crít 5% · +2 MP" |
| Barras da heroína | 684 a 722 | 38 | HP verde-musgo `#4F7A3A` e MP azul-aço `#3B5C86`, 26 px, texto 14 px com contorno |
| Ações principais | 730 a 810 | 80 | Atacar (60% da largura) e Defender (40%), ícone 40 px + rótulo, uppercase serifado 18 px |
| Abas secundárias | 818 a 874 | 56 | Habilidades, Itens, Tático, com ícone 28 px e contador; todas ≥ 48 px de toque, 8 px de respiro |
| Margem de segurança | 874 a 960 | 86 | Para gesto do sistema e a folha das gavetas |

Regras:
1. **Gavetas como folha sobreposta** com 300 px de altura que sobe sobre barras e ações (escurece o palco a 35%), sem mudar o tamanho do palco. Fecha por toque fora, arrastar para baixo ou na aba ativa.
2. **Botão de habilidade** 100% de largura, 64 px de altura, em lista de 1 coluna (máximo 4 visíveis, rolagem depois): ícone 40 px, nome 17 px, custo de MP em azul à direita, previsão de dano em dourado abaixo ("dano 22-26, acerto 87%"). Estados: normal (borda bronze), foco/pressionado (borda dourada, fundo mais claro), sem MP (50% de opacidade, custo em vermelho e cadeado), desabilitado por turno (mesmo cinza + motivo curto).
3. **Previsão de dano ao tocar:** primeiro toque seleciona e mostra a previsão no selo sobre o inimigo (número + chance), segundo toque confirma. Itens e Fugir pedem confirmação só se custosos.
4. **Estados do botão Atacar e Defender** quando não é o turno do jogador: 40% de opacidade com um cronômetro (arco) no ícone, em vez de cinza morto (hoje `combate-giant_rat.png` parece quebrado).
5. **Selo de intenção** 56x56 px no canto superior direito do palco (ver P1 nº 9). Aviso de golpe perigoso (GDD justiça) em vermelho com pulso, um turno antes.
6. **Itens:** grade 3 colunas, 88x88 px por item, ícone 48 px + quantidade em canto. Zero em estoque: 40% de opacidade.
7. **Tático:** Fugir e Velocidade como linha de 2 botões de 56 px; Velocidade como alternância 1x/2x com ícone, não texto.
8. **Cores:** pedra `#15171C`, borda bronze `#8A6A3A`, foco dourado `#E5B84A`, texto `#E8DFC8`. Sem azul-marinho chapado.
9. **Cadência de moeda** (cara ou coroa, GDD §7): botões Cara e Coroa de 96 px de altura, lado a lado, com a chance e o ícone; a moeda gira no centro do palco.

## (e) Especificação da Bibiana de costas

- **Enquadramento:** câmera baixa atrás do ombro direito da heroína, plano fechado de combate. Ela fica no terço inferior esquerdo do palco (centro em x≈190 de 540, base dos pés em y≈600 do palco de 576 de altura), ocupa 32 a 36% da altura do palco (≈190 px; hoje ≈210, mas de frente e pequena em leitura). O corpo ocupa uma coluna estreita para não cobrir o inimigo; o inimigo central fica livre, 55 a 70% da altura do palco.
- **Pose:** vista de costas quase pura (rotação de 10 a 15 graus para a esquerda para mostrar a borda da espada e a curva do escudo). Espada baixa na mão direita, ponta levemente para frente-direita; escudo no braço esquerdo, visto pela borda; capa vinho esfarrapada caindo até o joelho; cabelo escuro preso, sem mecha colorida (F-024). Postura de guarda: joelhos flexionados, peso para frente.
- **Entrada:** ao abrir o combate, a heroína caminha de baixo do quadro para a marca, de costas, 0,8 s, com poeira e respingos; o inimigo reage e levanta a cabeça. Em vitória, ela abaixa a espada e continua de costas.
- **Variações necessárias (todas de costas, mesmo fundo transparente, mesma luz):** idle (respiração), ataque (investida e golpe), defender (escudo à frente, vista pela borda), dano (recuo), derrota (ajoelha), 4 frames de caminhada para o mapa. Recorte final ≈ 240 px de altura no mesmo padrão de `bibiana_warrior.png` (135x240).
- **Mapa e cenas de acampamento:** a mesma imagem de costas serve; a fogueira usa uma versão sentada de costas, olhando o fogo.
- **Prompt para o Gemini (sem citar jogos ou artistas, GDD §18).** Gerar uma prancha por pose, fundo chapado verde-croma `#00B140` para recorte:

> Pixel-art painterly character sprite, full body, seen from directly behind with a slight three-quarter turn to the left. A young woman warrior in dark, worn steel plate armour: pauldrons, vambraces and a cuirass back-plate scratched, soot-stained, with rust at the edges and faded dark-wine leather straps. A tattered deep-wine cloak hangs from her shoulders to the knees, torn at the hem. Dark brown hair tied in a short low knot, no colour streaks. Her right hand holds a plain battered longsword pointing low and slightly forward; her left arm carries a round wooden shield with iron rim, seen edge-on. Knees slightly bent, weight forward, guarded stance, adult proportions, serious silhouette, never cute or chibi. Cold blue-grey moonlight from the upper left with a thin warm amber rim light from a lantern on the right. Dense hand-painted texture on metal and cloth, hard readable silhouette at small size, 2:3 portrait, solid flat chroma-green background, no ground, no shadow, no text, no logo.

  Para as variações, trocar apenas a frase da pose: "sword raised overhead mid-swing", "shield raised in front, sword tucked back", "crouched on one knee, head lowered, sword planted in the ground", "walking away from camera, mid-stride, cloak swaying". Manter o resto igual.

## Resumo executivo

Prioridade imediata: o mapa (P0 1 a 3 e 5), a Bibiana de costas (P0 4) e o enquadramento do inimigo (P0 6). O combate pintado já é o melhor trecho do jogo; o resto das telas ainda parece protótipo.
