# Revisão cruzada da TASK-081 (ADR-0067): lutas mínimas por rota

Revisor: outro modelo. Commit `3047c73`, 2026-11-27. Suíte 393/393 verde (lida nesta rodada). Script de apoio: `/tmp/claude-0/rv_scripts/rv.gd` (Descidas reais com `RunState.new`, rota mais pobre de `run.map`).

## Veredito: NÃO APROVA PARA PUBLICAR

A garantia central do ADR-0067 falha na 1ª Descida (`first_run = true`), que é justamente o caso do P0 (jogador novo, sem Poder). Medição com `RunState.new(...)` e rota mais pobre de `run.map`:

| Cenário | first_run | Sementes com rota de 1 luta |
| --- | --- | --- |
| 4 camadas, sem checagem | sim / não | 43 de 100 / 0 de 100 |
| 4 camadas, checagem de 200 simulações (como no jogo) | sim | sementes 1, 3, 4... (falha logo nas primeiras) |
| 6 camadas | sim / não | 21 de 100 / 0 de 100 |
| 10 camadas | sim / não | 1 de 100 / 0 de 100 |

Rotas típicas: `S B C F C`, `S B C F V`, `S B C V C` (batalha, baú, fogueira, baú/vazio): 1 luta antes do chefe. Fora da 1ª Descida a garantia vale (0 falhas em 100 sementes de 4, 6 e 10 camadas; 0 violações de `MapRules`).

## P0

- **P0-1** `game/core/run/run_state.gd:1069-1070` e `:1099-1117` (`_apply_first_run_guarantees`). O gerador repara o mapa em `generate()`, mas depois `_assign_enemies` e `_apply_first_run_guarantees` mexem nele: a camada 1 vira toda batalha e um nó da camada 2 vira baú à força (linha 1115), sem checar `_poorest_route`. Resultado: `batalha, baú, fogueira, baú` = 1 luta. A checagem só foi acrescentada em `Winnability.smooth`, não aqui. Correção: ao trocar o nó da camada 2 por baú, reverter se `MapGenerator._poorest_route(map)["fights"] < MIN_FIGHTS_PER_ROUTE` (como em `winnability.gd:130`); se nenhum candidato servir, manter o baú e converter o último baú/evento das rotas pobres (camadas 3 a 4), não o primeiro. Tornar `_poorest_route` e `_ensure_fights_on_every_route` públicos (`poorest_route`, `ensure_fights_on_every_route`), hoje são chamados de fora da classe como privados (`winnability.gd:131`, testes).
- **P0-2** `tests/unit/test_map_fights.gd`. Só testa `MapGenerator.generate`. Falta teste com `RunState.new(data, seed, ..., is_first_run=true/false)` em 4, 6 e 10 camadas, que teria pego o P0-1 (o teste atual passa e dá falsa segurança). Acrescentar também teste de `smooth` que não deixa rota abaixo de 2.
## P1

- **P1-1** `docs/tasks/TASK-081-*.md`, critério 1 marcado `[x]` e "Verificação" sem a medição pós-`_assign_enemies`: o critério ("gerador e suavização") ficou cumprido só no gerador. Reabrir até o P0-1 fechar. A seção "Revisão cruzada" deve apontar este arquivo.
- **P1-2** `docs/HANDOFF.md` (linha 3): trechos históricos foram reescritos por substituição em massa: "TASK-078, 079 e 080 ... (`RULES_VERSION` = 24)" e "Suíte `380/380` (`RULES_VERSION` = 24)" estavam em 23 naquele momento. Restaurar para 23. A tabela ainda diz "Testes `380/380` em `52` scripts" e "Equilíbrio (simulador, regras v15)" sem avisar que o equilíbrio mudou na v24 e não foi medido (ADR-0067 diz isso, o HANDOFF deveria repetir na linha de Equilíbrio).
## P2

- **P2-1** `game/presentation/map3d/map3d_screen.gd:441` (dica em y=126) e `:373` (banner do Perseguidor em y=82, ~42 px de altura): ficam a ~2 px um do outro, sem sobreposição. Hoje não conflitam: a dica só aparece na 1ª Descida (`run.first_run`, `nodes_cleared < 4`) e o Perseguidor está desligado no cenário 1 (`roaming_boss: false`). Se o cenário 1 ganhar a flag ou `roaming_override` for usado, a folga some; mover a dica para y=132 ou empilhar na mesma coluna.
- **P2-2** Dica: `mouse_filter = STOP` no painel (linha 444) bloqueia toques sob ele (y 126 a ~190). No print as bolhas ficam abaixo (y>=342), mas `_update_overlay` aceita bolhas a partir de y=76; em mapas com opção alta a dica engole o toque até ser fechada. Aceitável, mas anotar. Fecha ao tocar e reaparece no mesmo passo se `Map3DScreen` for recriada (`_tip_hidden_step` é da instância; `_show_map` cria uma nova a cada retorno). Hoje passo (`nodes_cleared`) muda a cada nó, então só reaparece se o jogador voltar ao mapa sem resolver nó (ex.: após carregar save). Sem teste dessa volta.
- **P2-3** `game/presentation/game_screen.gd:519-536`: a página com cenário agora é um `ScrollContainer` ancorado em 42% do topo, sem centralizar; em telas curtas (carga, "Gerando o mapa...") o painel fica colado no topo da faixa. Na tela de fim o 3º botão ("Início") fica fora da vista (print: "Santuário" já cortado); depende de arrastar. Não verificado em celular: arrastar sobre `Button` dentro de `ScrollContainer` com toque pode não rolar no Godot (labels têm `mouse_filter` IGNORE, ok). Considerar colocar os botões fora da rolagem.
- **P2-4** `run_state.gd` `end_summary`: `unlock_line` usa `meta_unlocks` do início da Descida (ok), "camada X de Y" limitada por `mini(reached_layer, total_layers)` (ok), frase do algoz correta. Sem texto "?" na derrota se `defeated_by_id` vazio (`killer_name = "?"`), caso raro; sem teste novo de `end_summary` (`unlock_line`).
## O que está certo (conferido)

- `_poorest_route` (`map_generator.gd:43-69`): a programação dinâmica cobre todos os `next_ids`, ignora o chefe (último nível termina em `layer_count`), conta a camada 0 como 0 e nós inalcançáveis só entram no cálculo sem afetar o início. Correta para o grafo atual (janela de 3 destinos).
- Reparo (`:72-85`): só converte baú/evento (nunca fogueira, elite ou mini boss) em batalha; isso não viola `MapRules` (elites, calma, `CHEST_CHAIN`, fogueira): 0 violações em 600 mapas. Determinístico, sem sorteio. Pode deixar o mapa com <2 se a rota tiver só fogueira/nós fixos (não ocorreu; sem aviso se acontecer).
- `Winnability.smooth` (`:130-131`): reverte troca por baú que quebre regra ou o mínimo. Correto. Mini boss, mutação e emboscada de `_assign_enemies` só trocam batalha/emboscada: mantêm a contagem.
- Pureza do núcleo (`test_core_purity`), tipagem, `RULES_VERSION` 24 em `core_version.gd`, ADR-0067 e GDD "Garantia de lutas por rota" coerentes entre si. Sem simulador (regra 9 do projeto): aceito.

## Resumo (10 linhas)

1. Suíte 393/393 verde; pureza e tipagem ok; `RULES_VERSION` 24 coerente com ADR e GDD.
2. Gerador e `smooth` corretos e determinísticos; 0 falhas em 100 sementes sem `first_run` (4, 6 e 10 camadas).
3. P0: com `first_run=true` (a 1ª Descida) 43% das sementes de 4 camadas ainda têm rota de 1 luta (`S B C F C`).
4. Causa: `_apply_first_run_guarantees` (`run_state.gd:1115`) troca um nó da camada 2 por baú sem checar o mínimo.
5. Os testes atuais só cobrem o gerador, por isso passaram. Falta teste com `RunState` e `first_run`.
6. Correção: checar `_poorest_route` ao criar o baú (reverter) ou reparar depois pelo último baú/evento da rota.
7. P1: HANDOFF com `RULES_VERSION` histórico trocado para 24 por engano e linhas de testes/equilíbrio velhas.
8. P2: dica e banner do Perseguidor sem conflito hoje (y=126 vs 82); rolagem da tela de fim não validada em toque.
9. Dica fecha ao tocar e só aparece na 1ª Descida (código e print conferidos).
10. APROVA PARA PUBLICAR: NÃO, até corrigir P0-1 e P0-2.
