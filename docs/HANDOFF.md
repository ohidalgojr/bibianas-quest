# HANDOFF

Atualizado em 2026-11-27. **TASK-077 (ADR-0064) + revisão do lote 5 e abertura das `TASK-078`, `TASK-079` e `TASK-080`:** (1) Lote 5 entregue e integrado (`6/6` eventos em `assets/bibiana/events/`, `4` texturas pintadas `wall_plaster_timber`, `roof_slate`, `stone_retaining_wall`, `ground_rubble` com espelho 2×2 nos prédios/muros/pátios, `trench_crawler` atualizado para a esquerda, `well_stone`/`gallows_post_3ropes` nos nós de evento, e sprites recortados de `lipless_choir`, `calcified_knight`, `crowned_pursuer`, `house_door_arch`, `house_window_lit`, `balcony_wood`, `church_gate_iron`, `stone_bridge_arch`); (2) Abertas `TASK-078` (aplicar janelas/portas/portão e fechar P1/P2 de `REVISAO-LOTE-5.md`), `TASK-079` (fichas `ENEMY-18`/`19` e dados de `lipless_choir` + `calcified_knight`) e `TASK-080` (Roaming Boss `crowned_pursuer` com ficha `ENEMY-20` e mecânica de perseguição). Suíte `380/380` (`RULES_VERSION` = 22). **Histórico recente:** **TASK-076 (ADR-0063), TASK-075 (ADR-0062) e TASK-074 (ADR-0061):** (1) **TASK-074 (`F-025`):** ritmo de ataque refeito em 4 tempos (`STRIKE_APPROACH = 0,44 s`, `STRIKE_WINDUP = 0,18 s`, `STRIKE_LUNGE = 0,08 s`, `STRIKE_RECOVER = 0,22 s`, `STRIKE_RETURN = 0,38 s`) com passada procedural em `_hero_sprite` e poeira de pisada no combate e no `Map3DScreen`, além dos prompts §34–35 para o Gemini gerar quadros reais de caminhada alternada (`walk-v2`) e golpe em arco (`strike`); (2) **TASK-075:** folha `assets/bibiana/fx/flame.png` convertida e animada na fogueira (`Scene3DBackdrop` + `Map3DScreen`), `poison.png` ligada ao veneno no combate, discos de pedra (`node_disc_0..4.png`) + ícones pintados nas bolhas de opção com clamping `y >= 76`, Santuário com `UiKit` + retratos no Códice, e correção de `GamePreview` para `tela=event`; (3) **TASK-076:** revisão cruzada das `TASK-070` a `TASK-073` contra `docs/REVIEW-CHECKLIST.md`. **TASK-073 (ADR-0060):** o tabuleiro do mapa virou uma cidade gótica que sobe até a igreja (`docs/design/ESTRUTURA-TABULEIRO-GOTICO.md`). **TASK-072 (ADR-0059):** integrados ícones (102), UI kit (`UiKit`), arenas, moedas e UX do combate. **TASK-071 (ADR-0058):** poses de combate da Bibiana de costas e FX por quadros. **TASK-070 (ADR-0057):** retorno do tabuleiro isométrico em terraços (GDD §17). **TASK-069 (ADR-0056):** 16 sprites por classe (`bibiana_<classe>_<back|left|right|camp>`). Antes: **TASK-068 (ADR-0055):** cenários fora do combate usam arenas pintadas. **TASK-066 (ADR-0053):** sprites HD-2D e arenas pintadas no combate; mecha colorida removida (`F-024`). **Texto anterior, mantido abaixo para referência histórica:** `docs/design/GUIA-DE-ARTE-DARK-FANTASY-MOBILE.md`, `docs/design/PROXIMA-RODADA-VALIDACAO.md`, `ADR-0036`.
- **`TASK-029` (`b08098f`), `TASK-026` (`09b6a04`), `TASK-027` (`35d06b4`), `TASK-028` (`5ccfeb6`), `TASK-030` (`9fa4254`) e `TASK-031`**: **100% concluídas, validadas (315/315 testes em 40 scripts) e enviadas para `origin/main`**.
- **Numeração:** as tarefas de calibração e do portão da Fase 1 (propostas pelo Claude) são a TASK-032 e a TASK-033; as TASK-030 e 031 são as do Argon.

## Estado em um olhar

| Item | Valor |
| --- | --- |
| Jogo | RPG tático de turnos roguelite, Godot 4.7. **Visual atual = tabuleiro isométrico gótico 3D texturizado (`TASK-070`/`073`/`077`) + combate e telas em HD-2D com arenas pintadas `9:16`, sprites recortados, UI kit pintado (`UiKit`), 102 ícones, 6/6 eventos e animações com passada/FX (`ADR-0052` a `ADR-0064`, `TASK-066`..`077`).** Áudio procedural (`SoundFx`) e menu com Santuário (Biblioteca, Arsenal e Códice com miniaturas). |
| Classe | só o Guerreiro (Bibiana); 3 skills iniciais, 3 à venda, 5 espaços (pranchas das 4 classes prontas em `docs/design/refs/bibiana/`) |
| Cenário | só a Cidade Abandonada: 4 inimigos comuns (+ elenco completo do cenário 1 incluindo `trench_crawler` novo, com mutações temáticas Inchado, Voraz, Fantasma e Espinhoso), 1 elite (Carrasco Apodrecido), 1 mini boss anunciado (Carcereiro do Sino), chefe O Coveiro (2 fases), 6 eventos temáticos; cada inimigo com ficha em `docs/enemies/` |
| Regras | `RULES_VERSION` = 22 (histórico em `game/core/core_version.gd`); GDD em `docs/GDD.md`; ADR-0001 a ADR-0064 |
| Equilíbrio (simulador, regras v15) | bot mediano vence 66,0% (meta 55% a 65%), cuidadoso 72,0%, 1ª Descida 49,3% (meta 35% a 55%, 98,0% chegam ao chefe), mortes por moeda 13,7% (meta até 25%), 0 de 40 mapas sem rota vencível, 1,28 s para criar a Descida |
| Testes | `380/380` em `52` scripts (`tools\run_tests.ps1`) |
| Git | `main` sincronizado com `origin/main` |
| Executável Windows | `build\windows\BibianasQuest.exe` atualizado em 2026-11-27 (`tools\build_windows.ps1`, anterior à `TASK-077` — regerar após `TASK-078`) |
| Nunca testado por pessoa | tudo depois da TASK-009 foi jogado só por bots e testes; o Orlando jogou uma Descida na TASK-020 e deu os feedbacks de `docs/FEEDBACK.md` (F-025 registrado em 2026-11-27) |

## O que falta fazer (Arte, Código e Validação)

### 1. Integrado em `assets/bibiana/` (`TASK-070` a `TASK-077`)

- `102` ícones pintados `96×96` (`assets/bibiana/icons/`), `UiKit` (`panel_stone`, `slot_*`, `divider`, `banner_ribbon`, `frame_illustration`, `node_disc_0..4`, `coin_heads/tails`), `13` arenas/faixas/overlays (`arena-cidade-chefe`, `arena-fogueira-apagada`, `bg-reward-shrine`, `bg-defeat`, `sanctuary-interior`, `map-strip-01..03`, `map-fg-ironfence`, `map-mist-band`), `6/6` eventos, `4` texturas pintadas (`wall_plaster_timber`, `roof_slate`, `stone_retaining_wall`, `ground_rubble`), `5` folhas de FX (`slash`, `block`, `crit`, `poison`, `flame`), poses/estados/caminhada da Bibiana de costas e `trench_crawler` atualizado (`TASK-077`).
- **Sprites recortados e registrados no `ModelRegistry`, aguardando uso/fichas:** `house_door_arch`, `house_window_lit`, `balcony_wood`, `church_gate_iron`, `stone_bridge_arch`, `lipless_choir`, `calcified_knight`, `crowned_pursuer` (`map-strip-04-canal.jpg` reservada em `docs/design/refs/arenas/` para o Cenário 3 / mapas com canal).

### 2. Falta gerar no Gemini (`2` pranchas de animação `F-025`)

Todas as peças do lote anterior e do `ESTRUTURA-TABULEIRO-GOTICO.md §7.2` já foram entregues na `TASK-077`. Restam apenas:
1. `docs/design/refs/bibiana/bibiana-guerreira-walk-v2-sheet.jpg` (`16:9`, 4 colunas `hframes=4`, marcha alternada real de costas — `PROMPTS-LOTE-HD2D.md §34`).
2. `docs/design/refs/bibiana/bibiana-guerreira-strike-sheet.jpg` (`16:9`, 4 colunas `hframes=4`: `dash | windup | cleave | recover` — `PROMPTS-LOTE-HD2D.md §35`).

### 3. Próximas tarefas abertas e pendências técnicas

- **`TASK-078` (aberta):** trocar retângulos laranja de `_build_window_quads` por `house_window_lit.png` + `house_door_arch.png`, limpar `#10131A` interno de `balcony_wood.png`, aplicar `church_gate_iron.png` como `Sprite3D` estático no adro, dessaturar muretes lilás (`TINT_WALL`), melhorar contraste de borda de `crowned_pursuer.png`, anexar print real de nó de evento (`REVISAO-LOTE-5.md`). *(Manter ponte 3D modular recebendo textura em vez de forçar `stone_bridge_arch.png` 3/4 plano.)*
- **`TASK-079` (aberta):** criar fichas `ENEMY-18-coro-sem-labios.md` e `ENEMY-19-cavaleiro-calcificado.md`, cadastrar `lipless_choir` e `calcified_knight` em `enemies.json`/`scenarios.json`/Códice com ADR e incremento de `RULES_VERSION`.
- **`TASK-080` (aberta):** implementar o Roaming Boss `crowned_pursuer` (`ENEMY-20`, perseguição determinística no `game/core/run/`, combate e prints, ADR + `RULES_VERSION`).
- **Demais pendências:** integrar `walk-v2`/`strike` após geração; reexportar `*_2x` dos inimigos a partir dos masters `2752×1536` (`GUIA §0.4`); LOD/redução de triângulos nas casas (`< 60 mil` primitivas); apagar `.glb` antigos após OK visual; seleção de classe (Clérigo/Ladino/Mago); bairros 8+ camadas; nó `"?"` (`TASK-041`); revisão cruzada das `TASK-074`..`076`; exportação/celular real (`TASK-014`) e `telemetry.log` (`TASK-032`/`033`/`040`).

## Como retomar (qualquer agente)

1. Leia este arquivo, `CLAUDE.md` e `AGENTS.md`. Abra a tarefa que vai executar em `docs/tasks/` (ou crie uma a partir de `docs/tasks/_modelo.md`: **sem tarefa aberta, nenhum código**).
2. Rode a suíte antes de mexer: `powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1` (Windows) ou `bash tools/run_tests.sh`. Em checkout novo rode antes `tools\setup.ps1` e `tools\setup_hooks.ps1`. O Godot vem de `GODOT_BIN` (use o `*_console.exe`).
3. **Ligue os hooks de git** (`tools\setup_hooks.ps1`): conferem a mensagem de commit (`TASK-NNN: resumo (ADR-XXXX)`) e rodam a suíte antes de commits que mexem em código. O teste `tests/unit/test_project_standards.gd` confere a estrutura de tarefas, ADRs, HANDOFF e fichas de inimigos.
4. Uma tarefa por vez, um commit por tarefa, e **pare ao fim de cada tarefa** para o resumo. Não mude regra do GDD sem ADR, GDD atualizado no mesmo commit e `RULES_VERSION` incrementado. Depois de mudar regra, rode o simulador (comando em "Pontos de atenção").
5. **Não envie ao GitHub sem o Orlando pedir.** Ao terminar uma tarefa, atualize este arquivo (feito, onde está, falta, decisões).
6. O jogo se abre abrindo a **pasta raiz do repositório** no Godot 4.7 e apertando F5. Depois de criar script com `class_name`, rode `"$GODOT_BIN" --headless --path . --import` ou o editor mostra só uma tela escura.
7. Revisão cruzada: o código das TASK-001 a 025 foi escrito por um só modelo. A TASK-029 pede revisão por outro modelo (`docs/REVIEW-CHECKLIST.md`).

## Como jogar

**Mais fácil: o executável.** `powershell -ExecutionPolicy Bypass -File toolsbuild_windows.ps1 -Run` gera e abre `buildwindowsBibianasQuest.exe` (pasta principal do repositório, mesmo se rodar de uma worktree), sem abrir o Godot. Build de depuração, com os atalhos F1 a F4. Os templates 4.7.2 do Windows já estão instalados neste PC.

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
- **TASK-013, depuração e telemetria** (concluída no código em 2026-11-16, suíte 285/285; jogada humana e revisão cruzada pendentes). Em build de depuração: semente no menu, F1 +100 ouro, F2 pular nó, F3 matar inimigo, F4 forçar moeda. `Telemetry` (serviços) grava `user://telemetry.log` (nós, moeda, lutas, mortes com `by_coin`). ADR-0018.
- **TASK-014, exportação** (em verificação em 2026-11-16): `export_presets.cfg` (Web e Android), `tools\export_web.ps1`, `docs/PLAYTEST.md` e toque desligado em mobile e web. **Nada foi exportado**: não há templates de exportação no PC. Depende do Orlando (ver pendências). ADR-0019.
- **Feedback de playtest:** registrado em `docs/FEEDBACK.md` (F-001 chefe com moeda demais, F-002 golpes com debuff por probabilidade, F-003 matar inimigos sem senso de progressão). Propostas de TASK-016 e TASK-017 lá.
- **TASK-016, ritmo da moeda e debuffs do chefe** (concluída no código em 2026-11-16, suíte 285/285; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 5). Ao menos 2 golpes entre golpes de moeda em todos os inimigos (sem exceção de chefe); novo golpe `debuff` com chance própria, aviso DEBILITA, Defender corta a chance pela metade; Veneno e Fraqueza do GDD §11; Coveiro com Toque Podre e Maldição. Simulador: mediano 56%, mortes por moeda 21,6%. F-001 e F-002 atendidos; F-003 segue aberto. ADR-0020.
- **TASK-017, progressão visível** (concluída no código em 2026-11-16, suíte 285/285; jogada humana e revisão cruzada pendentes). Recompensa com quem caiu e atributos antes e depois; mapa e fim com FOR, DEF, VEL e inimigos derrotados; números de dano e animação de abate na luta. Sem mudança de regra. **Achado:** o ganho por luta é de 1 a 2 de HP no começo; decisão de economia pendente (drops, marcos ou curva do Poder). ADR-0021.
- **TASK-018, drops e equipamento** (concluída no código em 2026-11-16, suíte 285/285; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 6). Inimigos soltam equipamento (12% comum, 35% elite, raridade por pesos, raro só de elite) e consumível de cura; a recompensa pergunta Equipar ou Vender (40%); 9 itens novos; loja sem raros. Simulador: mediano 65,5%. Recalibrar o Coveiro uma vez depois da TASK-020. ADR-0022. Parte do F-004; faltam TASK-019 (ganho de status) e TASK-020 (skills na loja).
- **TASK-019, ganho de status** (concluída no código em 2026-11-16, suíte 285/285, cerca de 2 min; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 7). ΔPoder = 0,4 × N × m_tipo (era 0,15); Nível = parte inteira do Poder, no mapa e na recompensa ("Subiu de nível!"); Coveiro com HP 215 e FOR 16. Simulador: mediano 65,0%, 0 mapas sem rota em 100. ADR-0023. Falta a TASK-020 (skills na loja) e então recalibrar o Coveiro de novo.
- **TASK-020, skills na loja** (concluída no código em 2026-11-16, suíte 285/285, cerca de 100 s; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 8). A loja oferece uma skill do Guerreiro por visita (Golpe Giratório, Grito de Guerra, Segundo Fôlego), até 5 skills; 5 botões de skill no combate; skills aprendidas no save. Simulador: mediano 65,3%. ADR-0024. Fecha o F-004 (TASK-018 a 020); candidato seguinte: MP curto e uso do Éter Sujo.
- **TASK-021, moeda 50/50, sorte nos drops e Moeda da Sorte** (concluída no código em 2026-11-16, suíte 285/285; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 9). Primeira das TASK-021 a 025 do ADR-0025. Moeda sempre 50% e sem chance na tela; SORTE e Maré de azar mexem em drops e baús; Moeda da Sorte (drop raro de baú, elite e chefe) que se arma antes do lance e rejoga um erro. Simulador: mediano 64,7%. ADR-0026. Fica para a TASK-025: inimigos mais difíceis e emboscadas por sorte.
- **TASK-022, economia, mapa e baú** (concluída no código em 2026-11-17, suíte 285/285; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 10). Cenário 1 com 6 camadas e 2 fogueiras; ouro 10 por nível; baú 14%; painel do baú com multiplicador moderado por Moeda da Sorte ou anúncio simulado; Coveiro 225/16. Simulador: mediano 76,7% (acima da faixa; conflito com a garantia do mapa, ADR-0027), 0 mapas sem rota. Calibrar com o `telemetry.log` do Orlando. ADR-0027.
- **TASK-023, fogueira com Galhos Secos** (concluída no código em 2026-11-18, suíte 285/285; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 11). Armar a fogueira gasta 1 Galho Seco; cada mapa garante 1; extras raros (comum 5%, elite 20%, baú 15%, chefe sempre) ou caros (loja, 120); nº de fogueiras por mapa proporcional à profundidade (6 e 7 camadas: 2; 8 a 10: 3). Corrige a primeira leitura (uma fogueira por Descida), ver `docs/FEEDBACK.md`. Coveiro 205/16 (mediano 68,7%). ADR-0028.
- **TASK-024, combate legível** (concluída no código em 2026-11-18, suíte 285/285; jogada humana e revisão cruzada pendentes; `RULES_VERSION` = 12). Previsão de dano, acerto e crítico nos botões; descrição de toda skill; atacar devolve 10% do MP; Éter Sujo em combate; crítico manipulável por Garra Afiada e Afiar o Fio. Evento de mapa que mexe no crítico fica para quando houver eventos. Coveiro 195/16 (mediano 70,7%). ADR-0029.
- **TASK-025, inimigos únicos** (concluída no código em 2026-11-18, suíte 285/285; jogada humana pendente; `RULES_VERSION` = 13). Papel de design de inimigos com fichas em `docs/enemies/` (modelo e seis fichas); golpes de moeda temáticos por inimigo (Fraqueza, Leptospirose, Cegueira, Lentidão, Maldição); Leptospirose como doença persistente tratada na fogueira por 1 Brasa; IA reativa em dados (`reactions`) com o motivo no aviso. Coveiro 175/16 (mediano 62,0%). Fica de fora: emboscadas e inimigos mais difíceis por sorte, eventos de mapa. ADR-0030. Fecha D4 e o F-018 (tensão da moeda e IA); falta o Orlando jogar.
- **TASK-029, revisão cruzada das TASK-001 a 025** (concluída em 2026-11-18 por Gemini, suíte 292/292). Todas as tarefas `TASK-001` a `TASK-025` revisadas contra `docs/REVIEW-CHECKLIST.md` e o GDD; corrigidos rótulos `pt-BR` de `"precision"` e `"relic"` em `RunPanels`, dica de `skill_0` em `CombatScreen`, código órfão `Combatant.in_final_phase()` e `debuff_turns()` explícito em `CombatEffect`; `test_project_standards.gd` agora exige revisão cruzada preenchida em toda tarefa concluída.
- **TASK-026, primeira Descida chamativa** (concluída em 2026-11-18, suíte 297/297; `RULES_VERSION` = 14). Primeira Descida (`runs_played == 0`) com Cidadão Infectado garantido na camada 1, baú na camada 2 com item incomum e Moeda da Sorte, elite no meio com drop raro e Moeda da Sorte, chefe visível de longe no mapa ("O Coveiro te espera"), Ecos em dobro e tela final "Morte que ensina" (inimigo e % de vida restante, conquistas, dica tática e o que ficou para a próxima). Simulador: mediano normal 62,7%, 1ª Descida 52,7% (98,0% chegam ao chefe). ADR-0031.
- **TASK-027, sorte, emboscadas e inimigos mutados** (concluída em 2026-11-18, suíte 303/303; `RULES_VERSION` = 15). Quatro mutações temáticas em dados (`bloated` Inchado, `voracious` Voraz, `phantom` Fantasma, `thorny` Espinhoso) visíveis no mapa antes da luta nas camadas 3..6 (máx. 1 por camada), com nível +1, Poder ×1,5, tabela própria de drops com 20% de raros e 12% (+SORTE) de Moeda da Sorte; nó de emboscada com ataque inicial do inimigo (sem moeda surpresa) e Guarda aberta no bote; SORTE e Maré de azar influenciando a chance de mutação e a conversão/evitação de emboscadas na camada revelada. ADR-0032.
- **TASK-028, eventos de mapa e mini boss** (concluída em 2026-11-18, suíte 306/306; `RULES_VERSION` = 16). 6 eventos temáticos na Cidade Abandonada (`game/data/events.json`) com 2 a 3 escolhas, custos, cara ou coroa e manipulação de CRIT por alguns combates (pedido D6); peso do nó de evento ativado (`PROTOTYPE_EVENT_WEIGHT = 9`); mini boss anunciado **Carcereiro do Sino** (`bell_warden`, ficha `ENEMY-07-carcereiro-do-sino.md`) na segunda metade do mapa com equipamento raro garantido, Galhos Secos e Moeda da Sorte. ADR-0033.
- **TASK-030, Santuário e meta-progresso** (concluída em 2026-11-18, suíte 311/311; `RULES_VERSION` = 20). `SanctuaryRules` (núcleo puro) e `SanctuaryScreen` acessíveis no menu inicial e no fim da Descida: Biblioteca (*Tomo do Grito de Guerra* e *Manual do Fio Afiado*), Arsenal (*Bênção da Malha Antiga*, +8% HP/DEF dentro do teto de +10% do GDD §9, e *Fardo do Viajante*) e Códice (Bestiário com os 7 inimigos, seus golpes de moeda, reações e contadores persistentes de vitórias e quedas em `meta.json`). ADR-0034.
- **TASK-031, apresentação Dark Fantasy, tabuleiro visual e áudio procedural** (concluída em 2026-11-18, suíte 315/315; `RULES_VERSION` = 20). `VisualTheme` (`game/presentation/visual_theme.gd`) com a paleta Dark Fantasy, os 9 estágios de Poder e cor da mecha da Bibiana (GDD §9), `PortraitCanvas` (silhuetas vetoriais da Bibiana e dos 7 inimigos + auras de mutação), `CoinMedallion` (medalhão Cara/Coroa com símbolos distintos, GDD §19), `MapScreen` com estradas curvas de calçamento, praças iluminadas, brasões por tipo de nó e peão da Bibiana, e `SoundFx` (`game/services/sound_fx.gd`) gerando 11 efeitos sonoros procedurais em `AudioStreamWAV`. ADR-0035.
- ADR-0004 aprovado; ADR-0005 aceito (observador funcionando em laço).

## Onde está

- Repositório: `C:\Users\Orlando\Downloads\Projetos\bibianas-quest`. A mesma pasta é o projeto Godot, o repositório Git e o vault do Obsidian. Um commit por tarefa.
- Regras e comandos: `CLAUDE.md`. Decisões: `docs/adr/`. Tarefas: `docs/tasks/`.
- Núcleo: `game/core/core_version.gd` (`RULES_VERSION = 17`), `game/core/rng/`, `game/core/map/`, `game/core/combat/`, `game/core/data/`, `game/core/run/` e `game/core/sim/`.
- Dados: `game/data/*.json`, carregados por `DataLoader.load_all()` (`game/services/data_loader.gd`).
- Apresentação: `game/presentation/main.tscn` abre o `GameScreen`. F5 no editor joga uma Descida ("Nova Descida") ou a luta de teste. Telas em `game/presentation/combat/` e `game/presentation/map/`.
- Testes: `tests/unit/`. Rodar com `tools\run_tests.ps1` (Windows) ou `tools/run_tests.sh`.
- `bibianas-quest.bundle` na raiz serviu só para trazer o commit da TASK-001. Está no `.gitignore` e pode ser apagado.

## Backlog ordenado (próximos passos, para qualquer agente)

Ordem sugerida; cada item tem arquivo de tarefa ou é feito pelo Orlando. Antes de começar um, leia o arquivo da tarefa e `docs/FEEDBACK.md`.
**DIRETRIZ DO ORLANDO (2026-11-18, atualizada em 2026-11-19):** o "MVP jogável com gráficos e som" **não é** a TASK-031 (2D vetorial): é a **apresentação 3D isométrica com kits CC0** do ADR-0036 (TASK-035 a 040, leia `docs/ART-DIRECTION.md`). Até a TASK-040 fechar, **não use recursos com simulador de balanceamento (`tools/simulate.gd`) nem testes muito complexos**.

| # | Tarefa | O que é | Quem | Por quê |
| --- | --- | --- | --- | --- |
| 1 | TASK-029 | Revisão cruzada das TASK-001 a 025 por outro modelo | concluída | concluída em 2026-11-18 |
| 2 | TASK-026 | Primeira Descida chamativa (F-019) | concluída | concluída em 2026-11-18 (ADR-0031) |
| 3 | TASK-027 | Sorte, emboscadas e inimigos mutados | concluída | concluída em 2026-11-18 (ADR-0032) |
| 4 | TASK-028 | Eventos de mapa e mini boss | concluída | concluída em 2026-11-18 (ADR-0033) |
| 5 | TASK-030 | Santuário e meta-progresso (Biblioteca, Arsenal, Códice/Bestiário) | concluída | concluída em 2026-11-18 (ADR-0034) |
| 6 | TASK-031 | Apresentação 2D vetorial e áudio procedural | concluída, **reprovada pelo Orlando como visual do MVP** (ADR-0036) | vira modo de depuração; `SoundFx` e `VisualTheme` continuam |
| 7 | TASK-035 | Kits CC0, licenças, cena de prova isométrica, ferramenta de print | agente (download autorizado pelo Orlando) | **próxima tarefa**; sem ela nada de 3D começa |
| 8 | TASK-036 | Tabuleiro 3D com altura, visão parcial, névoa e câmera que acompanha | em verificação | prints `docs/tasks/prints/TASK-036-*.png` esperando o OK do Orlando |
| 9 | TASK-037 | Combate 3D com fundo derivado do nó | em verificação | prints `docs/tasks/prints/TASK-037-*.png` esperando o OK do Orlando |
| 10 | TASK-038 | Fogueira, loja, baú, recompensa, menu e Santuário em 3D | em verificação | cenários 3D prontos; cartões, `xN` do baú e Santuário 3D pendentes |
| 11 | TASK-039 | Estilo unificado, clima, luz e música | em verificação | contorno, paleta, chuva, névoa e música prontos; mecha 3D, som de chuva e medição no celular pendentes |
| 12 | TASK-048 | 20 itens novos (cabeça e mão secundária incluídas) com ícones | agente | em verificação |
| 12 | TASK-049 | Preparar o jogo para as classes (estudo `docs/design/ESTUDO-quando-entram-as-classes.md`) | Orlando decide | aguardando decisão |
| 12 | TASK-046 e 047 | Mapa com relevo variado, canais, ruínas; criaturas de horror e 3 inimigos novos | agente | em verificação (ver as tarefas) |
| 12 | TASK-050 | Botão de som mudo (canto da tela, lembrado entre sessões) | agente | em verificação |
| 12 | TASK-051 | Estudo de UI mobile, 8 inimigos dark fantasy (Nano Banana + spec Blender) e estética de mundo morrendo (`docs/design/ESTUDO-ui-mobile-inimigos-estetica.md`) | Orlando decide | em verificação (aguardando decisões da Parte 6 antes do código) |
| 12 | TASK-052 | Primeiro mapa curto como tutorial-gancho (sem facilitar) e dificuldade gradual nos demais (`docs/FEEDBACK.md` F-020) | agente (após MVP visual / decisão do Orlando) | aberta; diretriz registrada em `CLAUDE.md` e `AGENTS.md` |
| 12 | TASK-053 | Algoritmo próprio Terrace-Grammar-Constraint para cenários 3D coerentes (mapa + combate + backdrops, ADR-0041) | em verificação | 9 prints `docs/tasks/prints/TASK-053-*.png` e executável gerados (< 50k primitivas); aguarda OK do Orlando |
| 12 | TASK-054 | Conceito visual Nano Banana (`O Perseguidor Coroado`, 5 pranchas) e dossiê 3D/Nemesis do Roaming Boss (`F-023`, `ADR-0042`) | em verificação | aguarda OK visual do Orlando em `docs/design/ROAMING-BOSS-perseguidor-coroado.md` antes de modelar `.glb` |
| 12 | TASK-055 | Atmosfera do estudo (D-ART-1/2/3, D-UI-5): ambiente frio, neblina, foco quente, dithering Bayer, fogueira apagada até acender | agente | em verificação (prints `docs/tasks/prints/TASK-055-*.png`) |
| 12 | TASK-056 | Combate mobile: gavetas Habilidades/Itens/Tático, confirmação em dois toques, palco maior (D-UI-1/2) | agente | em verificação (print `docs/tasks/prints/TASK-056-combate.png`; falta jogar no celular) |
| 12 | TASK-057 | Turiferário Cego: 1º inimigo do estudo, modelo Blender aceito por agente crítico (3 rodadas), ficha ENEMY-15 | agente | em verificação (print `docs/tasks/prints/TASK-057-turiferario.png`); próximos: Médico da Cera e Rastejador da Vala |
| 12 | TASK-058 | Médico da Cera e Rastejador da Vala (modelos Blender aceitos por agente crítico, fichas ENEMY-16 e 17) | agente | em verificação (prints `docs/tasks/prints/TASK-058-*.png`) |
| 12 | TASK-059 | Menus em bottom sheet: alça, rodapé fixo, loja em cartões 2x2, pinos de Brasas (Ui-C parcial) | agente | em verificação (prints `docs/tasks/prints/TASK-059-*.png`); faltam prévia de nó no mapa e Home/Santuário (Ui-D) |
| 12 | TASK-060 | Mapa com prévia de nó em dois toques e Home limpa com depuração recolhida (Ui-D parcial) | agente | em verificação (print `docs/tasks/prints/TASK-060-home.png`); faltam Santuário 3D, gaveta de equipamento e troca de fonte |
| 12 | TASK-052 | Primeiro mapa curto (4 camadas) e escalada 4/6/7/8/10 nos cenários; Coveiro 158/15 (`RULES_VERSION` 21) | agente | feita; simulador (150 Descidas): mediano 64,7%, 1ª Descida 42%, 0 mapas sem rota |
| 11 | TASK-061 | **Identidade visual (ADR-0050, `docs/design/IDENTIDADE-VISUAL.md`)**: combate como duelo (câmera, escala, luz, arena `DuelArena`, aviso sem faixa cinza). Regra nova: arte só é aprovada por print 540×960 do jogo contra o checklist E, revisado por agente de direção de arte | agente | em verificação; seguem TASK-062 (inimigos refeitos por kitbash), mapa, fogueira e loja |
| 11 | TASK-064 | DarkTheme 2.0 (tokens, Alegreya no corpo, componentes, toque 0,96 e vibração), `TrailBar` e combate com palco cheio (~68%), intenção sobre a cabeça e letreiro (auditoria pacotes 1, 2, 4) | agente | em verificação; backlog completo em `docs/design/AUDITORIA-UI-vs-ESTUDO.md`, decisões em `docs/design/DECISOES-ARTE-UI.md` |
| 11 | TASK-065 | Sprites 2D dos inimigos a partir das pranchas do Gemini (Turiferário, Médico da Cera, Rastejador integrados); próximos: Bibiana, demais inimigos e fundos pintados (o Orlando gera no Gemini) | agente + Orlando | em verificação |
| 12 | TASK-043 | Ícones, cartões, barras, status, inventário e xN | agente | em verificação |
| 12 | TASK-044 | Ícones e cartões; modelos próprios e 4 inimigos novos | agente | em verificação (ver as tarefas) |
| 12 | TASK-042 | Atmosfera: tema de UI dark fantasy, som ambiente, cinzas, relâmpago, transições | agente | feedback "parece RPG de texto": em verificação |
| 12 | TASK-045 | Ritmo e variedade de gameplay (estudo, decisão do Orlando) | agente | próximo do feedback "enjoativo" |
| 12 | TASK-040 | Fechamento visual: o Orlando joga e aprova | Orlando | fecha o "MVP jogável" |
| 13 | TASK-014 | Exportação Web e Android e sessão de 20 minutos no celular | **Orlando** | templates, JDK e SDK só na máquina dele |
| 14 | TASK-032 | Calibrar números com o `telemetry.log` do Orlando (ouro, Coveiro, moeda por luta, mortes) | agente, depois da TASK-040 e do playtest | os bots não jogam como uma pessoa; só depois de o Orlando jogar o MVP com gráficos e som |
| 15 | TASK-033 | Portão da Fase 1: fechar o MVP e abrir o roteiro da Fase 2 | Orlando e agente | depois das TASK-014, 032 e 040 |
| 16 | TASK-041 | Nó misterioso "?" no lugar da Emboscada visível (estudo em `docs/design/ESTUDO-nos-misteriosos.md`) | Orlando decide, agente implementa | a emboscada avisada não é escolha de ninguém; depois da TASK-040, ou antes se o Orlando pedir |
| 17 | monetização | Anúncio de verdade, o que o anúncio faz com a moeda, vender Moeda da Sorte? | Orlando decide | GDD §16; hoje o anúncio do baú é simulado |

Regra do pedido: ao fim de cada tarefa, parar e mostrar o resumo.

## Problemas conhecidos

- **Guerreiro único:** o Veterano que Defende anula a penalidade da coroa, inclusive a consequência temática (ADR-0030). Outras classes precisarão de regra própria.
- **Foco no MVP jogável (gráficos e som):** por determinação do Orlando (2026-11-18), testes de balanceamento (`tools/simulate.gd`) e testes de propriedade pesados ficam suspensos enquanto o MVP jogável de verdade (com gráficos e som) não estiver concluído.
- **Visual reprovado (2026-11-19):** as telas atuais (2D, desenhadas em código) são só depuração; o visual de verdade é a camada 3D das TASK-035 a 040. Anúncio simulado no baú e Éter/lenha ainda sem arte própria.
- **A TASK-014** só foi configurada (presets, script, guia); nada foi exportado.
- **Corrigida na TASK-034 (2026-11-19):** `SaveStore.load_meta` (`game/services/save_store.gd:63`) lê `saved["unlocks"]` sem a chave existir quando o `meta.json` é do formato anterior ao Santuário (só `echoes`, `format` e `runs_played`). O jogo quebrava ao abrir com o `meta.json` antigo; agora há teste de save antigo. Suíte 316/316.

## Pendências do Orlando

1. **Jogar uma Descida inteira** na versão atual (F5 na pasta raiz) e dar o feedback; enviar o `telemetry.log` (`%APPDATA%\Godot\app_userdata\<nome do projeto>\telemetry.log`) para calibrar.
2. **TASK-014:** instalar os templates de exportação (Editor > Projeto > Exportar > Gerenciar templates), rodar `tools\export_web.ps1 -Serve` e abrir o link; para o celular, JDK e Android SDK (`docs/PLAYTEST.md`); sessão de 20 minutos e a ficha.
3. Trocar o branch padrão do repositório no GitHub para `main` (hoje é `claude/godot-blender-setup-0792cc`).
4. Responder a pergunta do ADR-0008 (PRE como bônus sobre 90; Veterano com redução de 65% ou de 80%).
5. Decidir a monetização que ficou aberta (item 9 do backlog).
6. Conectar o addon do Blender (aba BlenderMCP, tecla `N`) quando for usar o Blender.

## Decisões

| ADR | Decisão | Status |
| --- | --- | --- |
| 0064 | Texturas pintadas por tipo de peça (`wall_plaster_timber`, `roof_slate`, `stone_retaining_wall`, `ground_rubble`), lote 5 integrado (`trench_crawler`, eventos, props) e revisão cruzada que abriu `TASK-078`..`080` | Aceito com ressalvas (`TASK-077`) |
| 0063 | Revisão cruzada por modelo distinto (`TASK-070`..`073`), consolidação do HANDOFF e fila de geração do Gemini | Aceito (TASK-076) |
| 0062 | Chama animada `flame.png`, FX de veneno, discos/ícones de nó no mapa, Santuário em `UiKit` e `GamePreview` de evento | Aceito (TASK-075) |
| 0061 | Ritmo legível do ataque em 4 tempos, caminhada animada por cinemática de passada (`F-025`) e prompts `walk-v2`/`strike` | Aceito (TASK-074) |
| 0060 | Cidade gótica do tabuleiro (`NORTH_SHEAR`, rua principal, casas com porta na rua, canal com pontes, cenografia por nó) | Aceito (TASK-073) |
| 0059 | UI kit pintado (`UiKit`), 102 ícones do Gemini e UX do combate (AGORA+4, gaveta com CONFIRMAR, selo com ícone, moeda pintada) | Aceito (TASK-072) |
| 0058 | Animação de combate da Bibiana por poses de sprite (`combat`/`states`/`walk`), FX por quadros e bustos nítidos em Lanczos | Aceito (TASK-071) |
| 0057 | Retorno ao tabuleiro isométrico 3D em terraços como mapa (`GDD §17`), substituindo `PaintedMapScreen` | Aceito (TASK-070) |
| 0056 | Bibiana de costas no combate/mapa e 4 poses por classe (`back`, `left`, `right`, `camp`) | Aceito (TASK-069) |
| 0055 | Cenários pintados HD-2D fora do combate e seleção de destino com seta pulsante | Aceito (TASK-068) |
| 0053 | Arenas pintadas `9:16` e sprites HD-2D integrados ao combate (`F-024`) | Aceito (TASK-066) |
| 0052 | Personagens e inimigos como sprites 2D (HD-2D) a partir das pranchas de conceito; modelos 3D procedurais viram provisórios | Aceito (TASK-065) |
| 0051 | DarkTheme 2.0 e combate com palco cheio, intenção sobre a cabeça, letreiro de 2,2 s | Aceito (TASK-064) |
| 0050 | Identidade visual: foco quente único, escala de pesadelo, paleta de 8 cores, câmera de duelo e aprovação só por print do jogo | Aceito (TASK-061) |
| 0049 | Cenário 1 com 4 camadas e escalada 4/6/7/8/10; Coveiro 158/15 para manter a meta de vitória | Aceito (TASK-052) |
| 0048 | Prévia de nó em dois toques no mapa; Home sem versão de regras nem semente fora da depuração | Aceito (TASK-060) |
| 0047 | Menus da Descida em bottom sheet com rodapé fixo e cartões 2x2 na loja | Aceito (TASK-059) |
| 0046 | Médico da Cera (cura 12%) e Rastejador da Vala (rápido e frágil) entram na Cidade Abandonada | Aceito (TASK-058) |
| 0045 | Turiferário Cego entra na Cidade Abandonada; revisão crítica por agente obrigatória para modelos novos (`tools/blender/render_preview.py`) | Aceito (TASK-057) |
| 0044 | Combate mobile: Atacar/Defender fixos, gavetas por aba, skill/item/Fugir com 2 toques (previsão no 1º), sem texto duplicado | Aceito (TASK-056) |
| 0043 | Atmosfera comum (ambiente 0,46 azul-ardósia, neblina, foco quente no combate, dithering Bayer, desfoque 0,35 no combate) e fogueira 3D sincronizada com o estado aceso | Aceito (TASK-055) |
| 0042 | Cânone visual obrigatório para todo asset (`F-022`): craft/cenários/profundidade de Sword of Convallaria (nº 1), Tactics Ogre, Triangle Strategy, Octopath Traveler, Ragnarok Online e Buriedbornes sob atmosfera dark gótica de Bloodborne (prioridade máxima) e Dark Souls; descritores originais sem citar jogos em prompts IA | Aceito (Orlando, 2026-11-21) |
| 0001 | Godot 4.7, GDScript com tipagem obrigatória, Compatibility, retrato 540×960 com `keep_width` | Aceito |
| 0002 | `project.godot` na raiz; núcleo sem nós, verificado por teste; identificadores em inglês; vault na raiz | Aceito |
| 0003 | GUT 9.7.1 instalado por script, fora do Git; um comando roda a suíte em headless | Aceito |
| 0004 | `docs/GDD.md` é a cópia do GDD que vale para o código | Aceito (Orlando, 2026-11-15) |
| 0005 | Observador de arquivos roda a suíte no PC do Orlando e grava o resultado em `reports/` para o Claude ler | Aceito (2026-11-16) |
| 0006 | RNG próprio PCG32; quatro fluxos com sementes por SplitMix64; estado salvo como texto | Aceito (TASK-002) |
| 0008 | Leituras do GDD §6 a §8 para o combate (PRE como bônus, arredondamento, Veterano 65%, aviso garantido contra inimigo rápido, durações) | Aceito, com 2 perguntas (TASK-004) |
| 0033 | Eventos de mapa em dados (6 na Cidade Abandonada, com moeda e modificador de CRIT) e mini boss anunciado Carcereiro do Sino com raro + Galhos Secos + Moeda da Sorte | Aceito (TASK-028) |
| 0032 | Mutações temáticas (Inchado, Voraz, Fantasma, Espinhoso), emboscada com bote inicial e Guarda aberta, SORTE e Maré de azar nas mutações, emboscadas e drops raros | Aceito (TASK-027) |
| 0031 | Primeira Descida chamativa (`runs_played == 0`): Cidadão Infectado na camada 1, baú na camada 2, elite no meio, chefe de longe no mapa, Ecos em dobro e tela "Morte que ensina" | Aceito (TASK-026) |
| 0041 | Algoritmo próprio Terrace-Grammar-Constraint em 7 estágios para cenários coerentes (`ScenarioBlueprint`/`Generator`/`Validator`/`Renderer`), não-oclusão isométrica, batelada MultiMesh e `character-keeper` na loja | Aceito (TASK-053) |
| 0036 | Apresentação 3D isométrica com kits CC0 (mapa com visão parcial e câmera que acompanha, combate com fundo do nó, fogueira estilo Darkest Dungeon), print obrigatório nas tarefas de tela; substitui o visual 2D | Aceito (Orlando, 2026-11-19) |
| 0030 | Fichas de inimigos, golpes de moeda temáticos, Leptospirose persistente, reações em dados, Coveiro 175/16 | Aceito (TASK-025) |
| 0029 | Previsão de dano e acerto, descrição das skills, atacar devolve MP, Éter em combate, crítico por item e skill de fogueira, Coveiro 195/16 | Aceito (TASK-024) |
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

- **DIRETRIZ DE RECURSOS (Orlando, 2026-11-18):** Enquanto o MVP jogável de verdade (com gráficos e som) não for alcançado, **não gaste recursos com o simulador de balanceamento (`tools/simulate.gd`) nem com testes de propriedade/balanceamento complexos**. Mantenha os testes unitários enxutos e rápidos.
- **DIRETRIZ DE PROGRESSÃO DE MAPAS (Orlando, 2026-11-19; F-020, `TASK-052`):** o primeiro mapa deve ser **curto** (ritmo ágil de tutorial-gancho para prender o jogador logo no início), **sem deixá-lo mais fácil**; os mapas seguintes crescem gradativamente em extensão e dificuldade.
- **CÂNONE VISUAL E ATMOSFERA GÓTICA OBRIGATÓRIOS EM TODO ASSET (Orlando, 2026-11-21; `F-022`, `ADR-0042`):** **sempre que qualquer asset for criado ou ajustado** (3D, Blender, adaptação CC0, texturas, cenários/profundidade, props, inimigos, personagens, itens, ícones, UI, iluminação ou shaders), leia `docs/ART-DIRECTION.md` e `ADR-0042`: grafismo e profundidade espacial de **Sword of Convallaria** (referência nº 1 de arte), **Tactics Ogre**, **Triangle Strategy**, **Octopath Traveler**, **Ragnarok Online** e **Buriedbornes**, sempre sob a atmosfera **bem dark e gótica** de **Bloodborne** (prioridade máxima) e **Dark Souls** (prompts de IA sem citar nomes de jogos, GDD §18).
- Sorteio no núcleo só por `RngStreams` (`map()`, `combat()`, `loot()`, `coin()`); métodos do `Pcg32`: `draw_int`, `draw_float`, `draw_percent`, `draw_index`, `shuffled_copy`. Não usar `randi`, `shuffle` nem `pick_random`. O save usa `snapshot()` como está (texto, não número de 64 bits em JSON). A semente do próximo mapa vem de `RngStreams.derive_seed`.
- **Godot 4.7 e enums:** um enum usado dentro da própria classe e por outras com dependência cíclica dá erro de tipo ("Cannot assign Combatant.Side as Side"). Nesses casos, usar constantes inteiras.
- **Observador:** tem limite de tempo por rodada desde 2026-11-16 (status `timeout`, exit 124). Saída parcial fica em `reports/last_run.out.tmp` enquanto roda.
- **Telas:** as telas seguem o padrão do ADR-0010: um controlador `RefCounted` testável e uma tela montada em código. Nos testes, `time_scale = 0` deixa a animação instantânea.
- **Dados:** a luta é montada por `DataLoader.load_all()`, `make_player("warrior", poder)` e `make_enemy(id, nível)`. Não deve usar os `CombatFixtures`. `CombatSkill.warrior_set()` continua como referência, e um teste confere que é igual aos dados.
- **Exportação (TASK-014):** o Godot não exporta `.json` por padrão. No preset, incluir `game/data/*.json` em "Filtros para exportar arquivos que não são recursos", senão o jogo exportado abre sem dados.
- **Telas novas:** os nós trocados com `queue_free` aparecem como "órfãos" no GUT. É esperado: liberar na hora pode derrubar o jogo, porque o botão que pediu a troca ainda está emitindo o sinal.
- **Worktree e o Godot:** quem joga precisa abrir a pasta da worktree/branch com as mudanças (ou mesclar na `main`); abrir a raiz de outro checkout mostra o jogo antigo.
- "Moedas" no GDD §15 é o ouro; "a moeda" do §7 é o cara ou coroa. No código: `gold` e `coin`.
- Fórmulas do GDD só mudam com ADR, no mesmo commit do GDD (`docs/GDD.md`) e do código, com `CoreVersion.RULES_VERSION` incrementado.
- **Padrões que o repositório confere sozinho:** `tests/unit/test_project_standards.gd` (estrutura de tarefas e ADRs, numeração, HANDOFF com o `RULES_VERSION` atual, uma ficha de inimigo por inimigo), `tests/unit/test_core_purity.gd` (núcleo sem nós nem aleatoriedade global), `test_untyped_declarations_are_errors` (tipagem) e os hooks `.githooks/` (mensagem de commit e suíte antes do commit).
- **Galhos Secos, Moeda da Sorte, Maré de azar e SORTE** têm constantes em `game/core/run/run_rules.gd` (cada uma com o ADR no comentário). A concessão de Galhos do mapa acontece **antes** de gerar o mapa porque a checagem de vencibilidade usa os consumíveis da Descida.
