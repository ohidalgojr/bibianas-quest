# ADR-0044: combate mobile com gavetas de ações e confirmação em dois toques

| Campo | Valor |
| --- | --- |
| Status | Aceito (Opção A do quadro D-UI-1 e D-UI-2 do estudo da TASK-051; Orlando pediu implementar as melhorias em 2026-11-22) |
| Data | 2026-11-22 |
| Tarefa | TASK-056 |
| GDD | 6, 19 |

## Contexto

A previsão de dano usava `mouse_entered`, que não existe em toque; 11 a 12 botões quase iguais ocupavam 450 px e deixavam ~160 px para o inimigo.

## Decisão

1. Atacar e Defender sempre visíveis e de um toque.
2. Abas Habilidades, Itens e Tático abrem uma gaveta por vez; tocar na aberta recolhe e devolve altura ao palco.
3. Skill, item e Fugir (gastam MP, item ou arriscam a luta) pedem confirmação: o 1º toque marca o botão e escreve a previsão no painel, o 2º executa. Velocidade e Moeda da Sorte (alternadores) executam direto.
4. `confirm_taps` fica desligado em headless para os testes de luta completa; os testes da confirmação o ligam.
5. Com palco 3D os textos de HP/MP e de status somem; as barras e os ícones já os mostram.

## Consequências

Sem mudança de regra. Hover continua funcionando no desktop como atalho para a previsão.
