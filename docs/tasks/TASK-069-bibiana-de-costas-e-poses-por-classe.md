# TASK-069: Bibiana de costas e poses por classe (4 classes × 4 poses)

| Campo | Valor |
| --- | --- |
| Status | Em verificação (falta o OK visual do Orlando) |
| Aberta em | 2026-11-24 |
| Fase | 1, identidade visual |
| GDD | 17, 18, 19 |
| ADRs | ADR-0056 (ADR-0042, ADR-0053, ADR-0055) |

## Objetivo

Usar as 4 folhas de poses entregues pelo Orlando (`docs/design/refs/bibiana/bibiana-*-sheet.jpg`): a Bibiana de costas no combate (visão de duelo) e no mapa, sentada na fogueira e de perfil nas cenas de loja, baú e evento.

## Fora do escopo

- Animações por quadro (ataque, dano, derrota) e variações de poses de combate além de costas.
- Seleção de classe em jogo (só a Guerreira existe; as outras 3 classes ficam registradas).

## Critérios de aceite

- [x] 16 sprites recortados com `tools/make_sprite.py --thresh 8` (comandos do catálogo) em `assets/bibiana/sprites/bibiana_<classe>_<pose>.png`.
- [x] `ModelRegistry.hero_id(classe, pose)` devolve a pose, com reserva para a Bibiana de frente.
- [x] Combate e mapa usam a de costas; fogueira e derrota usam a sentada; loja, baú e evento usam a de perfil voltada para o NPC.
- [x] Suíte verde e prints `docs/tasks/prints/TASK-069-*.png`.

## Arquivos afetados

- `assets/bibiana/sprites/bibiana_*_*.png`, `game/presentation/stage/model_registry.gd`, `game/presentation/camp3d/scene3d_backdrop.gd`, `game/presentation/combat3d/combat3d_stage.gd`

## Testes esperados

- `tests/unit/test_stage_assets.gd`: todo sprite registrado carrega (cobre as 16 poses).

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR; núcleo sem nós.
- Cânone visual (`ADR-0042`); nunca mecha colorida (`F-024`).

## Verificação

Suíte completa em headless: ver HANDOFF (2026-11-24). Prints reais em `docs/tasks/prints/TASK-069-*.png`. Não verificado: celular e Windows real; recortes de pose sentada com pequenos resquícios de fundo azul entre braço e arma.

## Revisão cruzada

Pendente.
