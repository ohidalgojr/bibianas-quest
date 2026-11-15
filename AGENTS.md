# Bibiana's Quest: instruções para agentes

As regras do projeto valem para qualquer agente (Claude, Gemini, outros) e estão em um só lugar: [CLAUDE.md](CLAUDE.md). Leia esse arquivo inteiro antes de agir.

Resumo do que não pode ser quebrado:

- Sem arquivo de tarefa em `docs/tasks/`, nenhum código.
- Um commit por tarefa, com o ID da tarefa e o ADR.
- Fórmulas e regras do GDD (`docs/GDD.md`) não mudam sem ADR.
- `game/core/` não usa nós do Godot nem aleatoriedade global.
- Testes verdes em headless antes do commit; `docs/HANDOFF.md` atualizado ao fim.

Se você é o revisor (etapa 4 do pipeline, GDD §21): compare o diff da tarefa com os critérios de aceite do arquivo da tarefa e com as seções do GDD citadas, e registre os achados em `docs/tasks/TASK-NNN-...md`, na seção "Revisão cruzada".
