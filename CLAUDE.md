# Bibiana's Quest: guia do agente

RPG tático de turnos, roguelite, dark fantasy, para celular em retrato. Godot 4.7, GDScript tipado.
O projeto é de uma pessoa (o arquiteto) com agentes de IA escrevendo o código.

Leia nesta ordem antes de qualquer trabalho:

1. `docs/HANDOFF.md`: estado atual, backlog ordenado, pendências e problemas conhecidos.
2. A tarefa que vai executar em `docs/tasks/` (e `docs/FEEDBACK.md`, o feedback de playtest do Orlando).
3. As seções do GDD que a tarefa cita (`docs/GDD.md`) e os ADRs ligados em `docs/adr/`.
4. Para inimigos, a ficha em `docs/enemies/`; para revisar, `docs/REVIEW-CHECKLIST.md`.
5. **Para qualquer tela ou gráfico: `docs/ART-DIRECTION.md` e o ADR-0036.** O visual não é "provisório": o GDD §17 e §18 mandam tabuleiro isométrico 3D com kits CC0. Sem print do jogo rodando, a tarefa de tela não está pronta.

## Regras que não podem ser quebradas

1. **Sem tarefa aberta, nenhum código.** Antes de escrever, crie `docs/tasks/TASK-NNN-slug.md` a partir de `docs/tasks/_modelo.md`, com objetivo, critérios de aceite, arquivos afetados e testes esperados.
2. **Uma tarefa por vez, um commit por tarefa.** Mensagem: `TASK-NNN: resumo (ADR-XXXX)`.
3. **Fórmulas e regras do GDD não mudam sem ADR.** Isso vale para o texto do GDD e para o código que as implementa. Se a fórmula mudar: ADR, GDD atualizado no mesmo commit e `CoreVersion.RULES_VERSION` incrementado.
4. **Toda decisão relevante vira ADR** em `docs/adr/` (modelo em `ADR-0000-modelo.md`). Relevante é o que outro agente precisaria saber para não desfazer a decisão.
5. **O núcleo não tem nós.** `game/core/` só usa `RefCounted`, `Resource` e tipos de dados. Nada de `Node`, árvore de cena, `Time`, `OS` ou aleatoriedade global (`randi()`, `randf()`, `shuffle()`, `pick_random()`). Todo sorteio passa pelos quatro fluxos de RNG do núcleo (mapa, combate, loot, moeda). `tests/unit/test_core_purity.gd` falha se isso for violado.
6. **O núcleo fala com a apresentação por eventos**, nunca chamando cenas. A dependência só vai de `presentation` e `services` para `core`.
7. **Testes verdes antes do commit.** Regra nova no núcleo vem com teste; fórmula do GDD vem com teste de fórmula que cita a seção.
8. **Ao terminar a tarefa, atualize `docs/HANDOFF.md`** (feito, onde está, falta, decisões) e pare para o resumo.
9. **Foco no MVP jogável (gráficos e som): não gastar recursos com simulador de balanceamento nem testes complexos.** Enquanto o MVP jogável de verdade (apresentação 3D isométrica com kits CC0, ADR-0036; fecha na TASK-040) não estiver concluído, **ignore testes de balanceamento (`tools/simulate.gd`) e não crie testes de propriedade/simulação pesados**. Mantenha apenas testes unitários diretos e rápidos para validar que as mecânicas funcionam sem erros; o balanceamento fino será feito depois que o jogo estiver jogável de verdade.
10. **Cada inimigo tem uma ficha** em `docs/enemies/` (modelo em `_modelo.md`) antes ou junto do código dele, e a regra de justiça vale para todos: golpe perigoso avisado um turno antes, ao menos 2 golpes entre golpes de moeda, Golpe Mortal só em chefe.
11. **Não envie ao GitHub sem o Orlando pedir** e nunca reescreva histórico publicado. Branch `main`, histórico linear.
12. **Uma revisão por outro modelo** (etapa 4, GDD §21): quem escreveu não revisa o próprio trabalho. `docs/REVIEW-CHECKLIST.md` lista o que conferir.
13. **Primeiro mapa curto (sem facilitar) e dificuldade gradual:** o primeiro mapa/cenário deve ser curto, funcionando como gancho/tutorial ágil para chamar a atenção dos jogadores logo no início — **não deixe o mapa fácil, apenas mais curto em extensão**. Os demais mapas passam a ficar gradativamente mais longos e difíceis (`docs/FEEDBACK.md` F-020, `TASK-052`).

### Como o repositório faz cumprir isto

- `tests/unit/test_project_standards.gd`: tarefas com as seções exigidas e título com o ID, numeração de tarefas e ADRs sem buracos, tarefa concluída com "Verificação" preenchida, HANDOFF citando o `RULES_VERSION` atual, uma ficha por inimigo.
- `tests/unit/test_core_purity.gd`: núcleo sem nós, `Time`, `OS` e aleatoriedade global; `test_untyped_declarations_are_errors`: tipagem estática.
- Hooks de git em `.githooks/` (ligue com `tools\setup_hooks.ps1` ou `bash tools/setup_hooks.sh`): `commit-msg` confere `TASK-NNN: resumo (ADR-XXXX)` (ou `ADR-NNNN:`, `FEEDBACK:`, `HANDOFF:`, `DOCS:`); `pre-commit` roda a suíte quando o commit mexe em `game/`, `tests/`, `tools/` ou `project.godot`.

## Comandos

| O que | Windows | Linux, macOS |
| --- | --- | --- |
| Rodar todos os testes (headless) | `powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1` | `bash tools/run_tests.sh` |
| Instalar o GUT fixado | `powershell -ExecutionPolicy Bypass -File tools\setup.ps1` | `bash tools/setup.sh` |
| Ligar os hooks de git do projeto | `powershell -ExecutionPolicy Bypass -File tools\setup_hooks.ps1` | `bash tools/setup_hooks.sh` |
| Simulador de equilíbrio (10 a 12 min, em segundo plano) | `& "$env:GODOT_BIN" --headless --path . -s tools/simulate.gd -- --runs 150 --check 20 --maps 40 --map-check 40` | `"$GODOT_BIN" --headless --path . -s tools/simulate.gd -- --runs 150 --check 20 --maps 40 --map-check 40` |
| Reimportar o projeto (depois de script com `class_name` novo) | `& "$env:GODOT_BIN" --headless --path . --import` | `"$GODOT_BIN" --headless --path . --import` |
| Observador: roda a suíte a cada mudança (ADR-0005) | `powershell -ExecutionPolicy Bypass -File tools\watch_tests.ps1` | não há |

### MCP (Claude Code)

`.mcp.json` liga os servidores `godot` e `blender`. Detalhes, requisitos e como ligar o addon do Blender em `docs/MCP.md`. No Claude Code com terminal, `tools\run_tests.ps1` roda a suíte direto (o observador abaixo é para quando não há terminal).

### Ciclo de teste do agente (ADR-0005)

Só vale quando o agente não tem terminal (projeto do claude.ai). No Claude Code, rode `tools\run_tests.ps1` direto e leia a saída. Sem terminal, quem roda a suíte é o observador (`tools\watch_tests.ps1`), numa janela que o Orlando deixa aberta. Depois de gravar arquivos em `game/` ou `tests/`:

1. Confira que o observador está vivo: `reports/watcher.alive` com hora recente. Se não estiver, peça ao Orlando para abri-lo. Não presuma que os testes passam.
2. Espere `reports/last_run.status` com `state=done` e `started` posterior à gravação.
3. Leia `reports/last_run.txt`. `exit=0` e nenhum teste falhando é verde; qualquer outra coisa é vermelho e a tarefa não avança.
4. Para rodar sem mudar código, grave um arquivo vazio `reports/run_now`.

Nunca diga que a suíte passou sem ter lido `last_run.txt` desta rodada.

O Godot vem de `GODOT_BIN` ou do PATH. No Windows, use o executável `*_console.exe`. Versões fixadas em `tools/versions.env`.

## Estrutura

A raiz do repositório é, ao mesmo tempo, o projeto Godot e o vault do Obsidian (`.obsidian/` fica fora do Git).

```text
project.godot        projeto Godot na raiz do repositório (ADR-0002)
game/core/           regras do jogo, sem nós: Descida, mapa, combate, moeda, economia, IA
game/data/           definições: inimigos, skills, itens, doenças, biomas
game/presentation/   cenas, interface, efeitos, áudio
game/services/       save, anúncios, compras, telemetria, localização
tests/               testes GUT (unit/, e depois property/ e sim/)
tools/               scripts de setup e de teste; simulador headless
addons/gut/          GUT, instalado por script e fora do Git (ADR-0003)
docs/                GDD, ADRs, tarefas, HANDOFF (invisível para o Godot via .gdignore)
assets_src/          fontes de arte (Blender, imagens), invisível para o Godot
```

## Onde está cada regra no GDD

| Assunto | Seção |
| --- | --- |
| Laços de jogo, morte, o que persiste | 4 |
| Mapa em grafo, tipos de nó, vencibilidade | 5 |
| Combate, ordem de turnos, fórmulas de dano e acerto | 6 |
| Cara ou coroa, trapaça, limites de justiça | 7 |
| Classes, atributos iniciais, skills | 8 |
| Poder, mecha, meta-progresso | 9 |
| Equipamentos, doenças, fogueira, chefes, clima | 10 a 14 |
| Economia e loja | 15 |
| Monetização e seus limites | 16 |
| Arquitetura, RNG, entidades, save | 20 |
| Pipeline de 8 etapas, definição de pronto | 21 |
| Metas de balanceamento | 23 |

## Estilo de GDScript

- Tipagem estática em tudo: variáveis, parâmetros, retornos e variáveis de laço (`for i: int in n`). Declaração sem tipo é erro de compilação neste projeto.
- Indentação com tab. `snake_case` para funções e variáveis, `PascalCase` para classes, `UPPER_SNAKE` para constantes. Membros privados começam com `_`.
- Identificadores em inglês; comentários, documentação e textos de teste em português.
- Classes do núcleo: `class_name` + `extends RefCounted`. Funções puras quando possível: recebem estado e fluxo de RNG, devolvem resultado.
- Constantes de regra carregam a seção do GDD no comentário, por exemplo `## GDD §7: teto da chance sem trapaça.`
- Sem números mágicos de balanceamento espalhados: valores do GDD ficam em constantes nomeadas ou em `game/data/`.

## Glossário (termo do GDD para identificador)

| GDD | Código | GDD | Código |
| --- | --- | --- | --- |
| Descida | `descent` | Poder | `power` |
| Cenário | `scenario` | Moedas (ouro) | `gold` |
| Camada | `layer` | Moeda (cara ou coroa) | `coin` |
| Nó do mapa | `map_node`, `MapNode` | Cara, Coroa | `heads`, `tails` |
| Fogueira | `campfire` | Trapaça | `cheat` |
| Chefe, mini boss | `boss`, `mini_boss` | Moeda Viciada | `loaded_coin` |
| Baú | `chest` | Maré de azar | `bad_luck_streak` |
| Inimigo emboscado | `ambush` | Ecos, Almas, Brasas | `echoes`, `souls`, `embers` |
| Ritmo, Carga | `speed`, `charge` | Doença, Mutação | `disease`, `mutation` |

Atributos: HP `hp`, MP `mp`, FOR `strength`, MEN `mind`, DEF `defense`, RES `resistance`, VEL `speed`, PRE `accuracy`, ESQ `evasion`, CRIT `crit`, SORTE `luck`.

"Nó" no código é sempre `map_node`, para não confundir com `Node` do Godot.

## Definição de pronto (GDD §21)

- Tarefa aberta com critérios de aceite, e todos atendidos.
- ADR criado ou ligado para cada decisão.
- Testes e simulações verdes em headless.
- **Executável de teste:** ao fim de cada tarefa que muda o jogo, rode `powershell -ExecutionPolicy Bypass -File tools\build_windows.ps1` e informe ao Orlando o caminho do `.exe` (`build\windows\BibianasQuest.exe` na pasta principal do repositório), para ele testar sem abrir o Godot.
- **Tarefa de tela (ADR-0036): print do jogo rodando com janela, anexado em `docs/tasks/prints/`, e o "teste do print" de `docs/ART-DIRECTION.md` §8 respondido.** Suíte verde não prova que a tela está certa.
- Revisão cruzada por outro modelo (etapa 4) feita ou registrada como pendente no HANDOFF.
- GDD, ADRs e HANDOFF atualizados.
- Um commit com o ID da tarefa.

## Lições e armadilhas (aprendidas nas TASK-001 a 025)

- **Escrever arquivos com acento no Windows:** nunca passe texto em português por heredoc de shell para `python -`; a entrada padrão do Windows vira cp1252 e quebra a acentuação. Grave o script num arquivo `.py` (UTF-8) e rode `python arquivo.py`, ou edite com a ferramenta de edição de arquivos. Edite sempre os arquivos como UTF-8 com fim de linha LF (`.gitattributes` já força).
- **Indentação do GDScript é tab**, e a profundidade varia (corpo de função com 1 tab, `match` e blocos com mais). Ao editar por substituição de texto, não presuma o número de tabs: confira com `cat -A` ou use busca por regex que capture a indentação.
- **Classe nova com `class_name`** precisa de `--headless --import` antes de rodar fora do editor, senão aparece "Could not find type" ou o jogo abre com tela escura. O Godot que abre outra pasta (outro checkout ou worktree) mostra o jogo antigo: confira o caminho.
- **Equilíbrio é restrição dupla:** a faixa do jogador mediano e a garantia de mapa vencível competem. Antes de endurecer um inimigo, rode o simulador com `--map-check 40`; mais de 1 mapa sem rota em 40, ou criação da Descida acima de 2 s, significa que ficou duro demais.
- **Determinismo:** tudo que sorteia usa os quatro fluxos de `RngStreams`; adicionar um sorteio muda os resultados das sementes (suba o `RULES_VERSION`). A previsão de dano e a apresentação nunca sorteiam. Testes de distribuição usam sementes fixas e margens honestas.
- **Só apresentação lê estado e anima eventos:** o núcleo emite `CombatEvent` e `RunEvent`; a tela nunca recalcula regra. Telas novas seguem o padrão do ADR-0010: controlador `RefCounted` testável e tela montada em código. Texto que pode ficar longo precisa de `autowrap_mode` (botão que não quebra linha alarga a tela inteira).
- **Teste novo para regra nova, e teste antigo atualizado de propósito:** quando uma regra muda, os testes que fixavam o número antigo mudam junto, com a explicação no ADR. Nunca afrouxe um teste para passar sem entender a causa.
- **Fonte de verdade do que foi decidido:** ADR e GDD. O código cita o ADR e a seção do GDD em comentário. Feedback do Orlando vai para `docs/FEEDBACK.md` antes de virar tarefa.
- **Pare no fim de cada tarefa** com um resumo curto, honesto sobre o que não foi verificado (por exemplo, "não abri o jogo com janela"). Nunca diga que a suíte passou sem ter lido a saída desta rodada.
