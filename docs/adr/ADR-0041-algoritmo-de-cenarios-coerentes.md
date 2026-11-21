# ADR-0041: algoritmo próprio de cenários coerentes (Terrace-Grammar-Constraint)

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-19 |
| Tarefa | TASK-053 |
| GDD | 5, 17, 18 |

## Contexto

Na inspeção do jogo e dos prints das `TASK-036` a `TASK-046`, os cenários 3D (tabuleiro isométrico, arenas de combate e fundos de acampamento/menu) apresentavam vários elementos espaciais sem sentido (feedback `F-021`, acompanhado de referência de diorama isométrico coeso estilo *Final Fantasy Tactics*):

1. `Map3DLayout._scatter_props` e `Map3DScreen.DECOR_PROPS` espalhavam pedaços avulsos de muro, cerca quebrada, lápides, tumbas, velas, postes e pinheiros verdes saturados aleatoriamente pelo terreno com rotações soltas.
2. `Map3DScreen._build_border_walls` colocava `stone-wall.glb` de 2 em 2 células, formando muros pontilhados desconectados nas bordas.
3. `Map3DScreen._build_node` adicionava um poste fixo perto de cada nó `OPTION`, duplicando postes da rua e frequentemente flutuando ou enterrado em blocos vizinhos.
4. `Map3DLayout._fill_terrain` usava ruído em blocos `4×4` descontínuos, criando buracos quadrados e poças isoladas de água (`_carve_water`), enquanto `_build_ruin` aceitava desnível de 1 bloco dentro de `5×5` sem nivelar a base e ignorava o pivô deslocado na borda `-Z` de muros e cercas Kenney (deixando cantos abertos e criptas sem telhado).
5. `Map3DLayout._place_stairs` gerava escadas em quinas onde mais de um vizinho subia de nível.
6. `Combat3DStage` e `Scene3DBackdrop` exibiam platôs quadrados chapados, cercas flutuantes, pinheiros verdes vibrantes (`pine-crooked.glb`), poste bloqueando entrada de cripta e o chefe `gravedigger` como mercador na loja (havendo `character-keeper.glb` licenciado em `assets/kenney/graveyard/`).

## Decisão

Adotar em `game/presentation/scenario/` um algoritmo próprio e determinístico de geração arquitetônica e ecológica de cenários — o pipeline **Terrace-Grammar-Constraint** em 7 estágios — unificado entre o tabuleiro 3D (`Map3DLayout`/`Map3DScreen`) e os dioramas focais (`Combat3DStage` e `Scene3DBackdrop`):

1. **Separação estrita de responsabilidades em 4 classes `RefCounted`:**
   - `ScenarioBlueprint`: planta declarativa de células (`heights`, `zones`, `plaza_cells`, `road_cells`, `bridge_cells`, `water_cells`, `stairs`, `edge_paths`, `compounds`, `wall_runs`, `lamps`, `typed_props`, `focal_lights`, `origin_offset`, `base_cliff_level`).
   - `ScenarioGenerator`: executa o pipeline de 7 estágios de forma determinística (via hash de coordenadas/semente, sem aleatoriedade global):
     - Estágio 0: silhueta recortada de diorama (`ZONE_VOID` fora do corredor ativo no mapa; cantos recortados e saia de penhasco nos dioramas focais).
     - Estágio 1: topografia contínua por interpolação de distância inversa das praças + ruído bilinear suave + passes celulares de platô (terraços planos estilo FFT) + nivelamento absoluto das praças (`3×3`, chefe `5×5`).
     - Estágio 2: roteamento de estradas por A* 4-direcional com reaproveitamento de vias já abertas (bifurcações orgânicas), relaxamento de altura (`|Δh| <= 1`) e *Landing Promotion* (eliminação de quinas ambíguas antes de colocar `stairs`).
     - Estágio 3: escavação de canais contínuos de água + travessia por ponte elevada onde cruza estrada reta e plana + poda por BFS (`mínimo 6 células`, zero poças aleatórias) + margens `ZONE_EMBANKMENT`.
     - Estágio 4: alocação de compostos arquitetônicos completos sobre bases rigorosamente niveladas (Mausoléu do Chefe atrás da praça do chefe; `CHAPEL`, `WATCHTOWER`, `CEMETERY`, `COURTYARD_RUIN`, `SHRINE`) orientados para a rua/praça mais próxima.
     - Estágio 5: parapeitos de contenção contínuos (`wall_runs` com `comprimento >= 2`) apenas em bordas traseiras/laterais altas, com colunas nas pontas.
     - Estágio 6: postes disciplinados (fora da rua, altura exata igual à célula de rua/praça adjacente, `yaw` voltado para a via, espaçamento Manhattan `>= 5`, máximo 10 acesos) e micro-props estritamente contextuais (sem pinheiros verdes vibrantes e sem peças estruturais soltas).
   - `ScenarioValidator`: auditor puro em código que valida **12 invariantes estruturais e visuais** antes de renderizar e nos testes automatizados:
     1. Praças planas em todos os nós do grafo.
     2. Conectividade de todas as arestas alcançáveis por `edge_paths` em passos ortogonais caminháveis.
     3. Degrau máximo de `1` bloco (`|Δh| <= 1`) entre células caminháveis ortogonais.
     4. Escadas apenas em `road_cells`, fora de praças, com exatamente `1` vizinho caminhável em `h + 1` e `yaw` apontando para ele.
     5. Água disjunta de zonas secas/estradas/prédios e com todo componente conectado `>= 6` células.
     6. Compostos 100% nivelados (variância de altura 0), disjuntos e com porta desobstruída (sem parede/água/penhasco logo à frente).
     7. **Regra de não-oclusão de câmera isométrica:** compostos altos (`CHAPEL`, `WATCHTOWER`, `COURTYARD_RUIN`) são proibidos no cone sudeste `(dx ∈ [1..2], dz ∈ [1..2])` de qualquer praça, preservando a leitura dos personagens, inimigos e bolhas (como o moinho ao fundo na referência de FFT).
     8. Zero muros isolados (`wall_runs` sempre `>= 2` células niveladas).
     9. Postes aterrados na mesma altura exata da rua/praça vizinha, sem bloquear entradas, `yaw` voltado para a rua e distância Manhattan `>= 5` entre si.
     10. Props estritamente contextuais e exclusivos (sem sobreposição, sem assets proibidos soltos).
     11. Zona `5×5` livre de props ao redor de cada nó de mapa (`test_map3d.gd`).
     12. Coerência e determinismo por semente.
   - `ScenarioRenderer`: constrói o terreno estratificado em `MultiMesh` (penhasco escuro em pedra/terra, topo natural musgo-ardósia escuro nos terraços, lajeado mineral nas praças/prédios, paralelepípedos quentes nas estradas, degraus, pontes com pilares/parapeito e água ondulada), instancia os compostos completos (incluindo telhados alinhados sobre criptas e cantos fechados de muros/cercas considerando o pivô deslocado do kit Kenney) e aplica tingimento consistente via `StageKit`.
2. **Dioramas focais coerentes (`generate_focal_diorama`):** todas as 11 cenas de foco (`combat_common`, `combat_elite`, `combat_boss`, `campfire`, `shop`, `chest`, `event`, `reward`, `home`, `victory`, `defeat`) usam a mesma gramática sobre grade `13×13` com `origin_offset = (-6, -6)` e `base_cliff_level = -2`, substituindo muros soltos e pinheiros verdes por terraços escalonados, escada real, arcos/criptas com telhado, braseiros simétricos e `character-keeper.glb` como mercador na loja (no lugar de `gravedigger`).
3. **Zero impacto no núcleo:** nenhuma mudança em `game/core/`; `CoreVersion.RULES_VERSION` permanece `20`.

## Alternativas

- **Ajustar manualmente offsets e chances em `Map3DLayout` e `Combat3DStage`:** apenas remendaria casos pontuais sem impedir novas quebras estruturais (muros soltos, oclusão de câmera, poças isoladas ou escadas de quina).
- **WFC (Wave Function Collapse) genérico sem validação de câmera/conectividade:** exigiria tabelas grandes de adjacência para meshes com pivôs assimétricos e ainda precisaria de um pós-validador para oclusão isométrica e arestas do `MapGraph`. O pipeline **Terrace-Grammar-Constraint** é mais compacto, 100% determinístico, garantido por construção e fácil de estender para os biomas dos cenários 2–5.

## Consequências

- Todos os cenários do mapa e das telas focais ganham coerência arquitetônica e legibilidade isométrica verificável automaticamente por teste (`ScenarioValidator`) e visualmente nos prints.
- Futuros cenários/biomas (Catacumbas, Brejo Doente, etc.) poderão reutilizar os mesmos 7 estágios trocando apenas paletas e tabelas de compostos/props do tema.
- A remoção de `pine-crooked.glb`/`pine-fall.glb` e a estratificação musgo escuro/pedra já eliminam os principais elementos "de brinquedo" apontados em `F-021` e preparam o terreno para o refinamento de iluminação da `TASK-051`.
