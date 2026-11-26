# ADR-0057: o mapa é o tabuleiro isométrico (volta do `Map3DScreen`), com pedra pintada e horizonte gótico

| Campo | Valor |
| --- | --- |
| Status | Aceito (substitui o item 1 do ADR-0054) |
| Data | 2026-11-26 |
| Tarefa | TASK-070 |
| GDD | 5, 17, 18 |

## Contexto

O ADR-0054 trocou o mapa por uma tela pintada rolável vertical, seguindo a crítica do diretor de arte sem conferir o GDD. O GDD §17 manda o contrário: "O tabuleiro é o mapa: os nós são locais no cenário e a Bibiana caminha pelas estradas entre eles", em terraços isométricos como Final Fantasy Tactics. O Orlando reprovou a troca e mostrou a versão de navegador dele como a intenção correta.

## Decisão

1. O mapa da Descida é o tabuleiro isométrico em terraços (`Map3DScreen`, `ScenarioRenderer`, ADR-0041). `PaintedMapScreen` foi removido.
2. A fidelidade visual vem de: textura de pedra pintada em triplanar de mundo nas peças do terreno, resolução cheia (sem miniatura 2x nem posterização), luz mais alta e fria, névoa azul-ardósia, horizonte gótico pintado atrás do tabuleiro, losangos de luz nos destinos (estilo tática) e sprites HD-2D de atores e props em pé nas praças.
3. Seleção de destino: câmera desliza ao nó, seta pulsante e trilha de losangos até ele.
4. As arenas pintadas continuam valendo para o combate, a loja, a fogueira e as outras telas de painel (ADR-0053, ADR-0055), que não são o tabuleiro. O GDD §17 prevê fundo 3D menor no combate; o uso de arena pintada ali é um desvio assumido, a confirmar com o Orlando.

## Alternativas

- Manter o mapa pintado: descartado, contraria o GDD e a decisão do Orlando.

## Consequências

O tabuleiro depende de peças Kenney com textura de pedra por cima; a evolução natural é trocar paredes, escadas e telhados por peças próprias. Falta arte de primeiro plano e discos de nó pintados.
