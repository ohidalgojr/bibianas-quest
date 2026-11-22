# ADR-0045: Turiferário Cego entra na Cidade Abandonada

| Campo | Valor |
| --- | --- |
| Status | Aceito (D-ENEMY-1 do estudo da TASK-051; Orlando pediu implementar as melhorias em 2026-11-22) |
| Data | 2026-11-22 |
| Tarefa | TASK-057 |
| GDD | 7, 11, 13 |

## Contexto

O estudo propôs 8 inimigos dark fantasy e recomendou começar por Turiferário Cego, Médico da Cera e Rastejador da Vala (D-ENEMY-1). Também recomendou o pipeline híbrido (D-ENEMY-2); aqui usamos o caminho A (`kit.py` em Python), mais barato e sem serviço externo.

## Decisão

1. Comum de nível base 1, mutação sugerida `bloated`, VEL 7, HP 46, FOR 11: lento e pesado, com golpe de moeda que cega.
2. Modelo gerado por `make_censer.py` e aceito só depois de revisão crítica por agente (três rodadas), registrada nesta tarefa.
3. `render_preview.py` passa a ser o passo de revisão visual de todo asset novo (3 ângulos).
4. Sem mudança de `RULES_VERSION`: é conteúdo novo, como nas TASK-044 e 047.

## Consequências

O balanceamento fino fica para a TASK-032, depois do playtest do Orlando.
