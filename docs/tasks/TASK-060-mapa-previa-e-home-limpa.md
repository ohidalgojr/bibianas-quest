# TASK-060: prévia de nó em dois toques no mapa e Home limpa (Ui-D parcial)

| Campo | Valor |
| --- | --- |
| Status | Em verificação (código, testes e print da Home prontos; falta jogar o mapa no celular) |
| Aberta em | 2026-11-22 |
| Fase | 1, melhorias do estudo da TASK-051 (D-UI-3 no mapa, Home) |
| GDD | 5, 19 |
| ADRs | ADR-0048 |

## Objetivo

No mapa 3D, o primeiro toque num destino abre um mini-card (o que espera, nível, mutação) com Voltar e Caminhar, e a câmera desliza até lá; só o segundo toque caminha. A Home passa a ter um CTA principal grande, uma linha secundária (Santuário e Classe) e a depuração recolhida atrás de um botão discreto.

## Fora do escopo

- Gaveta de equipamento no mapa, Santuário 3D e Bestiário com retratos, troca de fonte.

## Critérios de aceite

- [x] Primeiro toque abre a prévia sem caminhar; Caminhar confirma; Voltar fecha e recentra a câmera.
- [x] Prévia desligada em headless (`preview_enabled`) para os testes de fluxo.
- [x] Home: CTA principal (Continuar se há save, senão Nova Descida), Santuário e Classe em linha; "regras vN", semente e Luta de teste só em build de depuração, recolhidos.

## Arquivos afetados

- `game/presentation/map3d/map3d_screen.gd`, `game/presentation/game_screen.gd`, `tests/unit/test_map3d.gd`, `tests/unit/test_game_screen.gd`

## Testes esperados

- `test_map3d.gd`: 1º toque abre a prévia e Caminhar confirma. `test_game_screen.gd`: depuração recolhida e aberta pelo botão.

## Regras que esta tarefa não pode quebrar

- Só apresentação; `RULES_VERSION` não muda.

## Verificação

Ver HANDOFF. Print `docs/tasks/prints/TASK-060-home.png`.

## Revisão cruzada

Pendente.
