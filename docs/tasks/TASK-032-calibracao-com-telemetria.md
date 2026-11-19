# TASK-032: calibração com o telemetry.log do playtest

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada; bloqueada até a TASK-040 e até o Orlando enviar o `telemetry.log` e o feedback da jogada) |
| Aberta em | 2026-11-18 |
| Fase | 1, caminho até o portão (GDD §22, §23) |
| GDD | 15, 23 |
| ADRs | a criar (ADR-0031 em diante; ver `docs/adr/`) |

## Objetivo

Ajustar os números do cenário 1 (ouro, Coveiro, frequência da moeda, mortes por moeda, drops) com dados de **uma pessoa jogando**, porque até aqui só bots e testes jogaram as TASK-009 a 025.

## Fora do escopo

- Mudar regra de fórmula do GDD fora das alavancas do §23; conteúdo novo (TASK-026 a 028).

## Critérios de aceite

- [ ] O Orlando enviou o `telemetry.log` de pelo menos 3 Descidas e o feedback em `docs/FEEDBACK.md`.
- [ ] Relatório comparando humano e bots: vitória, turnos por luta comum (meta 6 a 10), mortes por moeda (meta até 25%), ouro ao chegar ao chefe, ganho de nível por camada.
- [ ] Cada ajuste vem de uma alavanca do §23, com ADR e tabela do simulador (`--map-check 40` ou mais); bot mediano de volta à faixa de 55% a 65%.
- [ ] `RULES_VERSION` incrementado se algum número mudar; GDD e HANDOFF atualizados; suíte verde.

## Arquivos afetados

- `game/data/*.json`, `game/core/run/run_rules.gd`, `docs/adr/`, `docs/GDD.md`, `docs/FEEDBACK.md`

## Testes esperados

- Os testes de fórmula e de vencibilidade existentes continuam verdes; teste novo só se uma regra mudar.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR.
- Núcleo sem nós e sem aleatoriedade global.

## Verificação

Ainda não executada.

## Revisão cruzada

Pendente.
