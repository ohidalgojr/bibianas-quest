# ADR-0046: Médico da Cera e Rastejador da Vala entram na Cidade Abandonada

| Campo | Valor |
| --- | --- |
| Status | Aceito (D-ENEMY-1 do estudo da TASK-051; Orlando pediu implementar as melhorias em 2026-11-22) |
| Data | 2026-11-22 |
| Tarefa | TASK-058 |
| GDD | 7, 11, 13 |

## Contexto

Com o Turiferário Cego (ADR-0045), restavam dois dos três inimigos que o estudo recomendou priorizar.

## Decisão

1. Médico da Cera: comum de suporte, VEL 6, HP 52; usa o golpe `heal` já suportado pelos dados (Derreter Sebo, 12%) e reage abaixo de 50% de vida com golpe forte.
2. Rastejador da Vala: comum rápido e frágil (VEL 13, ESQ 14, HP 36), reage a uma Bibiana abaixo de 60% de vida.
3. Os dois modelos passaram por revisão crítica por agente antes de entrarem (v1 reprovada). A reação a dano de fogo da proposta do estudo fica fora, porque o núcleo ainda não tem reação a elemento.
4. Sem mudança de `RULES_VERSION`.

## Consequências

Cidade Abandonada tem 13 inimigos comuns; o equilíbrio fino fica para a TASK-032, depois do playtest do Orlando.
