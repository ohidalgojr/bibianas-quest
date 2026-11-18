# TASK-029: revisão cruzada das TASK-001 a TASK-025

| Campo | Valor |
| --- | --- |
| Status | Concluída |
| Aberta em | 2026-11-18 |
| Concluída em | 2026-11-18 |
| Fase | 1, etapa 4 da pipeline (GDD §21) |
| GDD | 21 |
| ADRs | ADR-0002, ADR-0010, ADR-0015, ADR-0020, ADR-0026 |

## Objetivo

Todo o código das TASK-001 a TASK-025 foi escrito por **um modelo só** (Claude). A pipeline (GDD §21, etapa 4) exige revisão por **outro modelo**. Esta tarefa registra essa revisão, tarefa por tarefa, e corrige o que for crítico. Quem executa **não pode ser o Claude**.

## Como fazer

1. Leia `docs/REVIEW-CHECKLIST.md`.
2. Para cada tarefa, compare o diff do commit (`git log --oneline` mostra o commit com o ID) com os critérios de aceite do arquivo da tarefa e as seções do GDD citadas.
3. Registre os achados na seção "Revisão cruzada" do arquivo da tarefa: o que achou, gravidade (crítico, importante, sugestão) e o que foi feito.
4. Corrija os críticos em commits próprios (`TASK-029: ...`), com teste que reproduz o defeito.

## Critérios de aceite

- [x] Cada arquivo `docs/tasks/TASK-001` a `TASK-025` tem a seção "Revisão cruzada" preenchida (sem "Pendente").
- [x] Achados críticos resolvidos e com teste; importantes resolvidos ou virados em tarefa; sugestões listadas.
- [x] Atenção especial a: pureza do núcleo (nenhum `Node` ou aleatoriedade global), determinismo por semente, vencibilidade do mapa, regras de justiça da moeda e do aviso, números mágicos fora de constantes, tipagem estática, textos em português, save e versão das regras.
- [x] `docs/HANDOFF.md` atualizado; suíte verde.

## Arquivos afetados

- `docs/tasks/TASK-001-*.md` a `docs/tasks/TASK-025-*.md` (seção "Revisão cruzada")
- `game/presentation/run/run_panels.gd`, `tests/unit/test_run_panels.gd` (rótulos `pt-BR` de `"precision"` e `"relic"`)
- `game/presentation/combat/combat_screen.gd` (preservação do `skill_tip(0)` no botão da primeira skill)
- `game/core/combat/combatant.gd`, `game/core/combat/combat_event.gd`, `game/core/combat/combat_effect.gd` (remoção de `in_final_phase()` órfão, doc de `COIN` e `match` explícito em `debuff_turns()`)
- `tests/unit/test_project_standards.gd` (checagem automática de que tarefas concluídas não têm revisão cruzada pendente)

## Verificação

2026-11-18: `bash tools/run_tests.sh`, 35 scripts, 292/292 testes passando. Nenhum achado crítico de regra; 2 achados importantes na apresentação (`RunPanels` e `CombatScreen`) e 3 sugestões de limpeza no núcleo (`Combatant`, `CombatEvent`, `CombatEffect`) corrigidos e cobertos por testes.

## Revisão cruzada

Esta tarefa é a própria revisão (executada por Gemini, modelo distinto do autor das TASK-001 a TASK-025).
