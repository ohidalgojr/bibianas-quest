# TASK-067: mapa pintado, Bibiana de costas e menus de combate (crítica do diretor)

| Campo | Valor |
| --- | --- |
| Status | Em verificação (falta o OK visual do Orlando; Bibiana de costas depende da arte) |
| Aberta em | 2026-11-24 |
| Fase | 1, identidade visual |
| GDD | 5, 17, 18, 19 |
| ADRs | ADR-0054 (ADR-0042, ADR-0053) |

## Objetivo

Aplicar a crítica `docs/design/critica-diretor/CRITICA-DIRETOR.md` (mapa nota 2,5 a 3, gavetas de combate nota 4): refazer o mapa como cena pintada legível, corrigir cortes de sprite e melhorar o menu de combate. A Bibiana de costas fica pronta no código e entra quando o arquivo existir.

## Fora do escopo

- Gerar a arte da Bibiana de costas (depende do Gemini; prompt em `docs/design/PROMPTS-BIBIANA-COSTAS.md`).
- Fogueira, loja, Home, baú e resultado com arenas pintadas (tarefa seguinte).

## Critérios de aceite

- [x] Mapa com fundo pintado, estradas, sprites de inimigos com contraste, props novos, pílulas dentro da tela e herói a 70% da altura.
- [x] Sprites do combate sem corte (largura e altura) e o selo de intenção fora do rosto.
- [x] Gavetas de combate como folha sobreposta, sem encolher o palco, com botões de 64 px.
- [x] `ModelRegistry` usa `bibiana_back` no combate e no mapa assim que `assets/bibiana/sprites/bibiana_back.png` existir.
- [x] Suíte verde e prints em `docs/tasks/prints/TASK-067-*.png`.

## Arquivos afetados

- `game/presentation/map2d/painted_map_screen.gd`, `game/presentation/game_screen.gd`, `game/presentation/combat3d/combat3d_stage.gd`, `game/presentation/combat/combat_screen.gd`, `game/presentation/stage/model_registry.gd`

## Testes esperados

- `tests/unit/test_painted_map.gd`: toque emite a escolha, pílulas dentro de 540 px, herói no nó atual, caminhada termina no destino.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR; núcleo sem nós.
- Cânone visual: `docs/ART-DIRECTION.md` e `ADR-0042`; nunca mecha colorida (`F-024`).

## Verificação

Suíte completa em headless (Godot 4.7.2, GUT 9.7.1): 376 testes, todos passando (2026-11-24). Prints reais 540x960 em `docs/tasks/prints/TASK-067-*.png`. Não verificado: celular, Windows real, fogueira/loja/Home/baú/resultado (próxima tarefa), a Bibiana de costas (sem arte).

## Revisão cruzada

Pendente.
