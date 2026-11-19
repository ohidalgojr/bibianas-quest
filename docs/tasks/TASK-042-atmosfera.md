# TASK-042: atmosfera do jogo

| Campo | Valor |
| --- | --- |
| Status | Em verificação (código, testes e prints prontos; falta o Orlando aprovar os prints e ouvir o som) |
| Aberta em | 2026-11-19 |
| Fase | 1, feedback do Orlando sobre o MVP visual ("a UI parece um RPG de texto") |
| GDD | 3, 14, 18, 19 |
| ADRs | ADR-0036 (e os que a tarefa criar) |

> Leia `docs/ART-DIRECTION.md` antes. A tarefa só fecha com o "teste do print" (seção 8) e as seis respostas por escrito.

## Objetivo

O jogo passa a **parecer e soar como um jogo sombrio**, antes de ganhar ícones, mais inimigos e outro ritmo (TASK-043 a 045). Atmosfera aqui é: **a interface com cara de dark fantasy** (fonte, molduras, botões, barras), **o som que cerca o jogador** (chuva, fogo, trovão por cima da música), **partículas vivas** (cinzas, brasas, poeira), **relâmpagos** raros e **transições** entre telas.

## Fora do escopo

- Ícones de itens, skills e status (TASK-043); novos inimigos e modelos (TASK-044); mudança de ritmo e de gameplay (TASK-045).

## Critérios de aceite

- [x] **Tema de interface** único (`DarkTheme`): fonte de título (Cinzel) e de texto (Alegreya), botões com moldura de bronze e brilho no toque, painéis de pedra escura, barras finas com brilho; aplicado a todas as telas (menu, mapa, combate, painéis, Santuário, fim).
- [x] **Som ambiente por cima da música:** chuva em laço (mapa, combate, menu), crepitar do fogo em laço (fogueira), trovão ocasional com relâmpago na tela; tudo sintetizado, volume baixo, sem quebrar o silêncio antes da moeda.
- [x] **Partículas de atmosfera:** cinzas e brasas à deriva sobre mapa, combate e fogueira (além da chuva e da névoa).
- [x] **Relâmpago:** clarão raro e curto, com trovão atrasado, no mapa e no combate (desligável pela opção de reduzir flashes, GDD §19).
- [x] **Transições:** entrada em fade a partir do preto entre telas; título do jogo com tratamento (fonte, brilho) no menu.
- [x] Interruptores em `GfxSettings` (clima, flashes); teste de contrato; prints antes e depois; executável gerado.

## Arquivos afetados

- `game/presentation/fx/` (`dark_theme.gd`, `ash_layer.gd`, `lightning.gd`, `screen_fade.gd`), `game/services/sound_fx.gd`, `game/services/music_box.gd`, `game/presentation/game_screen.gd`, `game/presentation/combat/combat_screen.gd`, `assets/google_fonts/`, `assets/LICENSES.md`

## Testes esperados

- Contratos: o tema carrega as fontes e estiliza botões, painéis e barras; os sons novos sintetizam um buffer válido (laço onde for o caso); as camadas de partícula e o relâmpago montam sem bloquear toque; `GfxSettings` desliga cada efeito.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR. `RULES_VERSION` não muda (só apresentação).
- Todo asset externo registrado em `assets/LICENSES.md` (as fontes Cinzel e Alegreya são OFL).
- Acessibilidade (GDD §19): opção de reduzir flashes e de desligar vibração continuam possíveis.

## Verificação

Suíte em 2026-11-19: 341 testes, 341 passando (`test_atmosphere.gd`). Prints: `docs/tasks/prints/TASK-042-home|combate|mapa|fogueira|loja.png`. 60 fps no PC deste agente.

**Feito:** `DarkTheme` (Cinzel para títulos e botões, Alegreya para texto, botões com moldura de bronze e brilho dourado, painéis de pedra escura, barras e rolagem finas; aplicado ao `GameScreen` e à tela de combate), sons sintetizados `rain_loop`, `fire_loop` e `thunder` em `SoundFx`, `Ambience` (chuva no mapa, combate e menu; fogo na fogueira; trovão a cada 22 a 48 s com `lightning`), `LightningFlash` (clarão em dois lampejos, desligável por `GfxSettings.flashes`), cinzas e brasas no `WeatherLayer` (clip na área do cenário), fade a partir do preto a cada troca de tela e título do menu em Cinzel. Fontes OFL registradas em `assets/LICENSES.md`.

**Não verificado:** **o som não foi ouvido por mim** (só confirmei que os buffers existem e fazem laço); os volumes são palpite e precisam do ouvido do Orlando. O relâmpago e o fade só foram vistos em quadro parado.

**Falta:** a opção "reduzir flashes" existe em `GfxSettings` mas ainda não há tela de opções para ligar; o Santuário e a tela de combate usam o tema mas seus textos longos seguem em botões e rótulos (cartões e ícones na TASK-043).

## Revisão cruzada

Pendente.
