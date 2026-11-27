# TASK-072: integração dos assets do Gemini (ícones, UI kit, arenas, eventos, moedas) e UX do combate

| Campo | Valor |
| --- | --- |
| Status | Em verificação (aguarda revisão dos agentes fã de dark fantasy e especialista mobile) |
| Aberta em | 2026-11-27 |
| Fase | 1, identidade visual |
| GDD | 6, 7, 17, 18, 19 |
| ADRs | ADR-0059 (ADR-0042, ADR-0058) |

## Objetivo

Integrar todo o material gerado pelo Gemini que ainda não estava no jogo e aplicar a crítica de UX do combate (`docs/design/critica-diretor/CRITICA-UX-COMBATE.md`).

## Fora do escopo

- Os 3 eventos novos, os inimigos `lipless_choir`, `calcified_knight`, `trench_crawler` novo e o `crowned_pursuer`: as imagens ainda não existem no repositório (cota do Gemini).
- Novo tabuleiro gótico coerente com o fundo (TASK-073, agente de estrutura de arenas).

## Critérios de aceite

- [x] 102 ícones pintados (`tools/make_icons.py`) no `IconRegistry`, com reserva para os antigos; filtros linear nos ícones.
- [x] UI kit (`UiKit`): painel de pedra, molduras de slot, divisor, moldura de ilustração, fita; aplicado em painéis de loja, recompensa, fogueira e menu, no card de prévia, nos slots e na folha de gavetas.
- [x] Arenas: chefe, fogueira apagada e acesa, derrota, recompensa, santuário; horizonte, primeiro plano com grade e névoa pintada no mapa.
- [x] Ilustrações dos 3 eventos existentes na moldura gótica.
- [x] Moedas Cara/Coroa pintadas, girando de verdade, botões de 96 px.
- [x] Combate: golpe com impacto em ~0,3 s e hit-stop real, flash, números maiores; linha do tempo por evento com AGORA e bustos nítidos; selo de intenção com ícone; gaveta com cabeçalho de HP/MP, previsão e CONFIRMAR.
- [x] Revisão cruzada visual/técnica registrada em `TASK-076`; ajustes complementares aplicados em `TASK-074` e `TASK-075`.

## Arquivos afetados

- `game/presentation/fx/ui_kit.gd`, `icon_registry.gd`; `game/presentation/combat/combat_screen.gd`; `game/presentation/combat3d/combat3d_stage.gd`; `game/presentation/camp3d/scene3d_backdrop.gd`; `game/presentation/run/*`; `game/presentation/map3d/map3d_screen.gd`; `game/presentation/visual_theme.gd`
- `tools/make_icons.py`, `tools/make_fx.py`; `assets/bibiana/{icons,ui,arenas,events,fx}/`

## Testes esperados

- Suíte existente verde, com os testes de cenário adaptados ao modo pintado.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR; a apresentação só lê eventos do núcleo.
- Cânone visual (`ADR-0042`); nunca mecha colorida (`F-024`).

## Verificação

Suíte completa em headless: 370 testes passando (2026-11-27). Prints reais em `docs/tasks/prints/`.

## Revisão cruzada

Revisão por modelo distinto (`Gemini`, `GDD §21` etapa 4, `docs/REVIEW-CHECKLIST.md`) sobre `329bf84` e `d8d8a10`:
- **Aprovação e regras:** `game/core/` intacto (`RULES_VERSION` = 21); `IconRegistry` usa os `102` ícones pintados (`96×96`) eliminando o furacão do Fugir; `UiKit` padronizou painéis, slots, divisores, fitas e moldura de evento; linha do tempo AGORA+4, gaveta com `CONFIRMAR` e moeda pintada funcionam sem cálculo de regra na tela.
- **Achados médios/menores:**
  1. *(Médio → atendido em `TASK-075`)* `flame.png` ainda não estava convertida/animada na fogueira, `SanctuaryScreen` ainda usava `StyleBoxFlat` plano em vez de `UiKit` e `GamePreview` com `tela=event` caía em vitória em sementes sem nó `EVENT` antes do fim.
  2. *(Médio → atendido em `TASK-074`)* `STRIKE_WINDUP` de `0,05 s` comprimiu a leitura da erguida de espada e causou a queixa `F-025` do Orlando.
  3. *(Aberto / pós-cota)* Os `3` eventos restantes, os `4` sprites isolados de inimigos/Roaming Boss e `*_2x` de todos os inimigos aguardam a liberação da cota semanal do Gemini e revisão em celular real.
