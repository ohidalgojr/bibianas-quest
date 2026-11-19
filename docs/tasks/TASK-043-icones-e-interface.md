# TASK-043: ícones e interface de jogo (fim do "RPG de texto")

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada; depois da TASK-042) |
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

- [ ] Conjunto de ícones CC0 (por exemplo Kenney "Game Icons" e "RPG Icons", ou Game-icons.net com a licença registrada) mapeado por id para todo item, skill, status e doença dos dados; teste de que nenhum id fica sem ícone.
- [ ] **Cartões** no lugar dos botões de texto na loja, na fogueira, no baú, na recompensa e no combate (ícone, nome, custo, efeito em uma linha, seta verde ou vermelha de comparação).
- [ ] Barras de HP e MP com moldura, número dentro e animação de dano; ícones de status e intenção sobre os personagens.
- [ ] Inventário e equipamento da Bibiana visíveis (slots com ícones) no mapa e na loja.
- [ ] `xN` do multiplicador sobre o baú; prints de cada tela alterada; executável gerado.

## Arquivos afetados

- `game/presentation/` (cartões, ícones, painéis), `assets/` (ícones), `assets/LICENSES.md`

## Testes esperados

- Todo id de item, skill, status e doença tem ícone; os cartões montam a partir dos controladores existentes sem mudar regra.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR; núcleo sem nós; asset externo registrado em `assets/LICENSES.md`.

## Verificação

Ainda não executada.

## Revisão cruzada

Pendente.
