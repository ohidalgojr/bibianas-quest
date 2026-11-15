# HANDOFF

Atualizado em 2026-11-16 (TASK-001: suíte verde, 13/13 no Godot 4.7.2; faltam F5, commit fechado e rodada do observador em laço; roteiro até o MVP aprovado). Quem chega agora lê este arquivo, depois `CLAUDE.md`, depois a tarefa aberta em `docs/tasks/`. O plano até o MVP jogável está em `docs/ROADMAP-MVP.md`.

## Como retomar

1. Leia este arquivo, `CLAUDE.md` e `docs/tasks/TASK-001-fundacao-repositorio-godot-gut.md`.
2. A pasta do projeto é `C:\Users\Orlando\Downloads\Projetos\bibianas-quest`. Em uma sessão nova, ela pode não estar conectada: peça acesso a esse caminho.
3. O ambiente do Claude não tem Godot e não grava a pasta `.git` da máquina do Orlando. A suíte roda no PC dele pelo observador `tools\watch_tests.ps1` (ADR-0005; protocolo em `CLAUDE.md`, "Ciclo de teste do agente"): confira `reports/watcher.alive` e leia `reports/last_run.status` e `reports/last_run.txt` com `device_stage_files`. Se o observador não estiver rodando, peça ao Orlando para abri-lo. O estado do Git ainda vem dele: `git status --short` e `git log --oneline -3`. Não presuma que os testes passam.
4. Não abra a TASK-002 antes de a TASK-001 estar fechada (suíte verde, Status Concluída). Uma tarefa por vez.

## Feito

- **TASK-001, fundação** (em verificação): repositório, `CLAUDE.md` e `AGENTS.md`, cópia do GDD em `docs/GDD.md`, modelos de ADR e de tarefa, ADR-0001 a 0004, projeto Godot 4.7 em retrato com ícone, três scripts de teste GUT (13 testes) e scripts de um comando para rodar em headless.
- O commit da TASK-001 já foi importado no repositório do Orlando (ramo `main`, `origin` configurado, nada enviado ao remoto). Os arquivos duplicados da raiz (GDD solto e `Welcome.md`) foram apagados.
- ADR-0004 aprovado pelo Orlando.

## Onde está

- Repositório: `C:\Users\Orlando\Downloads\Projetos\bibianas-quest`. A mesma pasta é o projeto Godot, o repositório Git e o vault do Obsidian. Um commit por tarefa.
- Regras e comandos: `CLAUDE.md`. Decisões: `docs/adr/`. Tarefas: `docs/tasks/`.
- Núcleo: `game/core/` só tem `core_version.gd` (`RULES_VERSION = 0`, nenhuma regra implementada).
- Apresentação: `game/presentation/main.tscn`, cena provisória.
- Testes: `tests/unit/`. Rodar com `tools\run_tests.ps1` (Windows) ou `tools/run_tests.sh`.
- `bibianas-quest.bundle` na raiz serviu só para trazer o commit da TASK-001. Está no `.gitignore` e pode ser apagado.

## Pendências da TASK-001

Feito em 2026-11-16: `GODOT_BIN` definida, `watch_tests.ps1 -Once` com `exit=0`, 13 testes passando (Godot 4.7.2, GUT 9.7.1).

1. **Deixar o observador aberto** (`powershell -ExecutionPolicy Bypass -File tools\watch_tests.ps1`, sem `-Once`, numa janela do PowerShell). A primeira gravação do Claude na TASK-002 mostra se ele reage sozinho; aí o ADR-0005 vira Aceito.
2. **Fechar o commit:** `git add -A` e `git commit --amend --no-edit` (inclui `*.uid`, ADR-0005, `watch_tests.ps1`, `ROADMAP-MVP.md` e as mudanças de documentação), antes de qualquer `git push`. Depois, trocar o Status da TASK-001 para Concluída.
3. **Abrir no editor e apertar F5:** a janela deve abrir em retrato com o nome do jogo.
4. **Revisão cruzada** pelo Gemini (etapa 4), com `git show HEAD` e as regras do `CLAUDE.md`.

Quando 2 e 3 estiverem feitos, o Claude abre a TASK-002.

## Falta (ordem combinada; o roteiro completo e as mudanças propostas estão em `docs/ROADMAP-MVP.md`)

| Tarefa | Entrega | GDD |
| --- | --- | --- |
| TASK-002 | RNG determinístico em 4 fluxos (mapa, combate, loot, moeda), com teste de reprodução | 20 |
| TASK-003 | Gerador de mapa em grafo, teste de propriedade em milhares de sementes, bot de vencibilidade | 5 |
| TASK-004 | Motor de combate 1 contra 1 e moeda, com testes de fórmula | 6, 7, 8, 9 |
| TASK-005 | Simulador headless de balanceamento e primeiro relatório | 23 |

Regra do pedido: ao fim de cada tarefa, parar e mostrar o resumo.

**Aprovado em 2026-11-16 (ROADMAP-MVP.md); a tabela acima fica como histórico da ordem original:** o bot de vencibilidade vai da TASK-003 para a TASK-008 (o combate só existe na 004), o simulador vira TASK-008 e entram TASK-005 (dados) e TASK-006 (combate jogável) antes do resto, até TASK-014 (portão da Fase 1).

O restante da Fase 0 que não está nessa ordem: Skills do projeto, `assets/LICENSES.md`, Style Bible, checklist de revisão cruzada, presets de exportação.

## Decisões

| ADR | Decisão | Status |
| --- | --- | --- |
| 0001 | Godot 4.7, GDScript com tipagem obrigatória, Compatibility, retrato 540×960 com `keep_width` | Aceito |
| 0002 | `project.godot` na raiz; núcleo sem nós, verificado por teste; identificadores em inglês; vault na raiz | Aceito |
| 0003 | GUT 9.7.1 instalado por script, fora do Git; um comando roda a suíte em headless | Aceito |
| 0004 | `docs/GDD.md` é a cópia do GDD que vale para o código | Aceito (Orlando, 2026-11-15) |
| 0005 | Observador de arquivos roda a suíte no PC do Orlando e grava o resultado em `reports/` para o Claude ler | Proposto (`-Once` verde; falta o laço sem `-Once`) |

## Revisão de 2026-11-16 (TASK-001)

- **Atualização:** a suíte rodou e passou (13/13) depois que o Orlando definiu `GODOT_BIN`. Falta só o observador em laço. O Godot fica em `C:\Program Files\Godot_v4.7.2-stable_win64.exe\` (pasta com o console `.exe`).
- **MCP do Godot não está instalado.** O comando `claude mcp add --transport stdio godot -- npx -y @coding-solo/godot-mcp` é do Claude Code (terminal) e o Claude daqui não roda terminal na máquina. Ele não roda a suíte GUT, só abre e executa o projeto; por isso o observador é o caminho principal. Se quiser o MCP assim mesmo: rode o comando no terminal do Claude Code, ou use o arquivo de configuração do aplicativo (Configurações, Desenvolvedor, Editar configuração) com `GODOT_PATH`.
- **Teste de pureza:** a regex `\.(shuffle|pick_random)\s*\(` bloqueia qualquer método com esses nomes, inclusive no nosso RNG da TASK-002. Resolver lá: nomear os métodos `draw_*` e `shuffled_copy()`, ou refinar a regex.
- **Commit:** `git add -A` e `git commit --amend --no-edit` ainda pendentes (inclui `*.uid`, ADR-0005, `tools/watch_tests.ps1`, `docs/ROADMAP-MVP.md`).
- **Pasta conectada antiga:** `C:\Users\Orlando\Downloads\vault\bibianas-quest` não existe mais; usar só `Projetos\bibianas-quest`.
- **Limpeza opcional:** sobras `*.tmp` em `reports/` (ignoradas pelo Git) e `bibianas-quest.bundle` na raiz.

## Perguntas em aberto

- **Ciclo de teste autônomo (ADR-0005).** O Orlando pediu que o Claude rode os testes sozinho. O servidor MCP do Godot e um terminal não estavam disponíveis, e o Claude não instala servidores locais. Solução proposta: `tools\watch_tests.ps1`, não testado em um PowerShell real. Falta confirmar que funciona. Se não funcionar, o plano B é o Orlando colar a saída de `run_tests.ps1` a cada tarefa. Complemento possível: o MCP do Godot (`@coding-solo/godot-mcp`, exige Node.js e `GODOT_PATH`), que roda o projeto e não a suíte.
- **Autoria do commit da TASK-001:** está com o e-mail da conta Claude do Orlando. Se o repositório for publicado com outro e-mail, corrigir antes do `git push` (`git commit --amend --reset-author`).
- **Obsidian:** o vault é a raiz do repositório. Se a busca ficar poluída, listar `addons/`, `game/`, `tests/` e `tools/` em Arquivos excluídos (ADR-0002). Opcional.

## Pontos de atenção para as próximas tarefas

- TASK-002 precisa decidir, com ADR, entre embrulhar `RandomNumberGenerator` e implementar um gerador próprio. O teste de pureza hoje libera chamadas de método como `stream.randi_range()` e barra as funções globais.
- TASK-003 depende de um bot que luta. O GDD §5 pede simulação do bot no caminho mais seguro, e o motor de combate só chega na TASK-004. A TASK-003 terá de definir uma interface de avaliação de rota que a TASK-004 preenche, ou um modelo de combate simplificado registrado em ADR.
- "Moedas" no GDD §15 é o ouro; "a moeda" do §7 é o cara ou coroa. No código: `gold` e `coin`.
- Fórmulas do GDD só mudam com ADR, no mesmo commit do GDD (`docs/GDD.md`) e do código, com `CoreVersion.RULES_VERSION` incrementado.
