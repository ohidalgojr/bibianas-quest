# TASK-066: integração dos 31 assets HD-2D (sprites e arenas pintadas) e remoção da mecha

| Campo | Valor |
| --- | --- |
| Status | Em verificação (código, testes e prints prontos; falta o OK visual do Orlando) |
| Aberta em | 2026-11-24 |
| Fase | 1, identidade visual |
| GDD | 17, 18, 19 |
| ADRs | ADR-0053 (ADR-0042, ADR-0052) |

## Objetivo

Integrar ao jogo as 31 pranchas HD-2D catalogadas em `docs/design/CATALOGO-ASSETS-HD2D.md`: recortar os 26 sprites com `tools/make_sprite.py`, registrá-los no `ModelRegistry` (Bibiana, 14 inimigos do cenário 1, 3 do estudo, 2 NPCs, 4 props), usar as arenas pintadas `9:16` como fundo do combate e apagar os vestígios da mecha colorida (`F-024`).

## Fora do escopo

- As pranchas ainda não geradas (`lipless_choir`, `calcified_knight`, `crowned_pursuer`, `arena-cidade-chefe`, `arena-fogueira-apagada`, folhas de poses das classes): o chefe usa a praça até existir a arena própria.
- Fogueira, loja, Home e mapa com as arenas pintadas (as arenas `fogueira-acesa`, `loja` e `home-santuario` já estão no repositório; a integração delas é a próxima tarefa de arte).
- Animação por quadros.

## Critérios de aceite

- [x] 26 sprites em `assets/bibiana/sprites/` gerados com os `--box` do catálogo, todos virados para a esquerda (inimigos) ou para a direita (Bibiana).
- [x] `ModelRegistry` usa sprite para a Bibiana e para todo inimigo do cenário 1; teste confere que o arquivo do sprite existe.
- [x] Combate com fundo pintado (arena comum = beco; elite, mini boss e chefe = praça) e sprites num viewport transparente, com sombra de contato.
- [x] `HAIR_STAGES`, `hair_*` e o selo "Mecha da Bibiana" removidos; teste dos 9 estágios removido.
- [x] Suíte verde; prints do combate em `docs/tasks/prints/TASK-066-*.png`.

## Arquivos afetados

- `assets/bibiana/sprites/*.png`, `game/presentation/stage/model_registry.gd`, `game/presentation/combat3d/combat3d_stage.gd`
- `game/presentation/visual_theme.gd`, `game/presentation/map/map_screen.gd`, `tests/unit/test_visual_and_audio.gd`, `tests/unit/test_stage_assets.gd`

## Testes esperados

- `tests/unit/test_stage_assets.gd`: todo `sprite` do registro existe e carrega; Bibiana e inimigos do jogo têm sprite.
- `tests/unit/test_combat3d.gd`: o palco monta com fundo pintado e os dois sprites.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR.
- Núcleo sem nós e sem aleatoriedade global.
- Cânone visual: `docs/ART-DIRECTION.md` e `ADR-0042`; nunca mecha colorida (`F-024`).

## Verificação

Suíte completa em headless com Godot 4.7.2 e GUT 9.7.1: 370 testes, 370 passando, 48589 asserts (2026-11-24). Prints reais (Vulkan por software, 540x960) em `docs/tasks/prints/TASK-066-combate-{rat,elite,boss}.png`. Não verificado: celular real, fogueira/loja/Home com as arenas novas, build `.exe` (ambiente Linux).

## Revisão cruzada

Pendente.
