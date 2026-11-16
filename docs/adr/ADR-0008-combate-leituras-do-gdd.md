# ADR-0008: motor de combate, leituras do GDD §6 a §8

| Campo | Valor |
| --- | --- |
| Status | Aceito (decisão técnica dentro da tarefa; os itens marcados com **pergunta** esperam o Orlando) |
| Data | 2026-11-16 |
| Tarefa | TASK-004 |
| GDD | 6, 7, 8, 9, 11 (Lentidão) |

## Contexto

O GDD dá as fórmulas, mas deixa pontos que o código precisa fixar: arredondamento, ordem dos multiplicadores, durações, o que acontece em empate de turno e como garantir o aviso de um turno quando o inimigo é mais rápido. Nenhuma fórmula muda aqui; estas são as leituras.

## Decisão

**Fórmulas**

1. **PRE.** As tabelas de classe dão PRE 90 para todos, e a fórmula é `clamp(90 + PRE - ESQ, 10, 98)`. Lida ao pé da letra, daria sempre 98%. Leitura adotada: o 90 da tabela é a base, e a fórmula usa o bônus acima dela (`PRE - 90`). Assim o Guerreiro acerta 87% contra ESQ 3 e 78% contra o Ladino (ESQ 12). **Pergunta.**
2. **DEF contra físico, RES contra magia.** ATK é FOR para físico e MEN para magia, como no GDD.
3. **Ordem e arredondamento.** Fórmula do GDD, depois o multiplicador da moeda, depois a redução de Defender. Arredonda para o inteiro mais próximo, com mínimo 1. Só então vale o limite de morte imediata. Clima vale 1,0 no MVP.
4. **Ordem dos sorteios.** No fluxo de combate: acerto, crítico, variação. Crítico base 5% (CRIT 5), multiplicador 1,5.

**Moeda**

5. **Golpe de moeda do inimigo.** A moeda é jogada antes do teste de acerto, porque o lance já foi anunciado; o golpe ainda pode errar.
6. **Maré de azar.** Vale +10 enquanto houver 3 ou mais perdas seguidas, e zera ao ganhar. O contador (`CoinState`) atravessa os combates da Descida.
7. **Trapaça.** A fórmula (soma depois do limite de 85, teto 90) está implementada e testada, mas não está ligada: anúncios ficam fora do MVP.
8. **Golpe Cruel com Coroa.** Causa só o dano dobrado; debuff e doença ficam para quando esses sistemas existirem.
9. **Morte imediata.** O limite de 60% vale para todo golpe que a Bibiana recebe, não só o Golpe Mortal (GDD §7, "Limites de justiça").

**Defender e Guerreiro**

10. **Defender.** Reduz 50% e devolve 10% do MP máximo, arredondado. Corta pela metade a penalidade de Coroa; o bônus de Cara do Golpe Cruel não muda.
11. **Veterano.** "Protege 30% a mais" vira redução de 65% (50% × 1,3), e Defender anula a penalidade de Coroa. **Pergunta**: a outra leitura seria 80% (50% + 30 pontos).
12. **Golpe de Escudo.** A moeda só é jogada se o golpe acertar. Em chefe, Cara vira Lentidão com os números da tabela de debuffs (VEL -30%, 3 turnos).
13. **Durações.** Contam turnos de quem tem o efeito e caem no início de cada turno dele: Defender e Investida duram até o próximo turno da Bibiana; Muralha, dois turnos dela. Reaplicar renova, sem acumular.

**Turnos e IA**

14. **Carga.** Ticks inteiros: cada unidade soma a VEL até 100. Em empate, a Bibiana age primeiro.
15. **Aviso garantido.** Se o inimigo vai agir de novo antes do turno da Bibiana, o golpe perigoso (forte ou de moeda) sorteado é trocado por um ataque comum. Assim o aviso sempre aparece antes de um turno dela, mesmo contra inimigos rápidos.
16. **Variação do ciclo.** O inimigo segue o ciclo, com 25% de chance de pular um movimento.
17. **Regras de justiça da IA.** Golpes proibidos viram o ataque comum: o mesmo golpe perigoso duas vezes seguidas, dois golpes de moeda seguidos (exceto na fase final de chefes) e Golpe Mortal fora de chefe.
18. **Fases.** A nova fase entra quando a vida fica igual ou abaixo do limite. Ela vale a partir da próxima intenção; a intenção já mostrada não muda.
19. **Atordoar.** O inimigo perde o turno e a intenção mostrada é cancelada (GDD §7, "Interromper").
20. **Morte simultânea.** Se os dois caem no mesmo golpe (reflexo da Muralha), vale a derrota.

**Fora deste motor por enquanto:** Preparo, skills das outras classes, debuffs e doenças, clima, mutações, Re-jogada, Moeda da Sorte. Os números das skills do Guerreiro estão em `CombatSkill.warrior_set()` até os dados de classe existirem (TASK-005).

## Alternativas

- **PRE ao pé da letra:** acerto sempre 98%, o que torna a ESQ inútil contra a Bibiana com PRE 90.
- **Aviso só por regra de dados** (nunca dar golpe perigoso a inimigo rápido): frágil, porque Lentidão e fases mudam a ordem. A checagem na hora da escolha cobre todos os casos.
- **Moeda depois do acerto nos golpes do inimigo:** o lance anunciado poderia nem acontecer, o que esvazia o momento de tensão.

## Consequências

- O teste de propriedade em 2.000 lutas confere as regras 9, 15, 17 e o fim de toda luta.
- Mudar qualquer leitura acima muda resultados por semente: exige ADR novo e subir `RULES_VERSION` (agora 2).
- As perguntas sobre PRE e Veterano mudam o equilíbrio, não a estrutura. Se o Orlando escolher outra leitura, a mudança fica em `CombatFormulas` e `Stats`.
