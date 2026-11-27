# TASK-078: fachadas góticas, portão de ferro do adro e polimento visual do lote 5

| Campo | Valor |
| --- | --- |
| Status | Em verificação (revisão cruzada pendente no fechamento do lote) |
| Aberta em | 2026-11-27 |
| Fase | 1, identidade visual |
| GDD | 17, 18 |
| ADRs | ADR-0064 (ADR-0042, ADR-0060) |

## Objetivo

Aplicar nas fachadas do tabuleiro os sprites recortados do lote 5 (`house_window_lit.png`, `house_door_arch.png`, `balcony_wood.png`), substituir o portão do adro por `church_gate_iron.png` e fechar as ressalvas P1/P2 apontadas em `docs/design/critica-diretor/REVISAO-LOTE-5.md`.

## Fora do escopo

- Alterar regras de `game/core/` (`RULES_VERSION` permanece `21`).
- Forçar o sprite isométrico `stone_bridge_arch.png` sobre as pontes modulares 3D rotacionáveis (manter ponte 3D recebendo textura `stone_retaining_wall`/`stone_cobble`).
- Ativar os inimigos sem ficha/dados (`TASK-079`, `TASK-080`).

## Critérios de aceite

- [x] Trocar os retângulos laranja chapados de `_build_window_quads` (`ScenarioRenderer._render_house`) por quads texturizados com `assets/bibiana/sprites/house_window_lit.png` e aplicar `house_door_arch.png` nas frentes voltadas à rua.
- [x] Limpar pixels internos `#10131A` fechados entre os balaústres de `assets/bibiana/sprites/balcony_wood.png` e posicionar nas empenas altas quando coerente.
- [x] Substituir `iron-fence-border-gate.glb` em `ScenarioRenderer._render_church_gate` por `church_gate_iron.png` como `Sprite3D` estático alinhado ao muro do adro.
- [x] Dessaturar/texturizar os muretes baixos lilás (`TINT_WALL` / barreiras) e melhorar o contraste de silhueta (luz de borda fria) de `crowned_pursuer.png`.
- [x] Anexar em `docs/tasks/prints/` um print real `540×960` mostrando nó de evento com `well_stone`/`gallows_post_3ropes`/`gothic_tombstone` + fachadas novas.
- [x] Suíte headless verde (`tools\run_tests.ps1`).

## Arquivos afetados

- `game/presentation/scenario/scenario_renderer.gd`, `game/presentation/stage/stage_kit.gd`
- `tools/make_sprite.py`, `assets/bibiana/sprites/{balcony_wood,crowned_pursuer}.png`
- `docs/tasks/TASK-078-...md`, `docs/tasks/prints/TASK-078-*.png`, `docs/HANDOFF.md`

## Testes esperados

- `tests/unit/test_scenario_coherence.gd`, `tests/unit/test_stage_assets.gd`, `tests/unit/test_map3d.gd`: verdes sem aumento de primitivas acima de 60 mil.

## Regras que esta tarefa não pode quebrar

- Núcleo sem nós e sem mudança em `RULES_VERSION`.
- Cânone visual (`ADR-0042`) e zero mecha colorida (`F-024`).

## Verificação

Suíte 380/380; mapa com 54 mil primitivas (limite 60 mil). Prints `docs/tasks/prints/TASK-078-evento.png` (semente 6, passo 1) e `TASK-078-mapa.png`. Janelas viram quads com `house_window_lit`, portas em arco e sacadas em quads, portão do adro vira `church_gate_iron`; `crowned_pursuer` ganhou luz de borda fria; sacada com fundo limpo. Não resolvido: muretes lilás de `TINT_WALL` seguem a identificar; poço/forca em escala pequena no print.

## Revisão cruzada

Pendente.
