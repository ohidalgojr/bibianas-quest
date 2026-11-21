# TASK-053: algoritmo próprio de cenários coerentes

| Campo | Valor |
| --- | --- |
| Status | Em verificação (código, suíte 353/353, 9 prints reais e executável prontos; aguarda aprovação visual do Orlando e revisão cruzada por outro modelo) |
| Aberta em | 2026-11-19 |
| Fase | 1, coerência espacial e arquitetônica dos cenários 3D (`docs/FEEDBACK.md` F-021) |
| GDD | 5, 17, 18 |
| ADRs | ADR-0036, ADR-0037, ADR-0041 |

> Leia `docs/ART-DIRECTION.md` (§2, §3, §4, §5 e §8) antes de alterar cenas. Tarefa de tela fecha somente com prints reais com janela anexados em `docs/tasks/prints/` e as 6 respostas do teste do print.

## Objetivo

Substituir o espalhamento aleatório e desconectado de objetos por um algoritmo próprio e determinístico de geração arquitetônica/ecológica (**Terrace-Grammar-Constraint**, `ADR-0041`) para que todo tabuleiro 3D (`Map3DScreen`) e todo diorama focal (`Combat3DStage`, `Scene3DBackdrop`) sempre faça sentido espacial, hidráulico, arquitetônico e de câmera isométrica, sem elementos flutuando, enterrados, bloqueando portas/personagens ou colocados sem contexto.

## Fora do escopo

- Alteração nas regras de geração de grafo ou progressão do núcleo (`game/core/`, `CoreVersion.RULES_VERSION` permanece `20`).
- Novos modelos no Blender ou alteração de UI/gavetas mobile (tratados na `TASK-051`).
- Biomas dos cenários 2 a 5 (apenas o pipeline fica extensível; o conteúdo segue Cidade Abandonada).

## Critérios de aceite

- [x] Criar o módulo `game/presentation/scenario/` (`ScenarioBlueprint`, `ScenarioGenerator`, `ScenarioValidator`, `ScenarioRenderer`) com tipagem estática obrigatória, indentação com tab e zero aleatoriedade global.
- [x] Garantir e validar os 12 invariantes estruturais no mapa 3D (platôs suaves sem buracos 4×4, silhueta recortada de diorama, estradas por A* sem escadas ambíguas de quina, canais contínuos `>= 6` células e pontes onde cruzam estradas planas, compostos nivelados voltados à rua com telhado alinhado e zero oclusão no cone sudeste das praças, parapeitos contínuos `>= 2` células, postes aterrados na exata altura e espaçados `>= 5`, props estritamente contextuais e zero pinheiros/muros/cercas/lápides soltas).
- [x] Aplicar a mesma gramática coerente nos 11 dioramas focais (`Combat3DStage` e `Scene3DBackdrop`), incluindo relevo em terraços ao fundo, substituição dos pinheiros verdes e troca do mercador da loja de `gravedigger` para `character-keeper.glb`.
- [x] Remover a duplicação de postes em `Map3DScreen._build_node()` mantendo a iluminação e destaque visual dos destinos `OPTION` e a compatibilidade total com `test_map3d.gd`, `test_combat3d.gd` e `test_scene3d.gd`.
- [x] Adicionar suíte `tests/unit/test_scenario_coherence.gd` validando 15 sementes de mapa + todos os 11 dioramas focais e passar 100% na suíte completa em headless.
- [x] Capturar e inspecionar os 9 prints reais (`docs/tasks/prints/TASK-053-*.png`), conferindo métricas de desempenho (`<= 60.000` primitivas), gerar `build\windows\BibianasQuest.exe` e atualizar `docs/HANDOFF.md`.

## Arquivos afetados

- `docs/FEEDBACK.md`, `docs/adr/ADR-0041-algoritmo-de-cenarios-coerentes.md`, `docs/HANDOFF.md`
- `game/presentation/stage/stage_kit.gd`
- `game/presentation/scenario/scenario_blueprint.gd`
- `game/presentation/scenario/scenario_generator.gd`
- `game/presentation/scenario/scenario_validator.gd`
- `game/presentation/scenario/scenario_renderer.gd`
- `game/presentation/map3d/map3d_layout.gd`
- `game/presentation/map3d/map3d_screen.gd`
- `game/presentation/map3d/map3d_preview.gd`
- `game/presentation/combat3d/combat3d_stage.gd`
- `game/presentation/camp3d/scene3d_backdrop.gd`
- `tests/unit/test_scenario_coherence.gd`

## Testes esperados

- `tests/unit/test_scenario_coherence.gd`: validação dos 12 invariantes de `ScenarioValidator` em 15 sementes de mapa e nos 11 dioramas focais; determinismo; zero oclusão; espaçamento e altura exata de postes; ausência de poças `< 6` células, muros isolados e props proibidos.
- `tests/unit/test_map3d.gd`, `tests/unit/test_combat3d.gd`, `tests/unit/test_scene3d.gd`, `tests/unit/test_core_purity.gd`, `tests/unit/test_project_standards.gd` e suíte completa via `tools\run_tests.ps1`.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD nem `game/core/` (`CoreVersion.RULES_VERSION` segue `20`).
- Todo sorteio determinístico da camada visual deve usar hash local/semente recebida (sem `randi()`, `randf()`, `shuffle()`, `pick_random()`).
- Assets usados apenas de pacotes já registrados em `assets/LICENSES.md` (`character-keeper.glb` pertence ao Kenney Graveyard Kit já listado).
- Tarefa de tela só fecha com print com janela aberta em `docs/tasks/prints/` e resposta às 6 perguntas de `docs/ART-DIRECTION.md` §8.

## Verificação

- **Suíte automatizada:** `powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1` -> **353/353 testes passando em 49 scripts** (incluindo `test_scenario_coherence.gd`, `test_map3d.gd`, `test_combat3d.gd`, `test_scene3d.gd`, `test_core_purity.gd` e `test_project_standards.gd`, `RULES_VERSION` = 20).
- **Executável Windows:** `powershell -ExecutionPolicy Bypass -File tools\build_windows.ps1` -> gerado `build\windows\BibianasQuest.exe`.
- **Prints capturados com janela (`tools\screenshot.ps1`, 540×960) e métricas `DESEMPENHO`:**
  - `docs/tasks/prints/TASK-053-mapa-inicio.png` (`passos=0,semente=7`): `fps=28 chamadas=152 primitivas=49682`
  - `docs/tasks/prints/TASK-053-mapa-meio.png` (`passos=3,semente=7`): `fps=28 chamadas=163 primitivas=49576`
  - `docs/tasks/prints/TASK-053-mapa-chefe.png` (`passos=5,semente=7`): `fps=28 chamadas=158 primitivas=48497`
  - `docs/tasks/prints/TASK-053-mapa-semente42.png` (`passos=1,semente=42`): `fps=29 chamadas=140 primitivas=45557`
  - `docs/tasks/prints/TASK-053-combate-comum.png` (`inimigo=infected_citizen,no=1,nivel=3`): `fps=28 chamadas=168 primitivas=26799`
  - `docs/tasks/prints/TASK-053-combate-chefe.png` (`inimigo=gravedigger,no=8,nivel=6`): `fps=28 chamadas=176 primitivas=26962`
  - `docs/tasks/prints/TASK-053-home.png` (`tipo=home`): `fps=30 chamadas=59 primitivas=18162`
  - `docs/tasks/prints/TASK-053-fogueira.png` (`tipo=campfire`): `fps=30 chamadas=59 primitivas=16790`
  - `docs/tasks/prints/TASK-053-loja.png` (`tipo=shop`): `fps=29 chamadas=77 primitivas=18502`

### Teste do print (`docs/ART-DIRECTION.md` §8)

1. **Cenário com profundidade (altura, camadas, luz dirigida), não vetorial chapado?** Sim — terreno estratificado em blocos (`dirt.glb`), platôs suaves de musgo escuro sobre penhasco de pedra, escadas nos dois sentidos, compostos elevados ao fundo, canal contínuo de água e contraste frio/quente dirigido em todas as 9 telas.
2. **Semelhança em composição com a referência (FFT / diorama isométrico coeso)?** Sim — silhueta recortada de diorama sem bordas pontilhadas, edificações com telhado alinhado sobre platôs atrás das praças (sem ocluir a frente), caminhos de pedra bem definidos e personagens/objetos ancorados ao chão em seus contextos.
3. **No mapa, veem-se os três caminhos e o futuro ofuscado, com câmera acompanhando?** Sim — nos prints início, meio, chefe e semente 42, as 3 opções aparecem iluminadas na praça com estradas/escadas livres de cristas de terraço à frente, enquanto camadas adiante ficam sob névoa progressiva e o `Map3DScreen` segue a heroína pelo caminho exato em `edge_paths`.
4. **Modelos 3D CC0 com contorno/sombra e clima em partículas?** Sim — kits Kenney (`mini_dungeon` + `graveyard`, incluindo `character-keeper.glb` como mercador na loja), KayKit (`Knight.glb`) e monstros próprios, contorno/dithering por `PostFx`, sombras ortogonais (`SHADOW_ORTHOGONAL`) e chuva/brasas em partículas.
5. **Números e ícones sobre o mundo?** Sim — bolhas vermelhas (`Nv X`) e douradas (`ouro`, `baú`, `evento`, `chefe`) flutuam sobre as praças de destino desobstruídas e sem postes duplicados.
6. **Funciona em retrato 540×960 com toque de 48 px?** Sim — todas as 9 capturas em 540×960 preservam leitura em terços, botões de destino com 120×120 px (`test_map3d.gd`) e orçamento entre 16.790 e 49.682 primitivas (abaixo do teto de 60.000 do GDD §18).

## Revisão cruzada

Pendente.
