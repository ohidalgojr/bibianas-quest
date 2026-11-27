# Crítica de UX do combate (540x960)

Base: `main` no commit `371ab8f` (TASK-071 já inclui bustos nítidos na linha do tempo e FX de golpe). Prints reais (Godot 4.7.2, Vulkan/lavapipe, retrato 540x960) em `docs/design/critica-diretor/combate-ux/`. A pasta `antes-f575da3/` guarda o que o Orlando viu antes da TASK-071 (linha do tempo com recorte de 30 px, "borrado"). Há trabalho de ícones de outra sessão **ainda não commitado** (`assets/bibiana/icons`, `icon_registry.gd`); este relatório não o avalia.

Limites honestos: não capturei crítico nem bloqueio (analisei o código: `_pop_text`, `_spawn_fx`); os tempos em ms são medidos por quadros a cerca de 26 ms por quadro (margem de ±40 ms); o hit-stop foi lido no código, não medido na tela.

## Veredito curto

O palco está bom (arena pintada, inimigo grande, Bibiana de costas: 7,5). **Tudo ao redor do palco ainda é UI de protótipo**: placas planas sem moldura de pedra, ícones do pacote antigo, texto onde deveria haver ícone, informação escondida pela gaveta, moeda que apaga a luta. Nota geral do combate: **4,8/10**. A queixa do dono procede: a linha do tempo melhorou (de 2 para 5), mas continua sem dizer *quem age agora*, e congela durante o turno.

## 1. Nota por elemento (0 a 10)

| Elemento | Nota | Em uma frase |
| --- | --- | --- |
| Linha do tempo / histórico | 5 | Bustos legíveis agora; mas sem "agora", sem passado, parada durante a animação, números sobre o rosto, primeiro slot rosa parece terceira facção |
| Registro de combate | 3 | Uma linha por 2,2 s e some; sem histórico; cobre os pés da Bibiana (y 681–717) |
| Selo de intenção | 3,5 | Cartão de texto ("ATAQUE", "MOEDA") em vez de selo de ícone; cobre o chapéu do chefe; vira "…" no turno do inimigo; detalhe em 13 px |
| Barras HP/MP | 5 | Funcionam; verde e azul saturados, texto de 13 px com contraste 1,95:1 sobre o verde; sem busto nem nome da heroína |
| Status | 4 | Ícones de 30 px em posição fixa `(300,68)`/`(8,252)`, não presos aos personagens; sem contador de turnos |
| Previsão de dano | 5,5 | Conteúdo certo ("dano 14-17 · acerto 87% · crít 5% · +2 MP", contraste 12:1), mas é uma linha chapada e some sob a gaveta |
| Botões Atacar/Defender | 4,5 | Mesma aparência dos dois e das abas, 62 px de altura, ícone de 30 px (Atacar mostra um brilho azul); desabilitado a ~35% parece quebrado |
| Gavetas | 4 | Cobrem HP/MP, previsão e Atacar/Defender; texto centralizado; custo no rótulo; vazio embaixo; sem prévia de dano |
| Ícones | 3 | Pacote gnola14 de 34 px (pixel art colorida) sobre arte pintada; Fugir é um furacão; Velocidade sem ícone |
| Moeda cara-ou-coroa | 3 | Painel preto opaco cobre o combate, medalhão de 88 px é um sol, sem chance nem consequência, botões lisos |
| Números de dano | 4 | 30 px, laranja escuro `(0.85,0.35,0.2)`, caem no meio da capa da Bibiana; "Errou" em cinza |
| Feedback de acerto/crítico/bloqueio | 4,5 | Existem corte, bloqueio e crítico por quadros; falta flash no inimigo, hit-stop real e tremor da arena; do toque ao impacto são cerca de 900 ms |
| Hierarquia visual | 5 | Nada manda: tudo tem o mesmo peso (placa escura, filete bronze fino) |
| Zonas do polegar / toque | 6,5 | Ações em y 820–944, certo; abas de 52 px e margem inferior de 16 px abaixo do guia (56 e 24) |
| Contraste de texto | 6 | Texto principal 11–12:1; HP 1,95:1; Atacar desabilitado 3,05:1 |
| Ocupação do palco | 7,5 | 645 px (67%); passa dos 568–576 do guia e empurra os controles para baixo |

## 2. Problemas, por prioridade

### P0 (bloqueiam a sensação de combate bom)

1. **Linha do tempo não mostra quem age agora e congela durante o turno.**
   Causa: `CombatScreen._refresh_timeline()` só roda no fim de `_play()` (`combat_screen.gd`), então durante a rodada inteira os 5 slots ficam iguais (ver `06-sequencia-turno-ataque.png`). Além disso `Combat.preview_turn_order()` parte do estado *depois* de o turno atual ser pago (`_advance()` desconta a carga antes de `_awaiting_player = true`), então no turno da Bibiana o slot 1 é o inimigo: o jogador nunca vê a si mesmo como "agora".
   Correção: componente novo `TurnTimeline` (controlador `RefCounted` + `Control`, padrão do ADR-0010) atualizado **por evento** (`TURN`, `ACTION`), com o ator atual separado do futuro. Especificação completa na seção 4.
2. **A gaveta esconde o que o jogador precisa para decidir.**
   Causa: `SHEET_HEIGHT = 270` e `SHEET_BOTTOM = 78` põem a folha em y 612–882, por cima das barras (735), da previsão (765–810) e de Atacar/Defender (820–882). O "toque de novo para confirmar" escreve a previsão em `_forecast`, que fica coberto (`12-gaveta-skill-selecionada.png`: só o fundo da linha muda de cor). O segundo toque na mesma linha não se descobre sozinho.
   Correção: folha em y 548–888 (340 px) com **cabeçalho próprio** (HP e MP em barras de 18 px), linhas de 64 px, e **rodapé fixo de 64 px** com a previsão da ação escolhida e um botão **CONFIRMAR** de 56 px (borda ouro). Primeiro toque seleciona, o botão confirma; sem toque duplo.
3. **A moeda apaga a luta e não diz o que está em jogo.**
   Causa: `_overlay()` ancora um painel `Color(0.03,0.03,0.05,0.92)` em y 25%–75% (240–720), cobrindo inimigo, heroína e cortando a linha do tempo no meio (`15-moeda-escolha.png`). `_ask_call(chance, odds)` **ignora `chance`**. O selo de intenção já virou "…" (`_apply` ACTION do inimigo), então a consequência do erro ("dano +50% e Leptospirose") sumiu justo na hora de escolher. `CoinMedallion` mostra um sol de 88 px, igual para os dois lados; os botões (80 px) não têm moeda nem porcentagem.
   Correção: ver seção 3, zona "Moeda": escurecer só 55% o palco (sem painel opaco), medalhão de 176 px, linha de consequência em chip `BLOOD`, botões Cara/Coroa de 96 px com mini-moeda de 48 px e a chance (GDD §7), tudo conforme o Guia §6.
4. **Selo de intenção é um cartão de texto, não um selo.**
   Causa: `CombatTexts.INTENT_ICONS` devolve strings ("ATAQUE", "FORTE", "MOEDA"); `_show_intent` as põe numa `Label` de 20 px com detalhe de 13 px; `_anchor_intent()` o centra sobre a cabeça e cobre o chapéu do Coveiro (`03-chefe-gravedigger.png`). Golpe de moeda vira um parágrafo de 3 linhas dentro do palco (`04-largo-giant_rat.png`). Quando o inimigo age vira um quadrado com "…".
   Correção: selo 56x56 hexagonal conforme Guia §2.8 (ícone 40 da folha `ico-b-skills-intent`, linhas 3–4), chip 24x16 com o dano previsto, borda por tipo (golpe `BLOOD`, debuff `VENOM`, moeda `GOLD`, mortal caveira com pulso 1 Hz), pulso 1,6 Hz e som grave um turno antes de golpe perigoso; texto só no toque longo (350 ms). Posição: 6 px acima da cabeça deslocado 40 px para o lado oposto à Bibiana; se cobrir o rosto do chefe, canto (444, 96). **Nunca mostrar "…"**: no turno do inimigo o selo fica aceso com o golpe que está sendo executado.
5. **O golpe não "bate".**
   Causas, todas em `combat3d_stage.gd`:
   - Do toque ao impacto passam cerca de **900 ms** (`STRIKE_APPROACH 0.38` + `STRIKE_WINDUP 0.16` + quadros do FX), repetidos em toda ação.
   - `hit_stop()` procura `AnimationPlayer`; sprites (`Sprite3D`) não têm, então o **hit-stop não faz nada**.
   - `play(true, "hit")` só desloca 0,35 unidade por 70 ms: o inimigo não pisca nem recua de forma legível (`07-zoom-impacto-ataque-heroi.png`).
   - O corte `slash` mede 3,2 unidades (cerca de 250 px): cobre rosto e número.
   - Número `-15`: 30 px, laranja escuro, 6 px de contorno (`_pop_text`), sem "pop".
   - O inimigo praticamente não se mexe ao atacar (`08-sequencia-turno-inimigo.png`), e a heroína só ganha o corte e o número; sem vinheta, sem tremor da arena.
   Correção: sequência em ms da seção 5.

### P1

6. **Ícones: pacote antigo.** `IconRegistry.UI` aponta para `S_Sword02`, `S_Buff02`, `S_Wind01` (gnola14, 34 px) com `icon_max_width = 30`. As folhas novas (`docs/design/refs/ui/ico-a-actions.jpg`, `ico-b-skills-intent.jpg`) já existem: espada com garras, escudo de madeira, livro, bolsa, bota com porta (Fugir), ampulheta (Velocidade 1x) e ampulheta com setas (2x). Cortar a 128 px, exibir a 40 px (primários) e 28 px (abas/linhas). Conferir com a sessão que já mexe em `icon_registry.gd`.
7. **Sem hierarquia entre botões.** Atacar e Defender são iguais (250x62 cada) e iguais às abas. Correção: Atacar 296x80 com borda `GOLD` e "respiração" de 0,3 Hz, Defender 204x80 secundário, abas 164x56. Alterar em `_build()` (`custom_minimum_size`) e no `DarkTheme`.
8. **Registro sem histórico, e sobre os pés da heroína.** `_ticker` ocupa y 681–717 (`offset_top -44`) e o hero termina em y≈700. Correção: placa de 28 px (y 612–640) com 1 linha de 15 px; toque abre folha com as últimas 8 linhas (`_log` já guarda `LOG_LINES = 7`; só é preciso exibi-las). O painel `log_panel` hoje fica invisível.
9. **Números de dano.** Guia §5.4: normal 44 px `#FFF3D6` com contorno 4; crítico 64 px `GOLD` com contorno vermelho e "CRÍTICO" em 20 px; veneno `VENOM`; bloqueio `STEEL_BLUE`; "ERROU" 22 px. Hoje 30/44 px e `COLOR_DANGER`. Posição do dano na heroína: `screen_pos(false)` usa altura 1,2 (cai no meio da capa); subir para 1,7 (altura do ombro).
10. **Dano recebido não tem feedback na heroína.** Só a barra muda. Adicionar vinheta vermelha nas bordas (alfa 0,25, 160 ms), tremor de 4 px na placa HP, flash branco de 80 ms na barra.
11. **Barras e texto.** Verde `(0.3,0.7,0.35)` e azul `(0.3,0.45,0.85)` saturados demais; usar `#4F7A3A→#2F4A22` e `#5B7FA6→#3B5C86`, texto de 14 px (hoje 13) com contorno 3 e tiques a cada 25% (Guia §2.5). Altura de 26 (hoje 22).
12. **Estado desabilitado.** Atacar/Defender a 35% parecem quebrados (`04-largo-giant_rat.png`). Usar alfa 0,40 com arco de carga de 3 px `GOLD` no ícone (Guia §5.6).
13. **Linhas de habilidade.** Texto centralizado, custo dentro do rótulo "(6 MP)", sem prévia. Cartão de 64 px: ícone 40 | nome 17 px à esquerda | custo MP `STEEL_BLUE` à direita | prévia `GOLD` 14 px embaixo ("dano 22-26 · 87%"). Sem MP: alfa 0,5, custo `BLOOD`, cadeado 16.
14. **Previsão do golpe do inimigo.** O selo diz "Defender reduz o dano", sem número. Exige um `preview_enemy_strike` de leitura no núcleo (sem mudar fórmula, seguindo o ADR-0029); levar como tarefa própria.

### P2

15. Margem inferior 16 px → 24 px de zona segura (hoje as abas terminam em y 944).
16. Palco de 645 px → 568 px (y 80–648); reposicionar `PLAYER_POS`/câmera para os pés da heroína em y≈600 do palco.
17. Status: ícones de 24 px com contador de turnos, presos à placa do inimigo (direita da barra) e à placa da heroína; hoje `_status_enemy.position = Vector2(300, 68)` fixo.
18. Chefe e elite: tampas de bronze na barra do inimigo, caveira no selo de Golpe Mortal.
19. Velocidade 1x/2x é muito usada e mora na aba Tático; promover a botão de ícone de 48 px no canto superior direito do palco.
20. Sprites de 126x224 (Cidadão Infectado) ampliados com filtro `NEAREST` sobre arena pintada de alta resolução: borda serrilhada contra fundo liso. Reentregar a 2x (Guia §0.4) ou filtrar linear com contorno de luz de 1 px.

## 3. Wireframe ideal, 540x960 (zona, y inicial, altura)

Imagem: `combate-ux/19-wireframe-ideal-540x960.png`.

| Zona | y | h | Conteúdo |
| --- | --- | --- | --- |
| Segura (sistema) | 0 | 24 | vazio |
| Placa do inimigo | 24 | 52 | Nome Cinzel 20 à esquerda + chip "Nv 3"; chips de status 24 px à direita; barra de HP 26 px (x 16–524) com tampas de bronze se elite/chefe |
| **Palco (fixo)** | 80 | 568 | Arena pintada; inimigo 55–62% da altura, cabeça ≥ 56 px abaixo do topo; Bibiana 190 px, pés em y≈600 do palco; vinheta e chuva |
| · linha do tempo | 96 | 330 | Coluna x 8–68 (seção 4) |
| · selo de intenção | dinâmico | 56 | 6 px sobre a cabeça; mínimo y 96; chefe em (444, 96) |
| · números de dano | dinâmico | | 40 px acima do impacto (seção 5) |
| · placa de log | 612 | 32 | 1 linha, 15 px, `IVORY_DIM`, fundo `#00000088`; toque abre histórico |
| Faixa de previsão | 652 | 44 | Ícone 24 + "ATACAR  14-17 · 87% · crít 5% · +2 MP" (números `GOLD`) à esquerda; chip de ameaça do inimigo à direita |
| Placa da heroína | 700 | 38 | Busto 36 px + HP 26 px + MP 26 px lado a lado (x 60–524), texto 14 px |
| Ações primárias | 744 | 80 | **ATACAR** x16 w296 (borda `GOLD`), **DEFENDER** x320 w204; ícone 40 + rótulo Cinzel 20 caixa-alta |
| Abas | 832 | 56 | Habilidades / Itens / Tático, 164x56, ícone 28 + rótulo 17 px |
| Zona segura | 888 | 72 | 24 de gesto + respiro |
| **Folha (gaveta aberta)** | 548 | 340 | Alça 48x4; cabeçalho 44 com HP/MP em barras de 18 px; lista de 3 linhas de 64 px (4ª parcialmente visível com fade de 24 px); rodapé fixo de 64 com previsão + CONFIRMAR 56 px; escurece o palco a 35% |
| **Moeda (sobreposição)** | 80 | 568 | Escurece o palco a 55%, sem painel opaco; título "GOLPE DE MOEDA" Cinzel 24 em y 130; medalhão 176 px centrado em y≈380 com halo âmbar; chip de consequência em y 520 ("Errar: dano +50% e Leptospirose", 17 px, `BLOOD`); botões CARA (x16 w246) e COROA (x278 w246) em y 700, 96 px de altura, mini-moeda 48 + nome Cinzel 22 + chip "50%". Linha do tempo e selo ficam **acima** do escurecimento |

Toque: alvos ≥ 48 px (slots da linha do tempo ocupam 44 px visíveis mas têm área de toque de 48x48); 8 px entre alvos; tudo que se aperta com frequência dentro de y 620–936.

## 4. Linha do tempo / histórico ideal

Referências: Tactics Ogre e FFT (coluna de retratos com ordem), Sword of Convallaria (retratos com moldura e barra no mesmo corpo), o mock `bibiana-mockup-combate-mobile.jpg` (5 retratos quadrados à esquerda).

**Estrutura da coluna** (x 8–68, de cima para baixo, passo variável):

| Posição | Tamanho | Função |
| --- | --- | --- |
| 1 slot "passou" (opcional, 1 só) | 32x32, 60% de opacidade, dessaturado | Quem agiu por último; selo de 14 px no canto inferior direito com a ação (espada, escudo, moeda, frasco) |
| **AGORA** | 60x60, moldura `GOLD` 3 px, brilho externo 6 px pulsando a 0,8 Hz, chip "AGORA" Cinzel 700 14 px encostado embaixo | Quem decide ou executa neste instante |
| 4 futuros | 44x44, passo 50 px, opacidade 100/85/70/55% | Próximos turnos |

Total: 36 + 8 + 66 + 8 + 4×50 = cerca de 318 px (y 96–414). Em criaturas largas (rato, cão) a cabeça começa em x≈70: a coluna de 60 px não a cobre.

**Quantos mostrar:** 4 futuros. O combate é 1x1 e alterna; mais que 4 não traz informação. Uma coluna acima de 7 linhas vira ruído.

**Destaque do turno atual:** só o AGORA tem borda dourada; **o primeiro futuro não leva cor especial** (hoje `lightened(0.35)` deixa o slot 1 rosa e parece uma terceira facção). Moldura aliada `#5B7FA6`, inimiga `#B82824`; nunca o azul e o vermelho puros atuais `(0.35,0.55,0.95)`.

**Rótulos e números:** sem número sobre o rosto (a posição já dá a ordem). Texto só no AGORA ("AGORA") e no toque longo (350 ms): tooltip com nome, HP atual, VEL e a intenção. Dois turnos seguidos do mesmo lado (cão rápido): elo de bronze de 8 px entre os dois slots, para parecer decisão do sistema e não erro.

**Previsão do futuro:** o primeiro slot inimigo mostra no canto inferior direito o ícone de intenção de 18 px (o golpe já é conhecido, `_choose_intent`); os demais mostram "?" de 14 px `IVORY_DIM`.

**Como mostrar quem agiu:** ao terminar um turno, o retrato do AGORA encolhe de 60 para 32 px e sobe ao slot "passou" (180 ms, `EASE_OUT` cúbico), enquanto os futuros sobem 50 px e o novo último entra com fade de 120 ms. O antigo "passou" desaparece (fade 150 ms). Atualizar **por evento** (`TURN`, `ACTION`), nunca só no fim de `_play()`.

**Recorte do busto por tipo de criatura** (pré-gerado como PNG 128x128 em `assets/bibiana/busts/<id>.png`, reduzido com Lanczos e exibido a 44/60 px; hoje o recorte roda em execução em `_bust_texture()`):

| Tipo | Exemplos | Recorte |
| --- | --- | --- |
| Humanoide | Cidadão Infectado, Coveiro, Carrasco | Quadrado de lado 40% da altura; topo da cabeça a 12% do quadro; corte na clavícula |
| Chefe e elite | Coveiro, Carrasco | Mesmo, mais largo (lado 46%) para chapéu e capuz inteiros; hoje o capuz do Carrasco sai cortado |
| Quadrúpede largo | Rato Grande, Cão de Peste, Mãe dos Ratos | Região esquerda 32%; quadrado de lado 80% da altura; focinho e olhos a 1/3 do quadro; hoje o focinho fica no limite e a cabeça do cão perde o topo |
| Voador | Corvo | Cabeça + asa dianteira, lado 85% da altura |
| Amorfo | Lodo, sanguessuga | Massa inteira centrada, sem cabeça |
| Espectral | Fantasma do Sino | Metade superior; halo preservado |
| Bibiana | Guerreira | Rosto de frente (já usado), lado 34%, com a cota de malha visível |

Moldura: `ui-slot-frame` (filete bronze 2 px + borda preta 2 px), fundo gradiente `#0B0C10→#15171C` com 20% de tinta da facção, bisel interno. A cor da facção vai na moldura, não em um retângulo chapado.

## 5. Feedback de animação de ataque (sequência em ms, 1x)

Medido hoje: toque → impacto ≈ 900 ms; fim do turno da heroína ≈ 1,2 s; golpe do inimigo chega ≈ 1,5 s; controle volta ≈ 2,2 s. A meta é **toque → impacto ≤ 450 ms** e rodada completa ≤ 1,6 s, porque é a ação mais repetida do jogo. Constantes a mudar: `STRIKE_APPROACH`, `STRIKE_WINDUP`, `STRIKE_RECOVER`, `STRIKE_RETURN` (`combat3d_stage.gd`) e `EVENT_DELAY` (`combat_screen.gd`: 0,35 → 0,22 s; 0 quando uma animação já ocupa o tempo).

### Golpe da Bibiana (t = 0 no toque)

| t (ms) | Ação |
| --- | --- |
| 0 | Botão escala 0,96 por 60 ms; vibração 12 ms; botões a 40% com arco de carga; AGORA pulsa; linha de log |
| 0–60 | Antecipação: Bibiana recua 8 px e ergue a espada (pose `attack`) |
| 60–260 | **Aproximação 200 ms**, `EASE_OUT` quadrática até 1,1 unidade do inimigo (hoje 1,55); 2 quadros de caminhada de 70 ms; 4 partículas de poeira nos pés |
| 260–300 | Pausa de 40 ms com a espada no alto (o olho do jogador precisa ver o "vai bater") |
| **300** | **IMPACTO.** Tudo abaixo ocorre no mesmo quadro |
| 300 | Corte `slash` de 6 quadros em **150 ms** (hoje 300), tamanho **2,2 unidades** (hoje 3,2), alinhado ao eixo do golpe, a 55% da altura do inimigo |
| 300 | **Hit-stop 70 ms** (crítico 110 ms) congelando tweens e FX: pausar o `Tween` ou usar `Engine.time_scale = 0` com temporizador que ignora a escala; **não** depender de `AnimationPlayer` |
| 300–360 | Inimigo: flash branco HDR `modulate = (3,3,3)` por 60 ms; depois tinta `(1.0,0.55,0.5)` até 200 ms e volta ao normal |
| 300–370 | Inimigo recua 14 px no eixo do golpe em 70 ms, assenta em 180 ms (hoje 0,35 unidade ≈ 50 px em 70 ms, pouco legível) |
| 300–460 | **Tremor da arena** 6 px a 40 Hz com decaimento linear por 160 ms (crítico 10 px, 220 ms), aplicado ao contêiner do palco e a 60% no fundo (paralaxe) |
| 300 | **Número de dano**: nasce 40 px acima da cabeça do inimigo; Cinzel 800 44 px `#FFF3D6` com contorno preto de 4 px; escala 0,6→1,15 em 90 ms →1,0 em 60 ms; sobe 36 px em 700 ms (`EASE_OUT`); some nos últimos 200 ms |
| 300 | Barra de HP do inimigo cai na hora (rastro `IVORY` 0,4 s depois), flash branco de 80 ms na barra |
| 300 | Som `hit` sincronizado ao quadro do impacto (hoje sai no evento, antes do corte aparecer) |
| 460–760 | Bibiana volta em 300 ms, `EASE_IN_OUT`, já na pose de guarda; o próximo evento começa em paralelo, sem esperar |
| ≈ 480 | Linha do tempo: AGORA vira "passou", próximo sobe (seção 4) |

**Crítico:** além do acima, flash de tela `#FFF3D6` alfa 0,35 em 60 ms, `fx_crit_burst` (raios dourados) por 250 ms, número de 64 px `GOLD` `#E5B84A` com contorno vermelho e "CRÍTICO" de 20 px acima, hit-stop 110 ms, tremor 10 px.
**Erro:** inimigo desvia 20 px em 150 ms, "ERROU" 22 px `IVORY_DIM` sobe 24 px; sem hit-stop, sem tremor.

### Golpe do inimigo (t = 0 quando o AGORA vira inimigo)

| t (ms) | Ação |
| --- | --- |
| 0–120 | Antecipação: inimigo recua 12 px e fica 1,15x mais claro (golpe perigoso: brilho âmbar-vermelho; moeda: halo dourado atrás); selo pulsa a 1,6 Hz |
| 120–200 | Investida de 80 ms, `EASE_IN`, 0,4 unidade em direção à Bibiana (hoje o inimigo mal se move) |
| **200** | **IMPACTO** |
| 200 | Pose `hurt` da Bibiana; corte do inimigo no peito dela com 1,6 unidade; hit-stop 60 ms (crítico 100) |
| 200–380 | Tremor da arena 8 px/180 ms; **vinheta vermelha nas bordas** alfa 0,25 por 160 ms; placa HP treme 4 px; barra flash branco 80 ms |
| 200 | Número `-10` a **44 px** em `#E5645F` (BLOOD claro, não o laranja escuro atual), nasce à altura do ombro (1,7 unidade) e sobe 36 px |
| 380–600 | Inimigo volta à marca em 220 ms |

**Bloqueio (Defender ativo):** sem pose `hurt`, o escudo recebe `fx_block` de 150 ms com 8 fagulhas âmbar; número "BLOQUEOU −4" em 36 px `#9DB7D8` (`STEEL_BLUE` claro); tremor 3 px; sem vinheta; hit-stop 40 ms.
**Veneno/sangramento:** sem avanço; bolhas `VENOM` (8 partículas, 1 s) ou 6 gotas `BLOOD`, número na cor do efeito.
**Golpe de moeda:** a escolha acontece **antes** do impacto (seção 3, zona Moeda); a investida só começa depois do resultado; erro de moeda soma 60 ms de hit-stop e 2 px de tremor ao padrão.

## 6. Ordem sugerida de trabalho

1. TASK de feedback: itens 5, 10 e 9 (constantes, hit-stop real, flash, números). Maior ganho sentido por menor custo.
2. TASK `TurnTimeline` (item 1 e seção 4), com os bustos pré-gerados.
3. TASK folha de gavetas e faixa de previsão (item 2, 13); depois moeda (item 3).
4. TASK selo de intenção em ícone (item 4) junto com o corte das folhas `ico-a` e `ico-b` (item 6).
5. Hierarquia e barras (itens 7, 11, 12) e, por último, os P2.

Cada tarefa de tela só fecha com print em `docs/tasks/prints/` e o "teste do print" (`docs/ART-DIRECTION.md` §8). Esta crítica não alterou código nem assets.

## 7. Evidências (pasta `combate-ux/`)

| Arquivo | O que mostra |
| --- | --- |
| `01` a `05` | Luta comum, elite, chefe, rato e cão no estado inicial |
| `06-sequencia-turno-ataque.png` | 15 quadros de 0 a 2,1 s da rodada completa (linha do tempo parada, selo "…", corte, tiro do inimigo) |
| `07-zoom-impacto-ataque-heroi.png` | Quatro quadros do impacto: corte cobrindo rosto e número |
| `08-sequencia-turno-inimigo.png` | Turno do inimigo: quase sem investida, corte e número na heroína |
| `09-zoom-linha-do-tempo-5-inimigos.png` | Bustos atuais dos cinco inimigos |
| `10` a `14` | Vez do jogador e as três gavetas (a previsão some sob a folha) |
| `15` a `18` | Moeda: escolha, giro, resultado e retorno com o dano na heroína |
| `19-wireframe-ideal-540x960.png` | Layout alvo |
| `zoom-*` | Ampliações da linha do tempo, dos botões/barras e do selo |
| `antes-f575da3/` | O estado anterior (linha do tempo "borrada") |

Scripts usados: `/tmp/claude-0/ux_scripts/` (`states.gd`, `coin.gd`, `burst.gd`, `rects.gd`), fora do projeto.
