# TASK-038: fogueira, loja, baú, recompensa e menu em 3D

| Campo | Valor |
| --- | --- |
| Status | Em verificação (cenários 3D prontos; cartões de ação e o Santuário 3D ficam para a TASK-039; falta o Orlando aprovar os prints) |
| Aberta em | 2026-11-19 |
| Fase | 1, apresentação 3D do MVP jogável (ADR-0036) |
| GDD | 5, 10, 12, 15, 19 |
| ADRs | ADR-0036 (e os que a tarefa criar) |

> **Antes de escrever código leia `docs/ART-DIRECTION.md` inteiro.** A tarefa só fecha com o "teste do print" (seção 8): print do jogo rodando com janela, anexado em `docs/tasks/prints/`, e as seis respostas por escrito. Suíte verde não basta.

## Objetivo

As telas de acampamento e de recompensa ganham **cenário e modelos** (`docs/ART-DIRECTION.md` §5): fogueira com a Bibiana junto ao fogo (referência Darkest Dungeon), loja com comerciante, baú que abre, recompensa e fim com o cenário ao fundo, menu inicial e Santuário.

## Fora do escopo

- Novas mecânicas; música e clima finais (TASK-039).

## Critérios de aceite

- [~] **Fogueira:** cena própria com luz quente oscilando e brasas; ações (Descansar, skills, Galho Seco, tratar doença) em cartões embaixo.
- [~] **Loja:** comerciante e lampião; mercadoria em cartões com seta verde ou vermelha de comparação e botão equipar e vender.
- [~] **Baú:** abre em 3D, ouro cai, multiplicador `xN` sobre o baú (Moeda da Sorte ou anúncio simulado).
- [~] **Recompensa e fim:** retrato, atributos antes e depois, `+N` subindo, cenário ao fundo; causa da morte e Ecos.
- [~] **Menu e Santuário:** panorama do cenário com a Bibiana e a mecha em destaque; Santuário como cômodo com três estações.
- [x] Todas ligadas ao fluxo de `RunPanels` e `GameScreen` sem mudar regra. Um print de cada tela anexado.

## Arquivos afetados

- `game/presentation/camp3d/` e `game/presentation/menu3d/` (novos), `game/presentation/run/`, `game/presentation/game_screen.gd`

## Testes esperados

- Contratos: cada painel abre, mostra as ações da regra e fecha; o fluxo de uma Descida inteira roda pelas telas novas sem erro. A estética é julgada no print.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR. `RULES_VERSION` não muda (só apresentação).
- Núcleo sem nós e sem aleatoriedade global; as cenas só leem eventos e controladores sem nós.
- Todo asset externo registrado em `assets/LICENSES.md`.
- Depende de: TASK-035 e TASK-037.

## Verificação

Suíte em 2026-11-19: 332 testes, 332 passando (`test_scene3d.gd`). Prints (`game_preview.tscn`, `tools/screenshot.ps1 -Extra tela=...`): `docs/tasks/prints/TASK-038-tela-home|shop|campfire|chest|reward|event|result.png` e os cenários puros `TASK-038-campfire|shop|chest|home.png`.

**Feito:** `Scene3DBackdrop` com oito cenários 3D (fogueira com chama em shader, brasas, luz que pulsa e a Bibiana sentada; loja com comerciante, mesa, barril, lampião; baú grande com a animação de abrir e moedas; evento com altar e velas; recompensa e vitória com a Bibiana comemorando; derrota com a Bibiana caída e vela; menu com panorama), ligados a `RunPanelScreen` (painel na metade de baixo, com rolagem) e às páginas de menu e fim do `GameScreen`.

**Falta (por isso `[~]`):** (1) as ações ainda são **botões de texto, não cartões** (Darkest Dungeon) e a loja não tem seta verde ou vermelha de comparação; (2) o baú abre mas **não há `xN` sobre ele**; (3) o Santuário continua em 2D (é uma tela própria, com abas); (4) a fogueira aparece acesa mesmo quando "apagada" (o estado aceso não muda o cenário); (5) comerciante usa o modelo do Coveiro (substituto).

## Revisão cruzada

Pendente.
