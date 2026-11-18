# TASK-004: motor de combate e moeda (Guerreiro)

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte completa 120/120 (2026-11-16); revisão cruzada pendente |
| Aberta em | 2026-11-16 |
| Fase | 1, protótipo cinza (GDD §22; roteiro em `docs/ROADMAP-MVP.md`) |
| GDD | 6 (combate), 7 (cara ou coroa), 8 (Guerreiro), 9 (atributos por Poder), 11 (Lentidão) |
| ADRs | ADR-0008 |

## Objetivo

O núcleo resolve uma luta 1 contra 1 da Bibiana (Guerreiro) contra um inimigo, sem tela: turnos por Carga, intenção avisada, dano e acerto pelas fórmulas do GDD, cara ou coroa com Maré de azar, Defender, as três skills do Guerreiro, item de cura e fuga. Tudo sai como eventos para a apresentação, e as regras de justiça valem em milhares de lutas.

## Fora do escopo

- Outras classes, Preparo, debuffs e doenças, clima, mutações, Re-jogada, Moeda da Sorte e trapaça por anúncio (a fórmula existe, mas não está ligada).
- Dados de verdade de inimigos, itens e da classe (TASK-005); aqui os inimigos de teste são inventados.
- Poder e ouro ganhos ao vencer (TASK-007). Tela (TASK-006).

## Critérios de aceite

- [ ] Fórmulas de dano, acerto, crítico, elemento, Defender, multiplicadores da moeda e crescimento por Poder testadas contra o GDD, citando a seção.
- [ ] Chance da moeda `clamp(50 + SORTE + mods, 15, 85)`, SORTE até +15, Maré de azar +10 após 3 perdas, trapaça com teto de 90.
- [ ] Ordem de turnos por Carga (VEL até 100), com previsão dos próximos turnos para a linha do tempo.
- [ ] Intenção do inimigo emitida antes de agir; golpe perigoso sempre com um turno da Bibiana entre o aviso e o golpe.
- [ ] Guerreiro: Golpe de Escudo (Cara atordoa; em chefe, Lentidão), Investida, Muralha, Veterano.
- [ ] Item de cura, fuga pela moeda (chefe não permite), vitória, derrota e fuga encerram a luta.
- [ ] Propriedade em 2.000 lutas jogadas por bot: sem morte imediata acima de 60%, sem golpe perigoso sem aviso, sem moedas seguidas fora da fase final de chefe, sem o mesmo golpe forte duas vezes, toda luta termina.
- [ ] Mesma semente e mesmas escolhas, mesma luta; acerto, crítico e IA no fluxo de combate e moeda no fluxo da moeda.
- [ ] `RULES_VERSION` sobe para 2. Suíte verde no observador.

## Arquivos afetados

- `game/core/combat/`: `stats.gd`, `combat_formulas.gd`, `coin_rules.gd`, `coin_state.gd`, `enemy_move.gd`, `enemy_phase.gd`, `combat_effect.gd`, `combat_skill.gd`, `combat_item.gd`, `combat_event.gd`, `combatant.gd`, `combat.gd`
- `game/core/core_version.gd`
- `tests/support/combat_fixtures.gd` (inimigos de teste, bot e auditor)
- `tests/unit/test_stats.gd`, `test_combat_formulas.gd`, `test_coin.gd`, `test_combat.gd`, `test_combat_properties.gd`
- `docs/adr/ADR-0008-combate-leituras-do-gdd.md`

## Testes esperados

- `test_stats.gd`: atributos do Guerreiro e crescimento com Poder 1, 2 e 45.
- `test_combat_formulas.gd`: dano, arredondamento, acerto, Defender, Veterano, tabela da moeda, limite de morte.
- `test_coin.gd`: chance, limites, Maré de azar, trapaça, frequência real dos lances.
- `test_combat.gd`: início, ordem de turnos, aviso contra inimigo rápido, ações inválidas, chefe sem fuga, Defender, Golpe de Escudo (Cara, Coroa, chefe), Investida, Muralha, item, fuga, vitória, morte imediata, fases, tooltip, determinismo.
- `test_combat_properties.gd`: as regras de justiça em 2.000 lutas e um teste de que o auditor enxerga cada violação.

## Regras que esta tarefa não pode quebrar

- Fórmulas do GDD só mudam com ADR; as leituras estão no ADR-0008.
- Núcleo sem nós; sorteio só por `RngStreams`; o núcleo fala por eventos.

## Verificação

- 2026-11-16 11:45: os scripts do combate não compilaram por um problema de tipo do Godot 4.7 com o enum `Combatant.Side` (referência cíclica entre classes). Troquei o enum por constantes inteiras (`Combatant.PLAYER`, `Combatant.ENEMY`).
- 2026-11-16 11:47, saída parcial: `test_coin` 6/6, `test_combat` 18/18, `test_combat_formulas` 9/9, `test_combat_properties` 2/2, `test_stats` não chegou a rodar nessa ordem (rodou verde, 5/5, na rodada anterior). Lutas do bot: Rato 6,2 turnos do jogador por luta, Brutamontes 14,6, Cão 8,4, Coveiro 26,7; 1.443 vitórias, 414 derrotas, 143 fugas, 8.526 golpes de moeda do inimigo, nenhuma violação.
- 2026-11-16 12:00: suíte completa pelo `run_tests.ps1` no Claude Code: 14 scripts, 120/120, exit 0, 19 s (o observador registrou o mesmo resultado às 11:56).
- Anotação anterior, superada pelas rodadas acima: **a rodada parou no meio de `test_map_generator`** (que antes passava em 19 s) e o processo ficou preso. Causa ainda desconhecida. O observador ganhou limite de tempo (`-TimeoutMinutes`, padrão 8). Falta repetir a suíte inteira.

## Revisão cruzada

Revisado por Gemini (modelo distinto do autor original, Claude Opus 4.6), seguindo `docs/REVIEW-CHECKLIST.md`:
- **GDD §6, §7, §8, §11, §13 e `ADR-0008`**: fila de turnos por `VEL` (`TURN_THRESHOLD = 100`, empate do jogador), `_move_allowed()` garantindo `coin_cooldown == 0` para golpes de moeda, e ordem de multiplicadores em `_strike` (elemento × crítico × variação `0,90..1,10` × defesa ativa × postura defensiva × veterano).
- **Achados corrigidos na `TASK-029`**:
  - *Sugestão (`game/core/combat/combatant.gd`)*: método `in_final_phase()` havia ficado sem uso após a `TASK-016` (`ADR-0020`) remover a exceção de fase final; removido para manter o núcleo sem código morto.
  - *Sugestão (`game/core/combat/combat_event.gd`)*: comentário de `COIN` atualizado para refletir `flag = acertou o lado` e `extra = 1 se a Moeda da Sorte re-jogou` (`ADR-0026`).
  - *Sugestão (`game/core/combat/combat_effect.gd`)*: `debuff_turns()` trocado de ternário implícito para `match` explícito sobre os tipos de debuff.
