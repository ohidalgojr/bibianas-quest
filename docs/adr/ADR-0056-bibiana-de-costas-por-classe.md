# ADR-0056: Bibiana de costas no combate e poses por classe

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-24 |
| Tarefa | TASK-069 |
| GDD | 17, 18, 19 |

## Contexto

O Orlando pediu a Bibiana de costas no combate, no estilo de visão por cima do ombro, e gerou folhas de 4 poses para as 4 classes. O combate mostrava a heroína de frente e pequena, e o mapa e as cenas usavam uma segunda versão dela.

## Decisão

1. Cada classe tem 4 sprites: `back` (combate e mapa), `left`, `right` e `camp` (sentada). Ids no `ModelRegistry`: `bibiana_<classe>_<pose>`.
2. `ModelRegistry.hero_id(classe, pose)` escolhe a pose e cai na Bibiana de frente se o arquivo faltar.
3. Combate e mapa usam `back`; fogueira (espelhada para olhar o fogo) e derrota usam `camp`; loja, baú e evento usam `right`, voltada ao NPC.
4. Só a Guerreira é usada em jogo; as demais já estão registradas para a seleção de classe.

## Alternativas

- Uma única imagem com `flip`: descartado, a costas não existe a partir da frente.

## Consequências

Uma heroína coerente em todas as telas. Pose de ataque, dano e derrota ainda são só deslocamentos procedurais.
