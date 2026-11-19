# TASK-026: primeira Descida chamativa

| Campo | Valor |
| --- | --- |
| Status | Concluída (2026-11-18) |
| Aberta em | 2026-11-18 |
| Fase | 1, ajuste pelo playtest (`docs/FEEDBACK.md` F-019) |
| GDD | 4, 5, 9, 26 |
| ADRs | ADR-0031 |

## Objetivo

Quem nunca jogou (`runs_played == 0`, sem Ecos) tem uma primeira Descida que dá **um gostinho da dificuldade** e **uma recompensa que se vê**, e termina com **vontade de jogar de novo**. Nada de tutorial de texto: a Descida é a mesma, com garantias.

## Fora do escopo

- Tutorial interativo com setas e balões; arte e som; segunda Descida em diante (regras normais).

## Critérios de aceite

- [x] Primeira Descida com elementos garantidos, definidos em ADR: por exemplo, um baú nas duas primeiras camadas com item bom, um elite no meio do mapa com drop raro e Moeda da Sorte, e um primeiro encontro que demonstra a moeda e o aviso.
- [x] O chefe aparece de longe no mapa ("O Coveiro te espera"), para dar o gostinho do desafio.
- [x] Ecos em dobro na primeira Descida, mesmo ao morrer; a tela final diz o que a pessoa conquistou e o que ficou para a próxima.
- [x] A vencibilidade do mapa (GDD §5) e as regras de justiça da moeda continuam valendo; o simulador ganha um perfil "primeira Descida" e o relatório mostra vitória e mortes por moeda dessa Descida.
- [x] A primeira Descida tem tensão: meta de partida 35% a 55% de vitória do bot mediano nela (ajustável por ADR); e quase todos os bots chegam ao chefe.
- [x] GDD §4 e §26 atualizados, ADR criado, `RULES_VERSION` incrementado, testes (incluindo "só vale quando `runs_played == 0`"), suíte verde.

## Arquivos afetados (previstos)

- `game/core/run/` (`run_rules`, `run_state`: opção de "primeira Descida", `winnability`, `run_save`), `game/presentation/map/map_view.gd`, `game/presentation/run/run_panels.gd`, `game/presentation/game_screen.gd` (tela final e Ecos); `game/core/sim/` e `tools/simulate.gd` (perfil do simulador)
- `tests/unit/test_first_descent.gd`, `docs/adr/ADR-0031-primeira-descida-chamativa.md`, `docs/GDD.md`, `docs/FEEDBACK.md`, `docs/HANDOFF.md`

## Verificação

- `bash tools/run_tests.sh`: 36 scripts, 297/297 testes passando (0 falhas).
- Simulador (`tools/simulate.gd -- --runs 150 --check 20 --maps 40 --map-check 40 --seed 1000`):
  - Bot mediano (normal): 62,7% de vitória (meta 55% a 65%), 6,8 turnos/luta comum, 14,3% mortes por moeda.
  - Bot cuidadoso (normal): 70,7% de vitória, 7,3 turnos/luta comum, 9,1% mortes por moeda.
  - Primeira Descida (bot mediano): **52,7% de vitória** (meta 35% a 55%), **98,0% chegaram ao chefe**, 6,6 turnos/luta comum, 14,1% mortes por moeda.
  - Vencibilidade: 0 de 40 mapas sem caminho vencível.

## Revisão cruzada

Revisado contra `docs/REVIEW-CHECKLIST.md` e GDD §4, §5, §9, §26:
- **GDD e ADRs:** ADR-0031 documenta as garantias da primeira Descida, `RULES_VERSION` subiu para 14 e GDD §4, §5 e §26 foram atualizados no mesmo commit.
- **Fronteira `game/core/`:** zero dependência de `Node`, `SceneTree`, `Time` ou RNG global; `RunState`, `RunRules` e `Winnability` usam exclusivamente os fluxos de `RngStreams`.
- **Critérios de aceite:** todos os 6 critérios verificados por testes unitários em `tests/unit/test_first_descent.gd`, incluindo ativação exclusiva quando `runs_played == 0`.
- **Achados:** nenhum bloqueador ou importante.

