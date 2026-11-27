# Revisão cruzada: TASK-078, TASK-079 e TASK-080 (commit b2d788e)

Revisor: outro modelo, não escreveu o código. Nada de código ou asset foi alterado.
Executado de verdade: `--import`, suíte GUT completa (**388/388 verde, exit 0**), capturas do mapa (`passos=3`, com e sem `perseguidor=2`) e do combate (`lipless_choir`, `calcified_knight`, `crowned_pursuer`), e um script de sondagem que joga uma Descida com `roaming_override` até o encontro forçado.

## Veredito: APROVA PARA PUBLICAR: SIM, com uma trava
- O jogo entregue hoje não é afetado: só existe o cenário 1 e `roaming_boss` está `false` nele. `_raise_alarm` sai logo quando `roaming_enabled()` é falso, então o fluxo do cenário 1 fica intacto (confirmado no código e em `test_scenario_one_has_no_roaming_boss_without_the_flag`).
- **NÃO ative `roaming_boss` em nenhum cenário 2+ antes de corrigir o P0-1.** A luta forçada mostra o inimigo errado na tela.

## Conferências do CLAUDE.md
- Pureza do núcleo e tipagem: `test_core_purity`/`test_untyped_declarations` passam; `roaming_rules.gd` e o trecho novo do `run_state.gd` só usam contadores, sem sorteio e sem nós.
- `RULES_VERSION` = 23 em `core_version.gd`, citado no HANDOFF. ADR-0064, 0065 e 0066 existem; fichas ENEMY-18, 19 e 20 existem e batem com o JSON (HP, ciclo).
- Justiça: nenhum dos três tem Golpe Mortal (só `gravedigger`). Ciclos têm 3 golpes sem moeda entre golpes de moeda, e `Combat.COIN_GAP = 2` também cobre as reações (Lamento, Talho de Osso e Decreto da Maça). Os golpes de moeda são `heavy` e `cruel`, que o jogo já avisa um turno antes.

## P0 (bloqueia ligar a mecânica; não bloqueia publicar)
1. **A luta do Perseguidor aparece com o inimigo do nó anterior.** `game/presentation/combat/combat_session.gd:59` (`for_run`) usa `node.enemy_id` e `node.level` do nó atual, não o do `combat.enemy`. Sondagem: lutando o Perseguidor, `session.enemy_id='sewer_slime'`, `level 4`. Por isso `combat_screen.gd:166-172` mostra o sprite, a mutação e o nível do nó anterior, ou nada se o nó for fogueira ou baú. O print `TASK-080-combate.png` veio do `combat3d_preview`, que não passa por esse caminho, então não provou o jogo real.
   Correção: em `for_run`, se `run_state.roaming_fight`, usar `RoamingRules.ENEMY_ID` e `run_state.roaming_level`, e `mutation=""` em `combat_screen.gd:166`. Acrescentar um teste de `CombatSession.for_run` com `roaming_fight`.

## P1
2. **Telemetria e música erradas na luta forçada.** `game_screen.gd:315` grava `node.enemy_id`/`node.level` (dados do inimigo errado); `:298-299` escolhe a trilha pelo `kind` do nó, então o Perseguidor toca "combat" e não "boss". Corrigir junto com o P0-1 usando `run.roaming_fight`.
3. **O sprite do Perseguidor não aparece no mapa.** `map3d_screen.gd:399-410` o põe `distância` camadas atrás da Bibiana, fora do quadro. Na minha captura só o banner "está a 2 nós" aparece, sem sprite nem brilho; a TASK-080 admite isso. O critério "marcador/sprite no Map3DScreen" ficou só no texto. Correção: um ícone/silhueta fixo no banner, ou limitar `layer_back` à borda visível.
4. **Divergência do GDD sem reconciliar.** GDD linha 537 diz "Roaming bosses não entram em fogueiras, mas o tempo continua passando"; `_advance_pursuer` (`run_state.gd:654-656`) congela o Perseguidor ao escolher fogueira, ou seja, o tempo não passa. O ADR-0066 declara a regra, mas o GDD só ganhou uma nota de "Estado no código". Corrigir o texto do GDD §13 e §12, ou deixar o Perseguidor avançar.
5. **Testes rasos para a regra mais arriscada.** `test_roaming_boss.gd` altera `current_node().layer` à mão e chama `_advance_pursuer` direto. Nenhum teste percorre `choose_node` do alarme à luta, nem cobre fogueira, baú e evento no meio da perseguição. Meu script fez isso e os fluxos funcionaram, mas faltam testes que fixem isso.
6. **HANDOFF desatualizado.** Linha 14 diz "ADR-0001 a ADR-0064" (deveria ser 0066); linhas 37-38 ainda listam TASK-079 e TASK-080 como "(aberta)".

## P2
7. Em mapa de 4 camadas a perseguição nunca alcança a Bibiana antes do chefe: com alarme na camada 2 e distância 3, `pursuer_pending` vira verdadeiro ao escolher o BOSS e se perde com a vitória. O banner pode piscar "alcançou você!" durante o chefe. Ajustar `START_DISTANCE` por tamanho de mapa quando existir o cenário 2.
8. `_finish_roaming_fight` (`run_state.gd:676`) trata qualquer saída que não seja derrota como vitória, inclusive `FLED`. Hoje é inalcançável (`can_flee=false`), mas vale `if outcome != VICTORY: return`.
9. `run_save.gd`: `from_dict` não valida `pursuer_distance` (aceita -50 ou 99) e `FORMAT` continua 1. O save mid-luta não existe (só salva em CHOOSING), então `roaming_fight` não precisa ser salvo: confirmado. `alarm` pode passar de 4 na camada 1 e dispara no primeiro `_raise_alarm` da camada 2, comportamento aceitável mas não testado.
10. `map3d_screen.gd:396`: o lambda do segundo sino captura `self` e roda 0,9 s depois; se a tela for liberada nesse intervalo, dá erro de captura liberada. Banner em `Vector2(10, 82)` fixo, sem ancoragem.
11. `scenario_renderer.gd:633`: se a textura não existir, o quad fica branco opaco (alpha 1 com scissor). Trocar por `return` quando `ResourceLoader.exists` falha. Os decalques de porta, janela, sacada e portão são um MultiMesh por mapa inteiro, sem os `CHUNK_ROWS` usados no resto; custo atual aceitável.
12. Cavaleiro Calcificado (HP 70, DEF 10) entra no cenário 1, o tutorial curto "sem facilitar" (CLAUDE.md regra 13). O HANDOFF já marca a calibração como pendente e a regra 9 proíbe o simulador agora; reavaliar no próximo playtest. `SanctuaryRules._reaction_summary` lê `reactions` dentro da fase e a chave `reason`, mas o JSON as guarda no topo com `when`, então o Códice mostra "Ciclo fixo" para todos (defeito antigo, não desta tarefa).

## Visual (TASK-078, e luz de borda)
- Mapa: 46,1 mil primitivas (46,5 mil com perseguidor), abaixo de 60 mil; 11-12 fps é o lavapipe por software. Janelas acesas e portas em arco aparecem, mas pequenas e discretas nas fachadas próximas da minha captura (`passos=3`); o portão de ferro aparece no print committado da subida final. Atende, sem exagero.
- Combate: Coro, Cavaleiro e Perseguidor renderizam bem, com a silhueta legível sobre o piso escuro e a luz de borda azulada visível no Perseguidor; atmosfera gótica coerente, sem mecha colorida. Combate com 7,7 mil primitivas.
- Dois prints comitados (`TASK-078-*.png`, ~1,8 MB) são pesados para o repositório, mas sem impacto no jogo.

## Resumo
1. Suíte 388/388 verde; núcleo puro, tipado, RULES_VERSION 23 coerente, fichas e ADRs presentes e batendo com os dados.
2. Justiça respeitada nos três inimigos; nenhum Golpe Mortal fora do Coveiro.
3. Cenário 1 intacto com a flag desligada; a mecânica do Perseguidor é inerte hoje (só existe 1 cenário).
4. P0-1: a luta forçada mostra o inimigo, nível e mutação do nó anterior (`combat_session.gd:59`), provado por sondagem.
5. P1: sprite do Perseguidor fora do quadro no mapa, telemetria e música erradas, GDD §12 contradito sem reconciliar, testes rasos, HANDOFF com itens velhos.
6. Visual dos três inimigos e das fachadas aprovado; janelas discretas.
7. Publicar: SIM. Ligar `roaming_boss` em cenário 2+: NÃO, até corrigir o P0-1 e o P1-2.
