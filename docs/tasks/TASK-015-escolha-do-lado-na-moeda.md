# TASK-015: o jogador escolhe o lado da moeda

| Campo | Valor |
| --- | --- |
| Status | Concluída |
| Aberta em | 2026-11-16 |
| Fase | Fase 1 (MVP), correção pedida pelo Orlando depois da jogada da TASK-009 |
| GDD | 7 |
| ADRs | ADR-0014 |

## Objetivo

Todo lance de moeda passa a pedir o lado (Cara ou Coroa) ao jogador antes de girar. Hoje o lance é automático e a tela mostra "Cara (sucesso)" ou "Coroa (falha)". A TASK-015 responde a pergunta aberta do ADR-0010.

Número da tarefa fora de ordem de propósito: ela entra antes da TASK-010 do roteiro, sem renumerar o `docs/ROADMAP-MVP.md`.

## Fora do escopo

- Trapaça (anúncio e Moeda Viciada), re-jogada do Clérigo e Maré de azar na tela além do que já existe.
- Animação e som do lance (Fase 2).
- Mudar a chance, o sorteio ou o fluxo de RNG da moeda: o núcleo não muda.

## Critérios de aceite

- [x] Em cada lance (golpe de moeda do inimigo, Atordoar, Fugir) a tela mostra a chance e dois botões, Cara e Coroa, e só gira depois da escolha.
- [x] A moeda cai no lado escolhido quando o lance dá sucesso e no outro lado quando dá falha; o texto diz se acertou ou errou.
- [x] A chance de sucesso e a sequência de sorteios são idênticas às de antes (o lado escolhido não altera o resultado).
- [x] Textos de intenção e tooltips falam em "acertar o lado" e não mais em "Chance de Cara".
- [x] GDD §7 atualizado e ADR-0014 criado.
- [x] Suíte verde.

## Arquivos afetados

- `game/presentation/combat/combat_texts.gd`, `combat_session.gd`, `combat_screen.gd`
- `game/core/combat/coin_rules.gd` (só o comentário)
- `docs/GDD.md` (§7), `docs/adr/ADR-0014-escolha-do-lado-da-moeda.md`, `docs/HANDOFF.md`
- `tests/unit/test_combat_session.gd`, `tests/unit/test_combat_screen.gd`

## Testes esperados

- `test_combat_session.gd`: o lado em que a moeda cai depende da escolha e do sucesso; o registro cita escolha e resultado.
- `test_combat_screen.gd`: com velocidade normal, o lance espera o botão e devolve o lado apertado.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR.
- Núcleo sem nós e sem aleatoriedade global.

## Verificação

`tools\run_tests.ps1` em 2026-11-16: 26 scripts, 205/205 verdes (4 testes novos). Todos os critérios atendidos; falta o Orlando jogar para ver se o ritual da escolha funciona.

## Revisão cruzada

Pendente.
