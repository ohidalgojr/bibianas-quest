# TASK-024: combate legível, crítico manipulável e MP

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte 272/272 (2026-11-18); jogada humana e revisão cruzada pendentes |
| Aberta em | 2026-11-18 |
| Fase | 1, ajuste pelo playtest (D6 do ADR-0025; `docs/FEEDBACK.md` F-007, F-008, F-011) |
| GDD | 6, 8, 10, 12 |
| ADRs | ADR-0025, ADR-0029 |

## Objetivo

O jogador vê, antes de agir, o que cada ação faz: faixa de dano, chance de acerto e de crítico, descrição das skills. O crítico fica visível e pode ser aumentado por item e skill de fogueira. O MP deixa de ser tão curto: atacar devolve MP e o Éter Sujo passa a ser usável em combate.

## Fora do escopo

- Evento de mapa que mexa no crítico (o sistema de eventos não existe; fica para a TASK-025 ou depois).
- Previsão contra os golpes do inimigo (o aviso de intenção já mostra o efeito).

## Critérios de aceite

- [x] O motor calcula a previsão de um golpe do jogador (dano mínimo e máximo, dano máximo com crítico, chance de acerto, chance de crítico) sem sortear nada.
- [x] Os botões de Atacar e das skills mostram a previsão; toda skill tem descrição (no botão e na dica).
- [x] Atacar devolve 10% do MP máximo; o Éter Sujo é um botão do combate e cai como drop de consumível.
- [x] Crítico visível: chance na previsão e número maior no acerto crítico; item (Garra Afiada, CRIT +8) e skill de fogueira (Afiar o Fio, CRIT +10 por 3 lutas) o aumentam.
- [x] GDD §6, §8, §10 e §12 atualizados, ADR-0029, `RULES_VERSION` incrementado, simulador rodado, suíte verde.

## Arquivos afetados

- `game/core/combat/` (`combat_formulas`, `combat`); `game/core/run/run_state.gd`; `game/data/` (`items`, `skills`, `classes`); `game/core/data/data_validator.gd`
- `game/presentation/combat/` (sessão, tela), `game/presentation/run/run_panels.gd`
- `tests/`, `docs/GDD.md`, `docs/HANDOFF.md`

## Verificação

2026-11-18: `tools\run_tests.ps1`, 34 scripts, 272/272. Simulador regras v12 com Coveiro 195/16: mediano 70,7%, 0 mapas sem rota em 40, 1,2 s para criar a Descida (ADR-0029).

## Revisão cruzada

Pendente.
