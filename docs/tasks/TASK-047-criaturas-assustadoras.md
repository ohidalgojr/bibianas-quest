# TASK-047: criaturas realmente assustadoras

| Campo | Valor |
| --- | --- |
| Status | Em verificação (modelos e criaturas prontos; falta o Orlando julgar se dão medo e a revisão cruzada) |
| Aberta em | 2026-11-19 |
| Fase | 1, feedback do Orlando ("crie criaturas realmente assustadoras") |
| GDD | 3, 11, 13, 18 |
| ADRs | ADR-0038, ADR-0039 |

> Leia `docs/ART-DIRECTION.md`, `docs/enemies/_modelo.md` e `docs/GDD.md` §3 e §13 antes. Fecha com print.

## Objetivo

Os inimigos deixam de parecer brinquedos. **Modelos feitos no Blender** com silhueta perturbadora (proporções erradas, membros demais, olhos que brilham, ossos e costuras aparentes), mais detalhados que os kits, e **criaturas novas** que dão medo: o medo vem do que a criatura **faz** (golpe de moeda, reação) e do que ela **é**.

## Fora do escopo

- Animação de esqueleto (fica a respiração procedural e os movimentos do palco); outros cenários.

## Critérios de aceite

- [x] Modelos novos no Blender (`tools/blender/make_enemies.py`) para o fantasma, a ossada, o vampiro e o chefe, e **criaturas novas** de design assustador (por exemplo: Enforcado, Costurado, Mãe das Ratazanas, Coro das Vozes), cada uma com olhos emissivos e silhueta própria; os kits que parecem brinquedo saem do jogo.
- [x] Pelo menos 3 inimigos novos com **ficha**, golpe de moeda temático e reação, respeitando a justiça (GDD §7); ao menos 1 elite novo.
- [x] `RULES_VERSION` incrementado, ADR e GDD §11 e §17 atualizados; Códice (bestiário) com os novos.
- [x] Prints de cada criatura no palco; teste de que todo inimigo tem ficha e modelo.

## Arquivos afetados

- `tools/blender/make_enemies.py`, `assets/bibiana/enemies/`, `game/data/enemies.json`, `game/data/scenarios.json`, `docs/enemies/`, `game/presentation/stage/model_registry.gd`, `game/core/run/sanctuary_rules.gd`, `game/presentation/combat/combat_texts.gd`, `docs/GDD.md`

## Testes esperados

- Validador de dados aceita os novos; auditor de justiça passa; todo inimigo tem ficha, modelo e ícone.

## Regras que esta tarefa não pode quebrar

- Regra nova: ADR, GDD no mesmo commit, `RULES_VERSION` incrementado; toda morte tem aviso (GDD §7); asset registrado.

## Verificação

Suíte em 2026-11-19: 344 testes, 344 passando, `RULES_VERSION` = 19 (ADR-0039). Prints: `docs/tasks/prints/TASK-047-*.png`. Simulador não rodado (diretriz de 2026-11-18).

**Feito:** `tools/blender/make_horrors.py` (com `kit.py`) gera no Blender 8 modelos: Sineiro Penado, Ossada Errante (4 braços), Sanguessuga de Beco, Carcereiro do Sino (cabeça de sino, jaula nas costas), O Coveiro (alto, capuz vazio, pá e caixão), e os novos Enforcado, Costurado e Mãe das Ratazanas (elite, com ratos menores no lombo, tumores e olhos demais). Três inimigos novos com ficha (ENEMY-12 a 14). Os kits de personagem da Kenney saíram do jogo.

**Não verificado:** se as criaturas dão medo de verdade é julgamento do Orlando; os olhos emissivos ficam pouco visíveis na distância do palco e a luz quente lava as cores; sem esqueleto de animação.

**Falta:** animações (só respiração e movimentos do palco); o Coveiro precisa de uma segunda fase visual (hoje o mesmo modelo nas duas fases); mutações por modelo.

## Revisão cruzada

Pendente.
