# Pacote Completo de Prompts em Lote — HD-2D Dark Gótico (`ADR-0042` / `F-024`)

| Campo | Valor |
| --- | --- |
| Versão | 1.0 (2026-11-23) |
| Total de assets | 33 (1 protagonista + 14 inimigos Cenário 1 + 7 arenas `9:16` + 2 NPC/prop + 8 horrores do estudo + 1 Roaming Boss) |
| Versão JSON para automação em lote | `docs/design/prompts-lote-hd2d.json` |
| Regra de originalidade | **GDD §18 / ADR-0042 §4:** zero nomes de jogos, personagens ou artistas nos prompts |
| Mecânica da mecha de cabelo | **Removida por completo (`F-024`):** Bibiana usa cabelo castanho-escuro natural gasto, sem mecha verde/colorida |

## Por que o estilo foi corrigido nesta versão

Os prompts anteriores usavam *"3D character concept"*, que empurrava o gerador para CGI 3D liso. Agora **todos os 33 prompts** usam o bloco de estilo **2.5D HD-2D tático dark gótico artesanal** (pincelada pictórica de alta densidade + silhueta com contorno escuro sutil + grão tátil + chiaroscuro de luar azul-ardósia e arquitetura gótica pesada), traduzindo fielmente o cânone do `ADR-0042` sem citar jogos.

## Regras técnicas para o recortador do Claude (`tools/make_sprite.py`)

- **Sprites (personagens, inimigos, NPC e baú):** proporção `16:9` (`1376×768` ou maior), **figura única** de corpo inteiro ocupando ~82% da altura com margem limpa, **fundo perfeitamente liso azul-preto `#10131A`**, sem chão, sem sombra projetada, sem névoa nos pés, sem moldura e sem texto. Bibiana vira 3/4 para a **direita**; inimigos viram 3/4 para a **esquerda**.
- **Arenas e fundos (`9:16`):** proporção retrato `9:16` (`768×1376` ou maior), **estritamente vazias** (zero personagens, zero monstros, zero UI/texto), com 3 planos de profundidade gótica.
- **Negative prompt universal (sprites):**
```text
multiple figures, turnaround sheet, two views, back view, scenery, background objects, floor, ground, cobblestone, cast shadow, drop shadow, fog around feet, mist, vignette, gradient background, border, frame, text, watermark, logo, chibi, cute, cartoon, anime, cel-shaded neon, glossy 3D CGI plastic, bright saturated colors, green hair streak, dyed hair, cropped feet, cropped weapon
```
- **Negative prompt universal (arenas `9:16`):**
```text
characters, people, warriors, monsters, silhouettes of people, UI, HUD, health bars, buttons, text, numbers, watermark, logo, bright daylight, cheerful green trees, vibrant saturated colors, cartoon, anime, smooth sterile 3D CGI, isometric grid overlay
```

## Índice rápido (33 assets)

| # | Prio | ID | Asset | Proporção | Salvar em |
| --- | :---: | --- | --- | :---: | --- |
| 1 | P1 | `bibiana_guerreira` | Bibiana (Guerreira) | `16:9` | `docs/design/refs/bibiana/bibiana-guerreira.jpg` |
| 2 | P2 | `gravedigger` | O Coveiro (Chefe — ENEMY-06) | `16:9` | `docs/design/refs/inimigos/09-o-coveiro.jpg` |
| 3 | P2 | `infected_citizen` | Cidadão Infectado (ENEMY-01) | `16:9` | `docs/design/refs/inimigos/infected_citizen.jpg` |
| 4 | P2 | `giant_rat` | Rato Grande (ENEMY-02) | `16:9` | `docs/design/refs/inimigos/giant_rat.jpg` |
| 5 | P2 | `carrion_crow` | Corvo Carniceiro (ENEMY-03) | `16:9` | `docs/design/refs/inimigos/carrion_crow.jpg` |
| 6 | P2 | `plague_hound` | Cão de Peste (ENEMY-04) | `16:9` | `docs/design/refs/inimigos/plague_hound.jpg` |
| 7 | P2 | `rotten_executioner` | Carrasco Apodrecido (Elite — ENEMY-05) | `16:9` | `docs/design/refs/inimigos/rotten_executioner.jpg` |
| 8 | P2 | `bell_warden` | Carcereiro do Sino (Mini Boss — ENEMY-07) | `16:9` | `docs/design/refs/inimigos/bell_warden.jpg` |
| 9 | P2 | `bell_ghost` | Sineiro Penado (ENEMY-08) | `16:9` | `docs/design/refs/inimigos/bell_ghost.jpg` |
| 10 | P2 | `wandering_bones` | Ossada Errante (ENEMY-09) | `16:9` | `docs/design/refs/inimigos/wandering_bones.jpg` |
| 11 | P2 | `sewer_slime` | Lodo de Esgoto (ENEMY-10) | `16:9` | `docs/design/refs/inimigos/sewer_slime.jpg` |
| 12 | P2 | `alley_leech` | Sanguessuga de Beco (ENEMY-11) | `16:9` | `docs/design/refs/inimigos/alley_leech.jpg` |
| 13 | P2 | `hanged_man` | Enforcado (ENEMY-12) | `16:9` | `docs/design/refs/inimigos/hanged_man.jpg` |
| 14 | P2 | `stitched_horror` | Costurado (ENEMY-13) | `16:9` | `docs/design/refs/inimigos/stitched_horror.jpg` |
| 15 | P2 | `rat_mother` | Mãe das Ratazanas (Elite — ENEMY-14) | `16:9` | `docs/design/refs/inimigos/rat_mother.jpg` |
| 16 | P3 | `arena_cidade_rua` | Arena Comum — Beco da Cidade Abandonada | `9:16` | `docs/design/refs/arenas/arena-cidade-rua.jpg` |
| 17 | P3 | `arena_cidade_praca` | Arena Elite / Mini Boss — Praça do Sino e da Forca | `9:16` | `docs/design/refs/arenas/arena-cidade-praca.jpg` |
| 18 | P3 | `arena_cidade_chefe` | Arena Chefe — Cemitério e Capela do Coveiro | `9:16` | `docs/design/refs/arenas/arena-cidade-chefe.jpg` |
| 19 | P3 | `arena_fogueira_apagada` | Fogueira Apagada — Ruína Fria (Antes do Galho Seco) | `9:16` | `docs/design/refs/arenas/arena-fogueira-apagada.jpg` |
| 20 | P3 | `arena_fogueira_acesa` | Fogueira Acesa — Refúgio de Brasas | `9:16` | `docs/design/refs/arenas/arena-fogueira-acesa.jpg` |
| 21 | P3 | `arena_loja` | Loja — Alcova do Mercador sob Lampião | `9:16` | `docs/design/refs/arenas/arena-loja.jpg` |
| 22 | P3 | `arena_home_santuario` | Menu Inicial / Santuário — Panorama da Catedral em Ruína | `9:16` | `docs/design/refs/arenas/arena-home-santuario.jpg` |
| 23 | P4 | `shop_keeper` | Mercador da Cidade Abandonada (NPC Loja) | `16:9` | `docs/design/refs/npcs/shop_keeper.jpg` |
| 24 | P4 | `iron_chest` | Baú Gótico de Ferro e Carvalho (Prop) | `16:9` | `docs/design/refs/props/iron_chest.jpg` |
| 25 | P5 | `blind_thurifer` | O Turiferário Cego (Estudo #01) | `16:9` | `docs/design/refs/inimigos/blind_thurifer.jpg` |
| 26 | P5 | `reliquary_lady` | A Dama do Relicário (Estudo #02) | `16:9` | `docs/design/refs/inimigos/reliquary_lady.jpg` |
| 27 | P5 | `wheel_pilgrim` | O Peregrino da Roda (Estudo #03) | `16:9` | `docs/design/refs/inimigos/wheel_pilgrim.jpg` |
| 28 | P5 | `wax_physician` | O Médico da Cera (Estudo #04) | `16:9` | `docs/design/refs/inimigos/wax_physician.jpg` |
| 29 | P5 | `bog_washerwoman` | A Lavadeira do Brejo (Estudo #05) | `16:9` | `docs/design/refs/inimigos/bog_washerwoman.jpg` |
| 30 | P5 | `lipless_choir` | O Coro Sem Lábios (Estudo #06) | `16:9` | `docs/design/refs/inimigos/lipless_choir.jpg` |
| 31 | P5 | `calcified_knight` | O Cavaleiro Calcificado (Estudo #07) | `16:9` | `docs/design/refs/inimigos/calcified_knight.jpg` |
| 32 | P5 | `trench_crawler` | O Rastejador da Vala (Estudo #08) | `16:9` | `docs/design/refs/inimigos/trench_crawler.jpg` |
| 33 | P5 | `crowned_pursuer` | O Perseguidor Coroado (Roaming Boss — TASK-054) | `16:9` | `docs/design/refs/roaming-boss/crowned_pursuer_sprite.jpg` |

---

## Prioridade 1 — Protagonista (Bibiana sem mecha colorida)

### 1. Bibiana (Guerreira) (`bibiana_guerreira`)

- **Salvar em:** `docs/design/refs/bibiana/bibiana-guerreira.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `right`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/bibiana/bibiana-guerreira.jpg assets/bibiana/sprites/bibiana_guerreira.png --box 0,0,1376,768 --height 240`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the RIGHT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: An adult female survivor warrior in a tense, grounded combat-ready stance — weary, determined, grim realistic proportions. Natural short unkempt dark chestnut-brown hair (completely natural dark hair with ZERO dyed streaks or bright highlights), weathered pale face with subtle grime and tired dark eyes, tattered dark wool hood pulled down around her shoulders. She wears dented, blackened-steel half-plate armor over rusted iron chainmail, a long ragged charcoal cloak torn along the hem, worn leather cross-straps, faded dried-blood-red wool under-tunic, scuffed iron gauntlets and muddy steel greaves. Holds a battered round iron-rimmed dark oak shield strapped to her left forearm and grips a plain, notched heavy steel arming sword low in her right hand.
```


---

## Prioridade 2 — Todos os 14 Inimigos do Cenário 1 (`docs/enemies/`)

### 2. O Coveiro (Chefe — ENEMY-06) (`gravedigger`)

- **Salvar em:** `docs/design/refs/inimigos/09-o-coveiro.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/09-o-coveiro.jpg assets/bibiana/sprites/gravedigger.png --box 0,0,1376,768 --height 260`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A towering, gaunt gothic horror gravedigger boss, much taller and broader than a normal human, hunched heavy shoulders and elongated weary neck. Wears a ruined wide-brimmed blackened felt hat pulled low so deep shadow conceals his eyes, revealing only a hollow pale cheekbone and grim jaw; a heavy ankle-length charcoal undertaker coat crusted stiff with dried grave earth and torn at the hem; dirty linen bandages wrapped tightly around huge scarred hands and forearms; heavy mud-caked boots. Grips a colossal rusted iron grave-digger shovel with a wide dirt-clumped blade and thick wooden haft angled forward-left; a small cracked iron lantern glowing with a single weak amber flame hangs from his belt beside a coiled hemp rope and a small rusted bronze bell.
```

### 3. Cidadão Infectado (ENEMY-01) (`infected_citizen`)

- **Salvar em:** `docs/design/refs/inimigos/infected_citizen.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/infected_citizen.jpg assets/bibiana/sprites/infected_citizen.png --box 0,0,1376,768 --height 224`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A deeply unsettling, emaciated adult plague-stricken townsfolk still staggering upright in fever delirium — horrifying because he still almost looks like an ordinary neighbor. Wears a damp, mud-stained tattered linen nightrobe and frayed moth-eaten wool shawl over bare bruised feet; neck swollen with pale grey-yellow plague lesions and dark veins; head tilted at an unnatural angle with milky unfocused sunken eyes and slack open mouth. Shuffles slowly toward the left with both thin trembling arms outstretched slightly forward as if reaching for a desperate embrace.
```

### 4. Rato Grande (ENEMY-02) (`giant_rat`)

- **Salvar em:** `docs/design/refs/inimigos/giant_rat.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/giant_rat.jpg assets/bibiana/sprites/giant_rat.png --box 0,0,1376,768 --height 180`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A grotesque oversized sewer plague rat the size of a large feral hound, coiled low on all fours facing left ready to lunge. Matted wet charcoal-brown fur clumped with sewer filth and bald scarred patches revealing pale mottled diseased skin, hunched bony spine, notched torn ears, milky pale staring eyes, long naked scarred scaly tail curled back, and yellowed needle-sharp incisor fangs bared with dark froth at the snout.
```

### 5. Corvo Carniceiro (ENEMY-03) (`carrion_crow`)

- **Salvar em:** `docs/design/refs/inimigos/carrion_crow.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/carrion_crow.jpg assets/bibiana/sprites/carrion_crow.png --box 0,0,1376,768 --height 195`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A large, sinister plague-fed carrion crow poised aggressively in mid-hop/half-spread wing stance angled toward the left, aiming its beak forward. Ragged oil-black feathers matted with rain and soot, sparse bald grey skin around the neck and skull, cold milky-white eyes, razor-sharp chipped bone-grey beak stained dark crimson-brown at the tip, and gnarled bony talons.
```

### 6. Cão de Peste (ENEMY-04) (`plague_hound`)

- **Salvar em:** `docs/design/refs/inimigos/plague_hound.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/plague_hound.jpg assets/bibiana/sprites/plague_hound.png --box 0,0,1376,768 --height 200`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A starved, feral gothic plague hound in a low tense stalking lunge posture facing left, all four paws visible. Wet matted black-grey fur falling out in mangy patches exposing taut scarred pale-grey skin, prominent ribcage and ridged spine, shredded ears, a heavy rusted iron spike-collar with a snapped short chain dangling from its neck, milky blind-looking eyes, and long foam-flecked jaws parted in a silent snarl of yellowed fangs.
```

### 7. Carrasco Apodrecido (Elite — ENEMY-05) (`rotten_executioner`)

- **Salvar em:** `docs/design/refs/inimigos/rotten_executioner.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/rotten_executioner.jpg assets/bibiana/sprites/rotten_executioner.png --box 0,0,1376,768 --height 248`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A massive, broad-shouldered towering undead executioner standing with slow, patient, terrifying weight. Wears a damp soot-black pointed leather executioner's hood with uneven jagged eye slits and crude black stitches along the seam, a heavy blood-darkened cracked leather butcher apron over corroded blackened iron chainmail, thick rusted manacles dangling from scarred grey-green necrotic forearms, and iron-shod muddy boots. Grips a colossal pitted iron headsman's cleaver-axe stained with dried rust and dark soot, angled heavily forward-left in both hands.
```

### 8. Carcereiro do Sino (Mini Boss — ENEMY-07) (`bell_warden`)

- **Salvar em:** `docs/design/refs/inimigos/bell_warden.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/bell_warden.jpg assets/bibiana/sprites/bell_warden.png --box 0,0,1376,768 --height 256`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A hulking, oppressive plague-quarantine jailer carrying an immense, cracked blackened-bronze bell-shaped iron quarantine cage strapped tightly onto his hunched back with rusted chains (a jagged split runs down the bronze bell cage, with rusted iron prison bars visible). Wears a bolted corroded iron grate mask over his face, heavy soot-black warden coat reinforced with tarnished iron pauldrons, chained gauntlets, and thick mud-crusted boots; a ring of rusted jail keys and dead small bells hang from his waist. Grips a heavy iron bell-clapper war maul in his right hand.
```

### 9. Sineiro Penado (ENEMY-08) (`bell_ghost`)

- **Salvar em:** `docs/design/refs/inimigos/bell_ghost.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/bell_ghost.jpg assets/bibiana/sprites/bell_ghost.png --box 0,0,1376,768 --height 228`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A haunting, gaunt spectral bell-ringer floating upright a few inches off an unseen ground (keep background completely solid flat #10131A with no floor glow). Draped in long shredded ash-grey and blackened-slate funeral robes with hollow shadowed hood concealing a sunken ghostly pale face; long skeletal pale hands clutch a frayed thick bell-tower hemp rope tied to a cracked tarnished-bronze hand bell dripping dark soot. Eerie cold pale-slate rim light catches the tattered floating cloth hems.
```

### 10. Ossada Errante (ENEMY-09) (`wandering_bones`)

- **Salvar em:** `docs/design/refs/inimigos/wandering_bones.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/wandering_bones.jpg assets/bibiana/sprites/wandering_bones.png --box 0,0,1376,768 --height 228`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A grim, heavy-set ancient skeleton warrior shambling slowly forward-left, armored in mismatched rusted medieval iron plate scraps, cracked breastplate over exposed yellowed ribs, tattered grey burial rags clinging to bone joints, and mud-caked iron greaves. Grips a split rotting wooden kite shield bound in corroded iron on one bony arm and a notched heavy rusted broadsword hanging low in the other hand; deep empty black eye sockets with zero cartoon glow.
```

### 11. Lodo de Esgoto (ENEMY-10) (`sewer_slime`)

- **Salvar em:** `docs/design/refs/inimigos/sewer_slime.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/sewer_slime.jpg assets/bibiana/sprites/sewer_slime.png --box 0,0,1376,768 --height 205`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A horrifying, grotesque amorphous mass of living black-olive gothic sewer sludge surging forward-left — strictly grim horror, NEVER cute or cartoon jelly. Thick glossy-wet tar-dark mire and turbid murky filth rippling into heavy creeping pseudopods, with half-dissolved human rib bones, rusted iron grate shards, tangled hair, wet rags, and bloated cloudy pustule bubbles trapped inside the dark viscous body.
```

### 12. Sanguessuga de Beco (ENEMY-11) (`alley_leech`)

- **Salvar em:** `docs/design/refs/inimigos/alley_leech.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/alley_leech.jpg assets/bibiana/sprites/alley_leech.png --box 0,0,1376,768 --height 224`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A predatory, gaunt pale humanoid-parasite hunched low in a shredded wet soot-black alley cloak, poised to pounce toward the left. Elongated bloodless pallid limbs ending in blackened needle-like clutching fingers, wet ragged hood pulled back slightly to reveal an eyeless pale head dominated by a gaping circular lamprey-like leech maw ringed with concentric pale teeth stained with dark dried blood.
```

### 13. Enforcado (ENEMY-12) (`hanged_man`)

- **Salvar em:** `docs/design/refs/inimigos/hanged_man.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/hanged_man.jpg assets/bibiana/sprites/hanged_man.png --box 0,0,1376,768 --height 236`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A deeply disturbing swaying corpse of a forgotten gallows prisoner hovering stiffly with toes pointed downward just barely suspended in mid-air. A thick frayed hemp hangman's noose is knotted tightly around his bruised elongated neck with a short snapped rope tail rising straight up above his head; his pale corpse head lolls sharply sideways at an impossible broken angle, milky dead eyes staring straight at the viewer; wearing tattered damp prisoner linen trousers and torn shirt, thin livid arms hanging limp with blackened fingers.
```

### 14. Costurado (ENEMY-13) (`stitched_horror`)

- **Salvar em:** `docs/design/refs/inimigos/stitched_horror.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/stitched_horror.jpg assets/bibiana/sprites/stitched_horror.png --box 0,0,1376,768 --height 236`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A grotesque patchwork undead abomination crudely sewn together from mismatched human remains, lumbering heavily toward the left. Asymmetric silhouette: one massive bloated muscular pale arm on the left side, one thin spindly arm on the right with a rusted butcher blade lashed directly onto the forearm with wire; coarse thick black surgical thread stitching mismatched skin tones across the torso, shoulder and sealing the mouth completely shut; two mismatched eyes of different sizes staring unevenly; ragged blood-stained burlap loincloth.
```

### 15. Mãe das Ratazanas (Elite — ENEMY-14) (`rat_mother`)

- **Salvar em:** `docs/design/refs/inimigos/rat_mother.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/rat_mother.jpg assets/bibiana/sprites/rat_mother.png --box 0,0,1376,768 --height 240`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A colossal, nightmarish bloated brood-mother plague rat the size of a cart, hunched heavily facing left. Saggy wet matted charcoal fur stretched over grotesque ulcerated pale tumours and knotted scars along her flanks; half a dozen smaller starved wet rats clambering and peeking out from folds along her humped back; clusters of too many small pale gleaming eyes blinking across her scarred snout and brow, long tangled naked tails trailing behind, stained yellowed fangs bared.
```


---

## Prioridade 3 — 7 Fundos Pintados de Arena e Telas (`9:16` vazios)

### 16. Arena Comum — Beco da Cidade Abandonada (`arena_cidade_rua`)

- **Salvar em:** `docs/design/refs/arenas/arena-cidade-rua.jpg`
- **Formato:** `9:16` (`768x1376`+) | **Direção:** `none`

```text
Masterpiece hand-crafted 2.5D HD-2D dark-gothic tactical RPG battle stage background illustration, rich artisanal painterly brushwork with crisp weathered stone masonry and subtle high-bit tactical diorama texture (NOT smooth sterile 3D CGI, NOT cartoon, NOT bright fantasy, NOT glossy neon). Vertical 9:16 mobile portrait framing with strong three-layer spatial depth: darkened crumbling stone foreground framing bottom corners, crisp rain-slicked cobblestone or stepped stone terrace combat stage across the center third, and towering oppressive gothic cathedral architecture (pointed ogival arches, slender needle spires, wrought-iron fences and gates, weathered gargoyles, cracked masonry buttresses) receding into dense cold slate-blue fog and pitch-black night shadow at the top. Dramatic chiaroscuro: cold pale silver-blue moonlight shafts cutting deep shadows, strictly muted charcoal-slate-umber palette. STRICTLY EMPTY STAGE: ZERO characters, ZERO monsters, ZERO human silhouettes, ZERO UI, ZERO text, ZERO watermarks.

SCENE: An empty rain-slicked cobblestone alleyway and stepped stone bridge inside a plague-abandoned gothic city at night. Foreground: dark shadowed crumbling stone parapet corners and faint creeping low fog. Midground stage: open wet uneven flagstones with shallow dark puddles reflecting cold slate-blue moonlight, flanked by crooked rusted wrought-iron fences. Background: towering narrow gothic townhouses, pointed stone archways, iron street grates, and distant cathedral needle spires disappearing into dense mist; ONE solitary crooked wrought-iron street lantern flickers with dim warm amber light in the mid-left distance.
```

### 17. Arena Elite / Mini Boss — Praça do Sino e da Forca (`arena_cidade_praca`)

- **Salvar em:** `docs/design/refs/arenas/arena-cidade-praca.jpg`
- **Formato:** `9:16` (`768x1376`+) | **Direção:** `none`

```text
Masterpiece hand-crafted 2.5D HD-2D dark-gothic tactical RPG battle stage background illustration, rich artisanal painterly brushwork with crisp weathered stone masonry and subtle high-bit tactical diorama texture (NOT smooth sterile 3D CGI, NOT cartoon, NOT bright fantasy, NOT glossy neon). Vertical 9:16 mobile portrait framing with strong three-layer spatial depth: darkened crumbling stone foreground framing bottom corners, crisp rain-slicked cobblestone or stepped stone terrace combat stage across the center third, and towering oppressive gothic cathedral architecture (pointed ogival arches, slender needle spires, wrought-iron fences and gates, weathered gargoyles, cracked masonry buttresses) receding into dense cold slate-blue fog and pitch-black night shadow at the top. Dramatic chiaroscuro: cold pale silver-blue moonlight shafts cutting deep shadows, strictly muted charcoal-slate-umber palette. STRICTLY EMPTY STAGE: ZERO characters, ZERO monsters, ZERO human silhouettes, ZERO UI, ZERO text, ZERO watermarks.

SCENE: An empty oppressive gothic execution plaza paved in cracked wet stone slabs beneath a brooding stone bell-tower with a massive cracked bronze bell hanging silently in its pointed arch. Foreground: weathered stone steps and rusted iron chains framing bottom edges. Midground stage: broad open circular stone courtyard slick with rain, an old dark timber gallows frame off to the left edge with frayed hanging ropes, wrought-iron quarantine cages stacked by the outer wall. Background: looming cathedral buttresses and tall iron spikes fading into cold blue-black storm clouds and drifting ash; one distant pale moonlight shaft cuts down onto the empty center plaza.
```

### 18. Arena Chefe — Cemitério e Capela do Coveiro (`arena_cidade_chefe`)

- **Salvar em:** `docs/design/refs/arenas/arena-cidade-chefe.jpg`
- **Formato:** `9:16` (`768x1376`+) | **Direção:** `none`

```text
Masterpiece hand-crafted 2.5D HD-2D dark-gothic tactical RPG battle stage background illustration, rich artisanal painterly brushwork with crisp weathered stone masonry and subtle high-bit tactical diorama texture (NOT smooth sterile 3D CGI, NOT cartoon, NOT bright fantasy, NOT glossy neon). Vertical 9:16 mobile portrait framing with strong three-layer spatial depth: darkened crumbling stone foreground framing bottom corners, crisp rain-slicked cobblestone or stepped stone terrace combat stage across the center third, and towering oppressive gothic cathedral architecture (pointed ogival arches, slender needle spires, wrought-iron fences and gates, weathered gargoyles, cracked masonry buttresses) receding into dense cold slate-blue fog and pitch-black night shadow at the top. Dramatic chiaroscuro: cold pale silver-blue moonlight shafts cutting deep shadows, strictly muted charcoal-slate-umber palette. STRICTLY EMPTY STAGE: ZERO characters, ZERO monsters, ZERO human silhouettes, ZERO UI, ZERO text, ZERO watermarks.

SCENE: An empty terraced gothic cemetery courtyard before a ruined pointed-arch stone mortuary chapel under cold pale moonlight. Foreground: darkened crooked wrought-iron cemetery gates and dead leafless twisted briars at bottom corners. Midground stage: open wet mud-and-flagstone funeral terrace with a freshly dug shallow open grave and mound of wet earth off to the side, flanked by leaning mossy gothic tombstones and iron lanterns. Background: towering ruined gothic chapel facade with shattered rose window, pointed spires, gargoyles, and thick cold ground fog swallowing the horizon.
```

### 19. Fogueira Apagada — Ruína Fria (Antes do Galho Seco) (`arena_fogueira_apagada`)

- **Salvar em:** `docs/design/refs/arenas/arena-fogueira-apagada.jpg`
- **Formato:** `9:16` (`768x1376`+) | **Direção:** `none`

```text
Masterpiece hand-crafted 2.5D HD-2D dark-gothic tactical RPG battle stage background illustration, rich artisanal painterly brushwork with crisp weathered stone masonry and subtle high-bit tactical diorama texture (NOT smooth sterile 3D CGI, NOT cartoon, NOT bright fantasy, NOT glossy neon). Vertical 9:16 mobile portrait framing with strong three-layer spatial depth: darkened crumbling stone foreground framing bottom corners, crisp rain-slicked cobblestone or stepped stone terrace combat stage across the center third, and towering oppressive gothic cathedral architecture (pointed ogival arches, slender needle spires, wrought-iron fences and gates, weathered gargoyles, cracked masonry buttresses) receding into dense cold slate-blue fog and pitch-black night shadow at the top. Dramatic chiaroscuro: cold pale silver-blue moonlight shafts cutting deep shadows, strictly muted charcoal-slate-umber palette. STRICTLY EMPTY STAGE: ZERO characters, ZERO monsters, ZERO human silhouettes, ZERO UI, ZERO text, ZERO watermarks.

SCENE: An empty sheltered gothic stone ruin alcove at night, cold and silent. In the lower-center stone hearth sits an unlit cold firepit of charred black wood, dead grey ashes, and wet stones (ZERO fire, ZERO glowing embers). Cracked pointed gothic archway and broken vaulted ceiling open to cold pale slate-blue moonlight and drifting mist outside; weathered stone benches and rusted iron sconces along the damp walls.
```

### 20. Fogueira Acesa — Refúgio de Brasas (`arena_fogueira_acesa`)

- **Salvar em:** `docs/design/refs/arenas/arena-fogueira-acesa.jpg`
- **Formato:** `9:16` (`768x1376`+) | **Direção:** `none`

```text
Masterpiece hand-crafted 2.5D HD-2D dark-gothic tactical RPG battle stage background illustration, rich artisanal painterly brushwork with crisp weathered stone masonry and subtle high-bit tactical diorama texture (NOT smooth sterile 3D CGI, NOT cartoon, NOT bright fantasy, NOT glossy neon). Vertical 9:16 mobile portrait framing with strong three-layer spatial depth: darkened crumbling stone foreground framing bottom corners, crisp rain-slicked cobblestone or stepped stone terrace combat stage across the center third, and towering oppressive gothic cathedral architecture (pointed ogival arches, slender needle spires, wrought-iron fences and gates, weathered gargoyles, cracked masonry buttresses) receding into dense cold slate-blue fog and pitch-black night shadow at the top. Dramatic chiaroscuro: cold pale silver-blue moonlight shafts cutting deep shadows, strictly muted charcoal-slate-umber palette. STRICTLY EMPTY STAGE: ZERO characters, ZERO monsters, ZERO human silhouettes, ZERO UI, ZERO text, ZERO watermarks.

SCENE: An empty sheltered gothic stone ruin alcove at night illuminated solely by a solitary crackling wood campfire burning in the lower-center stone hearth. Warm amber-orange firelight and tiny rising embers cast long dramatic dancing shadows across the cracked damp stonework and pointed gothic archway, contrasting starkly against the freezing pitch-black and slate-blue misty graveyard night visible beyond the broken stone arches.
```

### 21. Loja — Alcova do Mercador sob Lampião (`arena_loja`)

- **Salvar em:** `docs/design/refs/arenas/arena-loja.jpg`
- **Formato:** `9:16` (`768x1376`+) | **Direção:** `none`

```text
Masterpiece hand-crafted 2.5D HD-2D dark-gothic tactical RPG battle stage background illustration, rich artisanal painterly brushwork with crisp weathered stone masonry and subtle high-bit tactical diorama texture (NOT smooth sterile 3D CGI, NOT cartoon, NOT bright fantasy, NOT glossy neon). Vertical 9:16 mobile portrait framing with strong three-layer spatial depth: darkened crumbling stone foreground framing bottom corners, crisp rain-slicked cobblestone or stepped stone terrace combat stage across the center third, and towering oppressive gothic cathedral architecture (pointed ogival arches, slender needle spires, wrought-iron fences and gates, weathered gargoyles, cracked masonry buttresses) receding into dense cold slate-blue fog and pitch-black night shadow at the top. Dramatic chiaroscuro: cold pale silver-blue moonlight shafts cutting deep shadows, strictly muted charcoal-slate-umber palette. STRICTLY EMPTY STAGE: ZERO characters, ZERO monsters, ZERO human silhouettes, ZERO UI, ZERO text, ZERO watermarks.

SCENE: An empty gothic stone archway alcove converted into a grim makeshift scavengers' trading stall in a dark plague city alley. In the midground stands a battered dark-oak merchant counter cluttered with dusty glass potion phials, rusted iron weapons, dried herbs, tarnished bronze scales, and bound leather satchels, lit from above by ONE hanging wrought-iron oil lantern glowing warm dim amber; heavy gothic iron shutters, wet cobblestones, and dark misty street arches recede into cold shadow behind.
```

### 22. Menu Inicial / Santuário — Panorama da Catedral em Ruína (`arena_home_santuario`)

- **Salvar em:** `docs/design/refs/arenas/arena-home-santuario.jpg`
- **Formato:** `9:16` (`768x1376`+) | **Direção:** `none`

```text
Masterpiece hand-crafted 2.5D HD-2D dark-gothic tactical RPG battle stage background illustration, rich artisanal painterly brushwork with crisp weathered stone masonry and subtle high-bit tactical diorama texture (NOT smooth sterile 3D CGI, NOT cartoon, NOT bright fantasy, NOT glossy neon). Vertical 9:16 mobile portrait framing with strong three-layer spatial depth: darkened crumbling stone foreground framing bottom corners, crisp rain-slicked cobblestone or stepped stone terrace combat stage across the center third, and towering oppressive gothic cathedral architecture (pointed ogival arches, slender needle spires, wrought-iron fences and gates, weathered gargoyles, cracked masonry buttresses) receding into dense cold slate-blue fog and pitch-black night shadow at the top. Dramatic chiaroscuro: cold pale silver-blue moonlight shafts cutting deep shadows, strictly muted charcoal-slate-umber palette. STRICTLY EMPTY STAGE: ZERO characters, ZERO monsters, ZERO human silhouettes, ZERO UI, ZERO text, ZERO watermarks.

SCENE: A monumental empty panoramic view looking up a long rain-slicked gothic stone causeway ascending toward a colossal decaying plague-city cathedral under a pale clouded night sky. Multi-tiered stepped stonework terraces, rows of crooked wrought-iron street lamps (only two faintly lit with dying amber glow), flying buttresses, pointed gothic spires, and drifting rain and mist creating vast melancholic architectural depth; leave clean dark shadowed negative space in the upper sky for a game title.
```


---

## Prioridade 4 — NPC e Prop de Cena

### 23. Mercador da Cidade Abandonada (NPC Loja) (`shop_keeper`)

- **Salvar em:** `docs/design/refs/npcs/shop_keeper.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/npcs/shop_keeper.jpg assets/bibiana/sprites/shop_keeper.png --box 0,0,1376,768 --height 230`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A hunched, secretive plague-city scavenger merchant standing in a wary cautious stance. Wears a heavy layered rain-soaked charcoal cloak with deep tattered hood shadowing his upper face (only a weathered bearded chin visible), a huge strapped wooden packframe overflowing with hanging glass vials, rolled dry firewood twigs, tarnished brass trinkets, and coiled rope; holds a small dim amber hooded iron lantern in one gloved hand and a knotted wooden walking staff in the other.
```

### 24. Baú Gótico de Ferro e Carvalho (Prop) (`iron_chest`)

- **Salvar em:** `docs/design/refs/props/iron_chest.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/props/iron_chest.jpg assets/bibiana/sprites/iron_chest.png --box 0,0,1376,768 --height 170`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A single heavy medieval gothic reliquary treasure chest seen in crisp three-quarter view angled slightly left, closed and intimidating. Built from damp splintered dark-charcoal oak planks bound in thick hammered blackened wrought-iron straps, rusted corner spikes, a heavy corroded iron padlock and short draped chain, with faint tarnished antique-gold keyhole filigree as the only subtle metallic warmth.
```


---

## Prioridade 5 — 8 Horrores do Estudo (`TASK-051`) + Roaming Boss (`TASK-054`) em Sprite Único

### 25. O Turiferário Cego (Estudo #01) (`blind_thurifer`)

- **Salvar em:** `docs/design/refs/inimigos/blind_thurifer.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/blind_thurifer.jpg assets/bibiana/sprites/blind_thurifer.png --box 0,0,1376,768 --height 236`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A tall, skeletal gothic liturgical penitent wearing a nailed corroded iron funeral mask with vertical slits over hollow darkness, tattered soot-stained clerical tunic over exposed gaunt ribs, and dirty leg wrappings. Swings a heavy blackened-bronze spiked censer attached to a long rusted iron chain from his right hand, with faint dying amber embers visible inside the censer vents.
```

### 26. A Dama do Relicário (Estudo #02) (`reliquary_lady`)

- **Salvar em:** `docs/design/refs/inimigos/reliquary_lady.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/reliquary_lady.jpg assets/bibiana/sprites/reliquary_lady.png --box 0,0,1376,768 --height 244`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A tall, eerie aristocratic gothic mourning figure in a stiff triangular floor-length tattered black-brown funeral gown and tall corroded verdigris-bronze reliquary crown over a veiled porcelain face. Her torso opens into a dark barred bronze reliquary cage window from which a cluster of pale thin skeletal hands reach desperately outward toward the left.
```

### 27. O Peregrino da Roda (Estudo #03) (`wheel_pilgrim`)

- **Salvar em:** `docs/design/refs/inimigos/wheel_pilgrim.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/wheel_pilgrim.jpg assets/bibiana/sprites/wheel_pilgrim.png --box 0,0,1376,768 --height 236`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A gaunt condemned penitent hunched forward under a massive splintered oak-and-rusted-iron execution cartwheel strapped directly behind his shoulders like a dark halo. His thin bandaged arms are twisted backward and bound with coarse rope to the wooden spokes, wearing ragged loin strips and heavy rusted iron shin greaves over bare dirty feet.
```

### 28. O Médico da Cera (Estudo #04) (`wax_physician`)

- **Salvar em:** `docs/design/refs/inimigos/wax_physician.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/wax_physician.jpg assets/bibiana/sprites/wax_physician.png --box 0,0,1376,768 --height 236`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A hunched gothic plague apothecary whose shoulders, hood, and cracked curved beak-mask are fused beneath a massive dripping mantle of yellowed melted tallow wax. A dozen stubby crooked wax candles sprout from his hunched back and shoulders with tiny dim warm amber flames; wears an oiled dark-leather trench coat and grips a large tarnished-brass syringe bolted to a serrated steel bone-saw.
```

### 29. A Lavadeira do Brejo (Estudo #05) (`bog_washerwoman`)

- **Salvar em:** `docs/design/refs/inimigos/bog_washerwoman.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/bog_washerwoman.jpg assets/bibiana/sprites/bog_washerwoman.png --box 0,0,1376,768 --height 232`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A tall unsettling swamp apparition bent forward almost 90 degrees at the waist beneath a soaked tattered grey-mire burial shroud trailing dead reeds. Four thin pale corpse arms emerge from beneath the damp cloak to wring a dripping tangled rope of hair and roots; a rusted iron chain and octagonal cage lantern with a weak amber core dangle down from her hooded neck.
```

### 30. O Coro Sem Lábios (Estudo #06) (`lipless_choir`)

- **Salvar em:** `docs/design/refs/inimigos/lipless_choir.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/lipless_choir.jpg assets/bibiana/sprites/lipless_choir.png --box 0,0,1376,768 --height 248`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A towering, slender cathedral horror in layered charcoal clerical vestments with symmetrical fan-shaped wings of broken tarnished-bronze church organ pipes bolted across its shoulders. Its oversized head consists of three fused smooth pale porcelain masks with zero mouths and hollow eye sockets weeping thin black soot streaks.
```

### 31. O Cavaleiro Calcificado (Estudo #07) (`calcified_knight`)

- **Salvar em:** `docs/design/refs/inimigos/calcified_knight.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/calcified_knight.jpg assets/bibiana/sprites/calcified_knight.png --box 0,0,1376,768 --height 244`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A towering gothic plate-armored citadel sentinel whose own skeleton has overgrown like jagged pale bone coral, bursting outward through cracked tarnished-steel pauldrons, cuirass, and knee guards. His right gauntlet is fused solidly in bone and rusted steel to a heavy greatsword; his open medieval armet visor frames a pitch-black hollow void holding a single tiny dim orange ember.
```

### 32. O Rastejador da Vala (Estudo #08) (`trench_crawler`)

- **Salvar em:** `docs/design/refs/inimigos/trench_crawler.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/inimigos/trench_crawler.jpg assets/bibiana/sprites/trench_crawler.png --box 0,0,1376,768 --height 200`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A terrifying quadruped grave-pit horror arched in an inverted spider-like bridge on four overly long bandaged pale limbs, facing left. A splintered rotted wooden coffin lid is strapped across its arched back with rusted iron bands; its gaunt pale head hangs completely upside-down beneath its chest staring forward with pinprick pale eyes.
```

### 33. O Perseguidor Coroado (Roaming Boss — TASK-054) (`crowned_pursuer`)

- **Salvar em:** `docs/design/refs/roaming-boss/crowned_pursuer_sprite.jpg`
- **Formato:** `16:9` (`1376x768`+) | **Direção:** `left`
- **Integração Claude (`make_sprite.py`):** `python tools/make_sprite.py docs/design/refs/roaming-boss/crowned_pursuer_sprite.jpg assets/bibiana/sprites/crowned_pursuer.png --box 0,0,1376,768 --height 268`

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite illustration, rich high-bit painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult gothic medieval plague-city proportions, heavy battered weathered materials (oxidized hammered iron, damp soot-stained wool, cracked leather, dried grave mud, corroded bronze, aged bone). Dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and deep shadowed folds, strictly muted desaturated charcoal, wet slate, bone-ash and dried-rust palette.

FORMAT (STRICT FOR AUTOMATED SPRITE CUTOUT): SINGLE FULL-BODY FIGURE ONLY, standing in three-quarter view turned slightly to the LEFT, head-to-toe completely inside frame occupying ~82% of image height with generous clean margin on all four sides (nothing cropped). COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO gradient, NO vignette, NO floor, NO ground plane, NO cast shadow under feet, NO mist wisps, NO scenery, NO frame, NO border, NO text, NO watermark.

SUBJECT: A colossal, terrifying 2.75-meter undead-corrupted dark warlord standing in imposing three-quarter combat stance facing left. Wears a tall vertical 5-spired blackened wrought-iron gothic crown-helm with pitch-black T-visor void and corroded cheek flaps exposing a rotting greyish-green jaw and sinewy neck. Clad in pitch-black fluted gothic plate armor encrusted with sculpted human skulls (massive twin-horned skull left pauldron, carved skull right pauldron, skull collar, waist chain of skulls, skull kneeguard), actively crumbling, rusted, and splitting apart across the torso and limbs to expose oozing greyish-green rotting necrotic flesh, broken pale ribs, dark tendons, and shredded black funeral cloth. Right gauntlet grips a colossal brutal six-flanged blackened-iron war mace with chained haft; left gauntlet grips a heavy broadsword VIOLENTLY BROKEN IN HALF AT MID-BLADE with a jagged diagonal fracture and gleaming razor-sharp silver steel cutting edge.
```

---

## Prioridade 6 — Animações dedicadas de caminhada e golpe da Bibiana (`F-025`, `ADR-0061`)

### 34. Bibiana Guerreira Costas — Ciclo Real de Caminhada/Marcha (`bibiana_warrior_walk_v2`)

- **Salvar em:** `docs/design/refs/bibiana/bibiana-guerreira-walk-v2-sheet.jpg`
- **Formato:** `16:9` (`1792x1008`, 4 colunas iguais de `448 px`, `hframes = 4`) | **Direção:** `de costas (3/4 para cima-direita)`
- **Âncora obrigatória:** anexar `docs/design/refs/bibiana/bibiana-guerreira-sheet.jpg` e `bibiana-guerreira-combat-sheet.jpg`.
- **Integração (`make_sprite.py --thresh 8`):** quadros `0..3` -> `assets/bibiana/sprites/bibiana_warrior_walk_{0..3}.png` (`--height 240`).

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite animation sheet, rich painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult proportions, dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light from upper-right and muted desaturated soot black, tarnished steel, wet umber leather and faded dark crimson-grey cloth.
GODOT SPRITE SHEET LAYOUT (STRICT — 16:9 WIDESCREEN, 1 ROW x 4 EQUAL HORIZONTAL COLUMNS):
Four separate full-body animation frames of the EXACT SAME armored female survivor seen from BEHIND in three-quarter back view facing toward the upper-right, aligned side-by-side in four equal vertical columns on one consistent horizontal baseline, generous empty margin around each pose. COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO grid lines, NO borders, NO ground, NO shadow, NO mist, NO text.
CHARACTER CONSISTENCY: Same adult woman warrior from reference: short messy natural dark chestnut-brown hair (ZERO dyed streaks), blackened-steel pauldrons and cuirass back-plate, tattered charcoal-black travel cloak torn at the hem, battered round dark-oak iron-rimmed shield strapped to left arm, notched steel longsword held in right hand, muddy leather-and-iron greaves.
EXACT 4-FRAME ALTERNATING WALK CYCLE (LEFT TO RIGHT — DISTINCT LEG & CLOAK SILHOUETTES IN EVERY COLUMN):
1. Column 1 (Contact A): Left leg striding noticeably forward with knee bent, right back heel lifted high off the ground showing the boot sole, torso leaning forward slightly, right sword arm swung forward low, cloak swinging backward-left.
2. Column 2 (Passing A): Body rising slightly higher over the planted left foot while the right knee bends sharply forward in mid-swing past the calf, cloak trailing tighter behind.
3. Column 3 (Contact B): Mirror stride — RIGHT leg striding noticeably forward with knee bent, left heel lifted high off the ground behind, left shield arm pushed forward slightly while right sword arm swings back, cloak billowing to the right.
4. Column 4 (Passing B): Body rising slightly higher over the planted right foot while the left knee bends forward in mid-swing past the shin, cloak settling back into rhythm.
Negative: identical leg pose across frames, static feet, sliding pose, grid lines, dividing lines, floor, cast shadow, text, dyed hair, chibi, cartoon, glossy 3D plastic.
```

### 35. Bibiana Guerreira Costas — Sequência de Golpe em Arco (`bibiana_warrior_strike`)

- **Salvar em:** `docs/design/refs/bibiana/bibiana-guerreira-strike-sheet.jpg`
- **Formato:** `16:9` (`1792x1008`, 4 colunas iguais de `448 px`, `hframes = 4`) | **Direção:** `de costas (3/4 para cima-direita)`
- **Âncora obrigatória:** anexar `docs/design/refs/bibiana/bibiana-guerreira-combat-sheet.jpg`.
- **Integração (`make_sprite.py --thresh 8`):** quadros `0..3` -> `bibiana_warrior_dash.png`, `bibiana_warrior_windup.png`, `bibiana_warrior_cleave.png`, `bibiana_warrior_recover.png` (`--height 240`).

```text
Masterpiece hand-crafted 2.5D dark-fantasy tactical RPG character sprite animation sheet, rich painterly brushwork with crisp subtle dark ink-outlined silhouette and fine tactile grain (NOT smooth 3D CGI, NOT glossy plastic render, NOT anime, NOT chibi, NOT cartoon). Grounded adult proportions, dramatic chiaroscuro lighting with cold pale slate-blue moonlight rim light and muted soot black, tarnished steel, wet umber leather and faded dark crimson-grey cloth.
GODOT SPRITE SHEET LAYOUT (STRICT — 16:9 WIDESCREEN, 1 ROW x 4 EQUAL HORIZONTAL COLUMNS):
Four separate full-body melee strike keyframes of the EXACT SAME armored female survivor seen from BEHIND in three-quarter back view facing upper-right, aligned side-by-side in four equal vertical columns on one consistent baseline, generous empty margin around blades and cloak. COMPLETELY FLAT SOLID UNIFORM DARK BLUE-BLACK BACKGROUND (#10131A) everywhere — NO slash VFX trails, NO grid lines, NO borders, NO ground, NO shadow, NO mist, NO text.
CHARACTER CONSISTENCY: Same adult woman warrior from reference: short messy natural dark chestnut-brown hair (ZERO dyed streaks), blackened-steel armor, tattered charcoal cloak, battered round wooden shield on left arm, steel longsword in right hand.
EXACT 4-FRAME MELEE ATTACK SEQUENCE (LEFT TO RIGHT):
1. Column 1 (Dash / Step-In): Low aggressive sprint lunge forward, torso crouched forward, left knee driving hard, sword pulled tightly back beside right hip, cloak streaming horizontally behind.
2. Column 2 (High Windup): Front foot planted wide, torso coiled back slightly to the right, BOTH shoulders twisted, longsword raised high above right shoulder poised to strike down.
3. Column 3 (Follow-Through Cleave): Explosive forward diagonal lunge with full shoulder rotation, right arm extended far upper-left after a heavy downward-left diagonal slash, shield flared behind for counterweight, cloak whipping sideways.
4. Column 4 (Braced Recovery): Pulling weight back onto rear leg, sword sweeping down into low diagonal guard ready to step back.
Negative: sword slash FX arcs, energy trails, front view, duplicate poses, cropped sword tip, grid lines, dividing lines, floor, cast shadow, text, dyed hair, chibi, cartoon, glossy 3D plastic.
```
