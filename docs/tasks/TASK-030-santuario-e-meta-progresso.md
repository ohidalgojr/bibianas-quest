# TASK-030: Santuário e meta-progresso (Biblioteca, Arsenal e Códice)

| Campo | Valor |
| --- | --- |
| Status | Concluída |
| Fase | MVP (GDD §9, §20, §26) |
| Depende de | TASK-012, TASK-028 |
| ADR | ADR-0034 |

## Objetivo

Transformar os Ecos acumulados em meta-progresso jogável no **Santuário** entre as Descidas (GDD §9):
1. **Biblioteca**: desbloqueio de tomos/ensinamentos com Ecos (`tome_of_fury`: começar com Grito de Guerra; `tome_of_edge`: fogueiras concedem +5 de CRIT por 2 combates).
2. **Arsenal**: desbloqueio de bênçãos e provisões iniciais com Ecos dentro do teto de +10% de bônus numérico permanente do GDD §9 (`blessing_iron_skin`: +8% de HP máximo e +8% de DEF; `pack_of_provisions`: +35 de ouro inicial e 1 Éter Sujo extra).
3. **Códice (Bestiário)**: catálogo dos 7 inimigos do jogo com nome, categoria, medo, golpe de moeda temático, reação e contadores persistentes de vitórias e derrotas contra cada inimigo no save de meta (`meta.json`).

## Escopo

- `game/core/run/sanctuary_rules.gd`: catálogo puro das melhorias da Biblioteca e do Arsenal (custos em Ecos, bônus respeitando o teto de +10% do GDD §9) e entradas do Códice/Bestiário a partir de `GameData`.
- `game/core/run/run_state.gd` e `game/core/run/run_save.gd`: suporte opcional a `meta_unlocks` na criação e serialização da Descida, além de histórico de inimigos derrotados por ID (`defeated_enemy_ids`) para atualizar o Bestiário ao fim da Descida.
- `game/services/save_store.gd`: persistir `unlocks` e `bestiary` em `meta.json` mantendo retrocompatibilidade total com chamadas existentes `save_meta(echoes, runs_played)`.
- `game/presentation/run/sanctuary_screen.gd` e `game/presentation/game_screen.gd`: tela do Santuário acessível a partir do menu inicial ("Santuário"), com abas/seções para Biblioteca, Arsenal e Códice (Bestiário), compra de desbloqueios com Ecos e gravação imediata em `SaveStore`.
- `tests/unit/test_sanctuary.gd`: testes cobrindo compra com Ecos, rejeição de compra repetida ou sem saldo, aplicação dos bônus de `meta_unlocks` na Descida dentro do teto de +10%, atualização do Bestiário (vitórias e derrotas) e persistência em `SaveStore`.

## Critérios de aceite

- [x] `SanctuaryRules` é 100% puro em `game/core/run/` e respeita o limite de +10% em bônus numéricos permanentes (GDD §9).
- [x] Comprar desbloqueios na Biblioteca e no Arsenal desconta Ecos, grava no `SaveStore` e aplica os efeitos nas próximas Descidas iniciadas pelo `GameScreen`.
- [x] O Códice (Bestiário) exibe todos os 7 inimigos de `enemies.json` com seus dados táticos e contadores de vitórias/derrotas atualizados ao fim de cada Descida.
- [x] `SaveStore` preserva compatibilidade com `save_meta(echoes, runs_played)` e persiste `unlocks` e `bestiary`.
- [x] `CoreVersion.RULES_VERSION` incrementado para `17`, GDD §9 atualizado e `ADR-0034` registrado.
- [x] Testes unitários verdes em headless (`tools/run_tests.sh`).

## Verificação

- `bash tools/run_tests.sh`: 311/311 testes verdes em 39 scripts (`tests/unit/test_sanctuary.gd` incluso).

## Revisão cruzada

Revisado contra `docs/REVIEW-CHECKLIST.md`: `SanctuaryRules` isolado em `game/core/run/` sem nós do Godot; bônus numéricos permanentes limitados a +8% (abaixo do teto de +10% do GDD §9); `RunState.new` preserva `run_unlocks = []` por padrão para não alterar sementes existentes; `SaveStore.save_meta` retrocompatível com chamadas de 2 argumentos. Sem achados pendentes.
