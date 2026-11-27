# TASK-070: tabuleiro isométrico fiel ao GDD §17 (volta do mapa em terraços, com pedra pintada e horizonte gótico)

| Campo | Valor |
| --- | --- |
| Status | Em verificação (falta o OK visual do Orlando) |
| Aberta em | 2026-11-26 |
| Fase | 1, identidade visual |
| GDD | 5, 17, 18 |
| ADRs | ADR-0057 (substitui ADR-0054 item 1; ADR-0036, ADR-0041, ADR-0042) |

## Objetivo

Corrigir o desvio da TASK-067: o mapa pintado rolável contrariava o GDD §17 (tabuleiro isométrico em terraços, nós como lugares do cenário, Bibiana caminhando pelas estradas, como em FFT, Tactics Ogre, Triangle Strategy e Sword of Convallaria). O tabuleiro 3D (`Map3DScreen`) volta como mapa e é levado à vibe das referências.

## Fora do escopo

- Camadas de paralaxe do primeiro plano (`map-fg-ironfence`, `map-mist-band`), discos de nó pintados (`ui-node-disc`) e ícones de nó (`ico-g-nodes`).
- Fogueira apagada pintada no nó e sprites de props além dos já usados.

## Critérios de aceite

- [x] `GameScreen` usa o `Map3DScreen`; `PaintedMapScreen` e seu teste removidos.
- [x] Pedra pintada (`assets/bibiana/textures/stone_cobble.jpg`, triplanar) em chão, estradas, praças e penhascos.
- [x] Mapa em resolução cheia, mais claro, com horizonte gótico pintado, névoa azul-ardósia e câmera com a Bibiana na metade de baixo.
- [x] Losangos de luz nos destinos, baú, fogueira e lápide em sprite, Bibiana de costas, inimigo derrotado não reaparece.
- [x] Seleção: seta pulsante acima do destino e trilha de losangos acesos até ele.
- [x] Suíte verde e prints `docs/tasks/prints/TASK-070-*.png`.

## Arquivos afetados

- `game/presentation/map3d/map3d_screen.gd`, `game/presentation/scenario/scenario_renderer.gd`, `game/presentation/stage/stage_kit.gd`, `game/presentation/stage/model_registry.gd`, `game/presentation/game_screen.gd`
- `assets/bibiana/textures/`, `assets/bibiana/arenas/`, `assets/bibiana/sprites/campfire.png`, `assets/LICENSES.md`

## Testes esperados

- `tests/unit/test_map3d.gd` (existente): layout, névoa, toque, caminhada e prévia continuam valendo.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR; núcleo sem nós.
- Cânone visual (`ADR-0042`); nunca mecha colorida (`F-024`).

## Verificação

Suíte completa em headless (Godot 4.7.2, GUT 9.7.1): 370 testes passando (2026-11-26). Prints reais 540x960 em `docs/tasks/prints/TASK-070-*.png`. Não verificado: celular e Windows real.

## Revisão cruzada

Revisão por modelo distinto (`Gemini`, `GDD §21` etapa 4, `docs/REVIEW-CHECKLIST.md`) sobre `f575da3`:
- **Aprovação estrutural e regras:** `game/core/` intacto (`RULES_VERSION` = 21); `PaintedMapScreen` removido sem resíduos; `test_map3d.gd` e `test_scenario_coherence.gd` cobrindo o retorno ao tabuleiro isométrico conforme `GDD §17` e `ADR-0057`.
- **Achados médios/menores:**
  1. *(Pendente → atendido em `TASK-075`)* Discos de pedra `ui/node_disc` e ícones `ico-g-nodes` nas bolhas de opção ficaram fora de `TASK-070` e entraram em `TASK-075`.
  2. *(Pendente → atendido em `TASK-074`)* `Map3DScreen._on_pick` chamava `ModelRegistry.play(..., "walk")` sem efeito sobre `Sprite3D`; passada animada nos quadros `walk_0..3` adicionada em `TASK-074`.
  3. *(Aberto / pós-cota)* Peças de parede/telhado do `kenney` seguem aguardando os sprites/texturas descritos em `ESTRUTURA-TABULEIRO-GOTICO.md §7.2` e o OK visual do Orlando.
