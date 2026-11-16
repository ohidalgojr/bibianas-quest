# ADR-0018: atalhos de depuração e telemetria local

| Campo | Valor |
| --- | --- |
| Status | Aceito (decisão técnica dentro da tarefa) |
| Data | 2026-11-16 |
| Tarefa | TASK-013 |
| GDD | 7, 23 |

## Decisão

1. **Atalhos só em build de depuração**, por `OS.is_debug_build()`: no editor (F5) e em exportação de depuração. A exportação de lançamento (TASK-014) os desliga sozinha.
2. **"Forçar o lado da moeda" virou forçar o resultado.** Com o lado escolhido sendo ritual (ADR-0014), o que serve para testar é forçar acerto ou erro. `Combat.forced_coin` (-1 normal, 1 acerta, 0 erra) troca só o resultado; o sorteio continua acontecendo, então os fluxos de RNG andam igual com ou sem o atalho.
3. **Pular nó e matar inimigo** passam pela via normal: `Combat.debug_kill_enemy` zera a vida do inimigo e a vitória, a recompensa e a loja seguem como numa luta de verdade.
4. **Telemetria em arquivo local**, JSON por linha, sem rede. Montar as linhas é função pura (`Telemetry.run_lines`, `fight_lines`); só gravar usa arquivo e relógio. Fica nos serviços, fora do núcleo.
5. **Morte por moeda** (meta ≤ 25%, GDD §23): a morte é marcada `by_coin` quando o golpe fatal foi um golpe de moeda perdido, lido do histórico do combate.
