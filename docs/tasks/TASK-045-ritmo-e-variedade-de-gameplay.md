# TASK-045: ritmo e variedade de gameplay (contra o "enjoativo")

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada; começa por um estudo e depende do Orlando) |
| Aberta em | 2026-11-19 |
| Fase | 1, revisão de mecânicas pós-MVP visual |
| GDD | 5, 6, 7, 10, 13 |
| ADRs | a criar |

## Objetivo

Descobrir **por que o laço atual enjoa** e propor mudanças com decisão do Orlando, antes de qualquer código. Hoje toda luta é o mesmo ritual (escolher ação, moeda, repetir) com pouca variação de situação, recompensa e escolha no mapa.

## Fora do escopo

- Implementar as mudanças (cada uma vira tarefa própria depois da decisão); arte (TASK-042 a 044).

## Critérios de aceite

- [ ] **Estudo** em `docs/design/ESTUDO-ritmo-e-variedade.md`: o que se repete (luta, loja, recompensa), onde a decisão do jogador é pobre, comparação com Slay the Spire, Darkest Dungeon, Hades e Fear & Hunger, métricas de telemetria que mostrem a repetição (turnos por luta, ações usadas, nós escolhidos).
- [ ] Propostas ordenadas por custo e impacto (por exemplo: lutas com objetivos diferentes, terreno e posição no combate, itens com efeito ativo, eventos de luta, escolha de recompensa entre 3, mini jogos de moeda), cada uma com risco para a regra de justiça.
- [ ] Decisões do Orlando registradas e tarefas abertas para cada mudança aprovada; liga com a TASK-041 (nó misterioso).

## Arquivos afetados

- `docs/design/`, `docs/tasks/`, `docs/GDD.md` (só depois da decisão)

## Testes esperados

- Nenhum (tarefa de estudo).

## Regras que esta tarefa não pode quebrar

- Mudança de regra só com ADR, GDD atualizado e `RULES_VERSION` incrementado, em tarefa própria.

## Verificação

Ainda não executada.

## Revisão cruzada

Pendente.
