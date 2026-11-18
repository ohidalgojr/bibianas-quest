# HANDOFF

Atualizado em 2026-11-16 (TASK-001 a 013 e TASK-015 concluídas e TASK-014 em verificação; suíte 266/266; desenvolvimento no Claude Code). Quem chega agora lê este arquivo, depois `CLAUDE.md`, depois a tarefa aberta em `docs/tasks/`. O plano até o MVP está em `docs/ROADMAP-MVP.md` (aprovado).

## Como retomar

1. Leia este arquivo, `CLAUDE.md` e a tarefa aberta em `docs/tasks/`. A TASK-014 está em verificação (ver pendências 7 e 8). Com ela fechada, a Fase 1 acaba e o próximo passo é decidir com o Orlando o ajuste do laço (`docs/FEEDBACK.md`, propostas TASK-016 e 017) e abrir o roteiro da Fase 2.
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
- **TASK-011, fluxo completo** (concluída no código em 2026-11-16, suíte 213/213; jogada humana e revisão cruzada pendentes). Menu com Ecos e classe, tela de fim com causa da morte e Ecos (1 por nó, 5 por chefe, provisório), "Outra Descida" com nova semente; três Descidas seguidas testadas. Ecos persistem desde a TASK-012. ADR-0016.
- **TASK-012, auto-save** (concluída no código em 2026-11-16, suíte 217/217; jogada humana e revisão cruzada pendentes). `RunSave` (núcleo) e `SaveStore` (serviços) gravam a Descida a cada nó no mapa, em `user://run.json`, e a meta (Ecos) em `user://meta.json`. Menu ganhou "Continuar Descida". ADR-0017.
- **TASK-013, depuração e telemetria** (concluída no código em 2026-11-16, suíte 266/266; jogada humana e revisão cruzada pendentes). Em build de depuração: semente no menu, F1 +100 ouro, F2 pular nó, F3 matar inimigo, F4 forçar moeda. `Telemetry` (serviços) grava `user://telemetry.log` (nós, moeda, lutas, mortes com `by_coin`). ADR-0018.
- **TASK-014, exportação** (em verificação em 2026-11-16): `export_presets.cfg` (Web e Android), `tools\export_web.ps1`, `docs/PLAYTEST.md` e toque desligado em mobile e web. **Nada foi exportado**: não há templates de exportação no PC. Depende do Orlando (ver pendências). ADR-0019.
- **Feedback de playtest:** registrado em `docs/FEEDBACK.md` (F-001 chefe com moeda demais, F-002 golpes com debuff por probabilidade, F-003 matar inimigos sem senso de progressão). Propostas de TASK-016 e TASK-017 lá.
- **TASK-016, ritmo da moeda e debuffs do chefe** (concluída no código em 2026-11-16, suíte 266/266; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 5). Ao menos 2 golpes entre golpes de moeda em todos os inimigos (sem exceção de chefe); novo golpe `debuff` com chance própria, aviso DEBILITA, Defender corta a chance pela metade; Veneno e Fraqueza do GDD §11; Coveiro com Toque Podre e Maldição. Simulador: mediano 56%, mortes por moeda 21,6%. F-001 e F-002 atendidos; F-003 segue aberto. ADR-0020.
- **TASK-017, progressão visível** (concluída no código em 2026-11-16, suíte 266/266; jogada humana e revisão cruzada pendentes). Recompensa com quem caiu e atributos antes e depois; mapa e fim com FOR, DEF, VEL e inimigos derrotados; números de dano e animação de abate na luta. Sem mudança de regra. **Achado:** o ganho por luta é de 1 a 2 de HP no começo; decisão de economia pendente (drops, marcos ou curva do Poder). ADR-0021.
- **TASK-018, drops e equipamento** (concluída no código em 2026-11-16, suíte 266/266; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 6). Inimigos soltam equipamento (12% comum, 35% elite, raridade por pesos, raro só de elite) e consumível de cura; a recompensa pergunta Equipar ou Vender (40%); 9 itens novos; loja sem raros. Simulador: mediano 65,5%. Recalibrar o Coveiro uma vez depois da TASK-020. ADR-0022. Parte do F-004; faltam TASK-019 (ganho de status) e TASK-020 (skills na loja).
- **TASK-019, ganho de status** (concluída no código em 2026-11-16, suíte 266/266, cerca de 2 min; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 7). ΔPoder = 0,4 × N × m_tipo (era 0,15); Nível = parte inteira do Poder, no mapa e na recompensa ("Subiu de nível!"); Coveiro com HP 215 e FOR 16. Simulador: mediano 65,0%, 0 mapas sem rota em 100. ADR-0023. Falta a TASK-020 (skills na loja) e então recalibrar o Coveiro de novo.
- **TASK-020, skills na loja** (concluída no código em 2026-11-16, suíte 266/266, cerca de 100 s; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 8). A loja oferece uma skill do Guerreiro por visita (Golpe Giratório, Grito de Guerra, Segundo Fôlego), até 5 skills; 5 botões de skill no combate; skills aprendidas no save. Simulador: mediano 65,3%. ADR-0024. Fecha o F-004 (TASK-018 a 020); candidato seguinte: MP curto e uso do Éter Sujo.
- **TASK-021, moeda 50/50, sorte nos drops e Moeda da Sorte** (concluída no código em 2026-11-16, suíte 266/266; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 9). Primeira das TASK-021 a 025 do ADR-0025. Moeda sempre 50% e sem chance na tela; SORTE e Maré de azar mexem em drops e baús; Moeda da Sorte (drop raro de baú, elite e chefe) que se arma antes do lance e rejoga um erro. Simulador: mediano 64,7%. ADR-0026. Fica para a TASK-025: inimigos mais difíceis e emboscadas por sorte.
- **TASK-022, economia, mapa e baú** (concluída no código em 2026-11-17, suíte 266/266; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 10). Cenário 1 com 6 camadas e 2 fogueiras; ouro 10 por nível; baú 14%; painel do baú com multiplicador moderado por Moeda da Sorte ou anúncio simulado; Coveiro 225/16. Simulador: mediano 76,7% (acima da faixa; conflito com a garantia do mapa, ADR-0027), 0 mapas sem rota. Calibrar com o `telemetry.log` do Orlando. ADR-0027.
- **TASK-023, fogueira com Galhos Secos** (concluída no código em 2026-11-18, suíte 266/266; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 11). Armar a fogueira gasta 1 Galho Seco; cada mapa garante 1; extras raros (comum 5%, elite 20%, baú 15%, chefe sempre) ou caros (loja, 120); nº de fogueiras por mapa proporcional à profundidade (6 e 7 camadas: 2; 8 a 10: 3). Corrige a primeira leitura (uma fogueira por Descida), ver `docs/FEEDBACK.md`. Coveiro 205/16 (mediano 68,7%). ADR-0028.
- ADR-0004 aprovado; ADR-0005 aceito (observador funcionando em laço).

## Onde está

- Repositório: `C:\Users\Orlando\Downloads\Projetos\bibianas-quest`. A mesma pasta é o projeto Godot, o repositório Git e o vault do Obsidian. Um commit por tarefa.
- Regras e comandos: `CLAUDE.md`. Decisões: `docs/adr/`. Tarefas: `docs/tasks/`.
- Núcleo: `game/core/core_version.gd` (`RULES_VERSION = 11`), `game/core/rng/`, `game/core/map/`, `game/core/combat/`, `game/core/data/`, `game/core/run/` e `game/core/sim/`.
- Dados: `game/data/*.json`, carregados por `DataLoader.load_all()` (`game/services/data_loader.gd`).
- Apresentação: `game/presentation/main.tscn` abre o `GameScreen`. F5 no editor joga uma Descida ("Nova Descida") ou a luta de teste. Telas em `game/presentation/combat/` e `game/presentation/map/`.
- Testes: `tests/unit/`. Rodar com `tools\run_tests.ps1` (Windows) ou `tools/run_tests.sh`.
- `bibianas-quest.bundle` na raiz serviu só para trazer o commit da TASK-001. Está no `.gitignore` e pode ser apagado.

## Congelamento por feedback (2026-11-16)

**Levantado em 2026-11-16:** o Orlando respondeu D1 a D6 (ADR-0025) e o trabalho segue pelas TASK-021 a TASK-025, uma por vez, na ordem do ADR. Antes: o Orlando jogou uma Descida completa e pediu **nenhuma implementação nova** até os pontos serem corrigidos. O feedback (F-005 a F-017), as decisões D1 a D6 que dependem dele e o agrupamento proposto em tarefas estão no fim de `docs/FEEDBACK.md`. A TASK-014 (exportação) também espera. Ao retomar, comece pelas decisões D1 a D6.

## Pendências do Orlando

1. Conectar o addon do Blender (aba BlenderMCP, tecla `N`) quando for usar o Blender.
2. **Jogar uma Descida (TASK-009):** F5 no Godot e "Nova Descida" (ver "Como jogar"), para ver se o mapa se lê bem e se o fluxo anda.
3. **Teste de sensação da TASK-006:** jogar algumas lutas (o Coveiro inclusive) e anotar no fim de `docs/tasks/TASK-006-combate-jogavel.md` se a moeda dá tensão e se o aviso de um turno basta.
4. Responder a pergunta do ADR-0008 (PRE como bônus sobre 90; Veterano com redução de 65% ou de 80%). A do ADR-0010 foi respondida no ADR-0014; confirmar que "acertar o lado" é o que o Orlando queria.
5. **Decidir os dois pontos do ADR-0012:** o custo da checagem de mapa no celular (a thread já existe; falta medir no celular e decidir o save) e as mortes por moeda acima da meta (31% e 35%, contra 25%; recomendação: esperar o teste de sensação).
6. Revisão cruzada do Gemini, TASK-001 a 013 e 015.
7. **TASK-014:** instalar os templates de exportação (Editor > Projeto > Exportar > Gerenciar templates), rodar `tools\export_web.ps1 -Serve` e abrir o link; para o celular, instalar JDK e Android SDK (`docs/PLAYTEST.md`).
8. **Sessão de 20 minutos no celular** e a ficha de `docs/PLAYTEST.md`.
9. **Feedback de design (`docs/FEEDBACK.md`), F-005 a F-017 e decisões D1 a D6 (ver o congelamento acima).** Antes: F-001 e F-002 atendidos (TASK-016); F-003 depende da escolha entre drops, marcos ou curva do Poder (pergunta do ADR-0021).

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
| 0028 | Fogueira com Galhos Secos: 1 garantido por mapa, extras raros ou caros, fogueiras proporcionais à profundidade, Coveiro 205/16 | Aceito (TASK-023) |
| 0027 | Mapa de 6 camadas e 2 fogueiras, ouro 10 por nível, baú 14%, baú multiplicável (x1,25 a x2) uma vez, Coveiro 225/16 | Aceito, com 1 ponto de calibração (TASK-022) |
| 0026 | Moeda 50% fixa e sem número; SORTE e Maré de azar nos drops e baús; Moeda da Sorte armada antes do lance | Aceito (TASK-021) |
| 0025 | Decisões D1 a D6 do primeiro playtest (moeda 50/50, fogueira com lenha, ouro e mapa, design de inimigos, baú, crítico) | Aceito |
| 0024 | Skill de combate como item especial da loja, até 5 skills, três skills novas do Guerreiro, efeitos power_strike, war_cry e mend | Aceito (TASK-020) |
| 0023 | Poder 0,4 por nível de inimigo, Nível = parte inteira do Poder, Coveiro 215/16 | Aceito (TASK-019) |
| 0022 | Drops de equipamento (GDD §10) e consumível, raridade por pesos, Equipar ou Vender a 40%, raros fora da loja | Aceito, com 1 ponto de calibração (TASK-018) |
| 0021 | Progressão visível só na apresentação (recompensa com atributos, contador, números de dano, abate); pergunta sobre a economia | Aceito, com 1 pergunta (TASK-017) |
| 0020 | Intervalo de 2 golpes entre golpes de moeda; golpes de debuff com chance própria; Veneno e Fraqueza; Coveiro reescrito | Aceito (TASK-016) |
| 0019 | Presets de exportação no Git sem segredos, dados `.json` incluídos, Web sem threads, toque emulado desligado em mobile e web | Aceito (TASK-014, não exercitado) |
| 0018 | Atalhos só em build de depuração; moeda forçada troca só o resultado; telemetria local em JSON por linha com morte por moeda | Aceito (TASK-013) |
| 0017 | Save: foto do estado no mapa (não repetição de escolhas), mapa incluso, versão das regras recusa save antigo, meta em arquivo separado | Aceito (TASK-012) |
| 0016 | Ecos do protótipo: 1 por nó e 5 por chefe, creditados também na morte; tela de fim com causa | Aceito, com 1 pergunta (TASK-011) |
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
