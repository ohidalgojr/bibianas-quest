# TASK-055: atmosfera (D-ART-1/2/3) e fogueira sincronizada (D-UI-5)

| Campo | Valor |
| --- | --- |
| Status | Em verificação (código e testes prontos; falta o Orlando ver os prints) |
| Aberta em | 2026-11-22 |
| Fase | 1, melhorias do estudo da TASK-051 (decisões recomendadas pelo Gemini, "Sim" no quadro 6.2) |
| GDD | 18, 19 |
| ADRs | ADR-0043 |

## Objetivo

Aplicar as correções de maior impacto estético e menor esforço do estudo `docs/design/ESTUDO-ui-mobile-inimigos-estetica.md`: luz ambiente baixa em azul-ardósia com neblina e foco quente no combate (D-ART-1), dithering Bayer, split-toning e desfoque menor no combate (D-ART-2), conferência de que não restam pinheiros verdes nas cenas de jogo (D-ART-3) e fogueira apagada até ser acesa (D-UI-5).

## Fora do escopo

- Novos modelos, escurecer o albedo dos kits Kenney, UI (tarefas seguintes), regras de jogo.

## Critérios de aceite

- [x] `Atmosphere` aplica ambiente frio (energia 0,46) e neblina exponencial; mapa usa 0,62 e sem neblina para manter a leitura.
- [x] Combate com `SpotLight3D` quente sobre o inimigo e desfoque 0,35.
- [x] `PostFx` com matriz de Bayer 4x4 e split-toning.
- [x] Nenhuma cena de jogo usa `pine-*` (só a cena de prova `proof_scene.gd`, de depuração).
- [x] A cena da fogueira mostra chama, faíscas e luz forte só depois de acesa; apagada, só brasa fraca.
- [x] D-UI-5, mercador: a loja já usa `character-keeper` (TASK-053), nada a fazer.

## Arquivos afetados

- `game/presentation/fx/atmosphere.gd`, `game/presentation/fx/post_fx.gd`, `game/presentation/combat3d/combat3d_stage.gd`, `game/presentation/map3d/map3d_screen.gd`, `game/presentation/camp3d/scene3d_backdrop.gd`, `game/presentation/run/run_panel_screen.gd`

## Testes esperados

- `tests/unit/test_atmosphere.gd`: constantes dentro da faixa do estudo, `apply` liga a neblina, foco com luz quente, `PostFx` com os parâmetros, fogueira apagada e acesa.

## Regras que esta tarefa não pode quebrar

- Só apresentação; `RULES_VERSION` não muda. `docs/ART-DIRECTION.md` e ADR-0042 seguidos.

## Verificação

Ver HANDOFF (suíte e data).

## Revisão cruzada

Pendente.
