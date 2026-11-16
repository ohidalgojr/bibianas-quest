# TASK-016: ritmo da moeda e debuffs por probabilidade no chefe

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte 231/231 (2026-11-16); jogada humana e revisão cruzada pendentes |
| Aberta em | 2026-11-16 |
| Fase | 1, ajuste pelo playtest (`docs/FEEDBACK.md`, F-001 e F-002) |
| GDD | 6, 7, 11 |
| ADRs | ADR-0020 |

## Objetivo

O chefe deixa de encadear golpes de moeda e ganha golpes com debuff que acertam por chance própria (fluxo de combate), com aviso e chance visíveis, para a moeda não decidir tudo.

## Fora do escopo

- Debuffs de outros inimigos além do chefe, Sangramento, doenças, itens e skills que curam debuff (Purgar, Antídoto), debuffs no inimigo.
- F-003, progressão (TASK-017).

## Critérios de aceite

- [x] Nenhum inimigo, chefe inclusive, usa dois golpes de moeda sem ao menos 2 golpes entre eles. A exceção da fase final sai.
- [x] Novo tipo de golpe `debuff`: causa dano e, se acertar, aplica o efeito com a chance do golpe (sorteio no fluxo de combate); Defender corta a chance pela metade.
- [x] Veneno (5% do HP máximo por turno, 4 turnos) e Fraqueza (FOR e MEN -25%, 3 turnos), valores do GDD §11.
- [x] O aviso do turno anterior mostra o ícone DEBILITA, o efeito e a chance.
- [x] O Coveiro usa os dois golpes novos e menos moeda; o simulador roda de novo e o relatório é anotado.
- [x] GDD §6, §7 e §11 atualizados, ADR-0020, `RULES_VERSION` incrementado, suíte verde.

## Arquivos afetados

- `game/core/combat/` (`enemy_move`, `combat_effect`, `combatant`, `combat`), `game/core/data/` (`game_data`, `data_validator`), `game/data/enemies.json`
- `game/presentation/combat/` (textos, sessão, tela), `game/core/core_version.gd`
- `tests/` (combate, dados, apoio), `docs/GDD.md`, `docs/FEEDBACK.md`, `docs/HANDOFF.md`

## Testes esperados

- Intervalo mínimo entre golpes de moeda, em muitas sementes e no auditor de justiça.
- Debuff: chance 100% e 0%, metade ao defender, Veneno tira 5% por turno e some em 4, Fraqueza reduz o dano da Bibiana.
- Validação de dados do golpe `debuff`.

## Verificação

2026-11-16: `toolsun_tests.ps1`, 30 scripts, 231/231. Simulador (200 Descidas, regras v5): bot mediano 56,0% de vitória, 21,6% das mortes por moeda, 6,3 turnos por combate comum; cuidadoso 74,5%, 17,6%, 5,8. Detalhes no ADR-0020.

## Revisão cruzada

Pendente.
