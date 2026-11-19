# ADR-0039: criaturas de horror, modelos do Blender e três inimigos novos

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-19 |
| Tarefa | TASK-047 |
| GDD | 3, 11, 13, 17, 18 |

## Contexto

Os kits CC0 dão cara de brinquedo aos mortos-vivos, e o Orlando pediu criaturas realmente assustadoras. O Blender 5.3 instalado roda sem janela por script (`tools/blender/`), o que permite modelar em baixo polígono com silhueta própria.

## Decisão

1. **Modelos feitos no Blender, sem kit,** para o Sineiro Penado (fantasma encapuzado, mandíbula caída, mãos longas, sino), a Ossada Errante (esqueleto de quatro braços com órbitas acesas), a Sanguessuga de Beco (curvada, boca de dentes, garras no chão), o Carcereiro do Sino (gigante de cabeça de sino, jaula nas costas), o Coveiro (magro e alto, capuz vazio com olhos verdes, pá e caixão nas costas) e três criaturas novas. Olhos emissivos, proporções erradas e membros demais. Script: `tools/blender/make_horrors.py`, helpers comuns em `tools/blender/kit.py`.
2. **Três inimigos novos** (fichas ENEMY-12 a 14), todos com golpe de moeda temático e reação:
   - **Enforcado** (`hanged_man`, comum): Capuz na Cabeça (coroa causa Cegueira); salta quando a Bibiana está ferida.
   - **Costurado** (`stitched_horror`, comum, 60 HP, lento): Braço Remendado (coroa causa Lentidão); costuras cedem abaixo de 50% de vida.
   - **Mãe das Ratazanas** (`rat_mother`, **elite**): Mordida do Enxame (golpe cruel, coroa causa Leptospirose), Guincho da Peste (Veneno 60%).
3. O pool do cenário 1 passa a 10 comuns e 2 elites; `RULES_VERSION` sobe para 19.
4. Os modelos de kit de personagem da Kenney (fantasma, esqueleto, vampiro, keeper) saem do `ModelRegistry`; os kits continuam em uso para cenário.

## Alternativas

- **Comprar ou gerar por IA:** o GDD reserva para o portão da Fase 2.
- **Mais inimigos com mecânica nova (invocar, curar a si):** exige regra de núcleo; fica para a TASK-045.

## Consequências

- Equilíbrio não foi rodado no simulador (diretriz de 2026-11-18): números na faixa dos existentes; calibração na TASK-032.
- Os modelos ainda não têm esqueleto: respiração procedural e os movimentos do palco.
- Silhuetas e olhos dependem do contorno e da luz para dar medo; o Orlando avalia nos prints e no jogo.
