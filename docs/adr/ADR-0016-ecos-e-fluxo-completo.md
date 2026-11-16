# ADR-0016: Ecos e fluxo completo do protótipo

| Campo | Valor |
| --- | --- |
| Status | Aceito, com 1 pergunta (valores dos Ecos) |
| Data | 2026-11-16 |
| Tarefa | TASK-011 |
| GDD | 4, 26 |

## Decisão

1. **Ecos do protótipo:** 1 por nó resolvido e 5 por chefe derrotado (`RunRules.echoes`). O GDD dá só o critério (profundidade, chefes, rivais) e diz que nenhuma Descida se perde, então a morte também credita. Os números são provisórios. Não mudou regra existente, então `RULES_VERSION` fica em 4.
2. **Ecos só valem no fim** (`RunState.echoes_earned`). O total vive no `GameScreen` até o save da TASK-012.
3. **Tela de fim** mostra quem derrotou a Bibiana (`defeated_by_id` e nível no `RunState`), Poder, ouro, nós, chefes e Ecos. A dica e o "o que faltou" do GDD §26 ficam para depois.
4. **Classe:** o menu mostra só o Guerreiro, sem escolha.

**Pergunta:** os valores de Ecos (1 por nó, 5 por chefe) servem até o Santuário existir?
