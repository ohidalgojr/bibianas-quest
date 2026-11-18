# TASK-031: Apresentação Dark Fantasy, Tabuleiro Visual e Áudio Procedural

| Campo | Valor |
| --- | --- |
| Status | Concluída |
| Fase | MVP (GDD §3, §5, §6, §7, §9, §17, §18, §19) |
| Depende de | TASK-006, TASK-009, TASK-028, TASK-030 |
| ADR | ADR-0035 |

## Objetivo

Substituir a apresentação de "protótipo cinza / tabuleiro tosco" por uma direção visual **Dark Fantasy** e **áudio procedural** fiéis ao GDD (§3, §9, §17, §18, §19), dando ao MVP "cara de jogo de verdade" com gráficos e som sem depender de arquivos binários externos:
1. **Regra do Acento e Mecha da Bibiana (GDD §3, §9, §18)**: paleta dessaturada de pedra/cinzas com três acentos saturados (ouro da moeda, vermelho de perigo e os 9 estágios de cor da mecha de cabelo da Bibiana conforme o Poder).
2. **Tabuleiro Visual da Cidade Abandonada (`MapScreen`, GDD §17)**: estradas curvas de calçamento, praças de pedra com brasões/ícones por tipo de nó, neblina e vinheta nas camadas ocultas, iluminação quente nos 3 destinos disponíveis e peão da Bibiana com a cor atual da mecha.
3. **Retratos Vetoriais e Medalhão da Moeda em Combate (`CombatScreen`, GDD §6, §7, §18, §19)**: silhueta detalhada da Bibiana (com espada, escudo e mecha reagindo ao Poder) e silhuetas distintas para cada um dos 7 inimigos (incluindo aura de mutação), mais medalhão visual giratório da moeda com símbolos distintos para Cara e Coroa.
4. **Sintetizador de Efeitos Sonoros Procedurais (`SoundFx`, GDD §7, §13, §19)**: geração em memória de `AudioStreamWAV` (PCM 16-bit) para tique e resultado da moeda, golpes, crítico, defesa, sino rachado do mini boss, fogueira, passos no mapa, vitória e derrota.

## Escopo

- `game/presentation/visual_theme.gd`: paleta Dark Fantasy, tabela dos 9 estágios de cor da mecha da Bibiana (`hair_stage_for_power`, `hair_color_for_power`, `hair_stage_name`), `PortraitCanvas` (silhuetas vetoriais da Bibiana e dos 7 inimigos + mutações), `CoinMedallion` (medalhão Cara/Coroa com animação de giro) e `draw_node_emblem` (brasões desenhados para os tipos de nó do mapa).
- `game/services/sound_fx.gd`: gerador procedural de `AudioStreamWAV` para 11 efeitos sonoros (`coin_tick`, `coin_heads`, `coin_tails`, `hit`, `crit`, `defend`, `bell`, `campfire`, `step`, `victory`, `defeat`) e reprodução segura em `Node`.
- `game/presentation/map/map_screen.gd`: tabuleiro visual com estradas curvas, praças desenhadas, brasões por tipo de nó, token da Bibiana com a mecha colorida, vinheta de névoa e som de passos/sino.
- `game/presentation/combat/combat_screen.gd`: retratos vetoriais da Bibiana e do inimigo, medalhão visual da moeda no overlay de Cara/Coroa, estilo dark fantasy nos painéis/barras e efeitos sonoros sincronizados.
- `game/presentation/game_screen.gd` e `game/presentation/run/run_panel_screen.gd`: cabeçalho e painéis com o tema dark fantasy, exibição do retrato da Bibiana e bordas de bronze envelhecido.
- `tests/unit/test_visual_and_audio.gd`: testes unitários verificando os 9 estágios da mecha do GDD §9, a geração válida de buffers `AudioStreamWAV` para todos os efeitos sonoros e a renderização dos componentes visuais (`PortraitCanvas`, `CoinMedallion`, `MapScreen`, `CombatScreen`).

## Critérios de aceite

- [x] `VisualTheme` implementa exatamente os 9 estágios de Poder e cores da mecha da Bibiana da tabela do GDD §9 (Poder 1, 3, 5, 8, 12, 17, 23, 30, 40).
- [x] `MapScreen` desenha estradas curvas, praças, brasões por tipo de nó e o marcador da Bibiana com a cor da mecha, mantendo 100% dos testes de mapa verdes.
- [x] `CombatScreen` exibe silhuetas distintas para a Bibiana e para cada um dos 7 inimigos de `enemies.json`, além do medalhão visual de Cara e Coroa com símbolos distintos (GDD §19).
- [x] `SoundFx` sintetiza `AudioStreamWAV` válidos (não vazios) para todos os 11 efeitos sonoros e funciona em headless sem erros nem nós órfãos.
- [x] Suíte de testes unitários 100% verde em headless (`tools/run_tests.sh`).

## Verificação

- `bash tools/run_tests.sh`: 315/315 testes verdes em 40 scripts (`tests/unit/test_visual_and_audio.gd` incluso).

## Revisão cruzada

Revisado contra `docs/REVIEW-CHECKLIST.md`: `VisualTheme` fica em `game/presentation/` e `SoundFx` em `game/services/`, mantendo `game/core/` 100% puro; os 9 estágios da mecha conferem com a tabela do GDD §9; `CoinMedallion` usa símbolos distintos para Cara e Coroa conforme GDD §19; `SoundFx.play()` não cria nós em modo headless para evitar órfãos nos testes. Sem achados pendentes.
