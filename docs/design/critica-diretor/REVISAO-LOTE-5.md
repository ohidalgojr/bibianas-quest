# Revisão de arte: TASK-077 (lote 5)

Revisor: diretor de arte (agente). Commit 1b876fb. Prints de mapa: passos 0, 2, 3, 4, 5, sementes 1, 3, 7, 9, renderizados por mim (lavapipe, 540x960). "Antes" é o commit e262b27, mesmas sementes.

## Notas do tabuleiro (0 a 10)

| | Antes (e262b27) | Depois (1b876fb) |
| --- | --- | --- |
| Tabuleiro 3D | 6,0 | 7,5 |

- Antes: casas e muros eram superfícies lisas chapadas, com o mesmo tom azul-lilás. Parecia maquete de papelão sob chuva.
- Depois: os telhados de ardósia, as casas com madeira aparente e os muros de arrimo dão material, escala e luz de borda. Combina com Bloodborne e Tactics Ogre. O corte do telhado tem leitura de sombra, e a casa com madeira (semente 7, passo 3) parece construída.
- A silhueta do inimigo continua legível em cima do piso (ghoul, ogro, cão). O contraste caiu pouco.

## O que melhorou

- Telhado: escala boa, com lajes legíveis a distância de celular. Foi o maior ganho do lote.
- Casas: o enxaimel (madeira escura sobre reboco) dá "cidade gótica".
- Pátio de entulho: quebra a monotonia do piso e é coerente com o cenário ao fundo.
- Os 3 sprites de monstro e o de cavaleiro estão no nível dos anteriores: pixel-art limpa, recorte sem halo, paleta do cânone, sem mecha colorida.
- As 6 ilustrações de evento (1024x571) têm paleta e luz de lanterna consistentes entre si e com os fundos de combate. Não há texto nem marca-d'água. A forca de 3 cordas, o sino rachado e a fonte são os melhores.

## O que ainda quebra a vibe

1. Repetição de textura. Nos muros longos e no piso de arrimo, o padrão de espelho 2x2 aparece como quadrados de grade (semente 3, topo, e piso de pátio). Dá para ver a repetição a olho nu a cada tile.
2. Os muretes baixos lilás (`TINT_WALL` e peças de barreira) continuam chapados, azul-lavanda e lisos, com brilho "plástico". Estão no meio de telhados texturizados e destoam (semente 1, passo 2, esquerda e baixo). Têm maior saturação que o resto da cena.
3. Ruído de alta frequência no piso de pátio ao lado de cobblestone. A área fica "suja" e disputa atenção com os nós e rótulos.
4. Os rótulos laranja, as tiras de lanterna e os decalques de porta (retângulos laranja) estão desproporcionais: parecem placas coladas na parede, não portas. A porta aparece como pílula laranja em todas as casas.
5. Os telhados de ardósia ficam mais claros e mais azuis que as paredes. Ao longe, a casa vira "caixa com chapéu azul". Dá para escurecer e dessaturar.
6. `crowned_pursuer` é quase preto sobre piso escuro. Sem luz de borda, a silhueta se perde (ver sprite).
7. Props sem lógica: lápides do cemitério em cluster claro azul-cinza (sementes 3 e 9) espalhadas no pátio de casas. Elas pareciam ser parte do nó de evento, mas a lápide não é diferenciada do cemitério decorativo.

## Verificações que não consegui fazer

- Preview de combate só aceita ids de `game/data`. `lipless_choir`, `calcified_knight` e `crowned_pursuer` não têm dados (a tarefa avisa), então o preview abre o menu de debug em vez da luta. Só avaliei esses três pelo PNG do sprite.
- `trench_crawler` abre no combate e funciona: olha para a esquerda, em direção à Bibiana. Boa leitura, caixão e pernas longas.
- Nas 7 capturas de mapa não achei um nó de evento visível com poço, forca ou lápide. Não posso afirmar que o prop alterna certo, nem como fica em escala. A forca visível (semente 9, passo 5) é do fundo pintado.
- Não abri a tela de evento no jogo. Avaliei só os JPG.

## Prioridades

**P0 (nenhum bloqueio de crash, mas dois de visual)**
- Nenhum.

**P1**
- Quebrar a repetição: aumentar o tamanho do tile ou rodar a UV por peça (offset por instância). `scenario_renderer.gd`, `_piece_texture`: `scale_f` de `TINT_WALL` (0,36) e `TINT_COURT_TILE` (0,26). Reduzir para 0,2 a 0,22 e variar o offset por chunk.
- Texturizar ou escurecer os muretes lilás: dessaturar `TINT_WALL` e `TINT_BARRIER` (o nome da constante é provável) e dar `roughness` alto.
- Mostrar um print real de nó de evento (poço, forca, lápide) em `docs/tasks/prints/`. O print atual (`TASK-077-mapa.png`) não prova o aceite.

**P2**
- Dessaturar e escurecer telhado: `paint` de `TINT_HOUSE_ROOF` de `Color(0.78, 0.8, 0.88)` para algo perto de `Color(0.62, 0.65, 0.72)`.
- Porta laranja: reduzir saturação/tamanho do decalque de porta (`make_sprite.py` / peças de cenário).
- `crowned_pursuer`: luz de borda fria no sprite, ou `modulate` mais claro no combate.
- Lápide de evento: variar a silhueta em relação às lápides decorativas, ou dar uma luz.
- Registrar os dados dos três inimigos novos para o preview funcionar antes da próxima tarefa.

## Aprova para publicação?

SIM, com ressalvas. O lote melhora claramente o tabuleiro, sem regressão. Os assets seguem o cânone gótico e não há mecha colorida. O que falta (repetição, muretes lilás, print do nó de evento) é polimento P1/P2, não bloqueio. Condição: antes de fechar a TASK-077, anexar o print do nó de evento (poço, forca, lápide) e de uma luta real com um dos inimigos novos, quando houver dados.

## Resumo

1. Tabuleiro sobe de 6,0 para 7,5. Ardósia e enxaimel são o ganho principal.
2. Sprites novos estão no cânone. `crowned_pursuer` precisa de luz de borda.
3. As 6 ilustrações de evento são coerentes e boas.
4. Repetição visível da textura nos muros e pátios (P1).
5. Muretes lilás lisos destoam dos telhados texturizados (P1).
6. Telhado azul claro demais; porta laranja grande demais (P2).
7. Não consegui ver poço, forca e lápide em nó de evento nas capturas (P1: print).
8. Preview de combate não roda ids sem dados (`lipless_choir`, `calcified_knight`, `crowned_pursuer`).
9. Aprovo para publicação, com o print do nó de evento como condição de fechamento.
