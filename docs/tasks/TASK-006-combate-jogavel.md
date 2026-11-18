# TASK-006: combate jogável

| Campo | Valor |
| --- | --- |
| Status | Concluída no código: suíte completa 161/161 (2026-11-16); teste de sensação e revisão cruzada pendentes |
| Aberta em | 2026-11-16 |
| Fase | 1, protótipo cinza (GDD §22; roteiro em `docs/ROADMAP-MVP.md`) |
| GDD | 6 (tela, ações, ritmo), 7 (moeda, tooltip, animação), 19 (interface em retrato) |
| ADRs | ADR-0010 |

## Objetivo

A primeira tela jogável: uma luta da Bibiana (Guerreiro) contra um inimigo do cenário 1, escolhido num seletor de depuração. É 2D, com formas simples e em retrato. A cena só anima os eventos que o núcleo emite. É o primeiro teste de sensação da moeda.

## Fora do escopo

- Cena 3D, modelos e animações de verdade (Fase 2).
- Escolher o lado da moeda antes do lance (ritual do GDD §7), trapaça por anúncio e Re-jogada.
- Recompensa, loja e mapa (TASK-009 e 010). Poder e ouro ao vencer (TASK-007).
- Repetir o último comando (GDD §6, ritmo). Fica para quando houver Descida inteira.

## Critérios de aceite

- [x] Seletor de depuração: inimigo do cenário 1, nível e Poder da Bibiana. Atalhos de teclado 1 a 6 escolhem o inimigo.
- [x] Tela em retrato 540×960: linha do tempo dos próximos turnos no topo; inimigo com barra de HP e ícone de intenção; registro da luta; Bibiana com HP, MP e efeitos; menu de ações na metade de baixo (zona do polegar).
- [x] Ações: Atacar, as três skills (cinza sem MP), Defender, Poção Turva (2 por luta), Fugir (desligado contra chefe).
- [x] O ícone de intenção mostra o golpe de moeda um turno antes, com a chance real da moeda (GDD §7: sem números escondidos).
- [x] Lance da moeda com animação de cerca de 1,2 s (placeholder), mostrando chance, resultado e Maré de azar.
- [x] Velocidade 2x (GDD §6, ritmo).
- [x] Dá para ganhar e perder com o mouse como toque; ao fim, tela de resultado com "Lutar de novo".
- [x] A cena não chama regras: lê eventos e as consultas públicas do `Combat` (linha do tempo, chance da moeda, pode agir).
- [x] Testes headless do controlador e da cena; suíte verde. Rodada manual no Godot com print da tela.

## Arquivos afetados

- `game/presentation/combat/combat_session.gd`, `combat_texts.gd`, `combat_screen.gd`
- `game/presentation/main.gd`
- `tests/unit/test_combat_session.gd`, `tests/unit/test_combat_screen.gd`
- `docs/adr/ADR-0010-combate-em-2d-no-prototipo.md`

## Testes esperados

- `test_combat_session.gd`: monta a luta pelos dados; textos dos eventos; intenção de moeda visível no turno anterior ao golpe; consumo de poções; fuga desligada contra chefe; luta até o fim.
- `test_combat_screen.gd`: a cena abre em headless, joga uma luta inteira pelos botões com animação instantânea e mostra o resultado.

## Regras que esta tarefa não pode quebrar

- A apresentação depende do núcleo, nunca o contrário. Nenhuma regra é recalculada na cena.
- Núcleo sem nós; sorteio só pelos fluxos.

## Verificação

- 2026-11-16: `tools/run_tests.ps1` no Claude Code, 19 scripts, 161/161, exit 0, 21 s.
- Rodada no Godot 4.7.2 com janela de 540×960, com prints do seletor, da luta contra O Coveiro e do lance da moeda. O primeiro print mostrou dois defeitos, já corrigidos: a tela não ocupava a janela (âncoras sem offsets) e o registro ficava com 1 px de altura.
- A jogada com mouse foi feita pelos testes de cena (botões apertados em headless). Ainda falta o Orlando jogar com o mouse e anotar o teste de sensação abaixo.

## Revisão cruzada

Revisado por Gemini (modelo distinto do autor original, Claude Opus 4.6), seguindo `docs/REVIEW-CHECKLIST.md`:
- **GDD §6, §7, §18, §20 e `ADR-0010`**: `CombatSession` faz a ponte entre `Combat` e `CombatScreen` sem recalcular regras na apresentação; botões na zona do polegar, painel de intenção colorido por risco/moeda e `time_scale = 0` para testes headless instantâneos.
- **Achados corrigidos na `TASK-029`**:
  - *Importante (`game/presentation/combat/combat_screen.gd`)*: em `_refresh_buttons()`, uma linha residual sobrescrevia `(_buttons["skill_0"] as Button).tooltip_text` com texto fixo, descartando `session.skill_tip(0)` introduzido na `TASK-017` (`ADR-0021`). Linha removida para preservar a dica completa da skill.

## Teste de sensação (humano)

Conferido nas rodadas de feedback `docs/FEEDBACK.md` (levando aos ajustes das `TASK-015` a `TASK-025`).
