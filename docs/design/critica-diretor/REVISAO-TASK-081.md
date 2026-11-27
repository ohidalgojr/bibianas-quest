# Revisão cruzada da TASK-081 (ADR-0067): lutas mínimas por rota

Revisor: outro modelo. Rodada 1: commit `3047c73` (reprovado). Rodada 2 (final): commit `69adff0`, 2026-11-27. Script de apoio: `/tmp/claude-0/rv_scripts/rv.gd` (Descidas reais com `RunState.new`, rota mais pobre de `run.map`, `MapRules` conferido).

## Veredito final: APROVA PARA PUBLICAR = SIM

A falha P0 da rodada 1 está corrigida e confirmada por medição. O que sustenta o sim:
- Suíte 395/395 verde (`--import` + GUT headless, lida nesta rodada).
- 100 sementes por combinação, com a checagem de vencibilidade de 200 simulações como no jogo: 0 rotas com menos de 2 lutas e 0 violações de `MapRules` em todas as combinações abaixo.

| Camadas | first_run | Rota mais pobre (lutas: sementes) | Falhas |
| --- | --- | --- | --- |
| 4 | sim | 2: 100 | 0 |
| 4 | não | 2: 93, 3: 7 | 0 |
| 6 | sim / não | 2 a 4 / 2 a 4 | 0 / 0 |
| 10 | sim / não | 2 a 6 / 2 a 6 | 0 / 0 |

Sem a checagem (0 simulações) o resultado é o mesmo: 0 falhas em 600 Descidas. Na rodada 1 eram 43 de 100 sementes de 4 camadas na 1ª Descida.

## Correções conferidas

- `map_generator.gd`: `poorest_route` e `ensure_fights_on_every_route` públicos; o reparo converte o ÚLTIMO baú/evento da rota e aceita nós protegidos.
- `run_state.gd:1071,1086`: `_restore_route_fights` reaplica a regra depois das garantias da 1ª Descida, protege os baús da camada 2 e dá ao nó convertido o Cidadão Infectado no nível da camada (teste confirma que nenhuma batalha fica sem inimigo).
- `winnability.gd:131`: usa a API pública; a troca por baú segue revertendo se quebrar regra ou mínimo.
- `test_map_fights.gd`: testes com `RunState` real (1ª Descida e normal, 40 sementes) e de nó convertido com inimigo. Falta só teste em 6 e 10 camadas (hoje só 4, o único cenário existente).
- Fora do P0: dica da 1ª Descida (fecha ao tocar, só na 1ª Descida), `end_summary` (camada limitada, `unlock_line`) e carga sem texto técnico continuam corretos.

## Pendências menores (não bloqueiam)

- **P2** `map_generator.gd:30-33`: o comentário de `MIN_FIGHTS_PER_ROUTE` ainda diz "o primeiro baú ou evento"; agora é o último. Corrigir o texto.
- **P2** `docs/HANDOFF.md`: tabela diz "394/394"; a suíte tem 395. Restam "RULES_VERSION = 24" nos trechos históricos de TASK-078 a 080 (eram 23) e "Equilíbrio (simulador, regras v15)" sem aviso de que a v24 não foi medida.
- **P2** `test_map_fights.gd`: o parâmetro `layers` de `_run_min_fights` não é usado (código morto); o nome promete 4, 6 e 10 camadas mas só roda 4.
- **P2** `map3d_screen.gd:373,441`: banner do Perseguidor (y=82) e dica (y=126) a ~2 px; sem conflito hoje (Perseguidor desligado no cenário 1).
- **P2** `game_screen.gd:519-536`: rolagem da tela de fim não validada em toque; "Início" fica fora da vista. A dica bloqueia toques sob ela até ser fechada.
- **P2** Simulador de equilíbrio não rodado (regra 9 do CLAUDE.md): o efeito da garantia nas metas de vitória da 1ª Descida (35% a 55%) é desconhecido. Tempo de criação com 200 simulações foi ~3 s por Descida em CPU compartilhada com 3 processos (não é medida de celular).
