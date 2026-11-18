# TASK-029: revisão cruzada das TASK-001 a TASK-025

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada) |
| Aberta em | 2026-11-18 |
| Fase | 1, etapa 4 da pipeline (GDD §21) |
| GDD | 21 |
| ADRs | nenhum (a revisão pode gerar ADR se achar defeito de regra) |

## Objetivo

Todo o código das TASK-001 a TASK-025 foi escrito por **um modelo só** (Claude). A pipeline (GDD §21, etapa 4) exige revisão por **outro modelo**. Esta tarefa registra essa revisão, tarefa por tarefa, e corrige o que for crítico. Quem executa **não pode ser o Claude**.

## Como fazer

1. Leia `docs/REVIEW-CHECKLIST.md`.
2. Para cada tarefa, compare o diff do commit (`git log --oneline` mostra o commit com o ID) com os critérios de aceite do arquivo da tarefa e as seções do GDD citadas.
3. Registre os achados na seção "Revisão cruzada" do arquivo da tarefa: o que achou, gravidade (crítico, importante, sugestão) e o que foi feito.
4. Corrija os críticos em commits próprios (`TASK-029: ...`), com teste que reproduz o defeito.

## Critérios de aceite

- [ ] Cada arquivo `docs/tasks/TASK-001` a `TASK-025` tem a seção "Revisão cruzada" preenchida (sem "Pendente").
- [ ] Achados críticos resolvidos e com teste; importantes resolvidos ou virados em tarefa; sugestões listadas.
- [ ] Atenção especial a: pureza do núcleo (nenhum `Node` ou aleatoriedade global), determinismo por semente, vencibilidade do mapa, regras de justiça da moeda e do aviso, números mágicos fora de constantes, tipagem estática, textos em português, save e versão das regras.
- [ ] `docs/HANDOFF.md` atualizado; suíte verde.

## Arquivos afetados

- `docs/tasks/TASK-0NN-*.md` (seção "Revisão cruzada"), eventuais correções em `game/` e `tests/`

## Verificação

(preencher)

## Revisão cruzada

Esta tarefa é a própria revisão.
