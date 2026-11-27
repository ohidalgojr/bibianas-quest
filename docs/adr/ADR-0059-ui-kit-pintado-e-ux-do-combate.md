# ADR-0059: UI kit pintado, ícones do Gemini e UX do combate

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-27 |
| Tarefa | TASK-072 |
| GDD | 6, 7, 18, 19 |

## Contexto

O Orlando entregou ícones, peças de UI, arenas, ilustrações e moedas pintadas, e a crítica de UX deu 4,8/10 ao combate: linha do tempo parada e borrada, gaveta que escondia a previsão, moeda que apagava a luta, selo de intenção em texto e golpe sem impacto.

## Decisão

1. `IconRegistry` prefere os ícones pintados 96x96 (`assets/bibiana/icons/`) e cai nos do pacote CC0 se faltar; `UiKit` concentra as molduras (painel de pedra 9-slice, slots, divisor, ilustração).
2. A linha do tempo mostra o AGORA (60 px, borda dourada) e 4 futuros que esmaecem, atualizada por evento, com bustos reduzidos em Lanczos.
3. A gaveta é folha de pedra com cabeçalho de HP/MP, previsão e botão CONFIRMAR; o primeiro toque seleciona e o botão executa.
4. O selo de intenção é ícone + nome curto (detalhe ao tocar) e nunca vira "...".
5. O golpe chega ao impacto em cerca de 0,3 s, com hit-stop pela escala de tempo do motor, flash do alvo e números de 44/64 px.
6. A moeda é a prancha pintada (Cara dourada, Coroa prateada), gira de verdade e a consequência do erro continua visível ao escolher.

## Alternativas

- Recortar ícones em tempo de execução: descartado, o script gera PNGs versionados.

## Consequências

O combate lê melhor e reúne a arte do Gemini. A duração das animações cai com a velocidade 2x. Cada nova classe precisa de ícones e poses próprias.
