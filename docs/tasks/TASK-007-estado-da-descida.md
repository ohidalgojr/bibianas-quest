# TASK-007: estado da Descida

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte completa 184/184 (2026-11-16); revisão cruzada pendente |
| Aberta em | 2026-11-16 |
| Fase | 1, protótipo cinza (GDD §22; roteiro em `docs/ROADMAP-MVP.md`) |
| GDD | 4 (laço e morte), 5 (nós), 9 (Poder), 10 (consumíveis), 12 (fogueira), 15 (ouro e loja) |
| ADRs | ADR-0011 |

## Objetivo

O núcleo passa a conduzir uma Descida inteira sem tela. O estado guarda a semente, o cenário e o mapa, o nó atual, o Poder, o ouro, o HP e o MP, o inventário, o equipamento e os buffs. Ele aceita as transições de escolher nó, lutar, abrir baú, usar a fogueira e comprar na loja, e termina no chefe ou na morte. Um bot de regras completa Descidas de forma determinística.

## Fora do escopo

- Telas do mapa, da loja e da fogueira (TASK-009 e 010). Fluxo de menu, Ecos e recomeço (TASK-011). Save (TASK-012).
- Prova de vencibilidade e simulador (TASK-008).
- Eventos, mini boss, emboscada com status, drops de equipamento, venda, item especial da loja e loja de skills de fim de cenário.

## Critérios de aceite

- [x] `RunRules`: Poder (GDD §9), ouro por inimigo (§15), ouro de baú (ADR-0011), m_tipo por tipo de nó, nível por camada.
- [x] `RunState` com fases e transições: escolher nó (só entre as opções), luta com HP e MP persistentes, vitória com Poder e ouro, fuga sem nada, derrota encerra a Descida, baú, fogueira (6 Brasas, Descansar 3, skills do Guerreiro 2), loja (2 equipamentos e 2 consumíveis, compra, atualização a 15 e depois +10), chefe encerra com vitória.
- [x] Ação fora da fase ou inválida é rejeitada sem mudar o estado.
- [x] Equipamento e buffs de fogueira mudam os atributos da Bibiana na luta.
- [x] Os itens usados na luta saem do inventário; o limite é de 8 consumíveis.
- [x] O bot completa uma Descida por semente; mesma semente, mesma Descida.
- [x] `RULES_VERSION` sobe para 3. Suíte verde.

## Arquivos afetados

- `game/core/run/run_rules.gd`, `run_state.gd`, `run_event.gd`
- `game/core/map/map_node.gd` (inimigo e nível do nó)
- `game/core/core_version.gd`
- `tests/support/run_bot.gd`
- `tests/unit/test_run_rules.gd`, `test_run_state.gd`, `test_run_properties.gd`
- `docs/adr/ADR-0011-estado-da-descida.md`

## Testes esperados

- `test_run_rules.gd`: fórmulas de Poder e ouro citando o GDD, faixa do U, nível por camada, ouro do baú.
- `test_run_state.gd`: cada transição, as rejeições, a persistência de HP e MP, o crescimento por Poder, a fogueira, a loja, o equipamento e os buffs, o consumo de itens, a derrota e a vitória no chefe.
- `test_run_properties.gd`: Descidas do bot em muitas sementes terminam sempre, sem estado inválido, e se reproduzem pela semente.

## Regras que esta tarefa não pode quebrar

- Fórmulas do GDD só mudam com ADR.
- Núcleo sem nós; sorteio só pelos quatro fluxos.

## Verificação

- 2026-11-16: `tools/run_tests.ps1` no Claude Code, 22 scripts, 184/184, exit 0, 31 s. Na primeira rodada, um teste falhou porque ele próprio não contava o dano de o inimigo agir antes do primeiro turno da Bibiana. O teste foi corrigido; o código não mudou.
- Bot de regras em 200 Descidas do cenário 1: **8% de vitórias**, Poder médio 2,57, ouro médio 40, 5,7 nós por Descida. A meta do GDD §23 é de 55% a 65%.
- Onde o bot morre, em 300 Descidas: 239 no Coveiro, 25 nas batalhas das camadas 2 e 3 e 14 na camada 5. **O chefe é a primeira alavanca da TASK-008**: nível 6, 220 de HP e Golpe Mortal, contra uma Bibiana com Poder perto de 2,5. A decisão (nível do chefe, HP, Poder ganho no caminho ou bot melhor) fica para a TASK-008, com ADR.

## Revisão cruzada

Pendente (etapa 4).
