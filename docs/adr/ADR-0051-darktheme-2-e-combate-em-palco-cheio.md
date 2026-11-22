# ADR-0051: DarkTheme 2.0 e combate com palco cheio

| Campo | Valor |
| --- | --- |
| Status | Aceito (auditoria `docs/design/AUDITORIA-UI-vs-ESTUDO.md`, pacotes 1, 2 e 4; decisões em `docs/design/DECISOES-ARTE-UI.md`) |
| Data | 2026-11-22 |
| Tarefa | TASK-064 |
| GDD | 18, 19 |

## Decisão

1. **Tokens da paleta fechada** (`ABYSS`, `SLATE_DEAD`, `STONE_WET`, `STEEL_MOON`, `MUD`, `AMBER_LAMP`, `DANGER`, `COIN_GOLD`) em `DarkTheme`.
2. **Fonte (D-UI-4):** botão em Alegreya; Cinzel só nas variações `ActionButton`, `PrimaryButton`, `DangerButton` e `RiskButton` e nos títulos. `DarkTheme.polish_button` põe `ActionButton` em botão de até 3 palavras.
3. **Componentes:** variações de tema `PrimaryButton`, `DangerButton`, `RiskButton`, `CardPanel`, `SheetPanel`, `MutedLabel`, `DeltaUpLabel` (ouro) e `DeltaDownLabel` (perigo), sem verde.
4. **Toque:** alvo mínimo de 48 px, escala 0,96 ao apertar e vibração curta (`GfxSettings.haptics`), aplicados a todo botão pelo `GameScreen`.
5. **`TrailBar`:** barra com rastro de dano nas barras do combate.
6. **Combate:** palco de cerca de 68% da altura com a gaveta fechada; log fixo vira letreiro de 2,2 s; previsão sai do palco; HP e MP lado a lado; abas de 48 px; aviso do inimigo preso à cabeça dele; `CAM_SIZE` 4,3.

## Consequências

Sem mudança de regra nem de `RULES_VERSION`. Faltam do mesmo estudo a loja com comparação, o ritual da Moeda, Resultado e Recompensa e o Santuário.
