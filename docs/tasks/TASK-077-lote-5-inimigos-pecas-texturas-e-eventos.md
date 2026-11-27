# TASK-077: lote 5 do Gemini (inimigos novos, peças de cenário, texturas e eventos)

| Campo | Valor |
| --- | --- |
| Status | Concluída com ressalvas (revisada pelo agente de arte) |
| Aberta em | 2026-11-27 |
| Fase | 1, identidade visual |
| GDD | 17, 18 |
| ADRs | ADR-0064 (ADR-0042, ADR-0060) |

## Objetivo

Integrar o lote 5 de assets do Orlando: 4 sprites de inimigo, 7 peças de cenário, 4 texturas e as 3 ilustrações de evento que faltavam.

## Fora do escopo

- Dados e regras dos inimigos `lipless_choir`, `calcified_knight` e do Roaming Boss `crowned_pursuer` (só sprites registrados).
- Portas, janelas e sacadas como decalques nas casas; ponte de pedra em sprite; faixa de mapa `map-strip-04-canal` (ficam prontas para a próxima tarefa de fachada).

## Critérios de aceite

- [x] `lipless_choir`, `calcified_knight`, `trench_crawler` (novo, olha para a esquerda) e `crowned_pursuer` recortados (`tools/make_sprite.py`) e no `ModelRegistry`.
- [x] `make_sprite.py --all` mantém todos os pedaços (portão de ferro com duas folhas e torres).
- [x] Texturas sem emenda (espelho 2x2, 768 px) em casas (reboco com madeira), telhados (ardósia), muros (pedra de arrimo) e pátios (entulho), por tom da peça.
- [x] Poço, forca de três cordas e lápide alternam nos nós de evento do mapa.
- [x] Os 6 eventos têm ilustração; originais grandes movidos para `docs/design/refs/`.
- [x] Suíte verde e prints.

## Arquivos afetados

- `tools/make_sprite.py`, `game/presentation/scenario/scenario_renderer.gd`, `game/presentation/stage/model_registry.gd`, `game/presentation/map3d/map3d_screen.gd`
- `assets/bibiana/{sprites,textures,events}/`, `docs/design/refs/{props,textures}/`

## Testes esperados

- `test_stage_assets`: todo sprite registrado carrega.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR; núcleo sem nós.
- Cânone visual (`ADR-0042`); nunca mecha colorida (`F-024`).

## Verificação

Suíte completa em headless: 380 testes passando (2026-11-27). Prints em `docs/tasks/prints/TASK-077-*.png`.

## Revisão cruzada

Agente de arte (`docs/design/critica-diretor/REVISAO-LOTE-5.md`): APROVA sem P0 (tabuleiro 6,0 para 7,5). Aplicado: menos repetição da textura em muros e pátios, telhado menos azul. Pendente: print de um nó de evento (poço, forca, lápide) e de luta com inimigo novo (sem dados ainda); muretes lilás lisos e `crowned_pursuer` quase preto (luz de borda).
