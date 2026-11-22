# TASK-061: combate como duelo (câmera, escala, luz, arena e aviso) segundo a identidade visual

| Campo | Valor |
| --- | --- |
| Status | Em verificação (código, testes e prints prontos; falta a aprovação do diretor de arte com os modelos novos) |
| Aberta em | 2026-11-22 |
| Fase | 1, identidade visual |
| GDD | 18, 19 |
| ADRs | ADR-0050 |

## Objetivo

Aplicar no combate os passos 1 a 5 de `docs/design/IDENTIDADE-VISUAL.md` §F: câmera próxima e baixa, escala do inimigo por altura, luz com foco quente e luar de contorno, arena composta com peças do kit e aviso do inimigo sem faixa cinza.

## Fora do escopo

- Modelos de inimigo (TASK-062), mapa, fogueira e loja.

## Critérios de aceite

- [x] `CAM_SIZE` 3,9 e inclinação de cerca de 24 graus; inimigo por altura (2,5/3,0/3,6), Bibiana a 1,45 no canto inferior esquerdo.
- [x] Luar de aço de trás, preenchimento frio, foco âmbar na cabeça do inimigo, ambiente baixo e névoa.
- [x] `DuelArena`: duas paredes altas em canto, portão, piso escuro, poças, prop narrativo por tipo, grade no primeiro plano.
- [x] Aviso do inimigo como cartão escuro com borda de ameaça, sem texto duplicado.

## Arquivos afetados

- `game/presentation/combat3d/combat3d_stage.gd`, `game/presentation/combat3d/duel_arena.gd`, `game/presentation/combat/combat_screen.gd`, `game/presentation/fx/atmosphere.gd`, `tests/unit/test_atmosphere.gd`, `tools/inspect_assets.gd`, `game/presentation/stage/asset_preview.*`

## Testes esperados

- Suíte existente verde; `test_atmosphere.gd` com a nova faixa de ambiente (0,30 a 0,40).

## Regras que esta tarefa não pode quebrar

- Só apresentação; `RULES_VERSION` não muda.

## Verificação

Suíte 364/364. Prints `docs/tasks/prints/TASK-061-*.png`. Checklist E ainda não preenchido: espera os modelos novos.

## Revisão cruzada

Pendente (diretor de arte, sobre os prints).
