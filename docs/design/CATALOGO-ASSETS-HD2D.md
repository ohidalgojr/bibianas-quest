# Catálogo de Assets 2D HD-2D Organizados e Auditados (`ADR-0042` / `F-024`)

| Campo | Valor |
| --- | --- |
| Atualizado em | 2026-11-25 |
| Total organizado | 43 pranchas (1 Bibiana retrato + 4 pranchas Bibiana 4 poses `16:9` + 14 Inimigos Cenário 1 + 5 Inimigos Estudo + 2 NPCs + 4 Props + 8 Arenas/Cenários `9:16` + 4 Folhas de ícones `4×4` `1024×1024` + 1 Textura UI tileável `ui-noise-stone.jpg`) |
| Origem | Arquivos brutos sem nome movidos de `assets/` (zero sobras soltas em `assets/`) e pranchas geradas pelo Guia de Arte (`docs/design/GUIA-DE-ARTE-DARK-FANTASY-MOBILE.md`) |
| Mecha colorida | Removida (`F-024`); `bibiana-guerreira.jpg` usa cabelo castanho-escuro natural |

## 1. Mapa completo dos 43 assets

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

## 3. O que ainda falta gerar (para completar 100% do lote)

As especificações e prompts estão em `docs/design/PROMPTS-LOTE-HD2D.md` (§30–33) e `docs/design/GUIA-DE-ARTE-DARK-FANTASY-MOBILE.md` (§11):

1. **Guia de Arte §11 restantes (`503 UNAVAILABLE` em `gemini-3.1-flash-image` durante esta janela):** `ico-e-armor-head`, `ico-f-relics-consum`, `ico-g-nodes`, `bg-defeat`, `map-strip-01..03`, `coin-heads/tails`, `ui-node-disc`, `ui-panel-stone`, `ui-slot-frame`, `ui-banner-ribbon`, `ui-frame-illustration`, `ui-divider`, 3 folhas de poses/animações de costas da Bibiana (`combat`, `states`, `walk`), folhas de FX (`fx-flame`, `fx-slash`, `fx-coin-flip`, `fx-block`, `fx-crit-burst`, `fx-poison`), `sanctuary-interior`, overlays/props de mapa (`map-fg-ironfence`, `map-mist-band`, `road-cobble-tile`, `campfire-props`) e 6 ilustrações de eventos.
2. **3 inimigos restantes do estudo (`TASK-051`):** `lipless_choir` (O Coro Sem Lábios), `calcified_knight` (O Cavaleiro Calcificado), `trench_crawler` (O Rastejador da Vala).
3. **1 Roaming Boss em sprite único (`TASK-054`):** `crowned_pursuer` (O Perseguidor Coroado — as 5 pranchas de key art/turnaround/diorama já estão em `docs/design/refs/roaming-boss/`).
