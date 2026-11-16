# TASK-009: mapa jogável

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte completa 201/201 (2026-11-16); revisão cruzada e jogada humana pendentes |
| Aberta em | 2026-11-16 |
| Fase | 1, protótipo cinza (GDD §22; roteiro em `docs/ROADMAP-MVP.md`) |
| GDD | 5 (mapa, neblina), 19 (interface móvel), 20 (núcleo por eventos) |
| ADRs | ADR-0013 |

## Objetivo

Passa a ser possível jogar uma Descida pela tela. O mapa em retrato mostra os três destinos com tipo, inimigo e nível, as camadas seguintes na névoa e o caminho já feito. Um toque escolhe o nó; a luta abre na tela de combate da TASK-006, ligada ao `RunState`, e volta ao mapa. A tela só lê o estado do núcleo.

## Fora do escopo

- Telas de verdade da recompensa, da loja e da fogueira (TASK-010). Até lá, a loja e a fogueira aparecem como painéis provisórios: a loja só tem "Seguir", e a fogueira tem "Descansar" e "Seguir".
- Menu de verdade, escolha de classe, Ecos e recomeço (TASK-011). Aqui há só uma tela inicial com "Nova Descida" e a luta de teste.
- Tabuleiro isométrico 3D (GDD §17), Lanterna e anúncio de mini boss.

## Critérios de aceite

- [x] Mapa em retrato: chefe no alto, partida embaixo, camadas entre os dois, com as ligações desenhadas.
- [x] Névoa (GDD §5): os 3 destinos mostram tipo, inimigo e nível e se destacam; as camadas seguintes aparecem como silhuetas sem tipo; o caminho feito fica marcado.
- [x] Topo com cenário, Poder, ouro, HP, MP e poções.
- [x] Toque num destino chama o `RunState`; luta abre o combate ligado à Descida (HP, MP e poções da Descida) e volta ao mapa ao fim.
- [x] Loja e fogueira provisórias, sem travar o fluxo; vitória e derrota mostram o resultado e "Nova Descida".
- [x] A Descida é criada fora da thread principal, com a checagem de vencibilidade de 200 simulações (ADR-0012), e uma tela de espera aparece enquanto isso.
- [x] Testes headless do modelo do mapa e de uma Descida inteira jogada pelos botões; suíte verde; prints no Godot.

## Arquivos afetados

- `game/presentation/map/map_view.gd`, `map_screen.gd`
- `game/presentation/game_screen.gd`
- `game/presentation/combat/combat_session.gd`, `combat_screen.gd` (modo Descida)
- `game/presentation/main.gd`
- `tests/unit/test_map_view.gd`, `test_game_screen.gd`
- `docs/adr/ADR-0013-tela-do-mapa-e-fluxo-provisorio.md`

## Testes esperados

- `test_map_view.gd`: névoa (só os destinos mostram tipo), caminho feito, posições por camada e coluna, cabeçalho.
- `test_game_screen.gd`: uma Descida inteira jogada pelos botões até vitória ou derrota, sem checagem de mapa e com animação instantânea; a luta usa o HP da Descida.

## Regras que esta tarefa não pode quebrar

- A apresentação só lê o núcleo e chama as ações públicas do `RunState` e do `Combat`.
- Núcleo sem nós.

## Verificação

- 2026-11-16: `tools/run_tests.ps1` no Claude Code, 26 scripts, 201/201, exit 0, 26 s, todos na primeira rodada. Uma Descida inteira é jogada pelos botões em `test_game_screen.gd`.
- Rodada no Godot 4.7.2 com janela de 540×960, com prints do início, da espera, do mapa no começo, de uma luta da Descida e do mapa na camada 2. Criar a Descida na thread, com a checagem de 200 simulações, levou de 1,3 a 1,7 s no PC (semente 4242, 1 suavização), sem travar a janela.
- O primeiro print mostrou dois defeitos, já corrigidos: a partida ficava esmaecida depois da saída, e as ligações do nó fora de alcance da camada 1 apareciam.
- O GUT acusa nós "órfãos" nos testes de tela. São telas trocadas com `queue_free`, que só são liberadas no frame seguinte, depois do fim do teste. Liberar na hora pode derrubar o jogo, porque o botão que pediu a troca ainda está emitindo o sinal.
- Falta o Orlando jogar uma Descida com o mouse.

## Revisão cruzada

Pendente (etapa 4).
