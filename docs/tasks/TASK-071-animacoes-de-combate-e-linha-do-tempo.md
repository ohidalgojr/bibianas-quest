# TASK-071: animações de combate da Bibiana, FX e linha do tempo nítida

| Campo | Valor |
| --- | --- |
| Status | Em andamento (animações e bustos prontos; UX do combate aguarda a crítica do diretor) |
| Aberta em | 2026-11-26 |
| Fase | 1, identidade visual |
| GDD | 6, 7, 17, 18, 19 |
| ADRs | ADR-0058 (ADR-0042, ADR-0053, ADR-0056) |

## Objetivo

Usar as poses e FX entregues pelo Orlando: a Bibiana caminha até o inimigo, golpeia com arco de corte, defende com faíscas, recua ferida, bebe a poção e comemora ou cai no fim; e as miniaturas da linha do tempo deixam de ser borrões.

## Fora do escopo

- Reorganização do menu de combate e dos botões (vem da crítica do diretor, tarefa seguinte).
- FX de veneno e chama no combate; animações dos inimigos por quadros.

## Critérios de aceite

- [x] 14 sprites de pose recortados (`bibiana_warrior_attack|defend|hurt|item|victory|defeat|idle_guard|sit_fire|walk_0..3`) e 4 folhas de FX com transparência (`tools/make_fx.py`).
- [x] Golpe: caminhada de 4 quadros até o inimigo, espada no alto, impacto com corte (e explosão no crítico), volta caminhando; o dano só aparece no impacto.
- [x] Defender mantém o escudo à frente e solta faíscas no golpe do inimigo; dano sem defesa mostra a pose ferida; poção mostra a pose de beber; vitória e derrota têm pose.
- [x] Linha do tempo com bustos nítidos de 46 px (recorte da cabeça, Lanczos).
- [ ] Revisão do agente crítico e ajustes de UX.

## Arquivos afetados

- `game/presentation/combat3d/combat3d_stage.gd`, `game/presentation/combat/combat_screen.gd`, `game/presentation/stage/model_registry.gd`
- `assets/bibiana/sprites/bibiana_warrior_*.png`, `assets/bibiana/fx/`, `tools/make_fx.py`, `assets/LICENSES.md`

## Testes esperados

- Suíte existente verde (sprites carregam: `test_stage_assets`).

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR; a apresentação só lê eventos do núcleo.
- Cânone visual (`ADR-0042`); nunca mecha colorida (`F-024`).

## Verificação

Pendente (ver HANDOFF).

## Revisão cruzada

Pendente.
