# ADR-0052: personagens e inimigos como sprites 2D (HD-2D) sobre o diorama

| Campo | Valor |
| --- | --- |
| Status | Aceito (Orlando escolheu "Sprites 2D das pranchas", 2026-11-23) |
| Data | 2026-11-23 |
| Tarefa | TASK-065 |
| GDD | 18, 19 |

## Contexto

As referências do Orlando (Octopath Traveler, Triangle Strategy, Tactics Ogre, Ragnarok Online, Buriedbornes, Sword of Convallaria) usam **personagens desenhados em 2D** sobre cenário com profundidade (HD-2D) ou arte 2D. Cinco rodadas de modelagem low-poly procedural (tubos, kitbash, textura baked) foram reprovadas pelo Orlando e pelo diretor de arte: a técnica não alcança a qualidade das pranchas de conceito do Gemini (`docs/design/refs/inimigos/`).

## Decisão

1. Inimigos e a Bibiana passam a ser **sprites 2D** em pé no diorama 3D (`Sprite3D` billboard preso ao eixo Y, filtro nearest), no lugar dos `.glb` feitos à mão.
2. As pranchas de conceito viram sprites por `tools/make_sprite.py` (recorte da figura, redução com média de área, paleta de 40 cores, contorno de 1 px). Entram já: Turiferário Cego, Médico da Cera e Rastejador da Vala.
3. `ModelRegistry` ganha a chave `sprite`; quem tem sprite usa o sprite, com altura natural de 1 unidade como os modelos 3D. O retrato da linha do tempo é o terço de cima do sprite.
4. Os modelos 3D feitos à mão que restam (cão, coveiro, carrasco, rato, corvo, etc.) são provisórios e saem quando houver sprite de cada um.
5. Cenário: composição alvo = `docs/design/refs/roaming-boss/04-perseguidor-coroado-combate-diorama.jpg` (arena gótica pintada com neblina, balaustrada, grade de ferro, lampião) e `docs/design/refs/ui/bibiana-mockup-combate-mobile.jpg` (tiles de pedra em pixel art, UI em moldura de pedra, aviso de moeda sobre a cabeça do inimigo).

## Consequências

Cada inimigo novo precisa de uma prancha (o Orlando gera no Gemini; o roteiro está em `docs/design/PROXIMA-RODADA-VALIDACAO.md`). Animação é só procedural (respiração, tremida, queda); quadros de animação ficam para depois. A mecha da Bibiana (GDD 9) exigirá uma variante de sprite por estágio.
