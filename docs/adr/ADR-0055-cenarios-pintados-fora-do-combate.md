# ADR-0055: cenários pintados nas telas fora do combate e seleção de nó legível

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-24 |
| Tarefa | TASK-068 |
| GDD | 17, 18, 19 |

## Contexto

O Orlando jogou o build e reprovou loja, recompensa, vitória e fogueira: objetos 3D soltos (moeda, poção, boneco do mercador) sobre um losango. Também reclamou que, ao tocar num destino do mapa, a câmera não foca nele nem mostra o caminho.

## Decisão

1. `Scene3DBackdrop` passa a montar cada tipo de cenário como arena pintada (`assets/bibiana/arenas/`) com sprites HD-2D (Bibiana, mercador, baú, lápide), sombra de contato e luz aditiva; o diorama 3D só é usado se a textura não existir.
2. Os ganhos de recompensa ficam no painel (texto e ícones), não mais como objetos soltos na cena.
3. No `PaintedMapScreen`, o primeiro toque num destino sobe o nó para a metade de cima, mostra uma seta pulsante acima do sprite e acende a estrada até ele.
4. A fogueira apagada escurece a arena acesa até existir `arena-fogueira-apagada`.

## Alternativas

- Reajustar o diorama 3D: descartado, a base procedural é o que estava reprovado.

## Consequências

Mesma linguagem visual do combate e do mapa. Falta arte própria da fogueira apagada e do chefe. Ícones e UI seguem o guia de arte.
