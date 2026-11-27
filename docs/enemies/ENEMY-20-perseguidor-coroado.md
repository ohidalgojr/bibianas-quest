# ENEMY-20: O Perseguidor Coroado

| Campo | Valor |
| --- | --- |
| Id (dados) | `crowned_pursuer` |
| Tipo e nível | roaming boss (`roaming_boss`), nível base 3; no encontro, nível da camada + 1 |
| Cenário | a partir do cenário 2 (flag `roaming_boss`); fora do cenário 1 (ADR-0066) |
| Medo | O som duplo do sino rachado às suas costas: um senhor da guerra podre e incansável entrou no mapa atrás de você e não entra em fogueira para esperar. |

## Fantasia

Colosso de 2,75 m em armadura de ferro negro coberta de crânios, elmo-coroa de cinco pontas, carne necrótica entre as placas, uma maça brutal na mão direita e uma espadão partido ao meio e afiadíssimo na esquerda. Dossiê visual e prompts em `docs/design/ROAMING-BOSS-perseguidor-coroado.md`.

## Mecânica assinatura

- **Perseguição (GDD §13):** o medidor de alarme sobe ao fugir (+2), descansar na fogueira (+1) e derrotar elite (+1). Com 4, o sino toca duas vezes e ele entra a **3 nós** atrás da Bibiana; a cada nó escolhido ele avança 1 e **nunca entra em fogueira** (não avança quando o destino é fogueira). Ao chegar, a luta é forçada antes do próximo movimento, sem fuga. Mapa e HUD mostram "O Perseguidor está a N nós".
- **Golpe de moeda: Decreto da Maça (cruel).** Em cara o dano é reduzido; em coroa o dano é +100% e a Bibiana fica com **Fraqueza**. Avisado um turno antes.
- **Corte Podre:** golpe de debuff com 65% de chance de **Veneno** (metade com Defender).
- **Reação:** se a Bibiana se fortalece (buff), ele responde com o **Decreto da Maça**; o aviso mostra "Não tolera quem se fortalece".
- **Contra-jogo:** vida alta, DEF média (11), fraco a Fogo e Sagrado (×1,5). Defender corta o Corte Podre; evitar buffs evita a reação; fugir é impossível, então o risco é decidido antes de acumular alarme.

## Ciclo e números

Gume Partido, Decreto da Maça, Corte Podre, Varredura de Ferro (forte, ×1,35). Vida 170, FOR 18, DEF 11, RES 5, VEL 5 e ESQ 3. Três golpes sem moeda entre dois golpes de moeda; nenhum Golpe Mortal (exclusivo de chefe de cenário).

## Drops e textos

Poder ×3, ouro ×3, drop de equipamento da tabela de elite (raros possíveis), Moeda da Sorte e a loja depois da luta. O nome mostrado é "O Perseguidor Coroado". Promoção por patentes e Cemitério de Rivais ficam para a fase seguinte (GDD §13, item 5).

## Regras que a ficha não pode quebrar

- Golpe perigoso avisado um turno antes; ao menos 2 golpes entre golpes de moeda; Golpe Mortal só em chefe de cenário.
