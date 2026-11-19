# TASK-041: nó misterioso "?" no lugar da Emboscada visível

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada; aguarda a decisão do Orlando em `docs/design/ESTUDO-nos-misteriosos.md` §7) |
| Aberta em | 2026-11-19 |
| Fase | 1, revisão de mecânicas pós-MVP visual |
| GDD | 5, 7, 11, 13, 15 |
| ADRs | a criar (ADR-0038 em diante; ver `docs/adr/`) |

## Objetivo

O jogador não escolhe mais uma "Emboscada" de olhos abertos. Entra um destino **"?"** cujo tipo só se resolve ao entrar (evento, mímico, tesouro, mercador errante, fogueira abandonada), com pistas e valor esperado que compensem o risco. Detalhe e justificativa em `docs/design/ESTUDO-nos-misteriosos.md`.

## Fora do escopo

- Atalho com armadilha consciente (opção D do estudo); novos cenários.

## Critérios de aceite

- [ ] Decisão do Orlando registrada (seção 7 do estudo) e ADR criado; sem decisão, vale a recomendação da seção 5.
- [ ] `MapNode.Kind.MYSTERY`: o gerador do mapa sorteia "?" no lugar da Emboscada e do Evento visíveis (frequência a calibrar, ADR); a Emboscada deixa de ser tipo de nó.
- [ ] Resolução ao entrar por pesos em `game/data/` (evento 40, mímico 25, tesouro 15, mercador 10, fogueira abandonada 10), deslocados por SORTE e Maré de azar, com os quatro fluxos de RNG do núcleo.
- [ ] **Mímico:** luta emboscada pelas regras de hoje (age primeiro, sem golpe de moeda sem aviso, sem morte instantânea acima de 60% de vida), com recompensa de baú garantida; aviso de uma tela ao entrar. Ficha em `docs/enemies/` e modelo (variante do inimigo comum ou próprio, decisão 2).
- [ ] **Pistas:** a bolha do "?" mostra 0 a 2 pistas reveladas por SORTE ou pela Lanterna do Viajante; testes de que a pista corresponde ao resultado.
- [ ] Valor esperado do "?" maior ou igual ao de uma luta comum de mesmo nível (simulador, `--map-check 40` ou mais); mapa continua vencível (GDD §5).
- [ ] Mapa 3D mostra o "?" (prop de mistério, sem revelar o tipo) e o resultado aparece só ao entrar; print anexado.
- [ ] `RULES_VERSION` incrementado; GDD §5, §7, §11, §13 e §15 atualizados no mesmo commit; testes; suíte verde; HANDOFF atualizado.

## Arquivos afetados

- `game/core/map/` (`map_node`, `map_generator`, `map_rules`), `game/core/run/` (`run_state`, `run_rules`, `winnability`), `game/core/sim/run_bot.gd`, `game/data/`, `docs/enemies/`, `game/presentation/map/map_view.gd`, `game/presentation/map3d/`, `docs/GDD.md`

## Testes esperados

- Determinismo do "?" pela semente; pesos respeitam SORTE e Maré de azar; o mímico respeita as regras de justiça do GDD §7; o mapa gerado nunca tem Emboscada visível; vencibilidade do mapa com "?".

## Regras que esta tarefa não pode quebrar

- Mudança de regra: ADR, GDD atualizado no mesmo commit e `RULES_VERSION` incrementado.
- Núcleo sem nós e sem aleatoriedade global; sorteio só pelos quatro fluxos.
- Toda morte tem aviso (GDD §7).

## Verificação

Ainda não executada.

## Revisão cruzada

Pendente.
