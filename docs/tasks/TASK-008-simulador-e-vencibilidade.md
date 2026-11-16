# TASK-008: simulador, vencibilidade e primeira calibração

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte completa 194/194 (2026-11-16); revisão cruzada pendente |
| Aberta em | 2026-11-16 |
| Fase | 1, protótipo cinza (GDD §22; roteiro em `docs/ROADMAP-MVP.md`) |
| GDD | 5 (garantia de vencibilidade), 23 (simulador, metas e alavancas) |
| ADRs | ADR-0012 |

## Objetivo

Há um simulador headless que joga milhares de Descidas com os bots "mediano" e "cuidadoso" e grava um relatório com as metas do GDD §23. Cada mapa gerado prova ter um caminho vencível (GDD §5), e o cenário 1 fica calibrado perto da meta de vitória.

## Fora do escopo

- Planilha de curvas e telemetria (GDD §23).
- Calibrar ouro e preços contra a meta de "60% do que gostaria de comprar" (§15): o bot não tem lista de desejos.
- Bots das outras classes. Rodar a checagem fora da thread principal (TASK-011).

## Critérios de aceite

- [x] Bots mediano e cuidadoso, com o cuidadoso lendo a intenção do inimigo.
- [x] `Simulator` com vitória do cenário 1, turnos por combate, mortes por moeda, onde a Bibiana morre e o estado ao chegar no chefe.
- [x] `tools/simulate.gd` grava `reports/simulation.md`.
- [x] Vencibilidade (GDD §5): caminho mais seguro, 200 simulações do bot, até 5 suavizações e descarte do mapa. As simulações não gastam os fluxos da Descida.
- [x] Prova em milhares de sementes: nenhum mapa entregue sem caminho vencível.
- [x] Vitória do cenário 1 com o bot mediano perto de 55% a 65%; combate comum com 6 a 10 turnos. Os ajustes ficam no ADR, sem mudar fórmula do GDD.
- [x] `RULES_VERSION` sobe para 4. Suíte verde.

## Arquivos afetados

- `game/core/sim/run_bot.gd` (movido de `tests/support/`), `game/core/sim/simulator.gd`
- `game/core/run/winnability.gd`, `game/core/run/run_state.gd`
- `game/core/data/data_validator.gd`, `game/data/scenarios.json`, `game/data/enemies.json`
- `game/core/core_version.gd`
- `tools/simulate.gd`
- `tests/unit/test_winnability.gd`, `test_simulator.gd`, `test_run_properties.gd`, `test_data_validator.gd`
- `docs/adr/ADR-0012-simulador-vencibilidade-e-primeira-calibracao.md`

## Testes esperados

- `test_winnability.gd`: custo do nó, suavização sem quebrar o mapa, parada antecipada com a mesma decisão, simulações sem gastar os fluxos, mapas com caminho vencível e determinismo.
- `test_simulator.gd`: métricas e relatório, reprodução por semente, morte por moeda e o bot cuidadoso defendendo golpe de moeda.
- `test_run_properties.gd`: os dois bots terminam Descidas válidas.

## Regras que esta tarefa não pode quebrar

- Fórmulas do GDD só mudam com ADR (nenhuma mudou).
- Núcleo sem nós; sorteio só pelos fluxos (as simulações usam sementes derivadas, sem tocar nos fluxos).

## Verificação

- 2026-11-16: `tools/run_tests.ps1` no Claude Code, 24 scripts, 194/194, exit 0, 25,5 s.
- Linha de base (Coveiro original, sem checagem, 400 Descidas). O mediano vence 5% das Descidas. Nas lutas comuns, vence 97% com 6,8 turnos; contra o chefe, só 5%. A primeira versão do cuidadoso venceu 8% e foi refeita.
- Prova de vencibilidade em 1.000 sementes (FOR 12, 20 simulações por mapa): nenhum mapa sem caminho vencível, 1,55 suavização e 0,19 descarte por mapa, 368 ms por Descida criada. Com FOR 14, em 200 sementes: nenhum mapa sem caminho, 3,05 suavizações e 0,37 descarte por mapa, 312 ms por Descida.
- Calibração com a checagem ligada (40 simulações por mapa):

| Coveiro | Descidas | Bot | Vitória | Turnos por luta comum | Mortes por moeda | Vitória no chefe |
| --- | --- | --- | --- | --- | --- | --- |
| HP 150, FOR 12 | 400 | mediano | 72,8% | 6,5 | 50,5% | 75,4% |
| HP 150, FOR 12 | 400 | cuidadoso | 65,5% | 6,5 | 23,2% | 71,4% |
| HP 150, FOR 13 | 300 | mediano | 66,7% | 6,5 | 39,0% | 68,7% |
| HP 150, FOR 13 | 300 | cuidadoso | 69,3% | 6,3 | 29,3% | 72,7% |
| **HP 150, FOR 14 (adotado)** | 200 | mediano | **65,0%** | 6,3 | 31,4% | 66,3% |
| **HP 150, FOR 14 (adotado)** | 200 | cuidadoso | **64,0%** | 6,2 | 34,7% | 66,0% |

- Metas atingidas: vitória do cenário 1 (55% a 65%) com os dois bots e combate comum entre 6 e 10 turnos. Fora da meta: mortes por moeda (meta de 25% ou menos), deixadas para depois do teste de sensação (ADR-0012).
- O relatório da rodada de 1.000 mapas saiu marcado como "regras v3" porque começou antes de o `RULES_VERSION` subir para 4. As regras eram as mesmas, com FOR 12.

## Revisão cruzada

Pendente (etapa 4).
