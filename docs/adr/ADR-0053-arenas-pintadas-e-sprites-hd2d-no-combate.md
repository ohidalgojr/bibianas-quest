# ADR-0053: arenas pintadas como fundo do combate e sprites HD-2D como elenco

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-24 |
| Tarefa | TASK-066 |
| GDD | 17, 18, 19 |

## Contexto

O Orlando entregou 31 pranchas HD-2D dark góticas (`docs/design/CATALOGO-ASSETS-HD2D.md`, `ADR-0042`, `F-024`). O `ADR-0052` já decidiu que personagens e inimigos são sprites, mas o combate ainda os colocava num diorama 3D procedural (`DuelArena`) que ficava escuro e sem a qualidade das pranchas, com o sprite reduzido a 270x300 e pixelado pelo pós-processamento.

## Decisão

1. O fundo do combate é a **arena pintada `9:16`** (`arena-cidade-rua` para luta comum, `arena-cidade-praca` para elite, mini boss e chefe até existir `arena-cidade-chefe`), exibida em `TextureRect` com corte "cover".
2. Os atores (Bibiana e inimigo) ficam num `SubViewport` **transparente**, em resolução cheia, com a mesma câmera ortográfica; cada ator ganha uma sombra de contato achatada. O pós-processamento por posterização não é aplicado nesse modo (ele força alfa 1).
3. Os sprites dos inimigos olham para a esquerda e o da Bibiana para a direita (o inimigo fica à direita da tela, ela embaixo à esquerda); por isso `flip` é falso em todos, exceto no `trench_crawler`, cuja prancha antiga olha para a direita.
4. O diorama 3D procedural (`DuelArena`) continua como reserva se a textura da arena não existir.
5. A mecha colorida foi removida do código de apresentação (`F-024`); o nó atual no mapa 2D de depuração usa um realce bronze neutro.

## Alternativas

- Manter o diorama 3D e só trocar os sprites: descartado, o cenário continuaria muito abaixo das pranchas.
- Redesenhar a câmera para perspectiva real sobre o quadro pintado: descartado por ora, a câmera ortográfica fixa basta para um duelo e preserva o resto do palco (tremida, números de dano, posição do aviso).

## Consequências

Fica mais fácil trocar de cenário (é uma textura). A sombra de contato e a altura dos atores precisam ser conferidas por print a cada arena nova. Os `.glb` antigos ficam no repositório como reserva até o Orlando aprovar o visual; apagá-los é tarefa futura.
