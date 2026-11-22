# TASK-058: Médico da Cera e Rastejador da Vala (D-ENEMY-1, conclusão)

| Campo | Valor |
| --- | --- |
| Status | Em verificação (modelos revisados por agente crítico; falta o Orlando ver no jogo) |
| Aberta em | 2026-11-22 |
| Fase | 1, melhorias do estudo da TASK-051 |
| GDD | 7, 11, 13 |
| ADRs | ADR-0046 |

## Objetivo

Entram os outros dois inimigos priorizados do estudo, com modelos próprios do Blender: Médico da Cera (suporte, cura e veneno) e Rastejador da Vala (rápido e frágil, emboscada).

## Fora do escopo

- Os outros 5 inimigos do estudo, animações, retratos 2D, balanceamento por simulador (suspenso).

## Critérios de aceite

- [x] `tools/blender/make_horrors2.py` gera `wax_physician.glb` e `trench_crawler.glb`.
- [x] Modelos reprovados na 1ª revisão crítica, refeitos e reavaliados.
- [x] Dados com golpe de moeda temático e reação; cenário, Bestiário e `ModelRegistry` atualizados.
- [x] Fichas `ENEMY-16` e `ENEMY-17`.

## Arquivos afetados

- `tools/blender/make_horrors2.py`, `assets/bibiana/enemies/*.glb`, `game/data/enemies.json`, `game/data/scenarios.json`, `game/presentation/combat/combat_texts.gd`, `game/core/run/sanctuary_rules.gd`, `game/presentation/stage/model_registry.gd`, `docs/enemies/`, testes de contagem e de identidade.

## Testes esperados

- `test_enemy_identity.gd` cobre o golpe de moeda e a reação; contagens (17 inimigos, 13 opções no seletor) atualizadas.

## Regras que esta tarefa não pode quebrar

- Cânone visual (ADR-0042); fórmulas do GDD intactas; `RULES_VERSION` não muda (conteúdo).

## Verificação

Ver HANDOFF.

## Revisão cruzada

Pendente.
