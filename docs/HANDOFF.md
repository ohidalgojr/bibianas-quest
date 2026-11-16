# HANDOFF

Atualizado em 2026-11-16 (TASK-001 a 010 e TASK-015, escolha do lado da moeda, concluídas; suíte 210/210; desenvolvimento no Claude Code). Quem chega agora lê este arquivo, depois `CLAUDE.md`, depois a tarefa aberta em `docs/tasks/`. O plano até o MVP está em `docs/ROADMAP-MVP.md` (aprovado).

## Como retomar

1. Leia este arquivo, `CLAUDE.md` e a tarefa aberta em `docs/tasks/`. A próxima é a TASK-011 (fluxo completo: menu, Descida, chefe, morte, recomeço; abrir o arquivo da tarefa a partir do roteiro antes de codar).
2. **Harness atual: Claude Code (aplicativo desktop), com terminal.** Rode a suíte direto: `powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1` (precisa de `GODOT_BIN`, já definido, e de `addons/gut/`; em worktree nova rode `tools\setup.ps1`). O observador (ADR-0005) só é necessário em ambientes sem terminal, como o projeto do claude.ai usado antes.
3. MCP do Godot e do Blender em `.mcp.json` (ver `docs/MCP.md`). O addon do Blender já foi instalado e ativado no Blender 5.3 do Orlando; falta conectar na aba BlenderMCP (`N`) a cada sessão. Os servidores só aparecem depois de reiniciar a sessão e aprová-los. Aprovação local: `.claude/settings.local.json` com `"enabledMcpjsonServers": ["godot", "blender"]` (fora do Git; copiar para cada checkout ou worktree). Testados em 2026-11-16: os dois respondem ao handshake MCP e o `blender` conecta no addon em `localhost:9876`. O pacote `blender-mcp` virou wrapper de `mcp-for-blender`; continua funcionando na versão fixada.
4. Uma tarefa por vez. O Orlando liberou seguir as tarefas do roteiro (2026-11-16), parando ao fim de cada uma para o resumo.
5. Git: remoto `origin` (GitHub `ohidalgojr/bibianas-quest`). A `main` tem tudo até a TASK-009 (mesclada em 2026-11-16 por avanço rápido, histórico linear; os branches e worktrees locais das sessões anteriores foram removidos; no GitHub, o branch padrão do repositório ainda é `claude/godot-blender-setup-0792cc` e pode ser trocado para `main` nas configurações). Regra do projeto: uma tarefa por vez, um commit por tarefa.

## Como jogar

Abra a **pasta raiz do repositório** no Godot 4.7 (Importar, `project.godot`) e aperte **F5**. A cena principal abre o `GameScreen`: "Nova Descida" gera o mapa do cenário 1 (cerca de 1,5 s) e leva a mapa, lutas, loja e fogueira provisórias, e fim; "Luta de teste (depuração)" abre o seletor de inimigo, nível e Poder. Se aparecer só uma tela escura com "regras vN", o Godot abriu uma cópia antiga do projeto (outra pasta ou worktree): confira que o caminho aberto é o da raiz do repositório atual.

## Feito

- **TASK-001, fundação** (concluída em 2026-11-16): repositório, `CLAUDE.md` e `AGENTS.md`, GDD em `docs/GDD.md`, modelos de ADR e de tarefa, projeto Godot 4.7 em retrato, GUT 9.7.1 em headless, observador `watch_tests.ps1`. F5 abre a janela 540×960; commit amendado pelo Orlando. Falta só a revisão cruzada do Gemini.
- **TASK-002, RNG determinístico** (concluída e commitada em 2026-11-16): `game/core/rng/pcg32.gd` e `rng_streams.gd` (fluxos mapa, combate, loot e moeda). ADR-0006.
- **TASK-003, grafo do mapa** (concluída e commitada em 2026-11-16): `game/core/map/`. ADR-0007.
- **TASK-004, combate e moeda** (concluída no código em 2026-11-16, suíte 120/120, 14 scripts, 19 s; revisão cruzada pendente): `game/core/combat/` com `Combat` (motor por eventos), `Combatant`, `Stats`, `CombatFormulas`, `CoinRules`, `CoinState`, `EnemyMove`, `EnemyPhase`, `CombatEffect`, `CombatSkill` (Guerreiro), `CombatItem`, `CombatEvent`. Testes em `tests/unit/test_combat*.gd`, `test_coin.gd`, `test_stats.gd`; apoio em `tests/support/combat_fixtures.gd` (inimigos de teste, bot, auditor). ADR-0008 (20 leituras do GDD, 2 perguntas). `RULES_VERSION` = 2. A travada anterior da suíte no `test_map_generator` não se repetiu (duas rodadas completas verdes, uma pelo observador e uma no Claude Code); causa não identificada, o limite de 8 minutos do observador fica como proteção.
- **TASK-005, dados do cenário 1** (concluída em 2026-11-16, suíte 150/150, 17 scripts; revisão cruzada pendente): JSON em `game/data/` (`classes`, `skills`, `enemies`, `items`, `scenarios`). `GameData` e `DataValidator` ficam em `game/core/data/`, sem I/O. `DataLoader` fica em `game/services/` e lê os arquivos. São 4 inimigos comuns, o Carrasco Apodrecido (elite) e O Coveiro (chefe, 2 fases). Os inimigos escalam por nível com as taxas do Poder. ADR-0009. Testes: `test_data_validator.gd`, `test_data_loader.gd` e `test_game_data.gd`, que inclui o auditor de justiça com os inimigos de verdade.
- **TASK-006, combate jogável** (concluída no código em 2026-11-16, suíte 161/161, 19 scripts; faltam o teste de sensação do Orlando e a revisão cruzada). A tela fica em `game/presentation/combat/`: `CombatSession` (controlador sem nós), `CombatTexts` e `CombatScreen` (tela 2D montada em código). `main.gd` abre a tela direto, no seletor de depuração (inimigo pelas teclas 1 a 6, nível e Poder). Tem linha do tempo, ícone de intenção com a chance da moeda, registro da luta, lance de 1,2 s, Poção Turva (2 por luta) e velocidade 2x. ADR-0010.
- **TASK-007, estado da Descida** (concluída no código em 2026-11-16, suíte 184/184, 22 scripts; revisão cruzada pendente). Os arquivos ficam em `game/core/run/`:
  - `RunRules`: Poder, ouro, baú, nível por camada e números da fogueira e da loja.
  - `RunState`: fases, transições, HP e MP persistentes, inventário, equipamento e buffs.
  - `RunEvent`: eventos da Descida para a apresentação.

  O `MapNode` ganhou `enemy_id` e `level`. O bot de regras está em `tests/support/run_bot.gd`. ADR-0011. `RULES_VERSION` = 3.
- **TASK-008, simulador e vencibilidade** (concluída no código em 2026-11-16, suíte 194/194, 24 scripts, 25 s; revisão cruzada pendente).
  - **Simulação:** os bots mediano e cuidadoso e o `Simulator` ficam em `game/core/sim/`. O bot saiu de `tests/support/`. `tools/simulate.gd` grava `reports/simulation.md`.
  - **Vencibilidade (GDD §5):** está em `game/core/run/winnability.gd` e entra pelo parâmetro `map_check_runs` do `RunState`, com padrão 0 nos testes e 200 no GDD. A meta de rota do cenário 1 é 60%.
  - **Coveiro calibrado:** HP 150, FOR 14, fase final com 2 golpes de moeda em 4. O mediano vence 65% e o cuidadoso 64%, com 6,3 turnos por luta comum.
  - ADR-0012. `RULES_VERSION` = 4.
- **TASK-009, mapa jogável** (concluída no código em 2026-11-16, suíte 201/201, 26 scripts; revisão cruzada e jogada humana pendentes).
  - **Mapa:** `game/presentation/map/` tem o `MapView` (modelo com névoa, sem nós) e o `MapScreen` (grade 2D em retrato, botões e ligações).
  - **Fluxo:** `game/presentation/game_screen.gd` leva do início à espera, ao mapa, à luta, à loja e fogueira provisórias e ao resultado. A Descida é criada numa `Thread`, com a checagem de 200 simulações (cerca de 1,5 s no PC).
  - **Combate:** o `CombatSession.for_run` e o `CombatScreen.start_run_fight` ligam o combate à Descida.
  - **Abertura:** `main.gd` abre o `GameScreen`; a luta de teste fica no início.
  - ADR-0013.
- **TASK-015, escolha do lado da moeda** (concluída no código em 2026-11-16, suíte 205/205; correção pedida pelo Orlando depois de jogar a TASK-009; número fora de ordem de propósito, entra antes da TASK-010).
  - Todo lance (golpe de moeda do inimigo, Atordoar, Fugir) pede Cara ou Coroa antes de girar. Acertar o lado é o sucesso: a moeda cai no lado escolhido no sucesso e no outro na falha. Chance, sorteio e núcleo não mudaram (a escolha é ritual).
  - GDD §7 atualizado. Respondeu a pergunta do ADR-0010. ADR-0014. Em testes, `CombatScreen.auto_call` decide o lado.
  - Quando a trapaça (anúncio ou Moeda Viciada) entrar, o núcleo vai precisar parar no lance; ver ADR-0014.
- **TASK-010, recompensa, loja e fogueira em tela** (concluída no código em 2026-11-16, suíte 210/210, 27 scripts; revisão cruzada e jogada humana pendentes).
  - `game/presentation/run/`: `RunPanels` (controlador sem nós) e `RunPanelScreen` (painel em código). O `GameScreen` mostra a recompensa (Poder, ouro) depois de uma vitória com loja, depois a loja (comprar, atualizar, motivo do botão desabilitado) e, nas fogueiras, Descansar e skills. ADR-0015.
- ADR-0004 aprovado; ADR-0005 aceito (observador funcionando em laço).

## Onde está

- Repositório: `C:\Users\Orlando\Downloads\Projetos\bibianas-quest`. A mesma pasta é o projeto Godot, o repositório Git e o vault do Obsidian. Um commit por tarefa.
- Regras e comandos: `CLAUDE.md`. Decisões: `docs/adr/`. Tarefas: `docs/tasks/`.
- Núcleo: `game/core/core_version.gd` (`RULES_VERSION = 4`), `game/core/rng/`, `game/core/map/`, `game/core/combat/`, `game/core/data/`, `game/core/run/` e `game/core/sim/`.
- Dados: `game/data/*.json`, carregados por `DataLoader.load_all()` (`game/services/data_loader.gd`).
- Apresentação: `game/presentation/main.tscn` abre o `GameScreen`. F5 no editor joga uma Descida ("Nova Descida") ou a luta de teste. Telas em `game/presentation/combat/` e `game/presentation/map/`.
- Testes: `tests/unit/`. Rodar com `tools\run_tests.ps1` (Windows) ou `tools/run_tests.sh`.
- `bibianas-quest.bundle` na raiz serviu só para trazer o commit da TASK-001. Está no `.gitignore` e pode ser apagado.

## Pendências do Orlando

1. Conectar o addon do Blender (aba BlenderMCP, tecla `N`) quando for usar o Blender.
2. **Jogar uma Descida (TASK-009):** F5 no Godot e "Nova Descida" (ver "Como jogar"), para ver se o mapa se lê bem e se o fluxo anda.
3. **Teste de sensação da TASK-006:** jogar algumas lutas (o Coveiro inclusive) e anotar no fim de `docs/tasks/TASK-006-combate-jogavel.md` se a moeda dá tensão e se o aviso de um turno basta.
4. Responder a pergunta do ADR-0008 (PRE como bônus sobre 90; Veterano com redução de 65% ou de 80%). A do ADR-0010 foi respondida no ADR-0014; confirmar que "acertar o lado" é o que o Orlando queria.
5. **Decidir os dois pontos do ADR-0012:** o custo da checagem de mapa no celular (a thread já existe; falta medir no celular e decidir o save) e as mortes por moeda acima da meta (31% e 35%, contra 25%; recomendação: esperar o teste de sensação).
6. Revisão cruzada do Gemini, TASK-001 a 009.

## Falta (ordem combinada; o roteiro completo e as mudanças propostas estão em `docs/ROADMAP-MVP.md`)

| Tarefa | Entrega | GDD |
| --- | --- | --- |
| TASK-002 | **Feita**: RNG determinístico em 4 fluxos | 20 |
| TASK-003 | **Feita** (sem o bot, que foi para a TASK-008): gerador de mapa em grafo e teste de propriedade | 5 |
| TASK-004 | Motor de combate 1 contra 1 e moeda, com testes de fórmula (**em verificação**) | 6, 7, 8, 9 |
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
| 0008 | Leituras do GDD §6 a §8 para o combate (PRE como bônus, arredondamento, Veterano 65%, aviso garantido contra inimigo rápido, durações) | Aceito, com 2 perguntas (TASK-004) |
| 0015 | Recompensa, loja e fogueira: controlador sem nós e painel em código por cima do mapa; recompensa só depois de vitória com loja | Aceito (TASK-010) |
| 0014 | O jogador escolhe Cara ou Coroa em todo lance; acertar o lado é o sucesso; a escolha é ritual e o núcleo não muda | Aceito (TASK-015) |
| 0013 | Mapa em grade 2D com névoa (`MapView` sem nós e `MapScreen`). Combate ligado à Descida. Loja e fogueira provisórias. Descida criada numa `Thread`. `GameScreen` como raiz provisória | Aceito (TASK-009) |
| 0012 | Bots mediano e cuidadoso; vencibilidade com 200 simulações, parada antecipada, 5 suavizações e descarte; meta de rota 60%; Coveiro com HP 150, FOR 14 e 2 golpes de moeda na fase final | Aceito, com 2 pontos para decidir (TASK-008) |
| 0011 | Estado da Descida. HP e MP persistem; nível por camada interpolado; eventos fora do protótipo; emboscada como batalha; baú só com ouro. Fogueira com skills a 2 Brasas e buffs como FOR e DEF ×1,15. Loja sem especial; equipamento equipado na hora | Aceito (TASK-007) |
| 0010 | Combate em 2D no protótipo: controlador sem nós e tela montada em código, com eventos animados em fila | Aceito, com 1 pergunta (TASK-006) |
| 0009 | Dados em JSON validado (núcleo sem I/O); inimigos escalam por nível com as taxas do Poder; atributos da classe já incluem o equipamento inicial | Aceito (TASK-005) |
| 0007 | Leituras do GDD §5 para o mapa (partida, convergência, fogueiras, 30% sem elite, máximo de 2 elites por camada); bot e níveis adiados para a TASK-008 | Aceito (TASK-003) |

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
- **A garantia de vencibilidade do GDD §5 ainda não está provada**: a TASK-003 só cobre as regras estruturais. A TASK-008 liga o bot a `MapGraph.safest_route(custo)` e passa a conferir a opção segura por nível. Eventos são sorteados (9%) e mini boss não é colocado; a configuração do cenário 1 do protótipo decide os eventos na TASK-005 ou 007, com ADR.
- **Godot 4.7 e enums:** um enum usado dentro da própria classe e por outras com dependência cíclica dá erro de tipo ("Cannot assign Combatant.Side as Side"). Nesses casos, usar constantes inteiras.
- **Observador:** tem limite de tempo por rodada desde 2026-11-16 (status `timeout`, exit 124). Saída parcial fica em `reports/last_run.out.tmp` enquanto roda.
- A suíte leva cerca de 20 s por causa dos testes de propriedade do mapa; se passar de 1 minuto, separar os testes longos em outra pasta.
- **Telas:** as próximas telas (TASK-009 e 010) seguem o padrão do ADR-0010: um controlador `RefCounted` testável e uma tela montada em código. Nos testes, `time_scale = 0` deixa a animação instantânea. Para ver uma tela sem abrir o editor, rode o Godot com janela e um script `SceneTree` que salva `root.get_texture().get_image()` em PNG (o headless não desenha).
- **Dados:** a TASK-006 monta a luta por `DataLoader.load_all()`, `make_player("warrior", poder)` e `make_enemy(id, nível)`. Não deve usar os `CombatFixtures`. `CombatSkill.warrior_set()` continua como referência, e um teste confere que é igual aos dados.
- **Exportação (TASK-014):** o Godot não exporta `.json` por padrão. No preset, incluir `game/data/*.json` em "Filtros para exportar arquivos que não são recursos", senão o jogo exportado abre sem dados.
- **Simulador:** `"$GODOT_BIN" --headless --path . -s tools/simulate.gd -- --runs 200 --check 40 --maps 200 --map-check 20`. Leva cerca de 7 min e passa do limite de 10 min com `--runs 300` ou mais, então rode em segundo plano. Script novo com `class_name` exige `--headless --import` antes de rodar fora da suíte.
- **Criação da Descida:** o `GameScreen` já cria o `RunState` numa `Thread`, com `Winnability.DEFAULT_RUNS` (200). Leva cerca de 1,5 s no PC e falta medir no celular (TASK-014). Guardar o resultado no save fica para a TASK-012.
- **Telas novas:** os nós trocados com `queue_free` aparecem como "órfãos" no GUT. É esperado: liberar na hora pode derrubar o jogo, porque o botão que pediu a troca ainda está emitindo o sinal.
- **Worktree e o Godot:** quem joga precisa abrir a pasta da worktree/branch com as mudanças (ou mesclar na `main`); abrir a raiz de outro checkout mostra o jogo antigo (foi o que fez a moeda parecer automática de novo).
- **Calibração resolvida na TASK-008 (histórico):** o bot de regras vence só 8% das Descidas do cenário 1, contra a meta de 55% a 65%. Em 300 Descidas, 239 mortes foram no Coveiro (nível 6, 220 de HP, Golpe Mortal), contra uma Bibiana com Poder perto de 2,5. Antes de mexer em números, ver se o bot joga mal o chefe (não guarda poção, não defende o Golpe Mortal) e só então ajustar as alavancas do GDD §23, com ADR. O script de diagnóstico usado foi um `SceneTree` com `RunBot.play` em 300 sementes, contando `run.current_node()` nas derrotas.
- **Calibração (TASK-008):** o Corvo Carniceiro dá 5,3 turnos por luta, abaixo da meta de 6 a 10. O Coveiro dá 28 turnos no teste com Poder suposto. A regra própria do Coveiro (covas e mortos) ainda não existe.
- "Moedas" no GDD §15 é o ouro; "a moeda" do §7 é o cara ou coroa. No código: `gold` e `coin`.
- Fórmulas do GDD só mudam com ADR, no mesmo commit do GDD (`docs/GDD.md`) e do código, com `CoreVersion.RULES_VERSION` incrementado.
