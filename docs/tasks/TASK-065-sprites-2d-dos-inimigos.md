# TASK-065: sprites 2D (HD-2D) a partir das pranchas de conceito

| Campo | Valor |
| --- | --- |
| Status | Em verificação (3 sprites integrados no combate; falta o Orlando ver e decidir os próximos) |
| Aberta em | 2026-11-23 |
| Fase | 1, identidade visual |
| GDD | 18, 19 |
| ADRs | ADR-0052 |

## Objetivo

Trocar os modelos 3D feitos à mão por sprites 2D recortados das pranchas do Gemini, em pé no diorama, como nas referências HD-2D do Orlando. Primeiro lote: Turiferário Cego, Médico da Cera e Rastejador da Vala.

## Fora do escopo

- Bibiana nova, inimigos sem prancha, cenário pintado, animação por quadros.

## Critérios de aceite

- [x] `tools/make_sprite.py` gera sprites com contorno e paleta fechada a partir das pranchas.
- [x] `ModelRegistry` cria o sprite (billboard, nearest) e as telas de combate e do mapa o usam; retrato da linha do tempo pelo sprite.
- [x] Licença do pacote registrada.

## Arquivos afetados

- `tools/make_sprite.py`, `assets/bibiana/sprites/`, `game/presentation/stage/model_registry.gd`, `game/presentation/combat3d/combat3d_stage.gd`

## Testes esperados

- Suíte existente verde (o teste de licenças cobre o pacote novo).

## Regras que esta tarefa não pode quebrar

- Cânone visual (ADR-0042, ADR-0050, ADR-0052); sem mudança de regra nem de `RULES_VERSION`.

## Verificação

Ver HANDOFF (suíte e data). Prints `docs/tasks/prints/TASK-065-*.png`. Não verificado: o mapa com sprites, o jogo no celular.

## Revisão cruzada

Pendente.
