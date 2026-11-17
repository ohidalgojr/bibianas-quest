# TASK-020: skills novas na loja

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte 254/254 (2026-11-16); jogada humana e revisão cruzada pendentes |
| Aberta em | 2026-11-16 |
| Fase | 1, ajuste pelo playtest (`docs/FEEDBACK.md`, F-004) |
| GDD | 8 (skills), 15 (item especial da loja) |
| ADRs | ADR-0024 |

## Objetivo

A loja passa a oferecer uma skill nova do Guerreiro por visita, para comprar com ouro. O combate aceita até 5 skills. Três skills novas: Golpe Giratório (dano), Grito de Guerra (FOR e MEN +25% por 3 turnos) e Segundo Fôlego (cura 25% do HP).

## Fora do escopo

- Outras classes, troca de skill (esquecer uma), skills de fogueira novas, uso do Éter Sujo em combate.

## Critérios de aceite

- [x] Três skills novas nos dados, com preço; skills iniciais com preço 0.
- [x] A loja oferece, ao abrir, uma skill ainda não aprendida (fluxo de loot); `buy_skill` cobra, aprende e respeita o limite de 5.
- [x] O combate da Descida usa as skills aprendidas; a tela mostra até 5 botões de skill.
- [x] Os três efeitos funcionam no motor (dano, Fúria de +25% de ataque, cura).
- [x] A skill aprendida entra no save; bots compram e usam skills.
- [x] GDD §8 e §15 atualizados, ADR-0024, `RULES_VERSION` incrementado, simulador rodado, suíte verde.

## Arquivos afetados

- `game/data/skills.json`; `game/core/combat/` (`combat_skill`, `combat_effect`, `combatant`, `combat`); `game/core/data/` (`game_data`, `data_validator`); `game/core/run/` (`run_rules`, `run_state`, `run_save`); `game/core/sim/run_bot.gd`
- `game/presentation/combat/` (sessão, tela), `game/presentation/run/` (painéis e tela)
- `tests/`, `docs/GDD.md`, `docs/FEEDBACK.md`, `docs/HANDOFF.md`

## Verificação

2026-11-16: `toolsun_tests.ps1`, 32 scripts, 254/254 (cerca de 100 s). Simulador regras v8: mediano 65,3%, cuidadoso 80,7%, 0 mapas sem rota em 100 (ADR-0024).

## Revisão cruzada

Pendente.
