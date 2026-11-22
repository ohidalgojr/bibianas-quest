# TASK-057: Turiferário Cego (primeiro inimigo do estudo, D-ENEMY-1)

| Campo | Valor |
| --- | --- |
| Status | Em verificação (modelo aceito pelo agente crítico em 3 rodadas; falta o Orlando ver no jogo) |
| Aberta em | 2026-11-22 |
| Fase | 1, melhorias do estudo da TASK-051 |
| GDD | 7, 11, 13 |
| ADRs | ADR-0045 |

## Objetivo

Entra na Cidade Abandonada o primeiro dos 3 inimigos priorizados do estudo: o Turiferário Cego, com modelo próprio feito no Blender, golpe de moeda temático (Defumação de Enxofre, Cegueira), reação a Defender duas vezes e ficha em `docs/enemies/`.

## Fora do escopo

- Médico da Cera e Rastejador da Vala (próximas tarefas), animações, retrato 2D.

## Critérios de aceite

- [x] `tools/blender/make_censer.py` gera `assets/bibiana/enemies/blind_censer_bearer.glb` (1015 faces, abaixo do orçamento de 2900 tris).
- [x] Modelo revisado por agente crítico até ACCEPT (v1 e v2 rejeitadas e refeitas; v3 aceita).
- [x] Dados validados, golpe de moeda temático e reação; registrado no cenário, Bestiário e `ModelRegistry`.
- [x] Ficha `ENEMY-15`.

## Arquivos afetados

- `tools/blender/make_censer.py`, `tools/blender/render_preview.py`, `assets/bibiana/enemies/blind_censer_bearer.glb`, `game/data/enemies.json`, `game/data/scenarios.json`, `game/presentation/combat/combat_texts.gd`, `game/core/run/sanctuary_rules.gd`, `game/presentation/stage/model_registry.gd`, `docs/enemies/ENEMY-15-turiferario-cego.md`, testes de identidade e da tela de combate.

## Testes esperados

- `test_enemy_identity.gd` cobre o golpe de moeda e a reação do novo inimigo; `test_combat_screen.gd` conta 14 opções no seletor.

## Regras que esta tarefa não pode quebrar

- Cânone visual (ADR-0042); fórmulas do GDD intactas; `RULES_VERSION` não muda (conteúdo, como nas TASK-044 e 047). Equilíbrio fora do simulador por diretriz do Orlando.

## Verificação

Ver HANDOFF. Não verificado: balanceamento por simulação (suspenso por diretriz) e olhar no jogo.

## Revisão cruzada

Pendente.
