# Estudo: quando as classes do GDD entram no jogo

| Campo | Valor |
| --- | --- |
| Status | Proposto (aguardando decisão do Orlando; recomendação na seção 4) |
| Escrito em | 2026-11-19 |
| Origem | Pedido do Orlando: "avaliar quando serão introduzidas as variedades de classe do GDD" |
| GDD | 8, 9, 22, 23 |

## 1. Onde estamos

- O GDD §8 define **quatro classes**: Clérigo e Guerreiro (seguras), Mago e Ladino (arriscam mais). O §22 já distribui: **Fase 1** com 1 classe (Guerreiro), **Fase 2** (vertical slice) com **2 classes**, **Fase 3** (Alpha) com as **4**.
- Hoje só existe o **Guerreiro** (Bibiana). O núcleo trata a classe como dado (`game/data/classes.json`, `RunState` recebe o id da classe), mas várias regras assumem o Guerreiro: o Veterano que Defende (ADR-0008, ADR-0030), as 3 skills de combate iniciais, os 3 itens de loja e as 2 skills de fogueira.
- O MVP visual (TASK-035 a 044) ainda não passou pelo teste do Orlando. O laço de jogo é apontado como **enjoativo** (TASK-045).

## 2. O que cada classe exige

| Classe | O que muda na regra | Custo no núcleo | Custo de arte | Risco |
| --- | --- | --- | --- | --- |
| **Clérigo** | Re-jogada da moeda (1 por combate, Providência), dano sagrado (MEN), cura, Purgar, fogueira com cura de doença | Médio: reaproveita Moeda da Sorte; dano por MEN e dano sagrado contra mortos-vivos e doentes; Purgar (imunidade) é regra nova | Modelo e animações (KayKit tem Mage e Knight; clérigo precisa de ajuste) | Baixo: classe segura, fácil de calibrar |
| **Mago** | Dano por MEN, clima altera dano (Raio na chuva), vida baixa, Corrosão (debuff de DEF e RES) | **Alto**: clima passa a ter efeito em combate (hoje só visual); elemento por skill; DEF e RES como alvo de debuff | Modelo (KayKit Mage pronto), efeitos de feitiço | **Alto**: depende do sistema de clima do §14 |
| **Ladino** | Furto (moeda rouba item), crítico até 2,5, esquiva automática no 1º golpe de moeda, fuga +25%, Sangramento (novo efeito) | **Alto**: furto mexe em drops e na moeda; sangramento é efeito novo; esquiva automática mexe na regra de justiça | Modelo (KayKit Rogue pronto) | **Alto**: o furto interage com a Moeda da Sorte e a justiça |

## 3. O que bloqueia a entrada de classes

1. **Falta validar o laço com uma classe só.** Se o jogo é enjoativo com o Guerreiro, mais classes dilatam o problema e custam calibração em dobro.
2. **O simulador e o balanceamento estão suspensos** (diretriz de 2026-11-18). Cada classe nova pede bot próprio e meta de vitória (GDD §23), então a calibração precisa voltar antes.
3. **Regras amarradas ao Guerreiro** (Veterano, skills, itens). Antes da segunda classe é preciso separar "o que é da classe" de "o que é do jogo".
4. **Sistemas que o GDD associa a classes e ainda não existem:** clima com efeito, Sangramento, Pavor, roubo.

## 4. Recomendação

Ordem e gatilhos:

1. **Agora até o portão da Fase 1:** só o Guerreiro. Fechar a TASK-040 (MVP com visual) e a TASK-045 (ritmo e variedade), e calibrar (TASK-032).
2. **Primeira classe nova: o Clérigo** (Fase 2, depois do portão). É a mais barata (reaproveita Moeda da Sorte e cura), a mais segura de calibrar e contrasta com o Guerreiro ("vence por sobrevivência"). Gatilho: o portão da Fase 1 aprovado e a TASK-045 resolvida.
3. **Segunda classe: o Ladino ou o Mago**, ainda na Fase 2 se o orçamento deixar, senão no começo da Fase 3. Recomendo o **Ladino** primeiro: o furto reforça a aposta central (a moeda) e é a classe que o jogador veterano quer. O Mago depende do clima com efeito (§14), então fica por último.
4. **Preparação que dá para fazer antes, sem classe nova:**
   - Separar o que é de classe (Veterano, skills iniciais, itens de loja, skills de fogueira) em dados por classe (`classes.json`), tirando as exceções do código.
   - Tela de seleção de classe já no menu (hoje fixa no Guerreiro), com as outras três bloqueadas ("Em breve") e silhuetas 3D dos modelos KayKit que já temos (Knight, Mage, Rogue, Barbarian).
   - Clima com efeito como tarefa própria (precondição do Mago).
5. **Cada classe nova é uma tarefa com ADR, ficha de skills, bot no simulador e meta de vitória** (GDD §23), e só entra depois de a anterior estar calibrada.

## 5. Decisões que dependem do Orlando

1. Ordem das classes: Clérigo, Ladino, Mago (recomendada) ou outra.
2. A tela de seleção de classe com as outras bloqueadas entra já (vitrine do que vem) ou só com a segunda classe?
3. Prefere que a segunda classe entre **antes do portão da Fase 1** (arriscado: dilata a calibração) ou **depois** (recomendado)?

Até a decisão, nada muda no código. A tarefa de preparação (separar regras por classe) fica registrada na TASK-049.
