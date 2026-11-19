# TASK-005: dados do cenário 1

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte completa 150/150 (2026-11-16); revisão cruzada pendente |
| Aberta em | 2026-11-16 |
| Fase | 1, protótipo cinza (GDD §22; roteiro em `docs/ROADMAP-MVP.md`) |
| GDD | 6 (IA), 8 (Guerreiro), 10 (itens), 13 (chefes), 15 (preços), 17 (cenário 1), 20 (entidades e dados) |
| ADRs | ADR-0009 |

## Objetivo

Passam a existir arquivos JSON em `game/data/` com o Guerreiro, as skills dele, os inimigos do cenário 1 (4 comuns, 1 elite e o Coveiro com 2 fases), itens básicos e o próprio cenário. Um carregador lê esses arquivos e um validador falha alto em dado inválido. O núcleo monta `Combatant`, `CombatSkill` e `CombatItem` a partir dos dados.

## Fora do escopo

- Aplicar equipamentos aos atributos e usar skills de fogueira (TASK-007).
- Regra própria do Coveiro (cavar covas e invocar mortos), drops e tabelas de loot, eventos e mini boss (TASK-007 ou depois, com ADR).
- Calibrar os números contra as metas do GDD §23 (TASK-008).
- Outras classes e outros cenários.

## Critérios de aceite

- [x] `game/data/` tem `classes.json`, `skills.json`, `enemies.json`, `items.json` e `scenarios.json`, cada um com `format`.
- [x] Os números do GDD estão copiados: atributos do Guerreiro (§8), custos e potências das skills (§8), níveis 1 a 6 e 5 camadas do cenário 1 (§17), preços dentro das faixas do §15.
- [x] O validador rejeita: campo faltando, tipo errado, id repetido, referência quebrada, valor fora da lista (tipo de golpe, slot, elemento) e regras do GDD (3 a 5 golpes por fase; chefe com 2 a 3 fases, golpe Cruel e Golpe Mortal na fase final; Golpe Mortal só em chefe).
- [x] O carregador junta os erros de leitura de arquivo e de JSON com os do validador e os mostra com `push_error`.
- [x] O núcleo monta a Bibiana (Guerreiro) e cada inimigo em qualquer nível do cenário, com a escala de nível do ADR-0009.
- [x] Os inimigos de verdade passam pelo auditor das regras de justiça em lutas jogadas por bot.
- [x] Núcleo sem I/O: a leitura de arquivo fica em `game/services/`. Suíte verde.

## Arquivos afetados

- `game/data/*.json`
- `game/core/data/game_data.gd`, `data_validator.gd`
- `game/services/data_loader.gd`
- `tests/unit/test_data_validator.gd`, `test_game_data.gd`, `test_data_loader.gd`
- `docs/adr/ADR-0009-dados-em-json-e-escala-de-nivel.md`

## Testes esperados

- `test_data_validator.gd`: cada regra do validador rejeita o dado certo, com mensagem que diz onde.
- `test_data_loader.gd`: os arquivos de verdade carregam sem erro; arquivo ausente e JSON quebrado viram erro.
- `test_game_data.gd`: dados iguais ao GDD §8 (atributos e skills do Guerreiro) e §17 (cenário 1); escala de nível; montagem de inimigos; auditor de justiça em lutas contra os inimigos de verdade.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR. Números que o GDD não dá são do protótipo e ficam marcados no ADR-0009 para a calibração da TASK-008.
- Núcleo sem nós, sem I/O de arquivo e sem aleatoriedade global.

## Verificação

- 2026-11-16: `tools/run_tests.ps1` no Claude Code, 17 scripts, 150/150, exit 0, na primeira rodada.
- Lutas do bot com os inimigos de verdade (150 por inimigo, níveis 1 a 6, Poder 1 + 0,5 por nível acima de 1; Coveiro no nível 6). Os turnos são da Bibiana por luta: Cidadão Infectado 7,3 turnos e 91% de vitórias; Rato Grande 6,2 e 93%; Corvo Carniceiro 5,3 e 93%; Cão de Peste 7,1 e 93%; Carrasco Apodrecido 14,9 e 81%; O Coveiro 28,4 e 65%. Nenhuma violação das regras de justiça.
- Para a calibração (TASK-008): o Corvo fica abaixo da meta de 6 a 10 turnos do GDD §23, e o Coveiro tem luta longa. O Poder usado no teste é uma suposição, não o da Descida real.

## Revisão cruzada

Revisado por Gemini (modelo distinto do autor original, Claude Opus 4.6), seguindo `docs/REVIEW-CHECKLIST.md`:
- **GDD §8, §11, §12, §13, §14, §20 e `ADR-0009`**: `DataValidator` e `GameData` vivem puros em `game/core/data/`, acumulando todos os erros estruturais e de referência cruzada sem parar no primeiro; `DataLoader` em `game/services/` isola `FileAccess` e `JSON`.
- **Testes**: `tests/unit/test_data_validator.gd` e `tests/unit/test_scenario_combat.gd` exercitam os JSONs reais e casos inválidos para cada regra.
- **Achados**: nenhum achado crítico ou importante. Aprovada.
