# ADR-0020: ritmo da moeda e golpes de debuff

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-16 |
| Tarefa | TASK-016 |
| GDD | 6, 7, 11 |

## Contexto

No playtest (`docs/FEEDBACK.md`, F-001 e F-002) o Orlando viu o chefe encadear golpes de moeda e notou que, sem outro tipo de risco, a moeda decide a luta. A regra antiga permitia golpes de moeda seguidos na fase final de chefes, e todo golpe especial dos inimigos era "moeda e mais dano".

## Decisão

1. **Intervalo entre golpes de moeda:** ao menos 2 golpes de outro tipo entre dois golpes de moeda (`Combat.COIN_GAP`), em todos os inimigos. A exceção da fase final sai. Se o próximo golpe do ciclo for de moeda cedo demais, entra o ataque básico.
2. **Golpe de debuff** (`EnemyMove.Kind.DEBUFF`, ícone DEBILITA): causa dano (poder do golpe) e, se acertar, aplica o efeito com `effect_chance` %. O sorteio usa o fluxo de combate, nunca o da moeda. Defender corta a chance pela metade (`DEFEND_CHANCE_FACTOR`).
3. **Efeitos novos na Bibiana**, com os valores do GDD §11: Veneno (5% do HP máximo por turno, 4 turnos, ignora a defesa, respeita a regra de não matar de uma vez acima de 60% de vida) e Fraqueza (FOR e MEN -25%, 3 turnos).
4. **Aviso:** o ícone mostra o efeito e a chance. Debuff não é "golpe perigoso" no sentido da regra do aviso garantido, porque não mata.
5. **Coveiro:** fase 1 com Ataque, Pá (Cruel), Toque Podre (Veneno 60%), Varredura e Ataque; fase 2 com Golpe Mortal, Maldição (Fraqueza 70%), Ataque, Toque Podre e Varredura. Um golpe de moeda por fase, em 5 golpes.
6. `RULES_VERSION` sobe para 5.

## Verificação no simulador

200 Descidas por bot, regras v5 (`reports/simulation.md`, 2026-11-16):

| Bot | Vitória do cenário 1 | Mortes por moeda | Turnos por combate comum |
| --- | --- | --- | --- |
| Mediano (meta 55% a 65%) | 56,0% | 21,6% (meta até 25%) | 6,3 |
| Cuidadoso | 74,5% | 17,6% | 5,8 |

Antes (ADR-0012): mortes por moeda de 31% e 35%. O mediano ficou dentro das metas sem outro ajuste; o chefe dura 16,5 turnos.

## Alternativas

- **Só reduzir a moeda do chefe:** resolve F-001, mas deixa o risco do chefe só na moeda (F-002).
- **Debuff junto da Coroa do Golpe Cruel:** mantém a moeda como única fonte do risco; fica para depois.
- **Sangramento e doenças já:** exigem dano por turno ligado ao ATK do atacante e persistência entre lutas; ficam para uma tarefa própria.

## Consequências

- Saves antigos são recusados (versão das regras).
- O sistema de efeitos agora tem dano por turno e redução de FOR; Purgar, Antídoto e debuffs em inimigos comuns ainda não existem.
