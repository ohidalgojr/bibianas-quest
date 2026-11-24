# TASK-068: cenários pintados (loja, fogueira, recompensa, Home) e seleção legível no mapa

| Campo | Valor |
| --- | --- |
| Status | Em verificação (falta o OK visual do Orlando) |
| Aberta em | 2026-11-24 |
| Fase | 1, identidade visual |
| GDD | 17, 18, 19 |
| ADRs | ADR-0055 (ADR-0042, ADR-0054) |

## Objetivo

Resolver o feedback do Orlando sobre o build testado: telas de recompensa, vitória, loja e fogueira com objetos 3D soltos e sem sentido, e seleção de nó no mapa sem foco nem indicação do caminho.

## Fora do escopo

- Ícones de skills, itens e ações (o "furacão" do Fugir): dependem do guia de arte `docs/design/GUIA-DE-ARTE-DARK-FANTASY-MOBILE.md` e de arte nova.
- Grade da loja que estoura a tela; painel de resultado; selo de intenção como ícone.
- Arenas `arena-cidade-chefe` e `arena-fogueira-apagada` (a fogueira apagada escurece a acesa).

## Critérios de aceite

- [x] Campfire, shop, chest, event, reward, home, victory e defeat usam arena pintada com a Bibiana e o NPC em sprite, sombra de contato e luz, sem 3D solto.
- [x] No mapa, o primeiro toque num destino foca nele (sobe para a metade de cima), mostra seta pulsante acima do sprite e acende o trecho da estrada até ele.
- [x] Suíte verde e prints `docs/tasks/prints/TASK-068-*.png`.

## Arquivos afetados

- `game/presentation/camp3d/scene3d_backdrop.gd`, `game/presentation/map2d/painted_map_screen.gd`
- `tests/unit/test_scene3d.gd`, `tests/unit/test_scenario_coherence.gd`, `tests/unit/test_atmosphere.gd`

## Testes esperados

- Os testes dos cenários conferem o modo pintado (peças, mercador `shop_keeper`, véu e halo da fogueira).

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR; núcleo sem nós.
- Cânone visual: `docs/ART-DIRECTION.md` e `ADR-0042`; nunca mecha colorida (`F-024`).

## Verificação

Suíte completa em headless (Godot 4.7.2, GUT 9.7.1): 376 testes passando (2026-11-24). Prints reais em `docs/tasks/prints/TASK-068-*.png`. Não verificado: celular e Windows real.

## Revisão cruzada

Pendente.
