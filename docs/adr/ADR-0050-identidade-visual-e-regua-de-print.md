# ADR-0050: identidade visual (foco quente único, escala de pesadelo) e régua de aprovação por print

| Campo | Valor |
| --- | --- |
| Status | Aceito (Orlando, 2026-11-22: "foque totalmente em trazer uma identidade visual única"; direção de arte em `docs/design/IDENTIDADE-VISUAL.md`) |
| Data | 2026-11-22 |
| Tarefa | TASK-061 (e as seguintes de arte) |
| GDD | 18, 19 |

## Contexto

Meses de feedback e de ADRs de arte (0036, 0041, 0042) não chegaram ao jogo: a câmera mostrava um tabuleiro distante, o inimigo ocupava 3% a 8% do palco, o piso claro e lilás dominava a imagem e os modelos eram aprovados por render do Blender, não pelo que o jogador vê. O diretor de arte (revisão independente) apontou que a lista de seis referências era um moodboard, não uma regra que o código obedeça.

## Decisão

1. **Gancho:** "uma moeda de luz âmbar numa catedral de pedra morta": tudo frio e quase preto, exceto o que a Bibiana ilumina e o que quer matá-la; uma fonte quente dominante por tela; o inimigo é sempre maior que a luz.
2. **Paleta fechada de 8 cores** e regras de luz em `IDENTIDADE-VISUAL.md` §B; cor de kit é sempre multiplicada pela paleta, nunca usada crua.
3. **Câmera de duelo:** `CAM_SIZE` 3,9, inclinação de cerca de 24 graus; inimigo normalizado por altura de pé (2,5 comum, 3,0 elite, 3,6 chefe) e Bibiana a 1,45, no canto inferior esquerdo.
4. **Arena composta** (`DuelArena`): canto de nave com as peças modulares do Kenney, piso escuro com poças, prop narrativo por tipo de luta e portão âmbar ao fundo; substitui o diorama procedural no combate.
5. **UI:** a faixa cinza "ATAQUE Ataque" vira um cartão escuro compacto com borda de ameaça.
6. **Processo:** nenhum asset novo é aprovado por render do Blender. Vale o print 540×960 do jogo contra o checklist de 12 itens (§E), revisado por um agente de direção de arte; a modelagem é feita por kitbash sobre os kits CC0 de que o Orlando gosta.

## Consequências

Os modelos antigos feitos à mão precisam ser refeitos (remodelagem em lotes) e o mapa e os dioramas (fogueira, loja) seguem a mesma régua nas tarefas seguintes. Sem mudança de regra do GDD nem de `RULES_VERSION`.
