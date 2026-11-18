# TASK-025: inimigos únicos, IA reativa e golpes de moeda temáticos

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte 285/285 (2026-11-18); jogada humana e revisão cruzada pendentes |
| Aberta em | 2026-11-18 |
| Fase | 1, ajuste pelo playtest (D4 do ADR-0025; `docs/FEEDBACK.md` F-006, F-012, F-013, F-018) |
| GDD | 6, 7, 11, 21 |
| ADRs | ADR-0025, ADR-0030 |

## Objetivo

Cada inimigo do cenário 1 passa a ter identidade: um medo próprio (inspirado em Fear & Hunger), um golpe de moeda temático com consequência concreta (efeito ou doença), e uma reação inteligente ao estado da luta. O processo de design vira um papel da pipeline, com uma ficha por inimigo em `docs/enemies/`, preenchida e implementada sem aprovação prévia do Orlando (D4).

## Fora do escopo

- Emboscadas e inimigos mais difíceis por sorte, mutados, mini boss e roaming boss (não existem no protótipo); eventos de mapa.
- Arte, som e animação própria por inimigo (Fase 2).
- Outras doenças além da Leptospirose (o sistema aceita mais).

## Critérios de aceite

- [x] Modelo de ficha `docs/enemies/_modelo.md` e uma ficha para cada um dos 6 inimigos (4 comuns, elite, chefe).
- [x] Golpes de moeda com consequência temática, por inimigo: efeito de combate (Febre/Fraqueza, Cegueira, Lentidão, Maldição) ou doença (Leptospirose: -15% do HP máximo até tratar na fogueira). O aviso mostra a consequência.
- [x] Doença persiste entre lutas, aparece no mapa e na fogueira, e se trata na fogueira por 1 Brasa.
- [x] IA reativa: cada inimigo tem ao menos uma reação (vida do jogador ou do inimigo baixa, Defender repetido, jogador fortalecido), avisada no aviso de intenção, sem quebrar as regras de justiça (golpe perigoso sempre avisado, intervalo entre golpes de moeda).
- [x] Dados validados (golpes com efeito e doença, reações), testes de cada mecânica, simulador rodado.
- [x] GDD §6, §7, §11 e §21 atualizados, ADR-0030, `RULES_VERSION` incrementado, suíte verde.

## Arquivos afetados

- `docs/enemies/` (novo), `game/data/enemies.json`; `game/core/combat/` (`enemy_move`, `combat_effect`, `combatant`, `combat`, `disease` novo); `game/core/data/` (`game_data`, `data_validator`); `game/core/run/` (`run_state`, `run_save`)
- `game/presentation/` (textos, sessão, tela do combate, painéis e cabeçalho)
- `tests/`, `docs/GDD.md`, `docs/HANDOFF.md`

## Verificação

2026-11-18: `tools\run_tests.ps1`, 35 scripts, 285/285. Simulador regras v13 com Coveiro 175/16: mediano 62,0%, 0 mapas sem rota em 40, 1,3 s para criar a Descida (ADR-0030).

## Revisão cruzada

Pendente.
