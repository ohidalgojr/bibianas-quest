# ADR-0063: revisão cruzada das TASK-070 a 073 e fechamento do lote de entrega HD-2D

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-27 |
| Tarefa | TASK-076 |
| GDD | 17, 18, 21 |

## Contexto

As tarefas `TASK-070` (`f575da3`), `TASK-071` (`371ab8f`), `TASK-072` (`329bf84`/`d8d8a10`) e `TASK-073` (`1cfa0c9`/`e3dad2f`), implementadas por outro modelo, estavam todas com revisão cruzada pendente (`GDD §21` etapa 4). Além disso, as tarefas `TASK-074` (`ADR-0061`) e `TASK-075` (`ADR-0062`) já endereçaram os principais achados de animação, UX e acabamento que ainda faltavam sobre os assets já presentes no repositório.

## Decisão

1. Registrar em cada ficha (`TASK-070` a `TASK-073`) o parecer completo de revisão cruzada contra `docs/REVIEW-CHECKLIST.md`, distinguindo o que foi validado, o que já foi corrigido em `TASK-074`/`TASK-075` e o que segue pendente para geração de imagens pós-cota do Gemini ou revisão do Orlando.
2. Consolidar `docs/HANDOFF.md` com o estado exato do projeto (`380/380` testes em `52` scripts, `RULES_VERSION` = 21, `ADR-0001` a `ADR-0063`), a fila completa de imagens novas solicitadas ao Gemini (`9` pranchas principais incluindo as `2` novas de animação `F-025`, além das peças de tabuleiro `ESTRUTURA-TABULEIRO-GOTICO.md §7.2`) e o caminho atualizado do executável Windows (`build/windows/BibianasQuest.exe`).

## Alternativas

- Acumular revisões sem registrar nas fichas: rejeitado por contrariar o `GDD §21` e dificultar a retomada entre modelos.

## Consequências

Todas as tarefas `TASK-070`..`TASK-073` ficam auditadas por modelo distinto; as `TASK-074`..`TASK-076` ficam prontas para a próxima revisão cruzada e teste humano no executável gerado.
