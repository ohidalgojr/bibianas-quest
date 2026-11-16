# ADR-0015: telas de recompensa, loja e fogueira

| Campo | Valor |
| --- | --- |
| Status | Aceito (decisão técnica dentro da tarefa) |
| Data | 2026-11-16 |
| Tarefa | TASK-010 |
| GDD | 9, 12, 15 |

## Decisão

1. **Mesmo padrão do ADR-0010:** `RunPanels` (`game/presentation/run/`) é um controlador `RefCounted` que lê o `RunState` e entrega dicionários de texto e estado dos botões; `RunPanelScreen` é uma tela montada em código que se refaz a cada ação. Os testes cobrem o controlador sem tela.
2. **Painel por cima do mapa**, com fundo escurecido, como os provisórios da TASK-009. O `GameScreen` abre um painel por fase e sai pelo sinal `closed`.
3. **Recompensa só depois de vitória com loja.** O `GameScreen` guarda `_reward_pending` ao fechar a luta. A tela lê Poder e ouro dos `RunEvent` posteriores ao último fim de luta, sem recalcular nada. Baú e fuga não abrem recompensa; o chefe final vai direto ao resultado.
4. **Botão desabilitado diz o motivo** (ouro insuficiente, mochila cheia), para não parecer defeito.
5. O lado da moeda não entra aqui (ADR-0014).

## Consequências

- A TASK-011 troca o início e o resultado; estes painéis ficam.
- Arte e layout de celular ficam para o teste de 20 minutos (TASK-014).
