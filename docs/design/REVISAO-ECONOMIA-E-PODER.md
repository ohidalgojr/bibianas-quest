# Revisão do bloco Economia e Poder (próximo bloco da revisão de game design)

Base: `docs/design/critica-diretor/CRITICA-GAME-DESIGN-MOBILE.md` (itens 5, 7, 8, 12, 16) e medições reais no código em 2026-11-27 (`RunRules`, `RunState.item_price`, `SanctuaryRules`). Nada aqui muda regra: é proposta para decisão.

## 1. O que medi (Cidade Abandonada, 4 camadas, níveis 1 a 6)

| Camada | Nível | Poder comum | Poder elite | Poder mini boss | Poder chefe |
| --- | --- | --- | --- | --- | --- |
| 1 | 1 | +0,40 | +0,60 | +1,00 | +1,60 |
| 2 | 2 | +0,80 | +1,20 | +2,00 | +3,20 |
| 3 | 4 | +1,60 | +2,40 | +4,00 | +6,40 |
| 4 | 5 | +2,00 | +3,00 | +5,00 | +8,00 |

- **Ouro médio por luta (nível 3):** comum 29, elite 44, mini boss 74, chefe 119. **Ouro da luta de nível 1:** 8 a 12.
- **Preços:** consumíveis 20 a 60 (Pão Mofado 20, Éter 25, Poção 30), equipamento comum 80 a 190, raros 320 a 380, Galho Seco 120.
- **Atributos por Poder (Guerreiro):** Poder 1 = HP 130 / FOR 14 / DEF 12; Poder 5 = 182 / 18 / 15; Poder 12 = 273 / 26 / 20; Poder 16 = 325 / 31 / 23. Ou seja, cerca de +13 HP por ponto de Poder no começo.
- **Ecos:** 1 por nó e 5 por chefe; o Santuário tem 4 itens (12, 16, 15 e 18 Ecos = 61).

## 2. Diagnóstico: onde concordo e onde discordo do designer

1. **"O Poder é muito desigual" (item 8): concordo só em parte.** Comparar "luta Nv 1 +0,4" com "elite Nv 6 +3,6" mistura nível com tipo. No **mesmo nível** a elite dá 1,5 vez a luta comum (+3,0 contra +2,0 na camada 4); o grosso da diferença vem do **nível crescer pelas camadas**, que é a progressão pretendida (a luta comum da camada 4 dá 5 vezes a da camada 1). O que é real: quem pula a elite perde cerca de +3 de Poder (cerca de +40 HP), um efeito moderado, não decisivo. **Recomendo não mexer na fórmula do GDD §9 agora.** O Poder do chefe (+8 a +9,6) só importa com cenário 2 em diante, pois a Descida de um cenário acaba nele.
2. **O que falta é informação, não fórmula (item 7).** O jogador não vê o que ganha: a pílula "ouro" repete em toda luta e "Nv" não diz o perigo. Mostrar **o Poder que a luta dá** (`RunRules.power_gain`, leitura pura) e a **diferença entre o nível do inimigo e o seu** resolve a decisão da elite sem mudar regra.
3. **A primeira loja é inútil (item 12): concordo.** Ouro de 8 a 12 contra o item mais barato de 20: a tela só atrapalha. Solução sem regra: pular a loja quando não há o que comprar nem vender (ouro menor que o menor preço e nenhum drop).
4. **Economia depois disso está saudável.** Uma Descida acumula 150 a 230 de ouro: um ou dois itens comuns ou uma poção cara, com decisão real. Não vejo motivo para mexer em ouro ou preços sem playtest.
5. **Meta (item 16): concordo, é o maior risco de retenção.** 61 Ecos acabam em 6 a 8 Descidas (10 a 20 Ecos por vitória). Subir a taxa de Ecos seria **[ADR]** e só aceleraria o fim; o certo é **mais conteúdo**: catálogo de 10 itens (3 por ala), preços de 12 a 40, dentro do teto de +10% do GDD §9.

## 3. Plano proposto (3 tarefas pequenas)

| Tarefa | O que faz | Regra do GDD? | Risco |
| --- | --- | --- | --- |
| **A. Informação do mapa e loja** | Pílula com **Poder previsto** (ícone) e **perigo relativo** (inimigo mais fraco, par ou mais forte que você); pular a loja inútil; cartões de loja de 2 colunas com ícone e preço dourado, sem "Atualizar" apagado | Não | Baixo |
| **B. Ouro da 1ª Descida** (opcional) | Se a pílula e a loja não bastarem: 1ª Descida com ouro da camada 1 ×2 (garante 20) | **Sim, ADR, `RULES_VERSION` 25** | Médio: muda sementes e equilíbrio sem simulador |
| **C. Santuário com 10 itens** | 6 melhorias novas, 3 por ala, dentro do teto de +10%; custos 12 a 40 | Só se alterar fórmula; o catálogo é conteúdo (ADR de conteúdo) | Médio: cada efeito precisa de teste |

Minha recomendação: **A agora** (sem ADR), **C em seguida** (retenção), **B só se o playtest humano pedir**.

## 4. Decisões que preciso de você

1. Aprova **A** (informação sem regra)? Sim ou não.
2. Para **C**, quer que eu proponha a lista dos 6 itens novos (nomes, efeito, custo, tudo dentro do teto) para você aprovar antes de implementar?
3. **Cara/Coroa sem decisão (item 9):** manter como ritual do GDD §7 (e só encurtar o giro para 1,6 s), ou abrir a conversa de "Aposta" (muda regra)?
4. **Poder:** concorda em **não** mudar a fórmula e apenas mostrá-la?

## 5. Não verifiquei

Efeito no equilíbrio de qualquer mudança (simulador suspenso, CLAUDE.md regra 9); o comportamento de jogadores humanos; Poder em cenário 2 em diante (não existe).
