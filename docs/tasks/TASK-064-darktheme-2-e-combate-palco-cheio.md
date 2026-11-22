# TASK-064: DarkTheme 2.0 e combate com palco cheio (pacotes 1, 2 e 4 da auditoria)

| Campo | Valor |
| --- | --- |
| Status | Em verificação (código, testes e print prontos; falta aprovação do diretor de arte com os modelos novos) |
| Aberta em | 2026-11-22 |
| Fase | 1, identidade visual |
| GDD | 18, 19 |
| ADRs | ADR-0051 |

## Objetivo

Fechar as lacunas de maior impacto da auditoria do estudo do Gemini: design system (tokens, fonte por tamanho do texto, componentes, polimento de toque) e o layout de combate mobile (palco cheio, intenção sobre a cabeça, letreiro, barras com rastro).

## Fora do escopo

- Loja com comparação, ritual da Moeda, Resultado e Recompensa, Santuário 3D, modelos e cenário (outras tarefas e agentes).

## Critérios de aceite

- [x] Tokens, variações de tema e `polish_button` com testes.
- [x] `TrailBar` com rastro ao cair e sem rastro ao subir.
- [x] Palco do combate >= 57% da altura com a gaveta fechada (medido: cerca de 68% no print).
- [x] Intenção do inimigo presa à cabeça, log fixo substituído por letreiro.

## Arquivos afetados

- `game/presentation/fx/dark_theme.gd`, `fx/trail_bar.gd`, `fx/gfx_settings.gd`, `game/presentation/game_screen.gd`, `combat/combat_screen.gd`, `combat3d/combat3d_stage.gd`, `tests/unit/test_dark_theme_2.gd`

## Regras que esta tarefa não pode quebrar

- Só apresentação; `RULES_VERSION` não muda.

## Verificação

Suíte 369/369. Print `docs/tasks/prints/TASK-064-combate.png` (o inimigo do print ainda é o modelo reprovado, em refação).

## Revisão cruzada

Pendente (diretor de arte).
