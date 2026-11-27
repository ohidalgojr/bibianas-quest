# TASK-075: chama animada, FX de veneno, discos/ícones de nó no mapa, Santuário e preview de evento

| Campo | Valor |
| --- | --- |
| Status | Em verificação |
| Aberta em | 2026-11-27 |
| Fase | 1, identidade visual e acabamento de telas |
| GDD | 5, 6, 9, 12, 17, 18, 19 |
| ADRs | ADR-0062 (ADR-0042, ADR-0055, ADR-0059, ADR-0060) |

## Objetivo

Converter e integrar a folha de chama `flame.png` na fogueira (painel e mapa), ligar `poison.png` ao veneno em combate, colocar os discos de pedra e ícones pintados de nó com margens seguras no `Map3DScreen`, polir `SanctuaryScreen` com `UiKit` e retratos no Códice, e corrigir `GamePreview` para `tela=event`.

## Fora do escopo

- Gerar as imagens ainda bloqueadas pela cota semanal do Gemini (`event-fountain-of-ash`, `gallows-tree`, `abandoned-armory`, 4 sprites isolados e pranchas de animação `F-025`).
- Refazer malhas 3D de casas do cenário (`TASK-073` §8).

## Critérios de aceite

- [x] `assets/bibiana/fx/flame.png` gerada via `tools/make_fx.py` a partir de `fx-flame-sheet.jpg` e documentada em `assets/LICENSES.md`.
- [x] `Scene3DBackdrop` (`campfire`) e `Map3DScreen` (`BONFIRE`) animam os 8 quadros de `flame.png` e respeitam `set_fire_lit(lit)`.
- [x] `Combat3DStage.spawn_poison_fx(on_enemy)` dispara em `CombatScreen._apply` no veneno aplicado e no tick de dano de veneno.
- [x] `Map3DScreen` coloca `node_disc_<0..4>.png` nos destinos/chefe, mostra ícone `node` nas bolhas e mantém todas as bolhas dentro de `[8, 532]`.
- [x] `SanctuaryScreen` usa `UiKit.panel` / `divider` / `slot` com miniaturas no Códice sem quebrar contratos de `test_sanctuary.gd`.
- [x] `GamePreview` com `tela=event` sempre abre uma tela em `RunState.Phase.EVENT`.
- [x] Testes novos verdes em headless e prints reais `540×960` em `docs/tasks/prints/TASK-075-*.png`.

## Arquivos afetados

- `assets/bibiana/fx/flame.png`, `assets/LICENSES.md`
- `game/presentation/camp3d/scene3d_backdrop.gd`, `game_preview.gd`
- `game/presentation/combat3d/combat3d_stage.gd`, `game/presentation/combat/combat_screen.gd`
- `game/presentation/map3d/map3d_screen.gd`
- `game/presentation/run/sanctuary_screen.gd`
- `tests/unit/test_combat3d.gd`, `test_map3d.gd`, `test_scene3d.gd`

## Testes esperados

- `tests/unit/test_scene3d.gd`: alternância da chama pintada via `set_fire_lit` no `Scene3DBackdrop`.
- `tests/unit/test_combat3d.gd`: chamada segura de `spawn_poison_fx` para jogador e inimigo.
- `tests/unit/test_map3d.gd`: presença de ícone pintado na bolha de destino e clamping na tela de 540 px.

## Regras que esta tarefa não pode quebrar

- Núcleo em `game/core/` intacto (`RULES_VERSION` = 21).
- Tipagem estática estrita em GDScript (`test_core_purity`).
- Cânone visual (`ADR-0042`) e zero mecha colorida (`F-024`).

## Verificação

- Suíte headless (`powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1`, 2026-11-27): `380/380` passando em `52` scripts (`57626` asserts, `33,841s`) e revalidada pelo `pre-commit` após o ajuste fino de posição da chama e do limite superior das bolhas.
- Prints reais `540×960` com janela (`tools\screenshot.ps1`, 2026-11-27): `docs/tasks/prints/TASK-075-fogueira.png` (`20 fps`, `10` chamadas, `176` primitivas), `docs/tasks/prints/TASK-075-evento.png` (`31 fps`, `36` chamadas, `3300` primitivas) e `docs/tasks/prints/TASK-075-mapa.png` (`28 fps`, `199` chamadas, `48260` primitivas).
- Não verificado: celular real e teste interativo da tela do Santuário com janela aberta (verificada via `test_sanctuary.gd`).

## Revisão cruzada

Pendente: revisão por outro modelo (GDD §21, etapa 4).
