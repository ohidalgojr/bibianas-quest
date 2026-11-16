# TASK-012: auto-save por nó e retomar

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte 217/217 (2026-11-16); revisão cruzada e jogada humana pendentes |
| Aberta em | 2026-11-16 |
| Fase | 1, protótipo cinza |
| GDD | 20 (save) |
| ADRs | ADR-0017 |

## Objetivo

A Descida grava a cada nó resolvido e pode ser retomada depois de fechar o jogo. Ecos e Descidas jogadas ficam num arquivo de meta separado, com versão de formato.

## Fora do escopo

- Salvar no meio de luta, loja ou fogueira; migração entre versões de regras; nuvem.

## Critérios de aceite

- [x] Save com a Bibiana no mapa a cada nó, incluindo o mapa inicial; apagado ao fim da Descida.
- [x] "Continuar Descida" no menu retoma do último nó salvo, com mapa, Poder, ouro, HP, MP, itens, buffs, Brasas, moeda e fluxos de RNG iguais.
- [x] Save de outra versão das regras, com campo faltando ou JSON quebrado é recusado, sem travar.
- [x] Meta (Ecos, Descidas) em arquivo próprio, com versão de formato; gravação por arquivo temporário e renomeação.

## Arquivos afetados

- `game/core/run/run_save.gd` (novo, sem I/O), `game/services/save_store.gd` (novo), `game/presentation/game_screen.gd`
- `tests/unit/test_save.gd` (novo), `test_game_screen.gd`
- `docs/adr/ADR-0017-save.md`

## Verificação

2026-11-16: `tools\run_tests.ps1`, 28 scripts, 217/217. Falta o Orlando fechar o jogo no meio de uma Descida e retomar.

## Revisão cruzada

Pendente.
