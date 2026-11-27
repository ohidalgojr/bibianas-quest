# TASK-074: ritmo legível do golpe, caminhada animada e prompts de animação para o Gemini

| Campo | Valor |
| --- | --- |
| Status | Em verificação |
| Aberta em | 2026-11-27 |
| Fase | 1, identidade visual e sensação de combate |
| GDD | 6, 17, 18, 19 |
| ADRs | ADR-0061 (ADR-0042, ADR-0058, ADR-0059) |

## Objetivo

Corrigir o ritmo apressado e estranho do ataque da Bibiana (`F-025`), dar caminhada animada com peso e poeira de passo no combate e no tabuleiro 3D (`Map3DScreen`) e anotar dois prompts dedicados no catálogo para o Gemini gerar quadros reais de marcha alternada e golpe em arco.

## Fora do escopo

- Gerar imagens no Gemini agora (bloqueado por cota semanal `429`).
- Mudar regras ou fórmulas em `game/core/` (`RULES_VERSION` segue 21).

## Critérios de aceite

- [x] `docs/FEEDBACK.md` registra `F-025` e liga ao `ADR-0061`.
- [x] `Combat3DStage.hero_strike` executa aproximação caminhada, erguida visível de espada (`windup`), bote de impacto (`lunge`), recuo pós-golpe e retorno caminhado sem encavalar com o turno do inimigo.
- [x] `Map3DScreen` anima os quadros `walk_0..3` e a passada em `_hero_sprite` ao caminhar entre nós, restaurando a pose e a origem ao chegar.
- [x] `docs/design/CATALOGO-ASSETS-HD2D.md` e `docs/design/PROMPTS-LOTE-HD2D.md` trazem os prompts prontos de `bibiana-guerreira-walk-v2-sheet.jpg` e `bibiana-guerreira-strike-sheet.jpg` seguindo `GDD §18`, `ADR-0042` e `F-024`.
- [x] Testes novos em `test_combat3d.gd` e `test_map3d.gd`, suíte verde em headless e prints com janela em `docs/tasks/prints/TASK-074-*.png`.

## Arquivos afetados

- `game/presentation/combat3d/combat3d_stage.gd`, `combat3d_preview.gd`
- `game/presentation/combat/combat_screen.gd`
- `game/presentation/map3d/map3d_screen.gd`
- `tests/unit/test_combat3d.gd`, `tests/unit/test_map3d.gd`
- `docs/FEEDBACK.md`, `docs/adr/ADR-0061-ritmo-ataque-e-caminhada-animada.md`, `docs/design/CATALOGO-ASSETS-HD2D.md`, `docs/design/PROMPTS-LOTE-HD2D.md`

## Testes esperados

- `tests/unit/test_combat3d.gd`: valida constantes legíveis (`STRIKE_APPROACH`, `STRIKE_WINDUP`, `STRIKE_LUNGE`), execução completa de `hero_strike` e limpeza de `_hero_sprite`.
- `tests/unit/test_map3d.gd`: valida que a caminhada no mapa restaura `_hero_sprite.position` e escala após chegar ao destino.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR; núcleo em `game/core/` intacto (`RULES_VERSION` = 21).
- Tipagem estática estrita em GDScript (`test_core_purity`).
- Cânone visual (`ADR-0042`), sem mecha colorida (`F-024`) e prompts sem citar nomes de jogos ou artistas (`GDD §18`).

## Verificação

- Suíte headless (`powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1`, 2026-11-27): `378/378` passando em `52` scripts (`57598` asserts, `32,463s`), incluindo os testes novos em `test_combat3d.gd` e `test_map3d.gd`.
- Prints reais `540×960` com janela (`tools\screenshot.ps1`, 2026-11-27): `docs/tasks/prints/TASK-074-combate-ataque.png` (`30 fps`, `82` chamadas, `7642` primitivas, `erro=0`) e `docs/tasks/prints/TASK-074-mapa.png` (`29 fps`, `186` chamadas, `47562` primitivas, `erro=0`).
- Não verificado: sensação tátil interativa do golpe no celular real e substituição pelos novos sprites `walk-v2` / `strike` após a liberação da cota do Gemini.

## Revisão cruzada

Pendente: revisão por outro modelo (GDD §21, etapa 4).
