# ADR-0048: prévia de nó em dois toques no mapa e Home sem lixo técnico

| Campo | Valor |
| --- | --- |
| Status | Aceito (D-UI-3 e roteiro Ui-D do estudo da TASK-051; Orlando pediu "Sim, Ui-D" em 2026-11-22) |
| Data | 2026-11-22 |
| Tarefa | TASK-060 |
| GDD | 5, 19 |

## Decisão

1. Mapa: toque no destino abre um mini-card com título e detalhe do `MapView`, câmera deslizando até o nó; "Caminhar" ou um segundo toque no mesmo nó confirma; "Voltar" cancela. Tocar em outro destino troca a prévia. Em headless a prévia fica desligada.
2. Home: o jogador vê título, Ecos, CTA e Santuário; o que é de desenvolvedor (versão das regras, semente, luta de teste) só existe em build de depuração e fica atrás de um botão "Depuração".

## Consequências

Menos entradas acidentais em elite ou emboscada, ao custo de um toque a mais por nó. Se o playtest achar o ritmo lento, `preview_enabled` pode virar opção.
