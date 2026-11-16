# Bibiana's Quest: guia do agente

RPG tático de turnos, roguelite, dark fantasy, para celular em retrato. Godot 4.7, GDScript tipado.
O projeto é de uma pessoa (o arquiteto) com agentes de IA escrevendo o código.

Leia nesta ordem antes de qualquer trabalho:

1. `docs/HANDOFF.md`: o que já foi feito, onde está e o que falta.
2. A tarefa aberta em `docs/tasks/`.
3. As seções do GDD que a tarefa cita (`docs/GDD.md`).

## Regras que não podem ser quebradas

1. **Sem tarefa aberta, nenhum código.** Antes de escrever, crie `docs/tasks/TASK-NNN-slug.md` a partir de `docs/tasks/_modelo.md`, com objetivo, critérios de aceite, arquivos afetados e testes esperados.
2. **Uma tarefa por vez, um commit por tarefa.** Mensagem: `TASK-NNN: resumo (ADR-XXXX)`.
3. **Fórmulas e regras do GDD não mudam sem ADR.** Isso vale para o texto do GDD e para o código que as implementa. Se a fórmula mudar: ADR, GDD atualizado no mesmo commit e `CoreVersion.RULES_VERSION` incrementado.
4. **Toda decisão relevante vira ADR** em `docs/adr/` (modelo em `ADR-0000-modelo.md`). Relevante é o que outro agente precisaria saber para não desfazer a decisão.
5. **O núcleo não tem nós.** `game/core/` só usa `RefCounted`, `Resource` e tipos de dados. Nada de `Node`, árvore de cena, `Time`, `OS` ou aleatoriedade global (`randi()`, `randf()`, `shuffle()`, `pick_random()`). Todo sorteio passa pelos quatro fluxos de RNG do núcleo (mapa, combate, loot, moeda). `tests/unit/test_core_purity.gd` falha se isso for violado.
6. **O núcleo fala com a apresentação por eventos**, nunca chamando cenas. A dependência só vai de `presentation` e `services` para `core`.
7. **Testes verdes antes do commit.** Regra nova no núcleo vem com teste; fórmula do GDD vem com teste de fórmula que cita a seção.
8. **Ao terminar a tarefa, atualize `docs/HANDOFF.md`** (feito, onde está, falta, decisões) e pare para o resumo.

## Comandos

| O que | Windows | Linux, macOS |
| --- | --- | --- |
| Rodar todos os testes (headless) | `powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1` | `bash tools/run_tests.sh` |
| Instalar o GUT fixado | `powershell -ExecutionPolicy Bypass -File tools\setup.ps1` | `bash tools/setup.sh` |
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
- Revisão cruzada por outro modelo (etapa 4) feita ou registrada como pendente no HANDOFF.
- GDD, ADRs e HANDOFF atualizados.
- Um commit com o ID da tarefa.
