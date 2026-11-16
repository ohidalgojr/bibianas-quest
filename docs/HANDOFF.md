# HANDOFF

Atualizado em 2026-11-16 (TASK-001 concluída; TASK-002 concluída, 39 testes verdes, aguardando commit e revisão cruzada). Quem chega agora lê este arquivo, depois `CLAUDE.md`, depois a tarefa aberta em `docs/tasks/`. O plano até o MVP jogável está em `docs/ROADMAP-MVP.md`.

## Como retomar

1. Leia este arquivo, `CLAUDE.md` e `docs/tasks/TASK-001-fundacao-repositorio-godot-gut.md`.
2. A pasta do projeto é `C:\Users\Orlando\Downloads\Projetos\bibianas-quest`. Em uma sessão nova, ela pode não estar conectada: peça acesso a esse caminho.
3. O ambiente do Claude não tem Godot e não grava a pasta `.git` da máquina do Orlando. A suíte roda no PC dele pelo observador `tools\watch_tests.ps1` (ADR-0005; protocolo em `CLAUDE.md`, "Ciclo de teste do agente"): confira `reports/watcher.alive` e leia `reports/last_run.status` e `reports/last_run.txt` com `device_stage_files`. Se o observador não estiver rodando, peça ao Orlando para abri-lo. O estado do Git ainda vem dele: `git status --short` e `git log --oneline -3`. Não presuma que os testes passam.
4. Uma tarefa por vez. Próxima: TASK-003 (grafo do mapa), só depois de o Orlando commitar a TASK-002 e mandar seguir.

## Feito

- **TASK-001, fundação** (concluída em 2026-11-16): repositório, `CLAUDE.md` e `AGENTS.md`, GDD em `docs/GDD.md`, modelos de ADR e de tarefa, projeto Godot 4.7 em retrato, GUT 9.7.1 em headless, observador `watch_tests.ps1`. F5 abre a janela 540×960; commit amendado pelo Orlando. Falta só a revisão cruzada do Gemini.
- **TASK-002, RNG determinístico** (concluída no código, 2026-11-16): `game/core/rng/pcg32.gd` (PCG32 próprio) e `rng_streams.gd` (fluxos mapa, combate, loot e moeda, sementes por SplitMix64, `snapshot`/`restore` com números como texto). ADR-0006. Suíte: 39/39 verdes (observador, 10:20). **Falta o commit do Orlando** (mensagem sugerida: `TASK-002: RNG determinístico em 4 fluxos (ADR-0006)`) e a revisão cruzada.
- ADR-0004 aprovado; ADR-0005 aceito (observador funcionando em laço).

## Onde está

- Repositório: `C:\Users\Orlando\Downloads\Projetos\bibianas-quest`. A mesma pasta é o projeto Godot, o repositório Git e o vault do Obsidian. Um commit por tarefa.
- Regras e comandos: `CLAUDE.md`. Decisões: `docs/adr/`. Tarefas: `docs/tasks/`.
- Núcleo: `game/core/core_version.gd` (`RULES_VERSION = 0`, nenhuma regra implementada) e `game/core/rng/` (`Pcg32`, `RngStreams`).
- Apresentação: `game/presentation/main.tscn`, cena provisória.
- Testes: `tests/unit/`. Rodar com `tools\run_tests.ps1` (Windows) ou `tools/run_tests.sh`.
- `bibianas-quest.bundle` na raiz serviu só para trazer o commit da TASK-001. Está no `.gitignore` e pode ser apagado.

## Pendências do Orlando

1. **Commit da TASK-002:** `git add -A` e `git commit -m "TASK-002: RNG determinístico em 4 fluxos (ADR-0006)"`.
2. **Revisão cruzada (etapa 4)** pelo Gemini das TASK-001 e TASK-002, com `git show HEAD` e as regras do `CLAUDE.md`. Na TASK-002, olhar a aritmética de 64 bits com deslocamento lógico (`next_u32`, `_split_mix`).
3. Manter `tools\watch_tests.ps1` aberto; sem ele o Claude não vê resultado.
4. Dizer "segue" para o Claude abrir a TASK-003.

## Falta (ordem combinada; o roteiro completo e as mudanças propostas estão em `docs/ROADMAP-MVP.md`)

| Tarefa | Entrega | GDD |
| --- | --- | --- |
| TASK-002 | **Feita**: RNG determinístico em 4 fluxos | 20 |
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
| 0005 | Observador de arquivos roda a suíte no PC do Orlando e grava o resultado em `reports/` para o Claude ler | Aceito (2026-11-16) |
| 0006 | RNG próprio PCG32; quatro fluxos com sementes por SplitMix64; estado salvo como texto | Aceito (TASK-002) |

## Revisão de 2026-11-16 (TASK-001)

- **Atualização:** a suíte passou depois que o Orlando definiu `GODOT_BIN`, e o observador em laço foi confirmado. O Godot fica em `C:\Program Files\Godot_v4.7.2-stable_win64.exe\` (pasta com o console `.exe`).
- **MCP do Godot não está instalado.** O comando `claude mcp add --transport stdio godot -- npx -y @coding-solo/godot-mcp` é do Claude Code (terminal) e o Claude daqui não roda terminal na máquina. Ele não roda a suíte GUT, só abre e executa o projeto; por isso o observador é o caminho principal. Se quiser o MCP assim mesmo: rode o comando no terminal do Claude Code, ou use o arquivo de configuração do aplicativo (Configurações, Desenvolvedor, Editar configuração) com `GODOT_PATH`.
- **Teste de pureza:** a regex que barra métodos `shuffle` e `pick_random` obrigou a nomear os do `Pcg32` como `draw_*` e `shuffled_copy` (resolvido na TASK-002).
- **Commit:** `git add -A` e `git commit --amend --no-edit` ainda pendentes (inclui `*.uid`, ADR-0005, `tools/watch_tests.ps1`, `docs/ROADMAP-MVP.md`).
- **Pasta conectada antiga:** `C:\Users\Orlando\Downloads\vault\bibianas-quest` não existe mais; usar só `Projetos\bibianas-quest`.
- **Limpeza opcional:** sobras `*.tmp` em `reports/` (ignoradas pelo Git) e `bibianas-quest.bundle` na raiz.

## Perguntas em aberto

- **Ciclo de teste autônomo (ADR-0005).** O Orlando pediu que o Claude rode os testes sozinho. O servidor MCP do Godot e um terminal não estavam disponíveis, e o Claude não instala servidores locais. Solução proposta: `tools\watch_tests.ps1`, não testado em um PowerShell real. Falta confirmar que funciona. Se não funcionar, o plano B é o Orlando colar a saída de `run_tests.ps1` a cada tarefa. Complemento possível: o MCP do Godot (`@coding-solo/godot-mcp`, exige Node.js e `GODOT_PATH`), que roda o projeto e não a suíte.
- **Autoria do commit da TASK-001:** está com o e-mail da conta Claude do Orlando. Se o repositório for publicado com outro e-mail, corrigir antes do `git push` (`git commit --amend --reset-author`).
- **Obsidian:** o vault é a raiz do repositório. Se a busca ficar poluída, listar `addons/`, `game/`, `tests/` e `tools/` em Arquivos excluídos (ADR-0002). Opcional.

## Pontos de atenção para as próximas tarefas

- Sorteio no núcleo só por `RngStreams` (`map()`, `combat()`, `loot()`, `coin()`); métodos do `Pcg32`: `draw_int`, `draw_float`, `draw_percent`, `draw_index`, `shuffled_copy`. Não usar `randi`, `shuffle` nem `pick_random`. O save usa `snapshot()` como está (texto, não número de 64 bits em JSON). A semente do próximo mapa vem de `RngStreams.derive_seed`.
- TASK-003 depende de um bot que luta. O GDD §5 pede simulação do bot no caminho mais seguro, e o motor de combate só chega na TASK-004. A TASK-003 terá de definir uma interface de avaliação de rota que a TASK-004 preenche, ou um modelo de combate simplificado registrado em ADR.
- "Moedas" no GDD §15 é o ouro; "a moeda" do §7 é o cara ou coroa. No código: `gold` e `coin`.
- Fórmulas do GDD só mudam com ADR, no mesmo commit do GDD (`docs/GDD.md`) e do código, com `CoreVersion.RULES_VERSION` incrementado.
