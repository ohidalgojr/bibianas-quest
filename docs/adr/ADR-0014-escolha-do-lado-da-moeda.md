# ADR-0014: o jogador escolhe o lado da moeda

| Campo | Valor |
| --- | --- |
| Status | Aceito (responde a pergunta do ADR-0010; o Orlando pediu a escolha manual em 2026-11-16) |
| Data | 2026-11-16 |
| Tarefa | TASK-015 |
| GDD | 7 |

## Contexto

O GDD §7 diz que o jogador escolhe o lado antes do lance, mas definia Cara como sucesso e Coroa como falha. A TASK-006 deixou o lance automático e perguntou o que mostrar se o jogador escolhe Coroa e o lance dá sucesso. Na jogada da TASK-009, o Orlando apontou que o lance não pode ser automático: o jogador escolhe Cara ou Coroa.

## Decisão

1. **Acertar o lado é o sucesso.** O jogador escolhe Cara ou Coroa. Se o lance dá sucesso, a moeda cai no lado escolhido; se dá falha, cai no outro. "Cara é sucesso" some do GDD, e a coluna da tabela de §7 passa a ser "acertou o lado" e "errou o lado". As consequências (dano +50%, atordoar etc.) são as mesmas de antes.
2. **A escolha é ritual.** A chance continua sendo `clamp(50 + SORTE + mods, 15, 85)`, agora chamada chance de acertar. Escolher Cara ou Coroa não muda a chance nem o sorteio, então nenhuma escolha é melhor que a outra, e os bots, o simulador e os testes do núcleo seguem iguais. A fórmula não mudou: sem alteração de `RULES_VERSION`.
3. **O núcleo não muda.** Ele sorteia sucesso ou falha no fluxo da moeda. Quem escolhe o lado e decide a face é a apresentação (`CombatScreen`, `CombatTexts.landed_side`). Só `CoinRules` ganhou as constantes `HEADS` e `TAILS`.
4. **A tela pede o lado em todo lance** (golpe de moeda do inimigo, Atordoar, Fugir): a chance e a Maré de azar aparecem com dois botões, a moeda gira 1,2 s depois da escolha e o resultado diz o lado em que caiu e se o jogador acertou. Em testes (`time_scale` 0) o lado vem de `auto_call`.

## Alternativas

- **Cara sempre sucesso, escolha só cosmética:** mantém o texto antigo do GDD, mas mostra "escolhi Coroa e saiu Cara: sucesso", que confunde.
- **Escolha com efeito real na chance:** quebraria a regra de §7 de que a chance vem da fórmula e criaria lado dominante.
- **Núcleo pausa até receber o lado:** necessário só quando a trapaça (anúncio ou Moeda Viciada, entre o aviso e o resultado) existir; fica para essa tarefa, quando o fluxo do núcleo precisar parar no lance.

## Consequências

- O resultado de um combate continua idêntico para a mesma semente, qualquer que seja a escolha.
- Quando a trapaça entrar, o núcleo vai precisar de uma pausa no lance; este ADR deixa o ponto de entrada na apresentação.
