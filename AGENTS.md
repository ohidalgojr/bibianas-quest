# Bibiana's Quest: instruções para agentes

As regras do projeto valem para **qualquer agente** (Claude, Gemini, GPT, outros) e estão em um só lugar: [CLAUDE.md](CLAUDE.md). Leia esse arquivo **inteiro** antes de agir, inclusive "Lições e armadilhas". Depois leia [docs/HANDOFF.md](docs/HANDOFF.md) (estado, backlog ordenado, pendências) e o arquivo da tarefa em `docs/tasks/`.

Resumo do que não pode ser quebrado:

- Sem arquivo de tarefa em `docs/tasks/`, nenhum código.
- Um commit por tarefa, com o ID da tarefa e o ADR: `TASK-NNN: resumo (ADR-XXXX)`.
- Fórmulas e regras do GDD (`docs/GDD.md`) não mudam sem ADR, GDD atualizado no mesmo commit e `CoreVersion.RULES_VERSION` incrementado.
- `game/core/` não usa nós do Godot nem aleatoriedade global; todo sorteio passa pelos quatro fluxos de RNG.
- Testes unitários rápidos verdes em headless antes do commit. **Enquanto não alcançar o MVP jogável (apresentação 3D, ADR-0036, TASK-040), não utilize recursos para simulador de balanceamento (`tools/simulate.gd`) nem testes muito complexos.**
- Cada inimigo tem uma ficha em `docs/enemies/`; a regra de justiça (aviso, intervalo entre golpes de moeda) vale para todos.
- **Tela ou gráfico: leia `docs/ART-DIRECTION.md` e o ADR-0036 antes.** O visual não é "provisório": GDD §17 e §18 mandam tabuleiro isométrico 3D com kits CC0. Tarefa de tela só fecha com print do jogo rodando com janela, anexado em `docs/tasks/prints/`.
- **Executável de teste:** ao fim de cada tarefa que muda o jogo, rode `toolsbuild_windows.ps1` e informe o caminho do `.exe` (`buildwindowsBibianasQuest.exe` na pasta principal do repositório).
- `docs/HANDOFF.md` atualizado ao fim da tarefa; pare e entregue o resumo.
- Não envie ao GitHub sem o Orlando pedir.

## Primeiros passos para um agente novo

1. `powershell -ExecutionPolicy Bypass -File tools\setup.ps1` (instala o GUT) e `tools\setup_hooks.ps1` (hooks de commit). Em Linux ou macOS: `bash tools/setup.sh` e `bash tools/setup_hooks.sh`.
2. Defina `GODOT_BIN` (no Windows, o `*_console.exe`) e rode a suíte: `powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1`. Tem de dar verde antes de você mexer.
3. Abra a tarefa em `docs/tasks/` (o backlog está no HANDOFF) e siga os critérios de aceite; commit com a mensagem do padrão. O hook confere a mensagem e roda os testes.

## Mensagens de commit e atribuição

Siga o formato acima. Se a sua ferramenta pede uma linha de coautoria ou atribuição, ponha-a no fim da mensagem, depois de uma linha em branco; a primeira linha é a que o hook confere.

## Se você é o revisor

Etapa 4 do pipeline (GDD §21): você **não pode ser o mesmo modelo que escreveu o código**. Use `docs/REVIEW-CHECKLIST.md`, compare o diff da tarefa com os critérios de aceite do arquivo da tarefa e com as seções do GDD citadas, e registre os achados em `docs/tasks/TASK-NNN-...md`, na seção "Revisão cruzada" (gravidade e o que foi feito). A TASK-029 pede essa revisão para todas as tarefas feitas até hoje.
