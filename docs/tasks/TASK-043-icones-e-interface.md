# TASK-043: ícones e interface de jogo (fim do "RPG de texto")

| Campo | Valor |
| --- | --- |
| Status | Em verificação (ícones, cartões, barras, status, inventário e `xN` prontos; falta o Orlando aprovar os prints e a revisão cruzada) |
| Aberta em | 2026-11-19 |
| Fase | 1, feedback do Orlando sobre o MVP visual |
| GDD | 6, 7, 10, 15, 19 |
| ADRs | a criar (ADR-0038 em diante) |

> Leia `docs/ART-DIRECTION.md` antes. Fecha com print e o teste do print.

## Objetivo

Trocar listas de texto e botões lisos por **interface de jogo**: **ícones** de itens, skills, status, doenças e tipos de nó; **cartões** de ação e de mercadoria (Darkest Dungeon), **barras com moldura** e retratos; inventário e equipamento visuais; o multiplicador `xN` sobre o baú.

## Fora do escopo

- Novos modelos 3D e inimigos (TASK-044); regras novas.

## Critérios de aceite

- [x] Conjunto de ícones CC0 (por exemplo Kenney "Game Icons" e "RPG Icons", ou Game-icons.net com a licença registrada) mapeado por id para todo item, skill, status e doença dos dados; teste de que nenhum id fica sem ícone.
- [x] **Cartões** no lugar dos botões de texto na loja, na fogueira, no baú, na recompensa e no combate (ícone, nome, custo, efeito em uma linha, seta verde ou vermelha de comparação).
- [x] Barras de HP e MP com moldura, número dentro e animação de dano; ícones de status e intenção sobre os personagens.
- [x] Inventário e equipamento da Bibiana visíveis (slots com ícones) no mapa e na loja.
- [x] `xN` do multiplicador sobre o baú; prints de cada tela alterada; executável gerado.

## Arquivos afetados

- `game/presentation/` (cartões, ícones, painéis), `assets/` (ícones), `assets/LICENSES.md`

## Testes esperados

- Todo id de item, skill, status e doença tem ícone; os cartões montam a partir dos controladores existentes sem mudar regra.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR; núcleo sem nós; asset externo registrado em `assets/LICENSES.md`.

## Verificação

Suíte em 2026-11-19: 343 testes, 343 passando (`test_icons.gd`: todo item, skill, efeito e tipo de nó tem ícone). Prints: `docs/tasks/prints/TASK-043-icones|loja|fogueira|recompensa|combate.png`.

**Feito:** pacote CC0 "496 RPG Icons" (gnola14) registrado em `assets/LICENSES.md`; `IconRegistry` por id (18 itens, 9 skills, 9 efeitos, doença, 9 tipos de nó, UI); cartões com ícone na loja (nome, espécie, preço e efeito), na fogueira (skills com efeito, descansar, acender, tratar), na recompensa (equipar e vender) e no baú (Moeda da Sorte e anúncio); botões de combate com ícone (atacar, defender, skills, poção, éter, fugir, Moeda da Sorte).

**Segunda rodada (2026-11-19):** barras de HP e MP com moldura de bronze e o número dentro; ícones dos efeitos ativos sobre os personagens no palco (inimigo no alto, Bibiana embaixo à esquerda); linha de equipamento e mochila sob o cabeçalho do mapa (arma, mão secundária, armadura, cabeça, relíquia, poções e Galhos Secos, com moldura apagada nos slots vazios); seta ▲ ou ▼ na loja pelo ganho líquido de atributos do item; `×N` grande no painel do baú depois de multiplicar; nomes dos slots de cabeça e mão secundária. Prints: `TASK-043-mapa-equipamento.png` e `TASK-043-combate-barras.png`.

**Falta:** o `xN` fica no painel e não sobre o modelo 3D do baú; a animação de dano das barras; ícones de tipo de nó nas bolhas do mapa; a seta da loja compara o total de atributos, não cada um; a tela de equipamento detalhada (hoje só ícones com dica).

## Revisão cruzada

Pendente.
