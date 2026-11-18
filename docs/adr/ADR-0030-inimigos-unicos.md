# ADR-0030: inimigos únicos, IA reativa e golpes de moeda temáticos

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-18 |
| Tarefa | TASK-025 |
| GDD | 6, 7, 11, 21 |

## Contexto

D4 do ADR-0025 e F-006, F-012, F-013 e F-018 do playtest: os golpes de moeda eram só "mais dano", os inimigos usavam os mesmos golpes genéricos e a IA era um ciclo fixo sem inteligência. O Orlando quer que cada inimigo seja único, com um medo próprio inspirado em Fear & Hunger ("puts, o inimigo X de novo"), moedas temáticas (o rato passa leptospirose e tira 15% do HP) e aceitou um papel de design de inimigos, sem aprovação prévia.

## Decisão

1. **Papel de design de inimigos na pipeline.** Cada inimigo ganha uma ficha em `docs/enemies/` (modelo `_modelo.md`, seis fichas `ENEMY-01` a `ENEMY-06`): medo, fantasia, golpe de moeda temático, reação, contra-jogo, ciclo e drops. O agente de design preenche a ficha e implementa; o Orlando dá feedback depois de jogar.
2. **Golpe de moeda temático.** Os dados dos golpes de moeda ganham `fail_effect` (Fraqueza, Veneno, Lentidão, Cegueira, Maldição) e/ou `fail_disease`. Ao errar o lado, se o golpe causar dano, a consequência vale; o Veterano que Defende a anula (GDD §7 e §8). O aviso mostra a consequência antes do lance.
3. **Efeitos novos:** Cegueira (PRE -30 pontos por 3 turnos) e Maldição (dano recebido +20% por 3 turnos), valores do GDD §11.
4. **Doença como estado da Descida:** `Diseases` (Leptospirose: -15% do HP máximo); a doença pega na luta, persiste entre combates (`RunState.diseases`), reduz o HP máximo, aparece no cabeçalho do mapa, vai para o save e se trata na fogueira por 1 Brasa (o HP máximo volta). Mais doenças entram só com dados e uma linha em `Diseases.DEFS`.
5. **IA reativa:** cada inimigo tem `reactions` nos dados: `{when, value, move}`, com condições `player_hp_below`, `self_hp_below`, `player_defended_twice` e `player_buffed`. A primeira regra cuja condição vale e cujo golpe existe na fase atual troca o próximo golpe, desde que as regras de justiça permitam (golpe perigoso avisado com turno do jogador, intervalo mínimo entre golpes de moeda, nunca o mesmo golpe forte seguido, nunca o mesmo golpe duas vezes seguidas). O evento de intenção leva um código do motivo, e o aviso mostra "Viu que você está ferido" e afins. O ciclo continua valendo quando nenhuma reação dispara.
6. **Os seis inimigos:** Cidadão Infectado (Abraço Febril, Fraqueza; reação: jogador ferido), Rato Grande (Mordida Imunda, Leptospirose; reação: acuado), Corvo Carniceiro (Bicada nos Olhos, Cegueira; ciclo passa a ter 4 golpes e moeda; reação: Defender duas vezes), Cão de Peste (Presas que Não Soltam, Lentidão; reação: jogador ferido), Carrasco Apodrecido (Guilhotina, Maldição; reação: acuado) e O Coveiro (Pá, Maldição; reação: jogador fortalecido).
7. `RULES_VERSION` sobe para 13.

## Fora do escopo (fica anotado)

- **Emboscadas e inimigos mais difíceis por sorte** (ADR-0026 apontava para esta tarefa): dependem de variantes mutadas e de emboscada, que não existem no protótipo; ficam para uma tarefa própria.
- Eventos de mapa (crítico, F-011).
- Arte e som próprios por inimigo (Fase 2).

## Verificação no simulador

Regras v13, 150 Descidas por bot e 40 mapas com 40 simulações (`reports/simulation.md`, 2026-11-18). A consequência da coroa, a doença e as reações deixaram o jogo mais difícil, e o Coveiro foi aliviado em etapas:

| Coveiro | Mediano (meta 55% a 65%) | Cuidadoso | Mapas sem rota vencível | Tempo para criar a Descida |
| --- | --- | --- | --- | --- |
| 195/16 | 61,3% | 62,7% | 2 de 40 | 3,9 s |
| 185/16 | 66,0% | 65,3% | 1 de 40 | 3,6 s |
| **175/16 (adotado)** | **62,0%** | 70,7% | **0 de 40** | 1,3 s |

Mortes por moeda: 12,3% (mediano). Os bots não escolhem em que turno Defender e tratam a doença sempre que possível, então o impacto para uma pessoa pode ser maior; calibrar com o `telemetry.log` do Orlando.

## Alternativas

- **IA por árvore de comportamento completa:** mais poder, muito mais custo; regras `when/move` em dados bastam para cada inimigo ter 1 a 2 reações legíveis e testáveis.
- **Consequência da coroa decidida por sorteio:** a moeda já é o sorteio; a consequência fixa por inimigo é o que cria "esse inimigo de novo".
- **Doenças curadas só com ouro:** o GDD §11 prevê cura em dinheiro, fogueira ou item; o protótipo usa a Brasa.

## Consequências

- O Corvo Carniceiro agora usa moeda; o jogador vê mais lances de moeda nas lutas contra ele (o intervalo mínimo de 2 golpes se mantém).
- Quem joga Defender sempre fica imune à consequência da coroa por ser Veterano; outras classes (que não existem) precisarão de regra própria.
