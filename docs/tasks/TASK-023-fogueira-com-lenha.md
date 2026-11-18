# TASK-023: fogueira com Galhos Secos

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte 266/266 (2026-11-18); jogada humana e revisão cruzada pendentes |
| Aberta em | 2026-11-17 |
| Fase | 1, ajuste pelo playtest (D2 do ADR-0025; `docs/FEEDBACK.md` F-009, F-010) |
| GDD | 12, 15 |
| ADRs | ADR-0025, ADR-0028 |

## Objetivo

Armar uma fogueira passa a gastar **Galhos Secos**. Cada mapa garante os Galhos de uma fogueira; os extras são raros (inimigos, baús, chefe) ou caros (loja, 120 moedas). O mapa sempre tem mais de um lugar para armar, em número proporcional à profundidade. Quem quer descansar toda hora precisa sacrificar ouro e coleta.

## Fora do escopo

- Cura de doenças na fogueira (TASK-025); mini boss (não existe).

## Critérios de aceite

- [x] Item `firewood` (Galhos Secos), consumável sem uso em combate, preço alto (120) na loja; cada mapa garante 1.
- [x] Entrar no nó de fogueira abre o painel com a fogueira apagada: sem Brasas até armar. "Acender" gasta 1 Galho Seco e dá as 6 Brasas; sair sem armar não gasta nada.
- [x] Galhos caem de baús (15%), de elites (20%), de inimigos comuns (5%) e do chefe (sempre), mais SORTE.
- [x] O número de fogueiras do mapa acompanha a profundidade (uma a cada 3 camadas, ao menos 2 a partir de 6) e nenhuma fica ligada a outra.
- [x] O mapa mostra os Galhos no cabeçalho; o painel mostra os disponíveis e por que "Acender" está desligado.
- [x] Os bots acendem quando têm Galhos e compram um na loja se sobrar ouro.
- [x] GDD §12 atualizado, ADR-0028, `RULES_VERSION` incrementado, suíte verde, simulador rodado.

## Arquivos afetados

- `game/data/items.json`; `game/core/data/data_validator.gd`; `game/core/map/` (`map_config`, `map_generator`); `game/core/run/` (`run_rules`, `run_state`); `game/core/sim/run_bot.gd`
- `game/presentation/run/` (painéis), `game/presentation/map/map_view.gd`
- `tests/`, `docs/GDD.md`, `docs/HANDOFF.md`

## Verificação

2026-11-18: `tools\run_tests.ps1`, 33 scripts, 266/266. Simulador regras v11 com Coveiro 205/16: mediano 68,7%, 0 mapas sem rota em 30, 1,1 s para criar a Descida (ADR-0028).

## Revisão cruzada

Pendente.
