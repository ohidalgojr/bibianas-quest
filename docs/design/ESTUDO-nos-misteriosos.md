# Estudo de gameplay: armadilhas como nós e o nó misterioso

| Campo | Valor |
| --- | --- |
| Status | Proposto (aguardando decisão do Orlando; recomendação na seção 5) |
| Escrito em | 2026-11-19 |
| Origem | Feedback do Orlando ao ver o mapa 3D: "ninguém escolhe cair numa armadilha de bom grado" |
| GDD | 5, 7, 11, 13, 15 |
| Tarefa que implementa | TASK-041 |

## 1. O problema

Hoje a **Emboscada** é um destino que o jogador **escolhe de olhos abertos**. O GDD §5 diz que ela aparece avisada no mapa ("Emboscada (age 1º)"): o inimigo começa com Carga cheia e a Bibiana com a Guarda aberta por 1 turno. No código, cerca de 18% das batalhas comuns viram emboscada (e a Maré de azar sobe para 35%).

O que isso causa:

1. **Não é escolha.** Entre "Luta" e "Emboscada (age 1º)", a emboscada é a mesma luta com uma penalidade. Ninguém a escolhe, a não ser que os três destinos sejam ruins. Aí ela pune sem dar escolha.
2. **Nó virou "o ruim".** O jogador aprende a lê-lo como "fuja disso". A tensão que a emboscada deveria criar (surpresa) some, porque a surpresa foi avisada com antecedência.
3. **O mapa perde interesse.** Dos três destinos, um é sempre um castigo conhecido. Isso estreita a decisão, em vez de ampliá-la.
4. **Vai contra a névoa.** O GDD §5 quer destinos legíveis e o que vem depois ofuscado. A emboscada é o único nó cuja informação *deveria* ficar oculta, e é justamente o que mostramos.

Princípio de design: **uma escolha só é interessante quando tem custo e ganho, e o jogador não sabe tudo.** Um nó ruim e conhecido não é escolha; um nó incerto, com ganho possível, é.

## 2. O que outros jogos fazem

| Jogo | Mecânica | Lição |
| --- | --- | --- |
| Slay the Spire | Sala "?": pode ser evento, luta, tesouro ou loja, com probabilidades que se ajustam conforme o que saiu antes | O mistério é um **destino escolhido de propósito**, com valor esperado bom e variância |
| Darkest Dungeon | "Curios": objetos que o jogador decide interagir, com risco e ganho possíveis | O risco é **opcional e visível como risco**, o resultado não |
| Dark Souls | Baús mímicos | A surpresa funciona porque o baú **parece igual** a um baú; dá para desconfiar por pistas |
| Hades | A porta mostra o ícone da recompensa e o jogador escolhe pela recompensa | Informação **parcial e boa** (o ganho) guia a decisão; o perigo vem junto |
| Fear & Hunger | Itens e salas sem garantia, perigo sem aviso explícito | O medo vem de **não saber**, mas o jogo precisa ser justo (aqui: toda morte tem aviso, GDD §7) |

## 3. Opções

**A. Tirar a Emboscada como destino.** Ela vira um modificador oculto de qualquer luta, descoberto ao entrar. Simples, resolve o ponto 1, mas perde o aviso de uma tela exigido pelo GDD §7 se não for tratado.

**B. Nó misterioso "?".** Um destino com tipo desconhecido que se resolve **ao entrar**, sorteado por pesos: evento, **mímico** (luta emboscada com recompensa de baú), tesouro, mercador errante, fogueira abandonada. Tem valor esperado igual ou maior que uma luta comum, para valer o risco.

**C. Baú mímico.** Entre os nós "Baú" visíveis, uma pequena chance de ser um mímico. Funciona se houver **pista detectável**; sem pista, é injusto.

**D. Atalho com armadilha consciente.** Um destino que **mostra** o risco ("Passagem estreita: -X HP, pula 1 camada"). O jogador escolhe a armadilha de propósito porque troca vida por tempo, ouro ou posição. É a única forma de "armadilha visível" que faz sentido.

**E. Pistas.** Ícones e sons ambíguos no mapa (um rato que foge, mancha de sangue, brilho metálico) e o Códice do Santuário revelando mais pistas conforme o jogador aprende. Dá valor ao conhecimento do jogador, não só ao acaso.

## 4. Análise

| Critério | A | B | C | D | E |
| --- | --- | --- | --- | --- | --- |
| Resolve "ninguém escolhe de bom grado" | sim | **sim** | em parte | sim (outro tipo de armadilha) | só com B ou C |
| Mantém a surpresa | sim | **sim** | sim | não, é consciente | reforça |
| Respeita o GDD §7 (aviso, justiça) | precisa de aviso de uma tela | sim, com o aviso na entrada | precisa de pista | sim | sim |
| Custo de implementação | baixo | **médio** | baixo | médio | médio |
| Ajuda a mostrar a névoa do mapa 3D | pouco | **muito** (o "?" é a cara da névoa) | pouco | pouco | muito |
| Risco de ficar frustrante | médio | baixo, se o valor esperado compensar | alto sem pista | baixo | baixo |

## 5. Recomendação

**B + C + E, e remover a Emboscada visível (A); D fica como ideia para depois.**

1. **O nó "?" substitui a Emboscada e o nó "Evento" como destinos separados.** No mapa, o jogador vê "?" com uma bolha de pista, nunca o tipo. Isso casa com a névoa e com as bolhas do tabuleiro 3D.
2. **Resolução ao entrar** (pesos iniciais, a calibrar): evento 40%, mímico 25%, tesouro 15%, mercador errante 10%, fogueira abandonada 10%. SORTE desloca peso do mímico para tesouro e mercador; a Maré de azar faz o contrário (hoje ela já aumenta a emboscada em 35%).
3. **Mímico é uma luta emboscada** (mesmas regras de hoje: o inimigo age primeiro, sem golpe de moeda sem aviso e sem morte instantânea acima de 60% de vida) **com recompensa de baú garantida** e chance de Moeda da Sorte. A surpresa é compensada. O aviso de uma tela do GDD §7 ("o baú se mexe") vira a animação de entrada.
4. **Pistas (E):** a bolha do "?" mostra 0 a 2 ícones de pista (gota de sangue = luta, brilho = tesouro, sino = evento), reveladas pela SORTE ou pela Lanterna do Viajante (que já revela 1 nó na névoa, GDD §15). O Códice ensina pistas novas depois de o jogador ver cada resultado.
5. **Baú mímico (C):** só com pista visível (baú com marca de mordida ou brilho estranho), nunca sem sinal.
6. **Equilíbrio:** o valor esperado do "?" tem de ser maior que o de uma luta comum de mesmo nível, senão volta o problema de ser sempre o nó ruim. O simulador mede isso (bots tratam o "?" por valor esperado).

## 6. Impactos

- **GDD:** §5 (tabela de nós e frequências), §7 (aviso), §11/§13 (mímico como inimigo ou como variante), §15 (Lanterna).
- **Regras:** `RULES_VERSION` incrementado; `MapNode.Kind` ganha `MYSTERY`; a Emboscada deixa de ser um tipo de nó sorteado pelo gerador do mapa; `Winnability` e os bots passam a tratar o "?".
- **Dados:** resultados do "?" em `game/data/` (pesos e pistas); ficha do mímico em `docs/enemies/`.
- **Apresentação:** a praça do "?" no tabuleiro 3D leva um prop de mistério (baú fechado, névoa de pergunta) e o resultado aparece só ao entrar.

## 7. Decisões que dependem do Orlando

1. **Unificar Evento e Emboscada no "?"** (recomendado) ou manter o Evento como destino visível?
2. **Mímico como inimigo próprio** (nova ficha, modelo próprio) ou como **variante do inimigo comum** (mais barato, usa os modelos que já temos)?
3. **Quer o atalho com armadilha consciente (D)** como nó, já nesta rodada ou depois?
4. **Pesos iniciais** da seção 5 estão bons para começar?

Até a decisão, a Emboscada continua como está (nada muda no núcleo). A TASK-041 já está escrita com as respostas recomendadas e só começa depois da TASK-040, a menos que o Orlando antecipe.
