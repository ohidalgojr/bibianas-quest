# ADR-0061: ritmo legível do golpe e caminhada animada por cinemática de sprite

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-27 |
| Tarefa | TASK-074 |
| GDD | 6, 17, 18, 19 |

## Contexto

No feedback `F-025`, o Orlando apontou que o ataque da Bibiana ficou rápido e estranho (`STRIKE_APPROACH = 0,20 s`, `STRIKE_WINDUP = 0,05 s`, `STRIKE_RECOVER = 0,06 s`) e que os quadros atuais de `walk_0..3` não transmitem caminhada real até o inimigo (nem no combate nem no mapa 3D, que chamava `ModelRegistry.play(..., "walk")` sem efeito sobre `Sprite3D`).

## Decisão

1. **Cadência em 4 tempos no ataque (`Combat3DStage`):** aproximação caminhando (`0,44 s`), preparação erguendo a espada (`0,18 s`), bote do golpe (`0,08 s` com corte FX no impacto e hit-stop sincronizado), recuo pós-impacto (`0,22 s`) e retorno caminhando (`0,38 s`). Em `CombatScreen`, o fluxo aguarda o retorno (`+0,32 s`) antes de iniciar a resposta do inimigo. A velocidade 2x continua escalando por `time_scale`.
2. **Cinemática de passada em `Sprite3D` (combate e `Map3DScreen`):** enquanto os novos quadros não são gerados, o sprite filho (`_hero_sprite`) anima passada alternada (subida/descida do passo, leve inclinação de tronco, compressão de pisada e poeira leve no chão) sem deslocar a origem do `Node3D` no chão nem quebrar o determinismo do mapa.
3. **Pranchas dedicadas para o Gemini (`PROMPTS-LOTE-HD2D.md` §34–35):** documentar `bibiana-guerreira-walk-v2-sheet.jpg` (ciclo de marcha alternado de costas em 4 colunas com silhueta de pernas distinta) e `bibiana-guerreira-strike-sheet.jpg` (investida, erguida, corte diagonal completo e recuperação) sob `#10131A` liso e cânone `ADR-0042`.

## Alternativas

- Apenas desacelerar o `Tween` atual: descartado, pois o deslize sem passada ficava ainda mais evidente em câmera lenta.
- Esperar a cota do Gemini antes de mexer no código: descartado, pois a melhoria de ritmo e passada já resolve a sensação imediata e prepara o encaixe das pranchas futuras.

## Consequências

O ataque passa a durar ~1,3 s em 1x (~0,65 s em 2x) com leitura clara de intenção, impacto e retorno; assim que o Gemini gerar `walk-v2` e `strike`, basta recortar com `tools/make_sprite.py --thresh 8` para substituir os quadros sem refatorar a coreografia.
