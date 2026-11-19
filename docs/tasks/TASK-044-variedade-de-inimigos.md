# TASK-044: variedade de inimigos e modelos próprios

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada; depois das TASK-042 e 043) |
| Aberta em | 2026-11-19 |
| Fase | 1, feedback do Orlando sobre o MVP visual ("não tem variedade de inimigos") |
| GDD | 11, 13, 17, 18 |
| ADRs | a criar |

> Leia `docs/ART-DIRECTION.md` e `docs/enemies/_modelo.md` antes. Fecha com print e o teste do print.

## Objetivo

O cenário 1 passa a ter **inimigos que se parecem com o que são** e em número suficiente para as lutas não repetirem: modelos próprios para o rato grande, o cão de peste, o corvo, o Carrasco e o chefe (hoje substitutos), e **novos inimigos** do GDD §17 com ficha, golpes e identidade.

## Fora do escopo

- Outros cenários; mini boss novo (já existe o Carcereiro do Sino).

## Critérios de aceite

- [ ] Modelos próprios para os inimigos hoje marcados como `placeholder` no `ModelRegistry`: pacote CC0 adicional (por exemplo Quaternius Ultimate Monsters, baixado com a autorização do Orlando) ou modelagem no Blender (servidor do Blender precisa estar conectado; ver `docs/MCP.md`).
- [ ] Pelo menos 4 inimigos novos do cenário 1 (do GDD §17 e do Códice), cada um com **ficha em `docs/enemies/`**, golpe de moeda temático, reação em dados e consequência da coroa, respeitando a regra de justiça.
- [ ] O mapa sorteia o pool maior sem quebrar a vencibilidade (GDD §5); `RULES_VERSION` incrementado; ADR; GDD §11 e §17 atualizados.
- [ ] Mutações visíveis por modelo, não só por luz; prints de cada inimigo no palco.

## Arquivos afetados

- `game/data/enemies.json`, `game/core/` (só se uma regra nova precisar), `game/presentation/stage/model_registry.gd`, `assets/`, `docs/enemies/`, `docs/GDD.md`

## Testes esperados

- Todo inimigo tem ficha, modelo e animações; o validador de dados aceita os novos; o auditor de justiça passa com todos.

## Regras que esta tarefa não pode quebrar

- Regra nova: ADR, GDD no mesmo commit e `RULES_VERSION` incrementado; toda morte tem aviso (GDD §7).

## Verificação

Ainda não executada.

## Revisão cruzada

Pendente.
