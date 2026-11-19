# ADR-0038: quatro inimigos comuns novos no cenário 1 e modelos próprios

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-19 |
| Tarefa | TASK-044 |
| GDD | 11, 17, 18 |

## Contexto

O Orlando apontou falta de variedade: o cenário 1 tinha só 4 inimigos comuns, e rato, cão, corvo e Carrasco usavam modelos substitutos de outros kits. A regra de justiça (GDD §7, ADR-0020, ADR-0030) vale para todo inimigo.

## Decisão

1. **Quatro inimigos comuns novos**, cada um com ficha em `docs/enemies/` (ENEMY-08 a 11), golpe de moeda temático e reação em dados:
   - **Sineiro Penado** (`bell_ghost`, fantasma, ESQ 16): Lamento do Sino, coroa causa Maldição; reage a buff.
   - **Ossada Errante** (`wandering_bones`, DEF 7, lenta): Chacoalhar de Ossos, coroa causa Fraqueza; reage abaixo de 30% de vida.
   - **Lodo de Esgoto** (`sewer_slime`, 52 HP, VEL 4): Respingo Ácido (debuff de Veneno, 55%) e Engolir (coroa causa Lentidão); reage a guarda repetida.
   - **Sanguessuga de Beco** (`alley_leech`, VEL 9): Beijo de Sangue, coroa causa Veneno; salta quando a Bibiana está ferida.
   Todos usam só golpes e efeitos que o validador já aceita; ciclo de 4 golpes com 1 golpe de moeda e golpe forte avisado.
2. **O pool do cenário 1 passa de 4 para 8 comuns** (`scenarios.json`). Muda a atribuição de inimigos por semente, então `RULES_VERSION` sobe para 18.
3. **Modelos próprios** no Blender, por script (`tools/blender/make_enemies.py`, CC0): Rato Grande, Cão de Peste, Corvo Carniceiro e Carrasco Apodrecido, em baixo polígono e cores chapadas. Sem animação de esqueleto: idle por respiração procedural; ataque, dano e morte pelas animações do palco (`Combat3DStage`). Os novos reaproveitam kits CC0 (fantasma, esqueleto, vampiro da Kenney e lodo do Quaternius, estes com animações).
4. **Escala do palco por tamanho do modelo:** o inimigo é escalado pela maior dimensão, e quadrúpedes giram para o perfil.

## Alternativas

- **Inimigos com mecânica nova (curar a si, invocar, reflexo):** exige regra de núcleo e simulador; fica para uma tarefa própria (TASK-045, estudo de ritmo).
- **Esperar um artista:** o GDD reserva isso ao portão da Fase 2.

## Consequências

- **Equilíbrio não foi rodado no simulador** (diretriz de 2026-11-18): os números seguem a faixa dos comuns existentes; a calibração é a TASK-032.
- Os kits CC0 deixam o fantasma, o esqueleto e o vampiro com cara de brinquedo; modelos feitos no Blender para eles entram depois.
- O rato, o cão, o corvo e o Carrasco ainda não têm animação de esqueleto.
