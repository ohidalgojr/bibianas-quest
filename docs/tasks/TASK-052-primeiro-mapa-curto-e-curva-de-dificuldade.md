# TASK-052: primeiro mapa curto (sem facilitar) e dificuldade gradual nos demais

| Campo | Valor |
| --- | --- |
| Status | Em verificação (código, testes e simulação prontos; falta o Orlando jogar o mapa curto) |
| Aberta em | 2026-11-19 |
| Fase | 1/2, ritmo inicial e progressão de cenários |
| GDD | 4, 5, 17, 23 |
| ADRs | ADR-0049 (revisa ADR-0027 e complementa ADR-0031) |

## Objetivo

Ajustar a extensão e a curva de dificuldade dos mapas conforme a diretriz do Orlando (`docs/FEEDBACK.md` F-020): fazer o primeiro mapa ser **mais curto** (funcionando como gancho/tutorial ágil para chamar a atenção dos jogadores logo de início), **sem deixá-lo mais fácil**, enquanto os demais mapas/cenários passam a crescer gradativamente em extensão e dificuldade.

## Fora do escopo

- Tutorial modal com setas ou caixas de texto bloqueantes (mantém a filosofia sem tutorial expositivo do `ADR-0031`).
- Reformulação visual da UI ou criação de inimigos (tratados em tarefas próprias da `TASK-051`).

## Critérios de aceite

- [x] Definir a extensão enxuta do primeiro mapa (proposta: 3 a 4 camadas mais o chefe) em `game/data/scenarios.json` e `MapConfig`, mantendo a tensão e a dificuldade real dos encontros, golpes de moeda e chefe (não aliviar inimigos nem recompensas defensivas além do previsto em `ADR-0031`).
- [x] Preservar as garantias de gancho da primeira Descida (`ADR-0031`) adaptadas ao mapa mais curto (ex.: encontro inicial didático, baú cedo, confronto tenso e chefe visível logo à frente).
- [x] Definir escalada gradual de extensão e dificuldade para os mapas/cenários seguintes (cenários 2 a 5: número de camadas, níveis, peso de elites/mutações/emboscadas e pressão de recursos).
- [x] Criar ADR próprio registrando os novos limiares, atualizar `docs/GDD.md` (§4, §5, §17) no mesmo commit e incrementar `CoreVersion.RULES_VERSION`.
- [x] Validar garantia de vencibilidade (GDD §5) e rodar testes unitários (`test_map_generator.gd`, `test_first_descent.gd`, `test_winnability.gd` e suíte completa).

## Arquivos afetados

- `game/data/scenarios.json`, `game/core/map/map_config.gd`, `game/core/run/run_state.gd`, `game/core/run/run_rules.gd`, `game/core/core_version.gd`
- `tests/unit/test_map_generator.gd`, `tests/unit/test_first_descent.gd`, `tests/unit/test_winnability.gd`
- `docs/adr/ADR-XXXX-...md`, `docs/GDD.md`, `docs/FEEDBACK.md`, `docs/HANDOFF.md`

## Testes esperados

- `tests/unit/test_map_generator.gd` e `tests/unit/test_first_descent.gd`: primeiro mapa com o número curto definido de camadas mantendo rota vencível e elementos de gancho sem suavizar o chefe; mapas seguintes com camadas e dificuldade crescentes.

## Regras que esta tarefa não pode quebrar

- Mudança de regra e números do GDD exige ADR, GDD atualizado no mesmo commit e `CoreVersion.RULES_VERSION` incrementado.
- Núcleo sem nós e sem aleatoriedade global (`test_core_purity.gd`).
- Garantia de vencibilidade do mapa (GDD §5) e limites de justiça da moeda (GDD §7).

## Verificação

Suíte 364/364. Simulador (150 Descidas, regras v21): mediano 64,7%, cuidadoso 80,0%, 1ª Descida 42,0%, mortes por moeda 11,3%, 0 de 100 mapas sem rota vencível. Sem o ajuste do Coveiro (175/16) o mediano caía para 44% e 11% dos mapas ficavam sem rota. Não verificado: jogada humana.

## Revisão cruzada

Pendente.
