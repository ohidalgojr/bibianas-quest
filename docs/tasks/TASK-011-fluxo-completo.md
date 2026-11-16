# TASK-011: fluxo completo

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte 213/213 (2026-11-16); revisão cruzada e jogada humana pendentes |
| Aberta em | 2026-11-16 |
| Fase | 1, protótipo cinza |
| GDD | 4, 26 (morte que ensina, Ecos) |
| ADRs | ADR-0016 |

## Objetivo

Menu, Descida inteira, chefe, tela de fim e recomeço com nova semente, com contador de Ecos. Marco "MVP rodando".

## Fora do escopo

- Persistir Ecos (save, TASK-012), Santuário e compras com Ecos, outras classes.

## Critérios de aceite

- [x] Menu com Ecos, Descidas jogadas, classe (só o Guerreiro) e "Nova Descida".
- [x] Tela de fim com semente, quem derrotou a Bibiana, Poder, ouro, nós, chefes, Ecos ganhos e total.
- [x] "Outra Descida" recomeça com nova semente; três Descidas seguidas rodam sem reiniciar o jogo.
- [x] Ecos creditados também na derrota (GDD §26).

## Arquivos afetados

- `game/core/run/run_rules.gd`, `run_state.gd`; `game/presentation/game_screen.gd`, `main.gd`
- `tests/unit/test_run_rules.gd`, `test_run_state.gd`, `test_game_screen.gd`
- `docs/adr/ADR-0016-ecos-e-fluxo-completo.md`

## Verificação

2026-11-16: `tools\run_tests.ps1`, 27 scripts, 213/213. Falta o Orlando jogar três Descidas com o mouse.

## Revisão cruzada

Pendente.
