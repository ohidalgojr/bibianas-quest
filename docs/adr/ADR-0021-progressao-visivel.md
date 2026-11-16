# ADR-0021: progressão visível

| Campo | Valor |
| --- | --- |
| Status | Aceito; deixa a decisão de economia para o Orlando |
| Data | 2026-11-16 |
| Tarefa | TASK-017 |
| GDD | 9, 19 |

## Contexto

No playtest (F-003 em `docs/FEEDBACK.md`), matar inimigos não dava senso de progressão: a recompensa era uma linha de texto e nada na tela dizia que a Bibiana tinha ficado mais forte.

## Decisão

1. **Só apresentação e contadores.** Nenhuma fórmula, número ou regra muda; `RULES_VERSION` fica em 5.
2. **`RunState.last_reward`** guarda, na vitória, quem caiu, o nível, o Poder e o ouro ganhos e os atributos antes e depois; `enemies_defeated` conta os inimigos derrotados e entra no save (campo opcional, saves anteriores seguem válidos).
3. **Recompensa** mostra "Poder 1,00 → 1,15" e uma linha por atributo que mudou ("HP 130 → 132").
4. **Mapa e tela de fim** mostram FOR, DEF, VEL e inimigos derrotados.
5. **Luta:** número de dano sobe do alvo (dourado no crítico, "Errou" no erro) e o inimigo derrotado clareia, some e ganha "Derrotado!". Sem tempo (testes), só some.

## Achado

Com Poder +0,15 por nível de inimigo (GDD §9), uma luta comum no começo muda só 1 ou 2 pontos de HP e nenhum outro atributo. O retorno agora aparece, mas é pequeno: a sensação fraca vem da economia, não da tela.

## Pergunta ao Orlando

Qual caminho para o ganho ficar sentido? (a) drops de equipamento e consumíveis dos inimigos, com raridade (GDD §10); (b) marcos por camada com bônus claro; (c) curva do Poder maior no começo. Qualquer um exige ADR, GDD e nova rodada do simulador.
