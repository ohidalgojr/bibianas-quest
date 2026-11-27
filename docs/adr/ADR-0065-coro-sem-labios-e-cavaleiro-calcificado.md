# ADR-0065: Coro Sem Lábios e Cavaleiro Calcificado entram na Cidade Abandonada

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-27 |
| Tarefa | TASK-079 |
| GDD | 6, 7, 11, 17, 21 |

## Contexto

Os sprites de `lipless_choir` e `calcified_knight` já existem (estudo TASK-051, lote 5 do Gemini). Faltavam ficha, dados e entrada no cenário. Adicionar inimigos ao sorteio do cenário muda as sementes dos mapas.

## Decisão

1. Dois inimigos comuns novos, com ficha (`ENEMY-18` e `ENEMY-19`): Coro Sem Lábios (HP 44, RES 8, golpe de moeda Hino Mudo com Fraqueza, reage a quem se fortalece) e Cavaleiro Calcificado (HP 70, DEF 10, VEL 4, golpe de moeda Investida Calcificada com Lentidão, reage a quem defende duas vezes).
2. Ambos entram na lista de inimigos comuns do cenário 1 e na ordem do Códice, com mutações temáticas Fantasma e Inchado.
3. Os ciclos respeitam a regra de justiça: golpe perigoso avisado, três golpes sem moeda entre golpes de moeda, nenhum Golpe Mortal.
4. `RULES_VERSION` sobe para 22 (o sorteio de inimigos muda as sementes). Nenhuma fórmula do GDD muda.

## Alternativas

- Elite para o Cavaleiro Calcificado: descartado por ora, o cenário 1 já tem dois elites e a escalada do primeiro mapa curto não pede um terceiro.

## Consequências

Mais variedade na primeira Descida. A calibração fina (HP e DEF do Cavaleiro) fica para depois do playtest do Orlando; o simulador está suspenso até o MVP (CLAUDE.md regra 9).
