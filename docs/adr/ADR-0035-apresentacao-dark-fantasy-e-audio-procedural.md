# ADR-0035: Apresentação Dark Fantasy, Tabuleiro Visual e Áudio Procedural

- **Status:** Aceito
- **Data:** 2026-11-18
- **Tarefa:** TASK-031

## Contexto

Com todas as mecânicas do MVP concluídas e validadas (`TASK-001` a `TASK-030`), a interface ainda usava o visual de "protótipo cinza" (`ColorRect` chapados em combate, linhas retas simples no mapa e ausência total de som). O Orlando pediu para focar no MVP jogável de verdade com gráficos e som, substituindo o "tabuleiro tosco do Godot" por uma apresentação condizente com o GDD (§3, §5, §6, §7, §9, §17, §18, §19).

## Decisão

1. **Paleta Dark Fantasy e Regra do Acento (`VisualTheme` em `game/presentation/visual_theme.gd`)**:
   - Fundos e painéis usam tons dessaturados de ardósia, pedra úmida, carvão e bronze envelhecido.
   - Os três acentos saturados do GDD §3 e §18 são reservados para:
     - **A mecha da Bibiana**, seguindo exatamente os 9 estágios de Poder da tabela do GDD §9 (1 Castanho, 3 Verde claro, 5 Azul claro, 8 Azul escuro, 12 Vermelho claro, 17 Vermelho escuro, 23 Roxo claro, 30 Roxo escuro, 40 Branco).
     - **O ouro da moeda** (`Color(0.92, 0.75, 0.26)`), para lances, recompensas e destinos iluminados.
     - **O vermelho carmesim de perigo** (`Color(0.86, 0.22, 0.20)`), para golpes perigosos, mini boss e chefe.
2. **Tabuleiro Visual (`MapScreen`)**:
   - `MapScreen.Board` passa a desenhar um diorama 2D da Cidade Abandonada: fundo com faixas de névoa e vinheta, estradas curvas de calçamento (curvas Bézier quadráticas com trilhas de pedra e brilho dourado nos 3 destinos disponíveis), praças circulares sob cada nó, brasões vetoriais por tipo de nó e o peão da Bibiana no nó atual com halo na cor atual da mecha.
3. **Silhuetas Vetoriais e Medalhão da Moeda (`CombatScreen`)**:
   - `VisualTheme.PortraitCanvas` (subclasse de `ColorRect` para manter compatibilidade total com animações e testes) desenha a silhueta da Bibiana (armadura, escudo, espada e mecha de cabelo brilhante conforme o Poder) e silhuetas distintas para cada um dos 7 inimigos (`infected_citizen`, `giant_rat`, `carrion_crow`, `plague_hound`, `rotten_executioner`, `bell_warden`, `gravedigger`), além de indicadores visuais para as 4 mutações (`bloated`, `voracious`, `phantom`, `thorny`).
   - `VisualTheme.CoinMedallion` desenha o disco metálico da moeda com símbolos distintos para **Cara** (sol radiante) e **Coroa** (crânio/cruz sombria), atendendo à exigência de acessibilidade do GDD §19 ("Lados da moeda diferentes por forma e símbolo, não só por cor").
4. **Áudio Procedural em Código (`SoundFx` em `game/services/sound_fx.gd`)**:
   - Para evitar dependência de arquivos `.wav`/`.ogg` externos e problemas de importação em headless, `SoundFx` sintetiza `AudioStreamWAV` (PCM 16-bit mono a 22050 Hz) em memória para 11 efeitos sonoros (`coin_tick`, `coin_heads`, `coin_tails`, `hit`, `crit`, `defend`, `bell`, `campfire`, `step`, `victory`, `defeat`).
   - Em execução headless ou quando `time_scale <= 0.0` nos testes automatizados, `SoundFx` não instancia tocadores desnecessários, evitando vazamento de nós (`orphans`).

## Consequências

- O jogo ganha identidade visual e sonora imediata ("cara de jogo de verdade") mantendo 100% de determinismo no núcleo (`game/core/` permanece intocado; `RULES_VERSION` continua em `17`).
- Nenhuma textura ou áudio externo proprietário foi introduzido; todo o visual e áudio do MVP é autossuficiente, leve para Web/Android (Compatibility renderer) e verificável por testes unitários.
