# TASK-073: tabuleiro gótico coerente com a igreja de fundo (cidade que sobe até o adro)

| Campo | Valor |
| --- | --- |
| Status | Em verificação (falta o OK visual do Orlando e a revisão cruzada) |
| Aberta em | 2026-11-27 |
| Fase | 1, identidade visual |
| GDD | 5, 17, 18 |
| ADRs | ADR-0060 (ADR-0041, ADR-0042, ADR-0057) |

## Objetivo

O tabuleiro do mapa deixa de ser uma grade de blocos cinza e vira a estrutura de uma **cidade gótica** que leva à igreja pintada do horizonte: rua principal em Z até o adro, praças ligadas por ruas, casas de empena com porta para a rua, escadarias nos desníveis, canal com pontes só no desnível, chefe no ponto mais alto diante do portão. Cada tipo de nó vira um lugar (baú numa casa em ruínas, fogueira numa praça abrigada, evento num campo-santo). Texto de projeto em `docs/design/ESTRUTURA-TABULEIRO-GOTICO.md`.

## Fora do escopo

- `map3d_screen.gd`, telas de combate e de corrida, `game_screen.gd`, `model_registry.gd` (outra pessoa edita).
- Modelar a igreja em 3D (continua o horizonte pintado) e gerar as peças novas do Gemini (prompts na seção 7.2 do documento).
- Compactar a névoa do `Map3DScreen` (só células não-VOID) para recuperar orçamento de primitivas.

## Critérios de aceite

- [x] O eixo de camadas avança na diagonal da câmera (`NORTH_SHEAR`), com a igreja pintada acima do chefe.
- [x] Rua principal contínua da partida ao chefe; escadaria de 3 células de largura; portão do adro no eixo do chefe.
- [x] Casas com porta para a rua, altas só fora da diagonal sudeste das ruas; ruínas baixas na frente; nenhum bloco sem porta.
- [x] Um canal no desnível, cruzado por pontes; sem poças.
- [x] Cenografia por tipo de nó (baú, fogueira, evento, elite, emboscada, luta, partida).
- [x] `ScenarioValidator` com as novas regras e verde em 280 mapas (3 a 12 camadas × 40 sementes).
- [x] Prints antes/depois em `docs/tasks/prints/TASK-073-*.png` e preview do mapa funcionando.

## Arquivos afetados

- `game/presentation/scenario/scenario_blueprint.gd`, `scenario_generator.gd`, `scenario_validator.gd`, `scenario_renderer.gd`
- `tests/unit/test_scenario_coherence.gd` (7 testes novos)
- `docs/design/ESTRUTURA-TABULEIRO-GOTICO.md`, `docs/adr/ADR-0060-cidade-gotica-do-tabuleiro.md`, `docs/GDD.md` (§17), `docs/adr/ADR-0041-...md` (status)

## Testes esperados

- `tests/unit/test_scenario_coherence.gd`: gramática válida em 3/4/6/8 camadas, orientação diagonal e linha de névoa, chefe no ponto mais alto com portão e escadaria, rua principal contínua, casas com porta na rua e sem oclusão, cenografia por tipo de nó, determinismo.
- `tests/unit/test_map3d.gd` (existente): layout, névoa, toque e caminhada continuam valendo sem mudança.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR; núcleo sem nós (`game/core/` não foi tocado, `RULES_VERSION` segue 21).
- Cânone visual e gótico (`docs/ART-DIRECTION.md`, `ADR-0042`; prompts do Gemini sem nomes de jogos ou artistas).

## Verificação

- Suíte inteira (`gut_cmdln.gd -gexit`, Godot 4.7.2 Linux): 377/377 passando, 52 scripts.
- Varredura de 280 plantas (3, 4, 5, 6, 8, 10 e 12 camadas × 40 sementes): 0 violações do validador, média 27 casas e ruínas por mapa.
- Prints com janela (Vulkan lavapipe) de `map3d_preview.tscn`, sementes 3, 5, 7, 11 e 21, passos 0 a 4: `docs/tasks/prints/TASK-073-depois-*.png`; planta e isométrica da semente 7 e de 6 camadas.
- Primitivas no passo 2 da semente 7: ≈63,6 mil (era 51 mil); ver o documento, seção 8.
- Não verificado: celular real, desempenho fora do software renderer, executável Windows.

## Revisão cruzada

Pendente: por outro modelo (GDD §21 etapa 4), a partir de `docs/REVIEW-CHECKLIST.md` e do documento de estrutura.
