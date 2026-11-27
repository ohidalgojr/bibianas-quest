# ADR-0062: chama animada na fogueira, FX de veneno, discos de nó e acabamento do Santuário

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-27 |
| Tarefa | TASK-075 |
| GDD | 5, 6, 9, 12, 17, 18, 19 |

## Contexto

Com os pacotes de ícones, UI kit e FX entregues em `docs/design/refs/` (`ef980c5`), faltava ativar a folha de chama `fx-flame-sheet.jpg` (`assets/bibiana/fx/flame.png`) na fogueira (painel e mapa), disparar o FX de veneno (`poison.png`) em combate, aplicar discos de pedra (`node_disc_0..4.png`) e ícones pintados (`ico-g-nodes`) nas bolhas de opção do mapa com clamping de margem para nunca vazar da tela de 540 px, dar acabamento com `UiKit` e miniaturas no Santuário, e corrigir `GamePreview` onde `tela=event` podia cair em vitória antes de encontrar um nó `EVENT`.

## Decisão

1. **Chama animada (`flame.png`, 8 quadros a 10 fps):** gerada com `tools/make_fx.py --thresh 22` em `assets/bibiana/fx/flame.png` e exibida sobre a pira em `Scene3DBackdrop` (`kind == "campfire"`, controlada por `set_fire_lit`) e sobre os nós `BONFIRE` em `Map3DScreen`.
2. **FX de veneno em combate (`poison.png`):** `Combat3DStage.spawn_poison_fx(on_enemy)` dispara a folha de 6 quadros tanto ao aplicar `veneno` (`EFFECT_ON`) quanto no dano periódico (`DAMAGE` com `label == "poison"`).
3. **Discos de pedra e bolhas com ícone no `Map3DScreen`:** cada opção disponível (`OPTION`) e o chefe recebem um `node_disc_<0..4>.png` no piso da praça; cada bolha de opção recebe o ícone `IconRegistry.texture_for("node", ...)` em `18×18` e tem posição limitada à área segura (`x ∈ [8, size.x - w - 8]`, `y >= 56`).
4. **Santuário com `UiKit` e retratos no Códice:** cartões usam `UiKit.panel(18)`, título separado por `UiKit.divider()`, chip de Ecos com ícone `ui/echoes` e Códice com miniaturas `48×48` dos inimigos em `UiKit.slot("bronze", 4)` mantendo todos os controles públicos intactos.
5. **`GamePreview` (`tela=event`):** tenta sementes determinísticas candidatas até estacionar em `RunState.Phase.EVENT` (sem cair em `VICTORY` nem perder a ilustração do evento).

## Alternativas

- Manter apenas o brilho radial estático na fogueira e bolhas só-texto no mapa: descartado, pois os assets pintados já estavam prontos e especificados no Guia de Arte (§4, §5.5, §9.1, §9.4).

## Consequências

A fogueira e os nós do mapa ganham leitura orgânica sem custo de IA extra; nenhuma regra de `game/core/` ou `RULES_VERSION` foi alterada.
