# TASK-034: carregar meta.json de formato anterior ao Santuário

| Campo | Valor |
| --- | --- |
| Status | Em verificação (código e testes prontos; falta a revisão cruzada por outro modelo) |
| Aberta em | 2026-11-19 |
| Fase | 1, correção de robustez do save (GDD §20) |
| GDD | 20 |
| ADRs | ADR-0017 |

## Objetivo

`SaveStore.load_meta` não pode quebrar com um `meta.json` do mesmo `format` que não tem as chaves `unlocks` ou `bestiary` (gravado antes da TASK-030). Faltando a chave, vale o padrão vazio e os Ecos e `runs_played` são mantidos.

## Fora do escopo

- Mudar `META_FORMAT` ou o conteúdo do save.

## Critérios de aceite

- [x] `load_meta` com arquivo só com `format`, `echoes` e `runs_played` devolve esses valores, `unlocks` vazio e `bestiary` vazio, sem erro.
- [x] `test_main_scene.gd` passa com um `meta.json` antigo na pasta de dados do usuário.
- [x] Suíte verde.

## Arquivos afetados

- `game/services/save_store.gd`, `tests/unit/test_save.gd`

## Testes esperados

- `tests/unit/test_save.gd`: meta antigo sem `unlocks` nem `bestiary` carrega com padrões.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR.
- Núcleo sem nós e sem aleatoriedade global.

## Verificação

Suíte completa em 2026-11-19: 316 testes, 316 passando, com o `meta.json` antigo real do PC do Orlando na pasta de dados.

## Revisão cruzada

Pendente.
