# ADR-0064: texturas pintadas por tipo de peça no tabuleiro

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-27 |
| Tarefa | TASK-077 |
| GDD | 17, 18 |

## Contexto

O tabuleiro gótico (ADR-0060) usava peças CC0 de cor lisa tingida. O Orlando entregou texturas pintadas de reboco com madeira, ardósia, pedra de arrimo e entulho.

## Decisão

1. As quatro texturas viram versões sem emenda (espelho 2x2, 768 px) em `assets/bibiana/textures/`; os originais de 2048 px ficam em `docs/design/refs/textures/`.
2. O `ScenarioRenderer` escolhe a textura pelo tom da peça (`TINT_HOUSE`, `TINT_HOUSE_ROOF`/`TINT_ROOF`, `TINT_WALL`, `TINT_COURT_TILE`) e a aplica em triplanar de mundo pelo `StageKit`; peças sem textura mantêm o tom do kit.
3. Os sprites de cenário e de inimigo novos entram no `ModelRegistry`; `make_sprite.py --all` mantém peças com vários pedaços.

## Alternativas

- UV por peça: descartado, os kits têm UV de atlas de cor única.

## Consequências

Casas, telhados e muros ganham o material pintado sem novas malhas. Mudar o tom de uma peça sem atualizar o mapa a deixa sem textura.
