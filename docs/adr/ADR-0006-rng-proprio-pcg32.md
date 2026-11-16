# ADR-0006: gerador próprio PCG32 e fluxos derivados por SplitMix64

| Campo | Valor |
| --- | --- |
| Status | Aceito (decisão técnica dentro da tarefa; o Orlando pode revogar na revisão) |
| Data | 2026-11-16 |
| Tarefa | TASK-002 |
| GDD | 20 (aleatoriedade determinística), 5 (nova semente do gerador de mapa) |

## Contexto

O GDD §20 exige quatro fluxos de sorteio com sementes separadas (mapa, combate, loot, moeda), reprodutíveis, para testar, reproduzir bugs, simular milhares de Descidas e, no futuro, fazer a Descida diária. A regra de pureza do núcleo (ADR-0002) proíbe a aleatoriedade global do motor.

## Decisão

- **Gerador próprio PCG32 (XSH-RR)**, em `game/core/rng/pcg32.gd`, com semente e número de sequência. O inteiro de 64 bits do GDScript dá a aritmética necessária (a multiplicação dá a volta sozinha); os deslocamentos à direita são feitos com máscara, porque o `>>` do GDScript preserva o sinal.
- **Intervalos sem viés:** `draw_int` rejeita as sobras da divisão (método padrão do PCG32). `draw_percent(p)` sorteia de 1 a 100 e vale `<= p`.
- **Quatro fluxos** em `RngStreams`: `MAP`, `COMBAT`, `LOOT`, `COIN`. A semente de cada um é `derive_seed(semente_da_descida, índice)`, e o índice também é o número da sequência do PCG32.
- **`derive_seed`** usa SplitMix64 (`splitmix(semente ^ splitmix(rótulo))`). Serve também para a "próxima semente" que o gerador de mapa usa ao descartar um cenário (GDD §5).
- **Estado salvável:** `snapshot()` e `restore()` gravam os números de 64 bits como **texto**, porque JSON guarda números em ponto flutuante e perderia bits.
- Métodos com nomes que não colidem com o teste de pureza: `draw_int`, `draw_float`, `draw_percent`, `draw_index`, `shuffled_copy`.

## Alternativas

- **Embrulhar `RandomNumberGenerator`:** menos código, mas a sequência depende da versão do Godot (uma atualização do motor poderia mudar todas as Descidas gravadas), e o estado tem de ser gravado pelas propriedades do motor.
- **Um único fluxo com a semente da Descida:** mais simples, mas qualquer mudança de quantos sorteios um sistema gasta alteraria todos os outros (por exemplo, um inimigo novo mudaria a moeda).
- **Semente por fluxo somando constantes:** deixaria fluxos correlacionados; o SplitMix64 espalha bem as sementes.

## Consequências

- Resultados idênticos em qualquer máquina e versão do Godot; testes com valores fixos protegem isso. Os valores foram conferidos contra o vetor de referência publicado do PCG32 (semente 42, sequência 54).
- Trocar o algoritmo, o modo de reduzir intervalos ou a derivação de sementes quebra os saves e relatórios existentes: exige ADR novo e subir `CoreVersion.RULES_VERSION`.
- O save (TASK-012) deve usar `snapshot()` tal como está (texto), sem converter para número.
- Quem sortear no núcleo usa só `RngStreams`; chamar `Pcg32.new(...)` solto no meio do jogo fura a regra dos quatro fluxos e deve ser barrado na revisão.
