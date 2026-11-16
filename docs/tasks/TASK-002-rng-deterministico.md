# TASK-002: RNG determinístico em 4 fluxos

| Campo | Valor |
| --- | --- |
| Status | Concluída em 2026-11-16, no código e nos testes; faltam o commit do Orlando e a revisão cruzada do Gemini |
| Aberta em | 2026-11-16 |
| Fase | 1, protótipo cinza (GDD §22; roteiro em `docs/ROADMAP-MVP.md`) |
| GDD | 20 (aleatoriedade determinística), 5 ("proxima_seed" do gerador de mapa), 7 (a trapaça só muda a chance, nunca refaz o sorteio) |
| ADRs | ADR-0006 |

## Objetivo

O núcleo passa a ter um gerador pseudoaleatório próprio e quatro fluxos independentes (mapa, combate, loot e moeda), todos derivados da semente da Descida: a mesma semente e as mesmas chamadas dão a mesma sequência, em qualquer máquina e versão do Godot, e o estado pode ser salvo e restaurado.

## Fora do escopo

- Gerador de mapa, combate, loot e moeda de verdade (TASK-003 em diante); aqui só nascem os fluxos.
- Gravar o save em disco (TASK-012). Aqui só existe `snapshot()` e `restore()` em memória.
- Qualquer fórmula do GDD. `CoreVersion.RULES_VERSION` continua 0, pois nenhuma regra de jogo foi implementada.

## Critérios de aceite

- [x] `Pcg32` reproduz os vetores de referência do PCG32 (semente 42, sequência 54).
- [x] Mesma semente e sequência dão a mesma saída; sementes ou sequências diferentes divergem.
- [x] `draw_int` é uniforme, sem viés, com extremos incluídos; `draw_float` fica em [0, 1); `draw_percent`, `draw_index` e `shuffled_copy` têm testes de limites.
- [x] `RngStreams` expõe `map()`, `combat()`, `loot()` e `coin()`, com sementes derivadas por SplitMix64, e gastar um fluxo não muda os outros.
- [x] `snapshot()` e `restore()` devolvem o mesmo futuro, inclusive passando por JSON (números de 64 bits vão como texto); dado inválido é rejeitado sem mudar o estado.
- [x] Nenhum script do núcleo usa aleatoriedade global (o teste de pureza continua verde).
- [x] Suíte verde com o observador (13 testes antigos mais os novos).

## Arquivos afetados

- `game/core/rng/pcg32.gd`
- `game/core/rng/rng_streams.gd`
- `tests/unit/test_pcg32.gd`
- `tests/unit/test_rng_streams.gd`
- `docs/adr/ADR-0006-rng-proprio-pcg32.md`

## Testes esperados

- `test_pcg32.gd`: vetores de referência; reprodução por semente; divergência por semente e sequência; reinício; valores fixos de `draw_int`; limites e cobertura do intervalo; uniformidade em 10 mil sorteios; intervalos degenerados; média de `draw_float`; `draw_percent` nos extremos e a 30%; `shuffled_copy` (mantém os itens e a lista original, ordem fixa); `snapshot` e `restore` (incluindo JSON e dados inválidos).
- `test_rng_streams.gd`: valores fixos de `derive_seed` e de cada fluxo; reprodução dos quatro fluxos; fluxos distintos; independência entre fluxos; semente da Descida diferente muda tudo; mil rótulos dão mil sementes; `snapshot` e `restore` em JSON; rejeição de dados inválidos.

Os números fixos foram gerados por uma réplica em Python do mesmo algoritmo, que também reproduz o vetor de referência publicado do PCG32.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR.
- Núcleo sem nós e sem aleatoriedade global. Os métodos novos evitam os nomes proibidos (`randi`, `shuffle`, `pick_random`, `seed(`).
- Trocar o algoritmo do `Pcg32` ou o modo de derivar sementes muda todas as Descidas gravadas: exige ADR e subir `RULES_VERSION`.

## Verificação

Observador, 2026-11-16 10:20 (`reason=arquivos mudaram`, `exit=0`): 5 scripts, 39 testes, 39 passando, 26.371 asserts, 0,78 s, sem avisos. Novos: `test_pcg32.gd` 17/17 e `test_rng_streams.gd` 9/9; os 13 antigos continuam verdes.

## Revisão cruzada

Pendente (etapa 4): revisor sugerido, Gemini, com `git show HEAD`, este arquivo e `CLAUDE.md`. Pontos que merecem olhar: a aritmética de 64 bits com deslocamento lógico em `next_u32` e `_split_mix`, e a escolha de `draw_percent` (sorteio de 1 a 100).
