# Prompts: Bibiana de costas (visão de combate, TASK-067)

Origem: `docs/design/critica-diretor/CRITICA-DIRETOR.md` (e). O combate já aceita o arquivo: salvar o recorte final em `assets/bibiana/sprites/bibiana_back.png` (altura ~240 px, gerado por `tools/make_sprite.py`, pose idle) faz `ModelRegistry.hero_id()` passar a usá-lo no combate e no mapa, sem mudar código.

Regras: sem mecha colorida (`F-024`), prompt sem citar jogos nem artistas (GDD §18), adulta, nunca fofa. Fundo: o `make_sprite.py` espera fundo liso `#10131A`; se o Gemini devolver verde-croma, trocar o fundo antes de recortar.

- **Prompt para o Gemini (sem citar jogos ou artistas, GDD §18).** Gerar uma prancha por pose, fundo chapado verde-croma `#00B140` para recorte:

> Pixel-art painterly character sprite, full body, seen from directly behind with a slight three-quarter turn to the left. A young woman warrior in dark, worn steel plate armour: pauldrons, vambraces and a cuirass back-plate scratched, soot-stained, with rust at the edges and faded dark-wine leather straps. A tattered deep-wine cloak hangs from her shoulders to the knees, torn at the hem. Dark brown hair tied in a short low knot, no colour streaks. Her right hand holds a plain battered longsword pointing low and slightly forward; her left arm carries a round wooden shield with iron rim, seen edge-on. Knees slightly bent, weight forward, guarded stance, adult proportions, serious silhouette, never cute or chibi. Cold blue-grey moonlight from the upper left with a thin warm amber rim light from a lantern on the right. Dense hand-painted texture on metal and cloth, hard readable silhouette at small size, 2:3 portrait, solid flat chroma-green background, no ground, no shadow, no text, no logo.

  Para as variações, trocar apenas a frase da pose: "sword raised overhead mid-swing", "shield raised in front, sword tucked back", "crouched on one knee, head lowered, sword planted in the ground", "walking away from camera, mid-stride, cloak swaying". Manter o resto igual.
