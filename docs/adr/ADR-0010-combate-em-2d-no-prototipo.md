# ADR-0010: combate em 2D no protótipo cinza

| Campo | Valor |
| --- | --- |
| Status | Aceito (decisão técnica dentro da tarefa; uma **pergunta** para o Orlando) |
| Data | 2026-11-16 |
| Tarefa | TASK-006 |
| GDD | 6, 7, 19, 22 |

## Contexto

O GDD descreve o combate numa cena 3D. O roteiro do MVP pede jogar uma luta o quanto antes, para testar se a moeda é divertida. Modelos, câmera e animações 3D atrasariam esse teste sem mudar as regras.

## Decisão

1. **Interface 2D com formas simples.** Retângulos coloridos no lugar dos modelos, barras do Godot e textos. Tudo fica montado em código, em `CombatScreen`, sem `.tscn` desenhado à mão. Assim os agentes editam texto, e a cena 3D da Fase 2 substitui só esta camada.
2. **Controlador sem nós.** `CombatSession` (`game/presentation/combat/`) monta a luta a partir de `GameData` e traduz eventos em textos e ícones. Também guarda o que é da tela, como poções restantes e velocidade. É `RefCounted` e testável em headless. A cena só desenha o que ele entrega.
3. **Fila de eventos.** A cada ação, o `Combat` devolve os eventos novos e a cena os anima em ordem, com uma pausa curta por evento. As barras seguem os valores dos eventos (vida depois do golpe), não o estado interno. O lance da moeda tem 1,2 s (GDD §7) e mostra chance, resultado e Maré de azar. A velocidade 2x divide todas as pausas por 2. Os testes usam velocidade instantânea.
4. **Ícones de intenção em texto** (ATAQUE, FORTE, MOEDA, CURA), com cor por perigo. A fonte padrão não garante símbolos, e o texto é legível sem arte. No golpe de moeda, o ícone mostra o tipo (Pesado, Cruel, Mortal) e a chance de Cara do momento.
5. **Poções do protótipo:** 2 Poções Turvas por luta, só para a luta ser jogável. O inventário de verdade é da TASK-007.
6. **Seletor de depuração** na mesma tela: inimigo, nível e Poder da Bibiana. As teclas 1 a 6 escolhem o inimigo. Ele some quando os atalhos de depuração forem separados por build (TASK-013).

**Pergunta:** o GDD §7 diz que o jogador escolhe o lado antes do lance, mas Cara é sempre sucesso. Se a escolha for só ritual, o que aparece quando o jogador escolhe Coroa e o lance dá sucesso? Até a resposta, a tela não pede o lado e mostra "Cara (sucesso)" ou "Coroa (falha)".

## Alternativas

- **Cena 3D já no protótipo:** é o visual do jogo, mas custa dias antes do primeiro teste de sensação.
- **`.tscn` desenhado no editor:** mais fácil para ajustar visualmente, mas o diff é ilegível e os agentes erram mais ao editar.

## Consequências

- A TASK-009 e a TASK-010 seguem o mesmo padrão: um controlador sem nós e uma tela montada em código.
- O teste de sensação vale para a regra, não para o visual. Tensão de câmera e som ficam para a Fase 2.
