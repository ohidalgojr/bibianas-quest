# ADR-0005: ciclo de teste autônomo por observador de arquivos

| Campo | Valor |
| --- | --- |
| Status | Proposto (aguarda a primeira execução no PC do Orlando) |
| Data | 2026-11-15 |
| Tarefa | TASK-001 |
| GDD | 21 (etapa 5) |

## Contexto

As tarefas 002 a 005 são lógica pura com milhares de sementes, e o agente que as escreve precisa ver a suíte rodar. O ambiente do agente não tem Godot, não tem rede para instalá-lo e não tem terminal na máquina do Orlando (a ponte de arquivos só lê e grava arquivos, e não grava `.git`). O servidor MCP do Godot mais conhecido (Coding-Solo) expõe ferramentas para abrir o editor, rodar o projeto em modo de depuração e ler a saída, mas não para chamar o motor com os argumentos do GUT (`-s addons/gut/gut_cmdln.gd -gexit`). Instalá-lo também exige Node.js e editar o arquivo de configuração do Claude no PC.

## Decisão

- `tools/watch_tests.ps1` roda no PC do Orlando, numa janela do PowerShell que ele deixa aberta. A cada mudança em `game/`, `tests/`, `project.godot` ou `.gutconfig.json` (esperando 2 s de calmaria), ele roda `tools/run_tests.ps1`.
- O resultado vai para `reports/` (fora do Git): `last_run.status` (`state`, `started`, `finished`, `exit`, `reason`), `last_run.txt` (saída completa) e `watcher.alive` (batida do laço).
- O agente grava arquivos pela ponte, espera `state=done` com `started` posterior à gravação, lê `last_run.txt` e só então afirma que a suíte passou. Um arquivo vazio `reports/run_now` força uma rodada.
- `*.uid`, `*.import` e documentação não disparam rodadas, porque o Godot os cria durante a própria suíte.
- `watch_tests.ps1 -Once` roda uma vez e sai com o código da suíte, para conferir a instalação.

## Alternativas

- **MCP do Godot:** pede instalação local e `GODOT_PATH`, e roda o projeto, não a suíte. Exigiria uma cena executora de testes e abre janela. Continua possível como complemento.
- **Servidor MCP de terminal na máquina:** daria a ferramenta mais geral, mas é uma permissão bem mais ampla do que este projeto precisa.
- **Instalar o Godot no ambiente do agente:** hoje sem rede; pode mudar se o Orlando liberar o acesso.
- **Orlando cola a saída a cada tarefa:** funciona e é o plano B.

## Consequências

- **O observador executa, sem confirmação, o GDScript que o agente grava**, com as permissões do usuário do Windows. A proteção é humana: revisar `git diff` depois de cada tarefa, a revisão cruzada (etapa 4) e fechar a janela para parar. O teste de pureza só vigia `game/core/`, não `tests/`.
- Enquanto a janela estiver fechada, o agente não tem resultado novo e deve pedir ao Orlando que a abra, nunca presumir que está verde.
- O script não foi executado por nenhum PowerShell real quando foi escrito. Em 2026-11-16 o `-Once` rodou no PC do Orlando e a suíte saiu verde (exit 0, 13/13); falta ver o laço sem `-Once` reagir a uma gravação. O Status passa a Aceito quando `-Once` e uma rodada automática funcionarem no PC do Orlando.
