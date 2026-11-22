# ADR-0047: menus da Descida em bottom sheet com rodapé fixo

| Campo | Valor |
| --- | --- |
| Status | Aceito (D-UI-3 e roteiro Ui-C do estudo da TASK-051; Orlando pediu "Menus em bottom-sheet" em 2026-11-22) |
| Data | 2026-11-22 |
| Tarefa | TASK-059 |
| GDD | 15, 19 |

## Decisão

1. O painel sobre o cenário 3D começa a 46% da altura e tem alça, `ScrollContainer` e um rodapé fora do scroll; a ação de sair (Seguir) nunca some atrás da rolagem.
2. A loja usa grade 2×2 de cartões (ícone, nome, efeito, preço); o motivo de bloqueio fica no cartão, em linha própria.
3. Brasas da fogueira em pinos `●●○`.
4. Sem o cenário 3D (depuração) o painel continua o antigo, com tudo em uma coluna.

## Consequências

Os testes que apertam "o último botão habilitado" seguem valendo, porque o rodapé é o último filho. Comparação de atributos no cartão e prévia de nó ficam para a Ui-D.
