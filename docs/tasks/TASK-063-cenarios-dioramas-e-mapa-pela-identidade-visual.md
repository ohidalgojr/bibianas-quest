# TASK-063: cenários (fogueira, loja, arena e mapa) pela identidade visual

| Campo | Valor |
| --- | --- |
| Status | Em andamento (rodada 1 reprovada pelo diretor de arte em 7 de 7 prints; rodada 2 entregue, aguardando nova revisão) |
| Aberta em | 2026-11-22 |
| Fase | 1, identidade visual |
| GDD | 17, 18, 19 |
| ADRs | ADR-0050 |

## Objetivo

Refazer a fogueira, a loja, a arena do duelo e o mapa para serem lugares sombrios coerentes (nave gótica, arcos ogivais, contrafortes, uma luz âmbar por cena), em vez de blocos tingidos, aprovados só por print do jogo.

## Fora do escopo

- Baú, evento, recompensa, vitória, derrota e Home em nova versão (lote seguinte).

## Critérios de aceite

- [ ] Fogueira (acesa e apagada), loja, arena comum e de chefe, mapa: 12/12 do diretor de arte.
- [x] Peças góticas próprias (`tools/blender/make_scenery.py`: arco ogival, arcada, contraforte, agulha) com licença registrada.
- [x] Sem cabeçalho de depuração no mapa; cartões da loja legíveis.

## Arquivos afetados

- `game/presentation/camp3d/scene3d_backdrop.gd`, `camp3d/focal_set.gd`, `combat3d/duel_arena.gd`, `scenario/scenario_renderer.gd`, `map3d/map3d_screen.gd`, `run/run_panel_screen.gd`, `tools/blender/make_scenery.py`, `assets/bibiana/scenery/`

## Testes esperados

- `test_scenario_coherence.gd` e `test_scene3d.gd` seguem verdes.

## Regras que esta tarefa não pode quebrar

- Cânone visual (ADR-0042 e ADR-0050); sem mudança de regra nem de `RULES_VERSION`.

## Verificação

Rodada 2 entregue; suíte 369/369 em 2026-11-22. **Pendente: nova revisão do diretor de arte** sobre `docs/tasks/prints/TASK-063-*.png` (ver `docs/design/PROXIMA-RODADA-VALIDACAO.md`).

## Revisão cruzada

Pendente.
