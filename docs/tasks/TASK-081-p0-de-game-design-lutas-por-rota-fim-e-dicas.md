# TASK-081: P0 da revisão de game design (lutas por rota, tela de fim, carga e dicas)

| Campo | Valor |
| --- | --- |
| Status | Em verificação (revisão cruzada pendente) |
| Aberta em | 2026-11-27 |
| Fase | 1 |
| GDD | 5, 26 |
| ADRs | ADR-0067 (`RULES_VERSION` 24) |

## Objetivo

Resolver os P0 restantes de `docs/design/critica-diretor/CRITICA-GAME-DESIGN-MOBILE.md`: Descida sem luta, tela de carga com texto técnico, tela de fim cortada e ambígua, e primeiro minuto sem ensino.

## Fora do escopo

- Tempo de geração do mapa em celular (precisa de medição no aparelho).
- Poder desigual entre luta, elite e chefe; Nv e pílula "ouro" que não preveem o perigo; Cara/Coroa com 50% fixo; economia da primeira loja; conteúdo do Santuário.

## Critérios de aceite

- [x] Nenhuma rota do início ao chefe passa por menos de 2 lutas (gerador e suavização), com teste por semente e tamanho (3 a 12 camadas × 40 sementes).
- [x] Tela de carga com texto de ambiente, sem "GDD §5".
- [x] Tela de fim rolável, "camada X de Y" limitada ao total, frase do algoz clara e linha do próximo desbloqueio do Santuário.
- [x] 4 dicas da 1ª Descida no mapa, só nela, que fecham ao tocar.
- [x] Suíte verde e prints.

## Arquivos afetados

- `game/core/map/map_generator.gd`, `game/core/run/winnability.gd`, `game/core/run/run_state.gd`, `game/core/core_version.gd`
- `game/presentation/game_screen.gd`, `game/presentation/map3d/map3d_screen.gd`
- `docs/GDD.md`, `docs/adr/ADR-0067-lutas-minimas-por-rota.md`, `tests/unit/test_map_fights.gd`, `test_map_generator.gd`, `test_map3d.gd`

## Testes esperados

- `test_map_fights.gd`: rota mais pobre com ≥ 2 lutas, determinismo, fogueiras preservadas.

## Regras que esta tarefa não pode quebrar

- Fórmulas do GDD só mudam com ADR (ADR-0067) e `RULES_VERSION` incrementado.
- Núcleo sem nós e sem aleatoriedade global.

## Verificação

Suíte 393/393 (`RULES_VERSION` = 24). Prints `docs/tasks/prints/TASK-081-resultado.png` e `TASK-081-dica.png`. Simulador não rodado (CLAUDE.md regra 9): o efeito no equilíbrio é desconhecido; a assinatura fixa do mapa de teste mudou de propósito.

## Revisão cruzada

Pendente.
