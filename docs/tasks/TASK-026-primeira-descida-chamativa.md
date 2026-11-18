# TASK-026: primeira Descida chamativa

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada) |
| Aberta em | 2026-11-18 |
| Fase | 1, ajuste pelo playtest (`docs/FEEDBACK.md` F-019) |
| GDD | 4, 5, 9, 26 |
| ADRs | a criar (ADR-0031 em diante; ver `docs/adr/`) |

## Objetivo

Quem nunca jogou (`runs_played == 0`, sem Ecos) tem uma primeira Descida que dá **um gostinho da dificuldade** e **uma recompensa que se vê**, e termina com **vontade de jogar de novo**. Nada de tutorial de texto: a Descida é a mesma, com garantias.

## Fora do escopo

- Tutorial interativo com setas e balões; arte e som; segunda Descida em diante (regras normais).

## Critérios de aceite

- [ ] Primeira Descida com elementos garantidos, definidos em ADR: por exemplo, um baú nas duas primeiras camadas com item bom, um elite no meio do mapa com drop raro e Moeda da Sorte, e um primeiro encontro que demonstra a moeda e o aviso.
- [ ] O chefe aparece de longe no mapa ("O Coveiro te espera"), para dar o gostinho do desafio.
- [ ] Ecos em dobro na primeira Descida, mesmo ao morrer; a tela final diz o que a pessoa conquistou e o que ficou para a próxima.
- [ ] A vencibilidade do mapa (GDD §5) e as regras de justiça da moeda continuam valendo; o simulador ganha um perfil "primeira Descida" e o relatório mostra vitória e mortes por moeda dessa Descida.
- [ ] A primeira Descida tem tensão: meta de partida 35% a 55% de vitória do bot mediano nela (ajustável por ADR); e quase todos os bots chegam ao chefe.
- [ ] GDD §4 e §26 atualizados, ADR criado, `RULES_VERSION` incrementado, testes (incluindo "só vale quando `runs_played == 0`"), suíte verde.

## Arquivos afetados (previstos)

- `game/core/run/` (`run_rules`, `run_state`: opção de "primeira Descida"), `game/core/map/` se o mapa precisar de garantias; `game/presentation/game_screen.gd` (tela final e Ecos); `game/core/sim/` (perfil do simulador)
- `tests/`, `docs/GDD.md`, `docs/HANDOFF.md`

## Verificação

(preencher)

## Revisão cruzada

Pendente.
