# Prompts do Gemini: Bibiana e O Coveiro (para virarem sprites)

Para o Orlando colar no Gemini (Nano Banana). Sem citar jogos nem artistas (GDD §18). Os descritores seguem o que já funcionou nas pranchas de `docs/design/refs/inimigos/`.

## Regras de formato (valem para os dois)

- **Uma figura só**, corpo inteiro, de pé, em 3/4, **sem a vista de costas** (diferente das pranchas anteriores, que tinham duas vistas).
- **Fundo liso escuro e uniforme** (quase preto azulado), sem cenário, sem chão desenhado, sem sombra no chão, sem moldura, sem texto, sem marca d'água.
- Figura inteira dentro da imagem, com margem, **sem nada cortado**, ocupando cerca de 85% da altura.
- Proporção horizontal 16:9 (1376x768) ou maior. Se o Gemini gerar mais de uma opção, salvar todas.

## 1. Bibiana (guerreira)

Salvar como `docs/design/refs/bibiana/bibiana-guerreira.jpg`.

```
Concept render of a single character, full body, standing, three-quarter view turned slightly to the right, neutral combat-ready stance, on a flat plain dark blue-black background with no scenery, no floor, no cast shadow, no text.
Subject: an adult woman, a weary survivor, grim and realistic proportions (not chibi, not cartoon, not cute). Short chestnut-brown hair, cropped and unkempt, hood pulled down on her shoulders. ONE thick lock of hair on the front-left side of her head is pure bright lime green (#00FF40), flat saturated colour with no shading variation, it is the only saturated colour in the whole image.
She wears worn dark steel half-plate armor over blackened mail, a tattered long dark cloak torn at the hem, leather straps, scuffed gauntlets and greaves, a battered round wooden shield with an iron rim on her left arm and a plain heavy arming sword held low in her right hand. Muted, desaturated palette: slate grey steel, soot black, dried-mud brown, faded dark red cloth. Detail of dents, rust, dirt, torn cloth.
Style: painterly dark-fantasy 3D character concept, crisp readable silhouette, strong rim light from the upper right, soft cool light, gritty textures, high detail, game-ready character turnaround quality, gothic and melancholic mood.
```

Por que o fio verde-limão: o jogo troca a cor da mecha em 9 estágios de Poder (GDD §9: castanho, verde claro, azul claro, azul escuro, vermelho claro, vermelho escuro, roxo claro, roxo escuro, branco). O agente recolore só esses pixels por código, a partir de uma única prancha.

## 2. O Coveiro (chefe da Cidade Abandonada)

Salvar como `docs/design/refs/inimigos/09-o-coveiro.jpg`. Ficha em `docs/enemies/ENEMY-06-o-coveiro.md` (a fantasia: "o homem que enterrou a cidade, ainda com a pá; ele não corre, ele cava").

```
Concept render of a single character, full body, standing, three-quarter view turned slightly to the left, on a flat plain dark blue-black background with no scenery, no floor, no cast shadow, no text.
Subject: a towering gaunt gravedigger, a dark gothic boss, much taller and broader than a normal person, hunched shoulders and a long tired neck, adult and menacing (not cute, not cartoon). He wears a wide-brimmed ruined black hat that hides most of his face, with only a hollow cheek and a faint pale jaw visible, a very long heavy coat stiff with dried grave soil, torn at the hem, wrapped bandages on his huge hands and forearms, heavy muddy boots. He grips a gigantic rusted shovel with a broad wide blade, pole as thick as a human arm, wet soil clumping on the blade; a small cracked lantern with a weak amber flame hangs from his belt, and a rope with a rusted bell is tied at his hip. Faint wisps of cold mist at his feet area are not allowed; keep the background perfectly plain.
Palette: soot black, wet grave-mud brown, slate blue-grey, tarnished iron, only ONE warm accent (the amber lantern flame). Detail of rust, dried soil, torn cloth, cracks.
Style: painterly dark-fantasy 3D character concept, crisp readable silhouette with a heavy asymmetric shape, strong cold rim light from behind-right, gritty textures, high detail, gothic, melancholic and oppressive mood.
```

## Depois de gerar

1. Salvar os arquivos nos caminhos acima (ou em qualquer pasta de `docs/design/refs/`, avisando o nome).
2. O agente roda `python tools/make_sprite.py <prancha> assets/bibiana/sprites/<id>.png --box x0,y0,x1,y1 --height 240`, confere o recorte, registra em `ModelRegistry` (chave `sprite`) e gera as variantes de mecha da Bibiana por recolor do verde-limão.
3. Se a prancha vier com mais de uma figura ou com cenário atrás, peça ao Gemini de novo com a frase: "single figure only, plain flat dark background, no scenery".

## Próximos da fila (quando o Orlando quiser)

Cidadão Infectado, Cão de Peste, Carrasco Apodrecido, Rato Grande, Corvo Carniceiro, Sineiro Penado, Ossada Errante, Lodo de Esgoto, Sanguessuga de Beco, Enforcado, Costurado, Mãe das Ratazanas e Carcereiro do Sino: usar o mesmo molde de prompt, trocando o sujeito pela fantasia da ficha em `docs/enemies/`. Depois, fundos pintados de arena (retrato, sem personagens) no estilo de `refs/roaming-boss/04-perseguidor-coroado-combate-diorama.jpg`.
