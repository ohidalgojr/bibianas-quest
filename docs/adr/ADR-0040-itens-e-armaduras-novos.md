# ADR-0040: 20 itens novos de equipamento e consumíveis

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-19 |
| Tarefa | TASK-048 |
| GDD | 10, 15 |

## Contexto

O jogo tinha 14 itens (5 armas, 5 armaduras, 4 relíquias e consumíveis) e nenhum nos slots de cabeça e mão secundária que o GDD §10 prevê. O Orlando pediu mais armaduras, itens e ícones.

## Decisão

1. **20 itens novos** em `game/data/items.json`, com tema de peste, ossos e sinos:
   - Consumíveis: Pão Mofado (15% HP), Elixir Rançoso (55% HP), Fumaça de Sálvia (80% MP).
   - Armas: Foice de Camponês, Lâmina de Sineiro, Machado de Carrasco, Estilete de Sangue.
   - Armaduras: Manto Encharcado, Couraça de Ossos, Armadura do Penitente.
   - **Cabeça (slot novo em uso):** Capuz de Peste, Elmo de Sineiro, Coroa de Espinhos.
   - **Mão secundária (slot novo em uso):** Escudo de Madeira Podre, Lanterna do Viajante, Livro de Orações Rasgado.
   - Relíquias: Dente de Rato Gigante, Olho de Vidro, Corda de Enforcado, Medalhão do Penitente.
2. **Mesma faixa de números** dos itens existentes por raridade (comum 2 a 4 pontos de atributo, incomum 4 a 7, raro 8 a 12), preços em escala com a raridade. Nenhum efeito novo no núcleo: todo item usa atributos já existentes; os consumíveis só curam.
3. Todos os slots já funcionam por dicionário (`equipment[slot]`), então **cabeça e mão secundária aparecem na loja, nos drops e no equipamento sem mudar regra**. O equipamento visível no modelo 3D fica para depois.
4. **Ícones** por id no `IconRegistry` (pacote CC0 "496 RPG Icons"); alguns itens repetem ícone por falta de arte (escudo, armaduras), listado como pendência.
5. `RULES_VERSION` sobe para 20 (o pool de drops e loja muda a Descida por semente).

## Alternativas

- **Antídoto que cura doença, bomba de fogo:** exigem efeito de núcleo; ficam para uma tarefa de itens ativos (TASK-045).
- **Equipamento visível no modelo da Bibiana agora:** exige variantes de modelo; fica como pendência.

## Consequências

- Equilíbrio não foi rodado no simulador (diretriz de 2026-11-18); a calibração é a TASK-032.
- Os slots de cabeça e mão secundária ficam vazios no começo; o jogador só os preenche com drops, baú e loja.
