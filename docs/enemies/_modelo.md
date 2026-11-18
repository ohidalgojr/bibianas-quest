# ENEMY-NN: nome do inimigo

| Campo | Valor |
| --- | --- |
| Id (dados) | `enemy_id` em `game/data/enemies.json` |
| Tipo e nível | comum, elite ou chefe; nível base |
| Cenário | onde aparece |
| Medo | uma frase: o que este inimigo faz o jogador temer (inspiração: Fear & Hunger) |

## Fantasia

Duas ou três frases: o que ele é, como se move, o que o jogador pensa quando o vê de novo ("pô, esse de novo").

## Mecânica assinatura

- **Golpe de moeda temático:** nome, o que acontece em cara (acertou o lado) e em coroa (errou), e a consequência concreta (efeito de combate ou doença).
- **Reação:** condição que ele percebe e o golpe com que responde; o aviso de intenção mostra o motivo.
- **Contra-jogo:** o que o jogador pode fazer (Defender, item, skill, ordem das ações).

## Ciclo e números

Lista dos golpes do ciclo (ids dos dados) e por que o ciclo é assim; números de vida, FOR, VEL e o porquê.

## Drops e textos

Drops típicos, texto de aviso e nome mostrado na tela.

## Regras que a ficha não pode quebrar

- Golpe perigoso sempre é avisado um turno antes; ao menos 2 golpes entre dois golpes de moeda; Golpe Mortal só em chefe.
- Mudança de regra do GDD precisa de ADR; a ficha só usa as regras existentes.
