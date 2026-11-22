# TASK-059: menus em bottom-sheet (Ui-C parcial: loja, fogueira, baú, recompensa, evento)

| Campo | Valor |
| --- | --- |
| Status | Em verificação (código, testes e prints prontos; falta jogar no celular) |
| Aberta em | 2026-11-22 |
| Fase | 1, melhorias do estudo da TASK-051 (D-UI-3, D-UI-4 e roteiro Ui-C) |
| GDD | 15, 19 |
| ADRs | ADR-0047 |

## Objetivo

Os painéis da Descida (recompensa, loja, fogueira, baú e evento) viram um bottom sheet: o diorama 3D fica com 46% da altura, o sheet tem alça, conteúdo rolável e rodapé fixo com a ação principal; a loja usa cartões 2×2 com ícone, efeito e preço; a fogueira mostra as Brasas em pinos.

## Fora do escopo

- Prévia de nó no mapa em dois toques e Home/Santuário (Ui-D), troca de fonte, comparação de atributos antes/depois no cartão.

## Critérios de aceite

- [x] Sheet com alça, área rolável e rodapé fixo (Seguir/Continuar, Atualizar na loja) sempre visível.
- [x] Loja em grade 2×2 de cartões, skill à venda no mesmo formato.
- [x] Fogueira com pinos de Brasas.
- [x] Fluxo completo e testes de tela seguem passando (um `ScrollContainer`).

## Arquivos afetados

- `game/presentation/run/run_panel_screen.gd`, `tests/unit/test_run_panel_sheet.gd`

## Testes esperados

- `test_run_panel_sheet.gd`: rodapé fora do scroll, cartões da loja em grade, pinos de Brasas.

## Regras que esta tarefa não pode quebrar

- Só apresentação; `RULES_VERSION` não muda; `RunPanels` intacto.

## Verificação

Ver HANDOFF. Prints `docs/tasks/prints/TASK-059-*.png`.

## Revisão cruzada

Pendente.
