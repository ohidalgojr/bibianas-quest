# TASK-010: recompensa, loja e fogueira em tela

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte 210/210 (2026-11-16); revisão cruzada e jogada humana pendentes |
| Aberta em | 2026-11-16 |
| Fase | 1, protótipo cinza (roteiro em `docs/ROADMAP-MVP.md`) |
| GDD | 9 e 15 (recompensa, loja), 12 (fogueira) |
| ADRs | ADR-0015 |

## Objetivo

Substitui os painéis provisórios da TASK-009 pelas telas de verdade: depois de vencer uma luta aparece a recompensa (Poder e ouro), depois a loja (comprar, atualizar, seguir) e, nas fogueiras, Descansar, skills de fogueira e Seguir.

## Fora do escopo

- Item especial da loja, eventos, venda de itens (ADR-0011).
- Arte, som e animação (Fase 2).
- Usar o Éter Sujo em combate (hoje só a Poção Turva tem ação na luta).

## Critérios de aceite

- [x] Vitória com loja mostra a recompensa (Poder ganho e novo, HP máximo, ouro) antes da loja; "Continuar" abre a loja.
- [x] Loja lista os itens com tipo, efeito e preço; compra, atualização e "Seguir" chamam o `RunState`; botão desabilitado mostra o motivo (ouro, mochila cheia).
- [x] Equipamento mostra o bônus e o item equipado no mesmo espaço.
- [x] Fogueira mostra Brasas, HP e MP, Descansar e as skills de fogueira com efeito e duração restante.
- [x] Nenhuma regra na tela: tudo vem do `RunState`.
- [x] Suíte verde, com uma Descida inteira jogada pelas telas.

## Arquivos afetados

- `game/presentation/run/run_panels.gd`, `run_panel_screen.gd` (novos)
- `game/presentation/game_screen.gd`
- `tests/unit/test_run_panels.gd` (novo), `test_game_screen.gd`
- `docs/adr/ADR-0015-telas-de-recompensa-loja-e-fogueira.md`

## Testes esperados

- `test_run_panels.gd`: recompensa lida dos eventos, loja com preços e motivos, compra e atualização, descrição de itens, fogueira.
- `test_game_screen.gd`: a Descida inteira passa pela recompensa e pela loja.

## Regras que esta tarefa não pode quebrar

- A apresentação só lê o núcleo e chama as ações públicas do `RunState`.

## Verificação

2026-11-16: `tools\run_tests.ps1`, 27 scripts, 210/210. Falta o Orlando jogar e olhar o layout no celular.

## Revisão cruzada

Pendente.
