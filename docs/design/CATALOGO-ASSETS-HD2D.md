# Catálogo de Assets 2D HD-2D Organizados e Auditados (`ADR-0042` / `F-024`)

| Campo | Valor |
| --- | --- |
| Atualizado em | 2026-11-26 |
| Total organizado | 75 pranchas (1 Bibiana retrato + 7 pranchas Bibiana 4 poses `16:9` + 14 Inimigos Cenário 1 + 5 Inimigos Estudo + 2 NPCs + 5 Props + 12 Arenas/Cenários `9:16` + 3 Sobreposições/Estrada de Mapa + 7 Folhas de Ícones `4×4` + 2 Moedas + 8 Peças/Texturas UI + 6 Folhas VFX + 3 Ilustrações de Eventos) |
| Origem | Arquivos brutos sem nome movidos de `assets/` (zero sobras soltas em `assets/`) e pranchas geradas pelo Guia de Arte (`docs/design/GUIA-DE-ARTE-DARK-FANTASY-MOBILE.md`) |
| Mecha colorida | Removida (`F-024`); toda prancha da Bibiana usa cabelo castanho-escuro natural |

## 1. Mapa completo dos 75 assets

| Tipo | ID | Nome | Caminho no repositório | Dimensões | Ajuste aplicado | `--box` `make_sprite.py` |
| --- | --- | --- | --- | :---: | --- | --- |
| Bibiana | `bibiana_guerreira` | Bibiana (Guerreira) | `docs/design/refs/bibiana/bibiana-guerreira.jpg` | `2752×1536` | Movido (sem mecha colorida, F-024) | `996,110,1788,1500` (`89% alt.`) |
| Inimigo C1 | `infected_citizen` | Cidadão Infectado (ENEMY-01) | `docs/design/refs/inimigos/infected_citizen.jpg` | `2752×1536` | Flip horizontal -> esquerda | `887,98,1686,1504` (`90% alt.`) |
| Inimigo C1 | `giant_rat` | Rato Grande (ENEMY-02) | `docs/design/refs/inimigos/giant_rat.jpg` | `2752×1536` | Movido (esquerda) | `293,103,2459,1493` (`89% alt.`) |
| Inimigo C1 | `carrion_crow` | Corvo Carniceiro (ENEMY-03) | `docs/design/refs/inimigos/carrion_crow.jpg` | `2752×1536` | Flip horizontal -> esquerda | `491,117,2388,1471` (`87% alt.`) |
| Inimigo C1 | `plague_hound` | Cão de Peste (ENEMY-04) | `docs/design/refs/inimigos/plague_hound.jpg` | `2752×1536` | Movido (esquerda) | `325,192,2471,1466` (`81% alt.`) |
| Inimigo C1 | `rotten_executioner` | Carrasco Apodrecido (ENEMY-05) | `docs/design/refs/inimigos/rotten_executioner.jpg` | `2752×1536` | Movido (esquerda) | `643,52,1883,1507` (`93% alt.`) |
| Inimigo C1 | `gravedigger` | O Coveiro (Chefe — ENEMY-06) | `docs/design/refs/inimigos/09-o-coveiro.jpg` | `2752×1536` | Movido em HD-2D unificado (esquerda) | `595,79,1911,1501` (`91% alt.`) |
| Inimigo C1 | `bell_warden` | Carcereiro do Sino (Mini Boss — ENEMY-07) | `docs/design/refs/inimigos/bell_warden.jpg` | `2752×1536` | Flip horizontal -> esquerda | `696,49,1963,1509` (`93% alt.`) |
| Inimigo C1 | `bell_ghost` | Sineiro Penado (ENEMY-08) | `docs/design/refs/inimigos/bell_ghost.jpg` | `2752×1536` | Movido (esquerda) | `952,72,1936,1458` (`89% alt.`) |
| Inimigo C1 | `wandering_bones` | Ossada Errante (ENEMY-09) | `docs/design/refs/inimigos/wandering_bones.jpg` | `2752×1536` | Removido martelo solto + Flip -> esquerda | `860,88,1763,1503` (`91% alt.`) |
| Inimigo C1 | `sewer_slime` | Lodo de Esgoto (ENEMY-10) | `docs/design/refs/inimigos/sewer_slime.jpg` | `2752×1536` | Movido (esquerda) | `234,114,2534,1461` (`86% alt.`) |
| Inimigo C1 | `alley_leech` | Sanguessuga de Beco (ENEMY-11) | `docs/design/refs/inimigos/alley_leech.jpg` | `2752×1536` | Movido (esquerda) | `688,112,2038,1481` (`88% alt.`) |
| Inimigo C1 | `hanged_man` | Enforcado (ENEMY-12) | `docs/design/refs/inimigos/hanged_man.jpg` | `2752×1536` | Movido (corda superior até topo) | `1193,0,1595,1473` (`95% alt.`) |
| Inimigo C1 | `stitched_horror` | Costurado (ENEMY-13) | `docs/design/refs/inimigos/stitched_horror.jpg` | `2752×1536` | Flip horizontal -> esquerda | `708,96,1960,1486` (`89% alt.`) |
| Inimigo C1 | `rat_mother` | Mãe das Ratazanas (ENEMY-14) | `docs/design/refs/inimigos/rat_mother.jpg` | `2752×1536` | Movido (esquerda) | `199,104,2573,1471` (`87% alt.`) |
| Inimigo Estudo | `blind_thurifer` | O Turiferário Cego (#01) | `docs/design/refs/inimigos/blind_thurifer.jpg` | `2752×1536` | Flip horizontal -> esquerda | `836,64,1680,1500` (`92% alt.`) |
| Inimigo Estudo | `reliquary_lady` | A Dama do Relicário (#02) | `docs/design/refs/inimigos/reliquary_lady.jpg` | `2752×1536` | Movido (esquerda) | `977,43,1861,1515` (`94% alt.`) |
| Inimigo Estudo | `wheel_pilgrim` | O Peregrino da Roda (#03) | `docs/design/refs/inimigos/wheel_pilgrim.jpg` | `2752×1536` | Flip horizontal -> esquerda | `1068,81,1788,1483` (`90% alt.`) |
| Inimigo Estudo | `wax_physician` | O Médico da Cera (#04) | `docs/design/refs/inimigos/wax_physician.jpg` | `2752×1536` | Movido (esquerda) | `840,71,1757,1500` (`91% alt.`) |
| Inimigo Estudo | `bog_washerwoman` | A Lavadeira do Brejo (#05) | `docs/design/refs/inimigos/bog_washerwoman.jpg` | `2752×1536` | Flip horizontal -> esquerda | `920,83,1724,1494` (`90% alt.`) |
| NPC | `shop_keeper` | Mercador da Cidade Abandonada | `docs/design/refs/npcs/shop_keeper.jpg` | `2752×1536` | Removido cajado solto à direita | `819,70,1828,1515` (`93% alt.`) |
| NPC | `grave_scavenger` | Saqueador de Covas (NPC) | `docs/design/refs/npcs/grave_scavenger.jpg` | `2752×1536` | Movido (esquerda) | `767,108,1905,1504` (`89% alt.`) |
| Prop | `iron_chest` | Baú Gótico de Ferro e Carvalho | `docs/design/refs/props/iron_chest.jpg` | `2752×1536` | Movido | `560,96,2191,1444` (`86% alt.`) |
| Prop | `plague_lamppost` | Poste Gótico com Lampião e Placa | `docs/design/refs/props/plague_lamppost.jpg` | `2752×1536` | Movido | `912,11,1808,1513` (`96% alt.`) |
| Prop | `gothic_tombstone` | Lápide Gótica com Grade e Crânio | `docs/design/refs/props/gothic_tombstone.jpg` | `2752×1536` | Movido | `857,36,1823,1493` (`93% alt.`) |
| Prop | `gallows_post` | Forca Gótica com Lampião | `docs/design/refs/props/gallows_post.jpg` | `2752×1536` | Fundo cinza normalizado -> #10131A | `932,38,1826,1504` (`94% alt.`) |
| Bibiana 4× | `bibiana_warrior_sheet` | Bibiana Guerreira — 4 poses (costas, esq., dir., fogueira) | `docs/design/refs/bibiana/bibiana-guerreira-sheet.jpg` | `1792×1008` | 4 colunas iguais de `448 px` (`hframes = 4`), `#10131A` liso | `0..448` / `448..896` / `896..1344` / `1344..1792` (`--thresh 8`) |
| Bibiana 4× | `bibiana_cleric_sheet` | Bibiana Clérigo — 4 poses (costas, esq., dir., fogueira) | `docs/design/refs/bibiana/bibiana-clerigo-sheet.jpg` | `1792×1008` | 4 colunas iguais de `448 px` (`hframes = 4`), `#10131A` liso | `0..448` / `448..896` / `896..1344` / `1344..1792` (`--thresh 8`) |
| Bibiana 4× | `bibiana_rogue_sheet` | Bibiana Ladino — 4 poses (costas, esq., dir., fogueira) | `docs/design/refs/bibiana/bibiana-ladino-sheet.jpg` | `1792×1008` | 4 colunas iguais de `448 px` (`hframes = 4`), `#10131A` liso | `0..448` / `448..896` / `896..1344` / `1344..1792` (`--thresh 8`) |
| Bibiana 4× | `bibiana_mage_sheet` | Bibiana Mago — 4 poses (costas, esq., dir., fogueira) | `docs/design/refs/bibiana/bibiana-mago-sheet.jpg` | `1792×1008` | 4 colunas iguais de `448 px` (`hframes = 4`), `#10131A` liso | `0..448` / `448..896` / `896..1344` / `1344..1792` (`--thresh 8`) |
| Arena 9:16 | `arena_cidade_rua` | Arena Comum — Beco da Cidade | `docs/design/refs/arenas/arena-cidade-rua.jpg` | `1536×2752` | Movido (9:16 vazio) | Fundo direto (`9:16`) |
| Arena 9:16 | `arena_cidade_praca` | Arena Elite/Mini — Praça do Sino e Forca | `docs/design/refs/arenas/arena-cidade-praca.jpg` | `1536×2752` | Movido (9:16 vazio) | Fundo direto (`9:16`) |
| Arena 9:16 | `arena_fogueira_acesa` | Fogueira Acesa — Refúgio | `docs/design/refs/arenas/arena-fogueira-acesa.jpg` | `1536×2752` | Movido (9:16 vazio) | Fundo direto (`9:16`) |
| Arena 9:16 | `arena_loja` | Loja — Alcova do Mercador | `docs/design/refs/arenas/arena-loja.jpg` | `1536×2752` | Movido (9:16 vazio) | Fundo direto (`9:16`) |
| Arena 9:16 | `arena_home_santuario` | Home / Santuário — Catedral | `docs/design/refs/arenas/arena-home-santuario.jpg` | `1536×2752` | Movido (9:16 vazio) | Fundo direto (`9:16`) |
| Arena 9:16 | `arena_fogueira_apagada` | Fogueira Apagada — Cinzas Frias | `docs/design/refs/arenas/arena-fogueira-apagada.jpg` | `768×1376` | Mesmo pátio de `arena-fogueira-acesa.jpg` com cinzas, 3 brasas fracas e fumaça | Fundo direto (`9:16`) |
| Arena 9:16 | `arena_cidade_chefe` | Arena Chefe — Cemitério e Capela | `docs/design/refs/arenas/arena-cidade-chefe.jpg` | `768×1376` | Cemitério gótico com túmulo aberto, lampião e capela em ruína (9:16 vazio) | Fundo direto (`9:16`) |
| Arena 9:16 | `bg_reward_shrine` | Recompensa / Level Up — Nicho de Relicário | `docs/design/refs/arenas/bg-reward-shrine.jpg` | `768×1376` | Nicho ogival de pedra com feixe de luar e candelabros (9:16 vazio) | Fundo direto (`9:16`) |
| Ícones 4×4 | `ico_a_actions` | Folha ICO-A — 16 Ícones de Ações e UI | `docs/design/refs/ui/ico-a-actions.jpg` | `1024×1024` | 16 células exatas `256×256` em `#10131A` liso (fatiados `96×96` RGBA) | Grade `4×4` (`256×256` por célula) |
| Ícones 4×4 | `ico_b_skills_intent` | Folha ICO-B — 9 Skills + 7 Selos de Intenção | `docs/design/refs/ui/ico-b-skills-intent.jpg` | `1024×1024` | 16 células exatas `256×256` em `#10131A` liso (fatiados `96×96` RGBA) | Grade `4×4` (`256×256` por célula) |
| Ícones 4×4 | `ico_c_status` | Folha ICO-C — 12 Status e Doenças | `docs/design/refs/ui/ico-c-status.jpg` | `1024×1024` | 12 células `256×256` nas linhas 1–3; linha 4 vazia `#10131A` | Grade `4×4` (`256×256` por célula) |
| Ícones 4×4 | `ico_d_weapons_slots` | Folha ICO-D — 9 Armas + 6 Slots Vazios | `docs/design/refs/ui/ico-d-weapons-slots.jpg` | `1024×1024` | 15 células `256×256` (`#2A2D33` nos slots vazios); `R4C4` vazio `#10131A` | Grade `4×4` (`256×256` por célula) |
| UI Textura | `ui_noise_stone` | Ruído de Pedra Escura Tileável | `docs/design/refs/ui/ui-noise-stone.jpg` | `512×512` | Ruído procedural contínuo sem emenda (`v_seam=0,49`, `h_seam=0,46`) | Textura tileável direta (`ui_panel_stone`) |
| Ícones 4×4 | `ico_e_armor_head` | Folha ICO-E — 8 Armaduras + 6 Cabeça/Mão | `docs/design/refs/ui/ico-e-armor-head.jpg` | `1024×1024` | 14 células `256×256` em `#10131A` liso (fatiados `96×96` RGBA); `R4C3..4` vazios | Grade `4×4` (`256×256` por célula) |
| Ícones 4×4 | `ico_f_relics_consum` | Folha ICO-F — 8 Relíquias + 7 Consumíveis | `docs/design/refs/ui/ico-f-relics-consum.jpg` | `1024×1024` | 15 células `256×256` em `#10131A` liso (fatiados `96×96` RGBA); `R4C4` vazio | Grade `4×4` (`256×256` por célula) |
| Ícones 4×4 | `ico_g_nodes` | Folha ICO-G — 14 Ícones de Nós do Mapa | `docs/design/refs/ui/ico-g-nodes.jpg` | `1024×1024` | 14 células `256×256` em `#10131A` liso (fatiados `96×96` RGBA); `R4C3..4` vazios | Grade `4×4` (`256×256` por célula) |
| Moeda | `coin_heads` | Moeda — Cara (Penitente Velada, Borda Serrilhada) | `docs/design/refs/ui/coin-heads.jpg` | `768×768` | Ouro velho `#D9AA32`, fundo `#10131A` liso (`d=0,00`) | Recorte direto (`512×512`) |
| Moeda | `coin_tails` | Moeda — Coroa (Coroa de Espinhos, Borda Lisa) | `docs/design/refs/ui/coin-tails.jpg` | `768×768` | Ouro-prata `#B9B4A0`, fundo `#10131A` liso (`d=0,00`) | Recorte direto (`512×512`) |
| UI Kit | `ui_node_disc` | 5 Discos de Pedra 2:1 para Nós do Mapa | `docs/design/refs/ui/ui-node-disc.jpg` | `1920×384` | 5 colunas iguais `384×384`, `#10131A` liso | `hframes = 5` (`384×384` por quadro) |
| UI Kit | `ui_panel_stone` | Painel Base 9-Slice em Pedra + Rebites Bronze | `docs/design/refs/ui/ui-panel-stone.jpg` | `768×768` | Ortográfico simétrico, chanfrado 6 px, `#10131A` externo | 9-slice (`margin 24 px`) |
| UI Kit | `ui_banner_ribbon` | Faixa-Título Bronze Cauda de Andorinha | `docs/design/refs/ui/ui-banner-ribbon.jpg` | `768×256` | Ortográfico vazio (texto no motor), `#10131A` liso | Banner recompensa / vitória |
| UI Kit | `ui_divider` | Divisor Ornamental Simétrico de Bronze | `docs/design/refs/ui/ui-divider.jpg` | `768×128` | Ponta dupla simétrica com losango gótico central, `#10131A` | Separador ornamental |
| UI Kit | `ui_slot_frame` | 4 Molduras de Slot por Raridade | `docs/design/refs/ui/ui-slot-frame.jpg` | `1024×256` | 4 colunas `256×256` (bronze, aço, ouro, sangue), `#10131A` | `hframes = 4` (`256×256` por quadro) |
| UI Kit | `ui_frame_illustration` | Moldura Gótica de Ilustração de Evento | `docs/design/refs/ui/ui-frame-illustration.jpg` | `768×512` | Cantos em ogiva e bronze sobre `#10131A` liso | Moldura para `events/*.jpg` |
| Arena 9:16 | `bg_defeat` | Cenário de Derrota — Lampião Caído | `docs/design/refs/arenas/bg-defeat.jpg` | `768×1376` | Beco dessaturado com névoa vermelha sutil nas bordas | Fundo direto (`9:16`) |
| Mapa 9:16 | `map_strip_01_rua` | Faixa de Mapa 1 — Avenida Molhada | `docs/design/refs/arenas/map-strip-01-rua.jpg` | `768×1376` | Perspectiva isométrica alta, 3 lampiões âmbar, névoa no topo | Parallax mapa (`9:16`) |
| Mapa 9:16 | `map_strip_02_praca` | Faixa de Mapa 2 — Praça e Igreja | `docs/design/refs/arenas/map-strip-02-praca.jpg` | `768×1376` | Poço seco, forca vazia com lampião, fachada gótica | Parallax mapa (`9:16`) |
| Mapa 9:16 | `map_strip_03_escadaria` | Faixa de Mapa 3 — Escadaria do Chefe | `docs/design/refs/arenas/map-strip-03-escadaria.jpg` | `768×1376` | Escadaria de gárgulas até portão e vitral vermelho na torre | Parallax mapa (`9:16`) |
| Arena 9:16 | `sanctuary_interior` | Santuário Interior — 3 Estações | `docs/design/refs/arenas/sanctuary-interior.jpg` | `768×1376` | Nave em ruínas com Biblioteca (esq.), Arsenal (dir.) e Códice (fundo) | Fundo direto (`9:16`) |
| Overlay 16:9 | `map_fg_ironfence` | 1º Plano Mapa — Grade de Ferro e Galhos | `docs/design/refs/arenas/map-fg-ironfence.jpg` | `1376×768` | Silhueta no rodapé sobre `#10131A` acima | Parallax 1º plano (`1,25x`) |
| Overlay 16:9 | `map_mist_band` | Faixa de Névoa Pintada com Agulhas | `docs/design/refs/arenas/map-mist-band.jpg` | `1376×768` | Névoa fria central com silhuetas de telhados sobre `#10131A` | Faixa de névoa / transição |
| Textura 16:9 | `road_cobble_tile` | Calçamento Molhado com Juntas Douradas | `docs/design/refs/arenas/road-cobble-tile.jpg` | `1376×768` | Vista superior 90° em ardósia úmida e pó de ouro gasto | Textura de estrada do mapa |
| Bibiana 4× | `bibiana_warrior_combat_sheet` | Bibiana Guerreira Costas — Combate | `docs/design/refs/bibiana/bibiana-guerreira-combat-sheet.jpg` | `1792×1008` | 4 colunas `448 px`: `attack \| defend \| hurt \| item` | `hframes = 4` / `--thresh 8` |
| Bibiana 4× | `bibiana_warrior_states_sheet` | Bibiana Guerreira Costas — Estados | `docs/design/refs/bibiana/bibiana-guerreira-states-sheet.jpg` | `1792×1008` | 4 colunas `448 px`: `sit_fire \| defeat \| victory \| idle_guard` | `hframes = 4` / `--thresh 8` |
| Bibiana 4× | `bibiana_warrior_walk_sheet` | Bibiana Guerreira Costas — Caminhada | `docs/design/refs/bibiana/bibiana-guerreira-walk-sheet.jpg` | `1792×1008` | 4 quadros de caminhada de costas (`walk_0..3`) | `hframes = 4` / `--thresh 8` |
| FX Sheet | `fx_flame_sheet` | Chama da Fogueira (Loop 8 Quadros) | `docs/design/refs/fx/fx-flame-sheet.jpg` | `2048×256` | 8 células iguais `256×256` ancoradas na base, `#10131A` | `hframes = 8` (`256×256`) |
| FX Sheet | `fx_slash_sheet` | Arco de Corte de Espada (6 Quadros) | `docs/design/refs/fx/fx-slash-sheet.jpg` | `1536×256` | 6 células iguais `256×256` (marfim + borda âmbar), `#10131A` | `hframes = 6` (`256×256`) |
| FX Sheet | `fx_coin_flip_sheet` | Giro Completo da Moeda (8 Quadros) | `docs/design/refs/fx/fx-coin-flip-sheet.jpg` | `2048×256` | 8 células `256×256` (`0°..315°` combinando Cara e Coroa) | `hframes = 8` (`256×256`) |
| FX Sheet | `fx_block_sheet` | Faíscas de Bloqueio de Escudo (5 Quadros) | `docs/design/refs/fx/fx-block-sheet.jpg` | `1280×256` | 5 células iguais `256×256` em `#10131A` liso | `hframes = 5` (`256×256`) |
| FX Sprite | `fx_crit_burst` | Explosão Radial de Acerto Crítico | `docs/design/refs/fx/fx-crit-burst.jpg` | `512×512` | Raios pontiagudos ouro velho e marfim em `#10131A` | Sprite único `512×512` |
| FX Sheet | `fx_poison_sheet` | Bolhas e Fumaça de Veneno (6 Quadros) | `docs/design/refs/fx/fx-poison-sheet.jpg` | `1536×256` | 6 células iguais `256×256` verde-musgo `#6E8F3F`, `#10131A` | `hframes = 6` (`256×256`) |
| Prop 2× | `campfire_props` | Fogueira Acesa e Apagada para Nó de Mapa | `docs/design/refs/props/campfire-props.jpg` | `1024×512` | 2 colunas iguais `512×512` (`campfire_lit \| campfire_cold`) | `0..512` / `512..1024` (`--thresh 8`) |
| Evento 16:9 | `event_weeping_bell` | Evento — O Sino Rachado da Praça | `docs/design/refs/events/event-weeping-bell.jpg` | `1376×768` | Sino rachado em poça d'água com lampião âmbar | Cartão de evento (`508×290`) |
| Evento 16:9 | `event_plague_wagon` | Evento — Carroça do Boticário | `docs/design/refs/events/event-plague-wagon.jpg` | `1376×768` | Carroça tombada, frascos, cofre trancado e ratos | Cartão de evento (`508×290`) |
| Evento 16:9 | `event_blind_herald` | Evento — O Arauto Cego | `docs/design/refs/events/event-blind-herald.jpg` | `1376×768` | Arauto cego de olhos costurados segurando balança de osso | Cartão de evento (`508×290`) |

## 2. Comandos prontos de recorte para o Claude (`tools/make_sprite.py`)

Todos os 26 sprites abaixo foram auditados contra a segmentação do `tools/make_sprite.py` (fundo `#10131A` liso, silhueta única coesa sem corte):

```bash
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira.jpg assets/bibiana/sprites/bibiana_warrior.png --box 996,110,1788,1500 --height 240
python tools/make_sprite.py docs/design/refs/inimigos/infected_citizen.jpg assets/bibiana/sprites/infected_citizen.png --box 887,98,1686,1504 --height 224
python tools/make_sprite.py docs/design/refs/inimigos/giant_rat.jpg assets/bibiana/sprites/giant_rat.png --box 293,103,2459,1493 --height 180
python tools/make_sprite.py docs/design/refs/inimigos/carrion_crow.jpg assets/bibiana/sprites/carrion_crow.png --box 491,117,2388,1471 --height 195
python tools/make_sprite.py docs/design/refs/inimigos/plague_hound.jpg assets/bibiana/sprites/plague_hound.png --box 325,192,2471,1466 --height 200
python tools/make_sprite.py docs/design/refs/inimigos/rotten_executioner.jpg assets/bibiana/sprites/rotten_executioner.png --box 643,52,1883,1507 --height 248
python tools/make_sprite.py docs/design/refs/inimigos/09-o-coveiro.jpg assets/bibiana/sprites/gravedigger.png --box 595,79,1911,1501 --height 260
python tools/make_sprite.py docs/design/refs/inimigos/bell_warden.jpg assets/bibiana/sprites/bell_warden.png --box 696,49,1963,1509 --height 256
python tools/make_sprite.py docs/design/refs/inimigos/bell_ghost.jpg assets/bibiana/sprites/bell_ghost.png --box 952,72,1936,1458 --height 228
python tools/make_sprite.py docs/design/refs/inimigos/wandering_bones.jpg assets/bibiana/sprites/wandering_bones.png --box 860,88,1763,1503 --height 228
python tools/make_sprite.py docs/design/refs/inimigos/sewer_slime.jpg assets/bibiana/sprites/sewer_slime.png --box 234,114,2534,1461 --height 205
python tools/make_sprite.py docs/design/refs/inimigos/alley_leech.jpg assets/bibiana/sprites/alley_leech.png --box 688,112,2038,1481 --height 224
python tools/make_sprite.py docs/design/refs/inimigos/hanged_man.jpg assets/bibiana/sprites/hanged_man.png --box 1193,0,1595,1473 --height 236
python tools/make_sprite.py docs/design/refs/inimigos/stitched_horror.jpg assets/bibiana/sprites/stitched_horror.png --box 708,96,1960,1486 --height 236
python tools/make_sprite.py docs/design/refs/inimigos/rat_mother.jpg assets/bibiana/sprites/rat_mother.png --box 199,104,2573,1471 --height 240
python tools/make_sprite.py docs/design/refs/inimigos/blind_thurifer.jpg assets/bibiana/sprites/blind_censer_bearer.png --box 836,64,1680,1500 --height 236
python tools/make_sprite.py docs/design/refs/inimigos/reliquary_lady.jpg assets/bibiana/sprites/reliquary_lady.png --box 977,43,1861,1515 --height 244
python tools/make_sprite.py docs/design/refs/inimigos/wheel_pilgrim.jpg assets/bibiana/sprites/wheel_pilgrim.png --box 1068,81,1788,1483 --height 236
python tools/make_sprite.py docs/design/refs/inimigos/wax_physician.jpg assets/bibiana/sprites/wax_physician.png --box 840,71,1757,1500 --height 236
python tools/make_sprite.py docs/design/refs/inimigos/bog_washerwoman.jpg assets/bibiana/sprites/bog_washerwoman.png --box 920,83,1724,1494 --height 232
python tools/make_sprite.py docs/design/refs/npcs/shop_keeper.jpg assets/bibiana/sprites/shop_keeper.png --box 819,70,1828,1515 --height 230
python tools/make_sprite.py docs/design/refs/npcs/grave_scavenger.jpg assets/bibiana/sprites/grave_scavenger.png --box 767,108,1905,1504 --height 230
python tools/make_sprite.py docs/design/refs/props/iron_chest.jpg assets/bibiana/sprites/iron_chest.png --box 560,96,2191,1444 --height 170
python tools/make_sprite.py docs/design/refs/props/plague_lamppost.jpg assets/bibiana/sprites/plague_lamppost.png --box 912,11,1808,1513 --height 240
python tools/make_sprite.py docs/design/refs/props/gothic_tombstone.jpg assets/bibiana/sprites/gothic_tombstone.png --box 857,36,1823,1493 --height 200
python tools/make_sprite.py docs/design/refs/props/gallows_post.jpg assets/bibiana/sprites/gallows_post.png --box 932,38,1826,1504 --height 240
```

### Bibiana — 4 Classes × 4 Poses (`1792×1008`, `4 × 448 px`)

Cada prancha suporta uso direto em `Sprite2D` / `Sprite3D` com `hframes = 4, vframes = 1` (quadros: `0` costas combate, `1` esquerda, `2` direita, `3` sentada na fogueira) ou recorte individual via `tools/make_sprite.py` com `--thresh 8` para preservar contorno e cabelo escuro:

```bash
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-sheet.jpg assets/bibiana/sprites/bibiana_warrior_back.png --box 0,0,448,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-sheet.jpg assets/bibiana/sprites/bibiana_warrior_left.png --box 448,0,896,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-sheet.jpg assets/bibiana/sprites/bibiana_warrior_right.png --box 896,0,1344,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-sheet.jpg assets/bibiana/sprites/bibiana_warrior_camp.png --box 1344,0,1792,1008 --height 175 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-clerigo-sheet.jpg assets/bibiana/sprites/bibiana_cleric_back.png --box 0,0,448,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-clerigo-sheet.jpg assets/bibiana/sprites/bibiana_cleric_left.png --box 448,0,896,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-clerigo-sheet.jpg assets/bibiana/sprites/bibiana_cleric_right.png --box 896,0,1344,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-clerigo-sheet.jpg assets/bibiana/sprites/bibiana_cleric_camp.png --box 1344,0,1792,1008 --height 175 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-ladino-sheet.jpg assets/bibiana/sprites/bibiana_rogue_back.png --box 0,0,448,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-ladino-sheet.jpg assets/bibiana/sprites/bibiana_rogue_left.png --box 448,0,896,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-ladino-sheet.jpg assets/bibiana/sprites/bibiana_rogue_right.png --box 896,0,1344,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-ladino-sheet.jpg assets/bibiana/sprites/bibiana_rogue_camp.png --box 1344,0,1792,1008 --height 175 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-mago-sheet.jpg assets/bibiana/sprites/bibiana_mage_back.png --box 0,0,448,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-mago-sheet.jpg assets/bibiana/sprites/bibiana_mage_left.png --box 448,0,896,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-mago-sheet.jpg assets/bibiana/sprites/bibiana_mage_right.png --box 896,0,1344,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-mago-sheet.jpg assets/bibiana/sprites/bibiana_mage_camp.png --box 1344,0,1792,1008 --height 175 --thresh 8
```

### Folhas de Ícones P0 (`4×4` em `1024×1024`, células `256×256`, `#10131A` liso)

Cada folha já está centralizada em células exatas `256×256` (`col*256, lin*256 .. +256`) e testada em `96×96` RGBA com descontaminação de borda (`assets/ui/icons/<categoria>/<id>.png`), seguindo `docs/design/GUIA-DE-ARTE-DARK-FANTASY-MOBILE.md` §3 e §11:

- **`ico-a-actions.jpg` (`--thresh 10`, 16/16):**
  - L1: `action/attack`, `action/defend`, `action/skills`, `action/items`
  - L2: `action/tactical`, `action/flee` (bota + porta ogival), `action/speed_1x`, `action/speed_2x`
  - L3: `ui/gold`, `ui/embers`, `ui/firewood`, `ui/luck`
  - L4: `ui/echoes`, `ui/power`, `ui/hp`, `ui/mp`
- **`ico-b-skills-intent.jpg` (`--thresh 10`, 16/16):**
  - L1: `skill/shield_bash`, `skill/charge`, `skill/bulwark`, `skill/whirlwind`
  - L2: `skill/war_cry`, `skill/second_wind`, `skill/sharpen_blade`, `skill/reinforce_shield`
  - L3: `skill/sharpen_edge`, `intent/attack`, `intent/heavy`, `intent/debuff`
  - L4: `intent/defend`, `intent/coin`, `intent/deadly`, `intent/unknown`
- **`ico-c-status.jpg` (`--thresh 10`, 12/12 + L4 vazia):**
  - L1: `status/defending`, `status/bulwark`, `status/armor_down`, `status/slowed`
  - L2: `status/poison`, `status/weakened`, `status/empowered`, `status/blinded`
  - L3: `status/cursed` (grafite + carmesim, sem roxo), `status/silenced`, `status/disease`, `status/bleeding`
- **`ico-d-weapons-slots.jpg` (`--thresh 7.5`, 15/15 + R4C4 vazio):**
  - L1: `item/sword_and_shield`, `item/worn_longsword`, `item/bone_dagger`, `item/rusty_axe`
  - L2: `item/spiked_mace`, `item/reaper_sickle`, `item/bellringer_blade`, `item/executioner_axe`
  - L3: `item/blood_stiletto`, `slot/weapon`, `slot/armor`, `slot/head`
  - L4: `slot/offhand`, `slot/relic`, `slot/consumable`
- **`ico-e-armor-head.jpg` (`--thresh 9.5`, 14/14 + R4C3..4 vazios):**
  - L1: `item/old_chainmail`, `item/dented_plate`, `item/leather_vest`, `item/reinforced_mail`
  - L2: `item/warden_plate`, `item/soaked_cloak`, `item/bone_cuirass`, `item/penitent_armor`
  - L3: `item/plague_hood` (bico de peste), `item/bellringer_helm`, `item/thorn_crown`, `item/rotten_shield`
  - L4: `item/traveler_lantern` (lanterna de ferro), `item/torn_prayer_book`
- **`ico-f-relics-consum.jpg` (`--thresh 9.5`, 15/15 + R4C4 vazio):**
  - L1: `item/worn_charm`, `item/iron_ring`, `item/sharp_claw`, `item/grave_bell`
  - L2: `item/giant_rat_tooth` (incisivo de rato), `item/glass_eye`, `item/hanged_rope`, `item/penitent_medal`
  - L3: `item/murky_potion`, `item/dirty_ether`, `item/lucky_coin`, `item/firewood`
  - L4: `item/rotting_bread`, `item/rancid_elixir`, `item/sage_smoke`
- **`ico-g-nodes.jpg` (`--thresh 9.5`, 14/14 + R4C3..4 vazios):**
  - L1: `node/start`, `node/battle`, `node/ambush`, `node/elite`
  - L2: `node/chest`, `node/event`, `node/bonfire`, `node/shop`
  - L3: `node/mini_boss`, `node/boss`, `node/fog`, `node/visited`
  - L4: `node/lock`, `node/danger`

### Bibiana Costas (Combate, Estados e Caminhada) & Props de Fogueira (`tools/make_sprite.py`)

```bash
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-combat-sheet.jpg assets/bibiana/sprites/bibiana_warrior_attack.png --box 0,0,448,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-combat-sheet.jpg assets/bibiana/sprites/bibiana_warrior_defend.png --box 448,0,896,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-combat-sheet.jpg assets/bibiana/sprites/bibiana_warrior_hurt.png --box 896,0,1344,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-combat-sheet.jpg assets/bibiana/sprites/bibiana_warrior_item.png --box 1344,0,1792,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-states-sheet.jpg assets/bibiana/sprites/bibiana_warrior_sit_fire.png --box 0,0,448,1008 --height 175 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-states-sheet.jpg assets/bibiana/sprites/bibiana_warrior_defeat.png --box 448,0,896,1008 --height 185 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-states-sheet.jpg assets/bibiana/sprites/bibiana_warrior_victory.png --box 896,0,1344,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-states-sheet.jpg assets/bibiana/sprites/bibiana_warrior_idle_guard.png --box 1344,0,1792,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-walk-sheet.jpg assets/bibiana/sprites/bibiana_warrior_walk_0.png --box 0,0,448,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-walk-sheet.jpg assets/bibiana/sprites/bibiana_warrior_walk_1.png --box 448,0,896,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-walk-sheet.jpg assets/bibiana/sprites/bibiana_warrior_walk_2.png --box 896,0,1344,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira-walk-sheet.jpg assets/bibiana/sprites/bibiana_warrior_walk_3.png --box 1344,0,1792,1008 --height 240 --thresh 8
python tools/make_sprite.py docs/design/refs/props/campfire-props.jpg assets/bibiana/sprites/campfire_lit.png --box 0,0,512,512 --height 110 --thresh 8
python tools/make_sprite.py docs/design/refs/props/campfire-props.jpg assets/bibiana/sprites/campfire_cold.png --box 512,0,1024,512 --height 85 --thresh 8
```

### Tiras Horizontais de UI e VFX (`#10131A` liso, quadros iguais)

- `ui-node-disc.jpg` (`1920×384`): `hframes = 5, vframes = 1` (quadros `384×384`, 5 discos 2:1 de pedra gasta)
- `ui-slot-frame.jpg` (`1024×256`): `hframes = 4, vframes = 1` (quadros `256×256`: `0` comum bronze, `1` incomum aço-azul, `2` raro ouro, `3` maldito sangue)
- `fx-flame-sheet.jpg` (`2048×256`): `hframes = 8, vframes = 1` (quadros `256×256`, fogo ancorado na base)
- `fx-slash-sheet.jpg` (`1536×256`): `hframes = 6, vframes = 1` (`256×256`)
- `fx-coin-flip-sheet.jpg` (`2048×256`): `hframes = 8, vframes = 1` (`256×256`, `0°` a `315°`)
- `fx-block-sheet.jpg` (`1280×256`): `hframes = 5, vframes = 1` (`256×256`)
- `fx-poison-sheet.jpg` (`1536×256`): `hframes = 6, vframes = 1` (`256×256`)

## 3. O que ainda falta gerar (para completar 100% do lote)

Apenas **7 itens P1/estudo** seguem pendentes após o bloqueio semanal de cota (`HTTP 429 RESOURCE_EXHAUSTED`, reset estimado em `~2026-11-30T18:27Z` em `gemini-3.1-flash-image`):

| Arquivo alvo | Tipo / Formato | Fundo / Direção | Fonte do prompt | Âncora de referência |
| --- | --- | --- | --- | --- |
| `docs/design/refs/events/event-fountain-of-ash.jpg` | Evento `16:9` (`1376×768`) | Cenário completo | `GUIA-DE-ARTE-DARK-FANTASY-MOBILE.md` §11.1 | `arena-cidade-rua.jpg` |
| `docs/design/refs/events/event-gallows-tree.jpg` | Evento `16:9` (`1376×768`) | Cenário (3 cordas vazias, sem corpos) | `GUIA-DE-ARTE-DARK-FANTASY-MOBILE.md` §11.1 | `arena-cidade-rua.jpg` |
| `docs/design/refs/events/event-abandoned-armory.jpg` | Evento `16:9` (`1376×768`) | Cenário completo | `GUIA-DE-ARTE-DARK-FANTASY-MOBILE.md` §11.1 | `arena-cidade-rua.jpg` |
| `docs/design/refs/inimigos/lipless_choir.jpg` | Inimigo Estudo #06 (`16:9`) | Figura única, `#10131A` liso, **ESQUERDA** | `PROMPTS-LOTE-HD2D.md` §30 | `09-o-coveiro.jpg` + `reliquary_lady.jpg` (conceito: `06-coro-sem-labios.jpg`) |
| `docs/design/refs/inimigos/calcified_knight.jpg` | Inimigo Estudo #07 (`16:9`) | Figura única, `#10131A` liso, **ESQUERDA** | `PROMPTS-LOTE-HD2D.md` §31 | `09-o-coveiro.jpg` + `reliquary_lady.jpg` (conceito: `07-cavaleiro-calcificado.jpg`) |
| `docs/design/refs/inimigos/trench_crawler.jpg` | Inimigo Estudo #08 (`16:9`) | Figura única, `#10131A` liso, **ESQUERDA** | `PROMPTS-LOTE-HD2D.md` §32 | `09-o-coveiro.jpg` + `reliquary_lady.jpg` (conceito: `08-rastejador-da-vala.jpg`) |
| `docs/design/refs/roaming-boss/crowned_pursuer_sprite.jpg` | Roaming Boss `TASK-054` (`16:9`) | Figura única, `#10131A` liso, **ESQUERDA** | `PROMPTS-LOTE-HD2D.md` §33 | `docs/design/refs/roaming-boss/01-perseguidor-coroado-key-art.jpg` + `09-o-coveiro.jpg` |
| `docs/design/refs/bibiana/bibiana-guerreira-walk-v2-sheet.jpg` | Bibiana Guerreira Costas — Marcha alternada (`16:9`, 4 colunas `hframes=4`) | 4 colunas iguais, `#10131A` liso, costas | `PROMPTS-LOTE-HD2D.md` §34 | `bibiana-guerreira-sheet.jpg` (F-025) |
| `docs/design/refs/bibiana/bibiana-guerreira-strike-sheet.jpg` | Bibiana Guerreira Costas — Sequência de golpe (`16:9`, 4 colunas `hframes=4`) | 4 colunas iguais, `#10131A` liso, costas | `PROMPTS-LOTE-HD2D.md` §35 | `bibiana-guerreira-combat-sheet.jpg` (F-025) |

Entregáveis P0 de **script (sem IA)** previstos em `GUIA-DE-ARTE-DARK-FANTASY-MOBILE.md` (§11.1 e §13 #2), a cargo do código/ferramentas:
- `enemy_bust_<id>` (17 bustos `96×96` / `192` via `tools/make_sprite.py --bust`).
- Reentrega `*_2x` dos sprites existentes a partir dos masters `2752×1536` com `--decontaminate`.
