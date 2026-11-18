# TASK-022: economia, mapa mais longo e baú com multiplicador

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte 262/262 (2026-11-17); jogada humana e revisão cruzada pendentes |
| Aberta em | 2026-11-17 |
| Fase | 1, ajuste pelo playtest (D3 e D5 do ADR-0025; `docs/FEEDBACK.md` F-005, F-015, F-016) |
| GDD | 5, 12, 15, 16 |
| ADRs | ADR-0025, ADR-0027 |

## Objetivo

O jogador chega ao chefe preparado: mais lutas e baús no caminho, mais ouro, e um baú que pode ser multiplicado de forma moderada (Moeda da Sorte ou anúncio opcional). O mapa do cenário 1 passa de 5 para 6 camadas, e mapas de 6 camadas ou mais têm 2 fogueiras.

## Fora do escopo

- Lenha e a regra de a segunda fogueira custar recurso (TASK-023); o anúncio de verdade (no protótipo o anúncio é simulado).
- Cenários 2 e 3.

## Critérios de aceite

- [x] Cenário 1 com 6 camadas e níveis 1 a 6; mapas de 6 camadas ou mais com 2 fogueiras (a segunda a ao menos 2 camadas da penúltima).
- [x] Ouro por inimigo = 10 × N × U(0,8 a 1,2) × m_tipo; baús com mais frequência (14 de 100).
- [x] Baú abre num painel que mostra o ouro e deixa multiplicar uma vez, por Moeda da Sorte (gasta uma) ou anúncio simulado; o multiplicador é sorteado entre ×1,25, ×1,5 e ×2 (50%, 35%, 15%); o ×2 também rende uma poção.
- [x] Meta de economia no simulador: o bot mediano chega ao chefe com ouro gasto em ao menos uma peça de equipamento e uma poção em média, e nenhum mapa sem rota vencível; a faixa de 55% a 65% do mediano não coube junto com a garantia do mapa (ver ADR-0027).
- [x] GDD §5, §12, §15 e §16 atualizados, ADR-0027, `RULES_VERSION` incrementado, suíte verde.

## Arquivos afetados

- `game/data/scenarios.json`; `game/core/map/` (`map_config`, `map_generator`); `game/core/run/` (`run_rules`, `run_state`)
- `game/presentation/run/` (painéis), `game/presentation/game_screen.gd`
- `tests/`, `docs/GDD.md`, `docs/HANDOFF.md`

## Verificação

2026-11-17: `tools\run_tests.ps1`, 33 scripts, 262/262. Simulador regras v10 com Coveiro 225/16: mediano 76,7% (acima da faixa, ver conflito no ADR-0027), 0 mapas sem rota em 60, 1,6 s para criar a Descida.

## Revisão cruzada

Pendente.
