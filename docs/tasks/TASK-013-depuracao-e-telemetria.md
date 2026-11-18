# TASK-013: atalhos de depuração e telemetria local

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte 222/222 (2026-11-16); revisão cruzada e jogada humana pendentes |
| Aberta em | 2026-11-16 |
| Fase | 1, protótipo cinza |
| GDD | 7 e 23 (mortes por moeda), 20 |
| ADRs | ADR-0018 |

## Objetivo

Atalhos para testar rápido, só em build de desenvolvimento, e um log local de eventos por nó, luta, moeda e morte, para medir a parcela de mortes por moeda (GDD §23).

## Fora do escopo

- Envio do log para qualquer servidor, painel de métricas, anúncios.

## Critérios de aceite

- [x] Em build de depuração: semente digitável no menu, F1 +100 de ouro, F2 pular nó, F3 matar o inimigo, F4 forçar a moeda (normal, sempre acerta, sempre erra), com uma linha de ajuda na tela.
- [x] Fora de build de depuração (`OS.is_debug_build()` falso) nenhum atalho age.
- [x] `telemetry.log` em `user://` com uma linha JSON por evento: nó, ouro, gasto, fogueira, cenário, fim da Descida, cada lance de moeda (chance, resultado, Maré de azar), resumo da luta e morte com a marca de morte por moeda.
- [x] O núcleo só ganhou `Combat.forced_coin` e `debug_kill_enemy`; o sorteio da moeda continua acontecendo.

## Arquivos afetados

- `game/core/combat/combat.gd`; `game/services/telemetry.gd` (novo); `game/presentation/game_screen.gd`, `combat/combat_screen.gd`
- `tests/unit/test_telemetry.gd` (novo), `test_game_screen.gd`, `test_save.gd`
- `docs/adr/ADR-0018-depuracao-e-telemetria.md`

## Verificação

2026-11-16: `tools\run_tests.ps1`, 29 scripts, 222/222. O log fica em `%APPDATA%\Godot\app_userdata\<nome do projeto>\telemetry.log`.

## Revisão cruzada

Revisado por Gemini (modelo distinto do autor original, Claude Opus 4.6), seguindo `docs/REVIEW-CHECKLIST.md`:
- **GDD §7, §20, §23 e `ADR-0018`**: atalhos `F1..F4` restritos a `debug_enabled` (`OS.is_debug_build()`); `Telemetry.run_lines()` e `Telemetry.fight_lines()` são funções estáticas puras testadas sem disco, registrando `by_coin` quando o golpe fatal vem imediatamente após um lance de moeda perdido do inimigo.
- **Achados**: nenhum achado crítico ou importante. Aprovada.
