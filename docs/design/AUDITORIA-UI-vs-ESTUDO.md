# Auditoria: UI e direção de arte do jogo contra o estudo do Gemini

| Campo | Valor |
| --- | --- |
| Escrito em | 2026-11-22 |
| Escopo | `ESTUDO-ui-mobile-inimigos-estetica.md` (Partes 1 a 6), `ART-DIRECTION.md`, `ADR-0042`, `FEEDBACK.md`, `IDENTIDADE-VISUAL.md`, `ROAMING-BOSS-perseguidor-coroado.md`, GDD §17 a §19 |
| Código lido | `game/presentation/**` (combate, combat3d, map3d, run, camp3d, fx, game_screen, sanctuary), branch `claude/project-improvements-701756`, incluindo mudanças ainda não commitadas da TASK-062/063 |
| Prints lidos | `docs/tasks/prints/TASK-055` a `TASK-063` e `_antes/` |
| Método | uma linha por requisito concreto; status só com evidência em arquivo:linha ou print. Nada foi executado (o jogo não foi aberto); onde o print e o código divergem, está dito |

Legenda: **APLICADO** (feito como o estudo pede), **PARCIAL** (existe, mas incompleto ou diferente do pedido), **NAO APLICADO** (não existe no código nem no print).

Leitura rápida: a base mecânica da UI do estudo entrou (gavetas, dois toques, prévia de nó, bottom sheet, fogueira sincronizada, Bayer, ambiente frio). O que **não** entrou é justamente o que o Orlando vê primeiro: o design system (`DarkTheme 2.0`), a hierarquia visual dos botões, o palco do combate a 57%, a intenção sobre a cabeça do inimigo, o ritual da moeda, os cartões de loja com comparação, o cabeçalho de depuração do mapa, o Santuário 3D e 5 dos 8 inimigos.

---

## 1. As 8 Leis de Ouro (Estudo §2.3)

| ID | Fonte | Requisito | Status | Evidência | O que falta |
| --- | --- | --- | --- | --- | --- |
| L1 | §2.3.1 | Mapa do polegar em 540x960: 0-88 px só leitura, 88-636 palco, 636-960 polegar | PARCIAL | `combat_screen.gd:543-561` (nome e barra do inimigo no topo), dock embaixo (`:625-673`); print `TASK-061-combate-gravedigger.png` | Palco vai de y~150 a y~545 (41%), não 88-636. Faixa de intenção e coluna de retratos entram no palco |
| L2 | §2.3.2 | Regra dos 55%+ de palco livre; barra ou log que reduza para menos da metade vira ícone ou gaveta | NAO APLICADO | `combat_screen.gd:565` (`custom_minimum_size 0,330`), log 44 px e previsão ainda fixos dentro do palco (`:890-916`); print mede 395 px de 960 | Subir para ~548 px úteis (57%): remover log fixo, previsão para dentro do dock, intenção para o mundo |
| L3 | §2.3.3 | Sem hover: toque 1 seleciona e mostra previsão, toque 2 confirma | PARCIAL | `combat_screen.gd:82, 783-794` (confirmação em 2 toques); `:919-920` ainda liga `mouse_entered` | Atacar e Defender executam direto (permitido por D-UI-1). Falta botão "armado" com brilho dourado (só `modulate`), e a previsão de Atacar/Defender não aparece antes do toque no celular |
| L4 | §2.3.4 | Dock de 5 botões: Atacar e Defender primários (56-64 px), gavetas Habilidades/Itens/Tático | PARCIAL | `combat_screen.gd:21-22, 630-649, 659` (62 px nos primários) | Abas de gaveta têm 38 px (`:638`) e botões de gaveta 46-52 px (`:659`), abaixo dos 48 px. A gaveta de skills abre por padrão (`:674`) e empurra o palco. Gaveta não é bandeja deslizante com animação |
| L5 | §2.3.5 | Bottom sheets e cartões com ícone, título curto, badge de delta, selo de preço dourado | PARCIAL | Sheet com alça e rodapé: `run_panel_screen.gd:49-77`; cartões 2x2: `:354-372` | Cartões são `Button` com texto corrido em Cinzel; sem badge de delta, sem selo de preço, sem borda por raridade (ver seção 4) |
| L6 | §2.3.6 | Zero texto duplicado; sem "(OURO INSUFICIENTE)" no botão | PARCIAL | HP/MP duplicados escondidos no palco (`combat_screen.gd:936-938`); sufixo ainda em `run_panel_screen.gd:195-196` e `:286`; print `TASK-063-shop.png` | Trocar o sufixo por cartão esmaecido e selo de preço vermelho. "ATAQUE Ataque" aparece nos prints 055-061; o código já dedupica (`combat_screen.gd:323`), reconferir em print novo |
| L7 | §2.3.7 | Hierarquia por categoria: primário bronze iluminado/carmesim, secundário pedra, risco âmbar, desabilitado limpo; alvo mínimo 48 px, 8-10 px de gap | NAO APLICADO | `dark_theme.gd:80-95`: um único `StyleBoxFlat` para todo `Button`; `_cta_button` só em `game_screen.gd:161` | Variantes PrimaryButton/DangerButton/risco (ver seção 8). Atacar e Defender têm o mesmo visual das abas |
| L8 | §2.3.8 | Juice: `scale 0.96` em 60 ms, barra fantasma 350 ms, `Input.vibrate_handheld(25)`, transições 180 ms CUBIC/EASE_OUT | NAO APLICADO | Nenhuma ocorrência de `vibrate_handheld`, `TRANS_CUBIC` ou escala de pressão em `game/presentation`. Só há hit-stop (`combat_screen.gd:243`) e números flutuantes (`:275-294`) | Compressão no toque, trail de HP, vibração, transições de gaveta e sheet |

---

## 2. Combate (Estudo §3.1, §3.2.1)

| ID | Fonte | Requisito | Status | Evidência | O que falta |
| --- | --- | --- | --- | --- | --- |
| UI-C1 | §3.2.1 | Palco 57% (~548 px), `CAM_SIZE` 5.8 para 4.2-4.5 | PARCIAL | `combat3d_stage.gd:12` (`CAM_SIZE 3.9`, mais fechado que o pedido); palco 41% no print | Câmera e escala entraram (TASK-061); a altura do palco, não |
| UI-C2 | §3.2.1 | Topo 76 px somente leitura: sino/mudo, nome, nível, HP do inimigo com trail | PARCIAL | `combat_screen.gd:543-561`; botão de som ausente no print de combate | Falta ícone de som (sumiu no combate), ícone de caveira/tipo, trail de dano |
| UI-C3 | §3.2.1 | Intenção flutuante em world-space sobre a cabeça do inimigo (`unproject_position`), ícone + tag curta | NAO APLICADO | Intenção é cartão no topo do palco (`combat_screen.gd:878-889, 923-934`); `Combat3DStage.screen_pos` (`combat3d_stage.gd:173`) só é usado nos números de dano | Mover o cartão para sobre a cabeça do inimigo, 48 px, ícone grande com forma distinta |
| UI-C4 | §3.2.1 | Tocar no inimigo ou no badge abre popover explicando o golpe | NAO APLICADO | Sem tratamento de toque no palco | Popover curto com golpe e reação |
| UI-C5 | §3.2.1 | Linha do tempo: chips 32x32 moldura azul/vermelha, 4 turnos, X=6 | APLICADO | `combat_screen.gd:943-974` (5 chips 30 px, retratos do `Combat3DStage`, moldura azul/vermelha, número) | Tamanho 30 e 5 chips, diferença irrelevante |
| UI-C6 | §3.2.1 | Ticker: só a última linha por 2,2 s com fade; drawer translúcido com o log completo | NAO APLICADO | `_log_label` com 7 linhas (`combat_screen.gd:19, 463-467, 587-597`), painel fixo de 44 px no palco (`:895`) | Ticker com fade e ícone de pergaminho para o histórico |
| UI-C7 | §3.2.1 | Strip de previsão `Atacar 14-17 dano 87% +2 MP` | APLICADO | `combat_screen.gd:908-916, 983-992`; print `TASK-061` ("dano 13-16 · acerto 87% · crít 5% · +2 MP") | Falta cor por tipo e posição acima do dock (hoje flutua sobre o palco) |
| UI-C8 | §3.2.1 | Barras de HP e MP da Bibiana + Buffs na mesma faixa de 46 px | PARCIAL | `combat_screen.gd:609-620`; print mostra duas barras largas empilhadas | HP e MP lado a lado, com buffs em ícones na faixa (hoje ícones ficam no palco, `:1007-1024`) |
| UI-C9 | §3.2.1 | Bandeja de skills em grid 2x2/3x2 com ícone, nome, custo em pílula azul, badge de dano | PARCIAL | `combat_screen.gd:643-649, 996-1002`; print mostra "Golpe de Escudo (6 MP)" em texto | Custo como pílula, badge de dano na carta, sem texto longo que quebra linha |
| UI-C10 | §3.2.1 | Ritual da Moeda: vinheta 75%, câmera fecha a `CAM_SIZE*0.72`, medalhão grande, faixa de aposta real, CARA/COROA monumentais, pílula "Armar Moeda da Sorte" | PARCIAL | `combat_screen.gd:338-367` (medalhão, 1,2 s), `:817-829` (caixa central 25%-75%), `:695-702` (botões 80 px); câmera `*0.8` em `combat3d_stage.gd:322` | Janela genérica sobre o palco, sem vinheta forte, sem texto do risco concreto ("Risco: dano +50% e Cegueira"), sem símbolo Sol/Cruz, sem pílula da Moeda da Sorte no ritual |
| UI-C11 | §3.2.1 | Atacar e Defender com ícone de espada/escudo, 68 px | PARCIAL | `combat_screen.gd:659-665` (62 px; ícones `IconRegistry`) | 68 px e estilo primário |
| UI-C12 | §1.2 | Preview não depende de hover | PARCIAL | `combat_screen.gd:783-794` | Ver L3 |
| UI-C13 | §1.2 | Sem coluna de 11-12 botões cinzas; Poção/Éter/Fugir/Moeda fora da zona nobre | APLICADO | Gavetas: `combat_screen.gd:630-672`, `_drawer_of` (`:763-768`) | Velocidade 1x ainda é botão da gaveta Tático (aceitável) |
| UI-C14 | §3.2.1 | Número de dano grande e luminoso no alvo, hit-stop 60-100 ms | APLICADO | `combat_screen.gd:243, 250, 275-294` | Sem brilho/glow, só contorno |
| UI-C15 | §2.1 SPD | Estados de combate legíveis no mundo: badge de buff/debuff sobre as cabeças | PARCIAL | Ícones de efeito sobre os dois lados: `combat_screen.gd:1007-1024` | Posição fixa em pixels (`:898, :901`), não presos ao modelo |

---

## 3. Mapa 3D (Estudo §3.2.2)

| ID | Fonte | Requisito | Status | Evidência | O que falta |
| --- | --- | --- | --- | --- | --- |
| UI-M1 | §3.2.2 | Barra superior limpa, fundo `rgba(12,13,17,0.88)` com borda inferior de bronze; cena, ouro, som | NAO APLICADO | `map3d_screen.gd:89-97`: `Label` solto de 13 px, sem fundo; print `TASK-063-mapa-inicio.png` mostra 3 linhas de texto de depuração | Barra com fundo, HP/MP em barras finas, ouro com ícone, nível, som |
| UI-M2 | §3.2.2 | Dock inferior fixo (84 px) com Mochila/Equip, Poções, Galho | NAO APLICADO | Itens estão em `_gear_row` no topo (`map3d_screen.gd:98-102, 526-537`) | Mover para o rodapé, 48 px, alvo de toque |
| UI-M3 | §3.2.2 | Gaveta de equipamento/status (5 slots, consumíveis, doenças, atributos) ao tocar a mochila | NAO APLICADO | Só `tooltip_text` (`map3d_screen.gd:549`), que não abre ao toque | Bottom sheet de equipamento |
| UI-M4 | §3.2.2 | Slots de 48 px mínimo (lei 7) | NAO APLICADO | Ícones de 30 px (`map3d_screen.gd:556`) | Subir para 48 px |
| UI-M5 | §3.2.2 | Bolhas enxutas: ícone do nó + 1 dado (`[Espada] Nv 3`, `[Baú]`), sem frases | NAO APLICADO | `map3d_screen.gd:25-29, 386-396`: pílulas de texto "Nv 1", "ouro", "equip. raro", "raro garantido", "mutado" | Trocar por ícones (`IconRegistry`) com 1 dado |
| UI-M6 | §3.2.2 | Prévia em 2 toques: câmera desliza, mini-card ~130 px com retrato, nível, mutação, recompensa e `CAMINHAR ATÉ AQUI` | PARCIAL | `map3d_screen.gd:47, 570-624` (card de 174 px, Voltar/Caminhar, tween 0,35 s) | Sem retrato 3D do inimigo, sem recompensa esperada estruturada; botão diz só "Caminhar" |
| UI-M7 | §3.2.2 | Tabuleiro livre de ~790 px; destinos tocáveis e legíveis | PARCIAL | `map3d_screen.gd:13-14` (`CAM_SIZE 18`), alvo de toque 120x120 (`:377`) | IDENTIDADE-VISUAL §C.2 pede 13-15: inimigos ainda ~60 px no print |
| UI-M8 | ART §3 | Os 3 destinos com luz própria e estrada visível; próximos camadas sob névoa | APLICADO | Fog por camada (`map3d_screen.gd:185-253`), brilho nos destinos (`:307`), print `TASK-063-mapa-inicio.png` | Cores dos destinos todas iguais (laranja) |
| UI-M9 | ART §3, F-019 | Chefe/catedral permanente ao fundo, visível de longe | NAO APLICADO | `map_view.gd:88` só tem o texto "te espera"; nenhuma massa de catedral no print | Silhueta da catedral/torre do chefe no topo do mapa (IDENTIDADE §C.2) |
| UI-M10 | IDENT §C.2 | Mini-modelos dos inimigos diferentes no mapa, 1,5x | PARCIAL | Print: os 3 destinos mostram o mesmo zumbi verde (`character-zombie.glb`, `model_registry.gd:16`) | Modelo real do inimigo do nó; o zumbi é kit Kenney chibi e verde |

---

## 4. Loja (Estudo §3.2.3)

| ID | Fonte | Requisito | Status | Evidência | O que falta |
| --- | --- | --- | --- | --- | --- |
| UI-S1 | §3.2.3 | Diorama 44% em cima, sheet 56% em baixo | PARCIAL | `run_panel_screen.gd:18` (`shop 0.5`, sheet ocupa 48%) | 56% e rolagem do conteúdo |
| UI-S2 | §3.2.3 | Alça visual, cabeçalho fixo (`LOJA`, badge de ouro dourado, contador `Mochila 3/8`) | PARCIAL | Alça `:57-67`; `Ouro: 9  Mochila: 3/8` como `Label` simples (`:182-185`), rola junto | Cabeçalho fixo com badge de ouro e ícone |
| UI-S3 | §3.2.3 | Grade 2x2 de cartões com ícone, nome, tipo, delta (`+3 FOR ▲`), selo de preço | PARCIAL | `run_panel_screen.gd:187-220, 354-372`; print | Cartão é botão com 5 linhas em Cinzel caixa-alta, ilegível; sem selo, sem raridade, sem ▲/▼ (o dado existe: `run_panels.gd:209` `delta`) |
| UI-S4 | §3.2.3 | Toque no cartão abre comparação equipado vs novo (`FOR 14 → 17 ▲`) e `COMPRAR E EQUIPAR (90 Ouro)` | NAO APLICADO | `panels.buy(item_id)` direto (`run_panel_screen.gd:197-199`) | Card de confirmação com comparação atributo a atributo e "Vender antigo" |
| UI-S5 | §3.2.3 | Preço insuficiente = selo vermelho escuro, sem texto de desculpa | NAO APLICADO | `:195-196` anexa "(Ouro insuficiente)" ao texto; print | Ver L6 |
| UI-S6 | §3.2.3, D-UI-5 | Mercador fora do `gravedigger`; vulto encapuzado | PARCIAL | Mudança NÃO commitada: `scene3d_backdrop.gd:300` usa `FocalSet.hooded_figure` (`focal_set.gd:153`, primitivas) | O print `TASK-063-shop.png` ainda mostra o mercador antigo de chapéu; reverificar e commitar. O vulto é feito de cilindros, não de modelo |
| UI-S7 | IDENT §A.3 | Bibiana não pode aparecer cortada atrás do painel | APLICADO | Print `TASK-063-shop.png` (Bibiana inteira à esquerda do carrinho) | n/d |
| UI-S8 | §3.2.3 | Rodapé fixo: `Atualizar 25` + `SEGUIR ADIANTE` | APLICADO | `_footer_button`, `run_panel_screen.gd:330-340` | n/d |

---

## 5. Fogueira (Estudo §3.2.4)

| ID | Fonte | Requisito | Status | Evidência | O que falta |
| --- | --- | --- | --- | --- | --- |
| UI-F1 | §3.2.4, D-UI-5 | Fogueira apagada = braseiro frio sem chama nem luz laranja; acender faz clarão | APLICADO | `run_panel_screen.gd:32, 225`; `scene3d_backdrop.gd` (`set_fire_lit`); prints `TASK-063-campfire.png` e `-lit.png` | Falta o fade/clarão ao acender (troca seca) |
| UI-F2 | §3.2.4 | 6 pinos de Brasas `● ● ● ○ ○ ○ 3/6` | APLICADO | `run_panel_screen.gd:237, 374-377` | Em texto, não em ícones de brasa |
| UI-F3 | §3.2.4 | Cartões em linha com custo de Brasas em badge laranja-brasa e efeito em 1 linha | NAO APLICADO | `run_panel_screen.gd:238-264`: botões com texto e `_text` solto abaixo | Cartão com badge `ACCENT_AMBER` |
| UI-F4 | IDENT §A.3 | Painel de ações ≤ 38-40% da altura; sem 280 px de preto vazio | PARCIAL | `SHEET_TOP_BY_KIND campfire 0.6` (`:18`) | Print `TASK-059-campfire.png` mostrava vazio; reconferir com `TASK-063-campfire.png` |
| UI-F5 | IDENT §C.3 | Fogueira = pira torta com espada e labareda, Bibiana de perfil iluminada de baixo | PARCIAL | Print `TASK-063-campfire-lit.png` (pira, labareda, brasas subindo) | Bibiana é o KayKit Knight de capacete (chibi) |

---

## 6. Baú, Recompensa, Evento e Resultado (Estudo §3.2.5)

| ID | Fonte | Requisito | Status | Evidência | O que falta |
| --- | --- | --- | --- | --- | --- |
| UI-R1 | §3.2.5 | Multiplicador `×1.75` grande flutuando sobre o baú 3D (world-space) | PARCIAL | `run_panel_screen.gd:162-166` (64 px dentro do sheet) | Preso ao baú com `unproject_position` |
| UI-R2 | §3.2.5 | Baú: 2 botões largos (Moeda da Sorte, Anúncio) + `Recolher e Seguir` | PARCIAL | `run_panel_screen.gd:172-179` | Rótulo "Seguir"; botões no sheet, não no rodapé fixo |
| UI-R3 | §3.2.5 | Recompensa: `VITÓRIA`, banner `NÍVEL 1!`, pílulas `+0.40 Poder`, `+9 Ouro`, `HP 130 → 135` | NAO APLICADO | `run_panel_screen.gd:129-138`: linhas de texto centradas (`view["lines"]`) | Pílulas e banner de nível |
| UI-R4 | §3.2.5 | Cartão único do drop com comparação, `Equipar & Vender antigo` ao lado de `Vender por X` | NAO APLICADO | `run_panel_screen.gd:141-156`: "Caiu: X (raridade, slot)" + 2 botões empilhados | Cartão com ▲/▼ e botões lado a lado |
| UI-R5 | §3.2.5 | Evento: texto Alegreya 18 px em `ScrollContainer`, escolhas com badges de risco `[Moeda]`, `[-15 Ouro]`, `[Seguro]` | PARCIAL | `run_panel_screen.gd:266-291` (texto 18 px, sheet rola); motivo anexado em parênteses (`:286`) | Badges à direita; sem badge de risco |
| UI-R6 | §3.2.5 | Resultado: conteúdo em `ScrollContainer` acima de botões fixos; `Outra Descida` primário dourado; `Santuário` e `Início` secundários em linha | NAO APLICADO | `game_screen.gd:376-400, 500-540`: `CenterContainer` sem rolagem; 3 botões empilhados de 64 px, todos iguais | Rolagem segura, CTA primário, linha secundária |
| UI-R7 | ART §5 | Recompensa e fim com retratos antes e depois, número `+` subindo; fim com cenário ao fundo | PARCIAL | Cenário ao fundo: `game_screen.gd:510` | Sem retratos nem contador animado |

---

## 7. Home e Santuário (Estudo §3.2.6)

| ID | Fonte | Requisito | Status | Evidência | O que falta |
| --- | --- | --- | --- | --- | --- |
| UI-H1 | §3.2.6 | Diorama 100% no fundo; título `BIBIANA'S QUEST` + subtítulo | APLICADO | Print `TASK-060-home.png`; `game_screen.gd:112-125` | Painel opaco ainda cobre o terço inferior |
| UI-H2 | §3.2.6 | CTA principal 64 px com borda dourada: `CONTINUAR DESCIDA` ou `NOVA DESCIDA` | PARCIAL | `game_screen.gd:130-134, 161` (`_cta_button`) | Borda dourada vem do tema; CTA e secundários quase iguais no print |
| UI-H3 | §3.2.6 | Linha secundária: `SANTUÁRIO (Ecos)` e `CLASSE: GUERREIRO` como botões (54 px) | PARCIAL | `game_screen.gd:139-144`: Santuário é botão, Classe é `Label` | Botão de classe (vira seletor na TASK-049) |
| UI-H4 | §3.2.6 | Som no canto; engrenagem/debug fora da frente (regras vN, semente, luta de teste recolhidos) | PARCIAL | Som no canto (`game_screen.gd:83`); debug em botão recolhido (`:145-157`) | Sem ícone de engrenagem; `regras vN` ainda aparece no subtítulo em build de debug (`:116-117`) |
| UI-H5 | §3.2.6 | Santuário com cena 3D própria (Bibiana diante de altar/cripta) | NAO APLICADO | `sanctuary_screen.gd`: sem `Scene3DBackdrop` (nenhuma referência) | Cena 3D e painel em sheet |
| UI-H6 | §3.2.6 | Abas segmentadas reais (`StyleBoxFlat` ativa com sublinhado dourado), sem `[colchetes]` | NAO APLICADO | `sanctuary_screen.gd:112` (`"[%s]" % text`) | Estilo de aba |
| UI-H7 | §3.2.6 | Bestiário com retratos 3D, selos de descoberta, ícone da consequência da moeda | NAO APLICADO | `sanctuary_screen.gd:98-101` (lista de texto); `Combat3DStage.portrait` não usado ali | Miniaturas e selos |
| UI-H8 | ART §5 | Home: Bibiana de costas diante da catedral com a luz da moeda | PARCIAL | Print `TASK-060-home.png` (Bibiana chibi de frente, prédio pequeno) | Catedral gigante, Bibiana nova |

---

## 8. Tokens e design system "DarkTheme 2.0" (Estudo §3.3, §3.4 Ui-A)

| ID | Fonte | Requisito | Status | Evidência | O que falta |
| --- | --- | --- | --- | --- | --- |
| UI-T1 | §3.3 | `BG_GLASS #0B0C10` alpha 0,90 | PARCIAL | Sheets usam `Color(0.06,0.065,0.09,0.9)` inline (`run_panel_screen.gd:41`) | Token nomeado em `DarkTheme`; valor difere |
| UI-T2 | §3.3 | `SURFACE_CARD #161820` | PARCIAL | `dark_theme.gd:15` `STONE (0.085,0.09,0.115)` | Renomear/fixar; não há `SURFACE_CARD` |
| UI-T3 | §3.3 | `SURFACE_ELEVATED #1F222C` (cartão selecionado) | NAO APLICADO | Só `STONE_LIGHT` (`:16`) para todo botão | Estado selecionado/ativo |
| UI-T4 | §3.3 | `BORDER_BRONZE #6B593D` 1 px | APLICADO | `dark_theme.gd:13` `BRONZE (0.42,0.35,0.24)` | Falta constante com o nome do token |
| UI-T5 | §3.3 | `BORDER_GOLD #EBBF42` 2 px (CTA, selecionado, turno ativo) | PARCIAL | `GOLD` (`:12`) só em hover/pressed (`:85-87`) | Nunca é estado fixo de CTA/selecionado |
| UI-T6 | §3.3 | `ACCENT_BLOOD #8F2420/#D93832` | NAO APLICADO | Sem DangerButton; vermelho solto em `VisualTheme.COLOR_DANGER` (`visual_theme.gd:12`) | Token e variante |
| UI-T7 | §3.3 | `ACCENT_AMBER #D4882A` (moeda, risco, brasa) | NAO APLICADO | Moeda usa dourado `COLOR_COIN` (`combat_screen.gd:30`) | Token e uso no botão de risco/Moeda |
| UI-T8 | §3.3 | `DELTA_UP/DOWN #57B86A/#D9534F` e `StatDeltaBadge` | NAO APLICADO | Sem `▲`/`▼` em `game/presentation` | Componente de badge |
| UI-T9 | §3.3, D-UI-4 | `FONT_TITLE` Cinzel 600/700 só em títulos e botões curtos (≤3 palavras); `FONT_BODY` Alegreya 500 no descritivo e nos números | PARCIAL | Theme: Alegreya como padrão (`dark_theme.gd:42`), Cinzel em `TitleLabel` (`:67`) e em TODO `Button` (`:75`) | Botões longos (cartões da loja, eventos, habilidades) ainda em Cinzel: parágrafos em caixa alta. Falta variante de botão com corpo Alegreya (HANDOFF confirma "troca de fonte" pendente) |
| UI-T10 | §3.3 | `MIN_TOUCH` 48 px; 56-64 px em CTAs; gap 8-10 px | PARCIAL | Atacar/Defender 62, CTAs 56-64; abas 38 (`combat_screen.gd:638`), ícones do mapa 30 | Auditar todos os `custom_minimum_size` abaixo de 48 |
| UI-T11 | §3.3 | `SAFE_AREA` via `DisplayServer.get_display_safe_area()` no `_ready()` do container raiz | NAO APLICADO | Nenhuma ocorrência em `game/` ou `project.godot` (só `stretch canvas_items, keep_width`) | `SafeAreaContainer` raiz |
| UI-T12 | Ui-A | `PrimaryButton`, `DangerButton` | NAO APLICADO | `dark_theme.gd` só tem `Button`, `TitleLabel`, `PanelContainer`, `ProgressBar` | Variações de tema |
| UI-T13 | Ui-A | `CardPanel` | NAO APLICADO | Cartões são `Button` (`run_panel_screen.gd:354`) | Componente de cartão com raridade |
| UI-T14 | Ui-A | `BottomSheet` como componente | PARCIAL | Montado à mão em `run_panel_screen.gd:49-77` | Extrair e reusar em mapa, Home, Santuário; animar entrada |
| UI-T15 | Ui-A | Barra de HP/MP com trail de dano animado | NAO APLICADO | `_bar` (`combat_screen.gd:833-859`): moldura de bronze e número, sem fantasma | Segunda barra branca/dourada que escorre 350 ms |
| UI-T16 | §3.3 raios/sombras | Cantos 5-8 px, sombra 4 px consistentes | APLICADO | `dark_theme.gd:50-62` (`_box`, raio 5/8, sombra 4) | Cartões e barras do combate usam `StyleBoxFlat` próprios com raio 3/6 (`combat_screen.gd:837-873`) |
| UI-T17 | §3.2.2 | Cabeçalho/painéis com borda bronze fina | PARCIAL | Sheets e painel de Home têm; header do mapa não | Ver UI-M1 |

---

## 9. Quadro de decisões do estudo (Estudo §6.2)

| ID | Decisão recomendada | Status | Evidência | O que falta |
| --- | --- | --- | --- | --- |
| D-UI-1 | Opção A: toque 1 seleciona, toque 2 confirma (Skills/Itens); Atacar/Defender em 1 toque | PARCIAL | ADR-0044; `combat_screen.gd:783-794` | Ver L3 |
| D-UI-2 | Opção A: Atacar e Defender fixos + gavetas | APLICADO | `combat_screen.gd:21-22, 625-674` | Ajuste de altura das abas |
| D-UI-3 | Opção A: prévia de nó com mini-card e Caminhar | PARCIAL | ADR-0048; `map3d_screen.gd:570-624` | Ver UI-M6 |
| D-UI-4 | Alegreya no corpo, Cinzel só em títulos, loja em bottom sheet 2x2 | PARCIAL | Loja 2x2 sim (`run_panel_screen.gd:187`); fonte não | Ver UI-T9 |
| D-UI-5 | Fogueira sincronizada e mercador sem `gravedigger` | PARCIAL | Fogueira sim (UI-F1); mercador só no working tree (UI-S6) | Commitar e reconferir print da loja |
| D-UI-6 | Abrir Ui-A, Ui-B, Ui-C, Ui-D | PARCIAL | TASK-056 (Ui-B parcial), 059 (Ui-C parcial), 060 (Ui-D parcial) | **Ui-A (design system) nunca foi aberta**; é o que as outras três pressupõem |
| D-ENEMY-1 | Priorizar Turiferário, Médico da Cera, Rastejador da Vala | APLICADO | ADR-0045/0046; `model_registry.gd:28-30` | Modelos ainda não batem com a arte (seção 13) |
| D-ENEMY-2 | Pipeline híbrido (TRELLIS.2 + vertex_grime) para horrores; kit.py para props | PARCIAL | `tools/blender/kitbash_*.py`, `kb_humanoid.py` (não commitados) | Sem TRELLIS.2; `skin_limb`/`draped_cloth`/`vertex_grime` conferir em `kit.py` |
| D-ART-1 | Ambiente 0,40-0,52 azul-ardósia, fog exponencial, `SpotLight3D` no combate | PARCIAL | `atmosphere.gd:7-24` (0,38; fog 0,014); spot `combat3d_stage.gd:113` | Combate sobe para 0,62 (`:86`) e fog 0,007; mapa 0,62 (`map3d_screen.gd:112`); sem `TONE_MAPPER_ACES` (nenhuma ocorrência) |
| D-ART-2 | Bayer 4x4, split-toning, blur de combate 1,3 para 0,35 | APLICADO | `post_fx.gd:11-23, 46-49, 57` | `edge_strength` continua 0,6 (estudo pede 0,35, `:9`) |
| D-ART-3 | Remover pinheiros verdes e escurecer albedo dos kits | PARCIAL | Pinheiros só em `stage/proof_scene.gd:114`; tintas `TINT_*` em `scenario_renderer.gd:11-13` | Poste de ferro ainda verde-azulado nos prints (home e mapa); zumbi e slime do Kenney/Quaternius ainda ativos (`model_registry.gd:16, 26`) |

---

## 10. Estética "mundo morrendo" (Estudo Parte 5) e IDENTIDADE-VISUAL

| ID | Fonte | Requisito | Status | Evidência | O que falta |
| --- | --- | --- | --- | --- | --- |
| ART-1 | §5.3A | Paleta fechada: Abismo `#07080B`, Ardósia `#1B2029`, Pedra `#4A4E54`, Luar `#7E8FA8`, Lama `#3A3128`, Âmbar, Perigo, Ouro | PARCIAL | Luar `#7E8FA8` em `combat3d_stage.gd:99, 109`; fundo `Color(0.02,0.024,0.038)` (`:83`) | Pedra do piso ainda rosada/lilás nos prints do combate; sem verificação de paleta |
| ART-2 | §5.3B | Luar direcional + única luz quente | APLICADO | `combat3d_stage.gd:98-113` | Várias OmniLight em outros focais |
| ART-3 | §5.3B | Rim-light fria atrás do inimigo | APLICADO | `combat3d_stage.gd:98-107` (luar de trás, `rotation_degrees 225`) | n/d |
| ART-4 | §5.3B | `ACES`, saturação 0,48, contraste 1,24, brilho 0,88 | PARCIAL | `adjustment_*` em `combat3d_stage.gd:88-91` (0,56 / 1,2 / 0,9) | Sem tonemap; valores diferentes |
| ART-5 | §5.3B | Fog densidade 0,035-0,05 no combate | NAO APLICADO | `combat3d_stage.gd:87` (0,007) | IDENTIDADE §B.2 pede 0,04-0,06 |
| ART-6 | §5.3B | Mapa mantém tilt-shift (blur 1,3) | APLICADO | `post_fx.gd:11, 63` | n/d |
| ART-7 | §5.3B | Poças e névoa rasteira (plano baixo semitransparente) | PARCIAL | Poças: `duel_arena.gd:68-90` | Névoa rasteira em movimento ausente |
| ART-8 | IDENT §C.1 | Câmera de duelo: `CAM_SIZE 3.6-4.0`, pitch 22-26 graus, alvo a 55% da altura do inimigo | PARCIAL | `combat3d_stage.gd:12-13` (3,9; offset `0,62` = ~32 graus) | Pitch ainda alto |
| ART-9 | IDENT §C.1 | Escala: inimigo 2,8-3,2 (comum), 3,6, 4,2; Bibiana 1,3-1,5; inimigo comum ≥ 280 px, chefe ≥ 380 px | PARCIAL | `combat3d_stage.gd:18-21` (2,5/3,0/3,6; Bibiana 1,45); print: Coveiro ~250 px de altura, cão largo e baixo | Alturas abaixo do pedido |
| ART-10 | IDENT §C.1 | Primeiro plano escuro e borrado + palco + fundo em névoa (3 camadas) | PARCIAL | `duel_arena.gd:116-128` (`_foreground`) | Prints mostram primeiro plano mínimo (vaso no canto) |
| ART-11 | IDENT §C.1/§E.3 | Piso mais escuro que o inimigo; nada de laje clara uniforme | NAO APLICADO | Prints `TASK-061-combate-*` e `TASK-057-turiferario.png`: piso rosado e claro domina | Escurecer piso, cone de luz com borda |
| ART-12 | IDENT §C.1 | Fundo = duas fachadas góticas convergentes com ogivas e agulha | PARCIAL | `duel_arena.gd` (canto de nave, portão âmbar), `scenario_renderer.gd:424-489` (`_render_gothic_mass`) | Nos prints do combate é um canto de caixa sem ogiva |
| ART-13 | IDENT §E.12 | Palco ≥ 58% em combate, ≥ 45% em fogueira/loja | NAO APLICADO | Combate 41%; loja 50% (`:18`) | Ver L2 |
| ART-14 | IDENT §D | Inimigo: foco emissivo único, 2-3 faixas de valor, nada mais claro que `#7E8FA8` | NAO APLICADO | Prints 057/058: Turiferário e Médico em bege claro, mais claros que o chão | Reescurecer e pintar emissivo |
| ART-15 | IDENT §B.1 | Zero verde saturado, rosa ou lavanda | NAO APLICADO | Prints: poste verde-azulado (Home, mapa), zumbi verde (mapa), piso rosado (combate), fogueira da loja antiga | Retingir props e substituir zumbi |
| ART-16 | IDENT regra 3 | Bibiana fora do capacete chibi do KayKit | NAO APLICADO | `model_registry.gd:15` (`Knight.glb`); prints | Reconstruir a Bibiana (pendência TASK-062) |
| ART-17 | IDENT §E | Print 540x960 com os 12 itens "passa/falha" anexado em toda tarefa visual | PARCIAL | ADR-0050 criado; prints existem | Nenhuma tarefa traz a tabela 12/12 preenchida; os prints reprovariam os itens 1, 3, 5, 6, 8, 12 |

---

## 11. ART-DIRECTION e ADR-0042

| ID | Fonte | Requisito | Status | Evidência | O que falta |
| --- | --- | --- | --- | --- | --- |
| RV-1 | ART §2.1 Eixo 1 | Craft de diorama estilo Sword of Convallaria: pedra, madeira e metal com textura tátil | PARCIAL | Kits Kenney tingidos, dithering | Texturas ricas: peças ainda lisas e chapadas |
| RV-2 | ART §2.1 Eixo 1 | Profundidade em 3 camadas (primeiro plano, palco, fundo em névoa) | PARCIAL | Ver ART-10 | Faltam camadas no mapa e no combate |
| RV-3 | ADR-0042 Eixo 2 | Arquitetura gótica: ogivas, pináculos, ferro forjado, lampiões em neblina | PARCIAL | `scenario_renderer.gd:410-489` (agulhas, janelas âmbar) | Presente no mapa gerado, quase ausente no combate |
| RV-4 | ADR-0042 Eixo 2 | Fogueiras e brasas como foco quente raro | APLICADO | Print `TASK-063-campfire-lit.png` | n/d |
| RV-5 | ADR-0042 §5 | Reprovação: luz ambiente alta e lilás | PARCIAL | Atmosphere 0,38 mas combate 0,62 e mapa 0,62 | Home e prints ainda azul-lilás |
| RV-6 | ART §2.2 ref. 1 | Bolhas de número sobre os destinos (nível em vermelho, recompensa dourada) | PARCIAL | `map3d_screen.gd:386-396` | Texto em vez de ícone (UI-M5) |
| RV-7 | ART §4.3/ref. 5 | Coluna de retratos da linha do tempo | APLICADO | UI-C5 | n/d |
| RV-8 | ART §4.4 | Painel de previsão entre os dois lados | PARCIAL | UI-C7 | Faixa azul-marinho (`combat_screen.gd:909`, `Color(0.05,0.09,0.18)`) fora da paleta de pedra/bronze |
| RV-9 | ART §4.5 | Moeda no palco, vinheta que fecha, silêncio e tique | PARCIAL | `coin_tick` (`combat_screen.gd:352`) | Sem vinheta forte e sem silêncio antes |
| RV-10 | ART §5 | Loja: cartões com seta verde/vermelha; botão "equipar e vender o antigo" | NAO APLICADO | Ver UI-S3, UI-S4 | n/d |
| RV-11 | ART §5 | Baú abre em 3D, ouro cai, `x2` sobre o baú | PARCIAL | Cena de baú em `scene3d_backdrop.gd`; multiplicador no painel | Ver UI-R1 |
| RV-12 | ADR-0042 §3.5 | UI "pedra escura, ferro batido, bronze oxidado, pergaminho envelhecido" | PARCIAL | Tema de pedra e bronze | Sem textura de pedra/ferro nos painéis; vidro chapado |
| RV-13 | ADR-0042 §4 | Prompts de IA nunca citam jogos ou artistas | APLICADO | `ROAMING-BOSS...md` §3 | n/d |
| RV-14 | ADR-0042 §3.2 | `ScenarioBlueprint` e validador de coerência | APLICADO | `scenario/scenario_validator.gd` (regra anti-prop solto, `:290`) | Combate usa `DuelArena`, fora do gerador |

---

## 12. FEEDBACK.md (itens visuais e de UX)

| ID | Fonte | Requisito | Status | Evidência | O que falta |
| --- | --- | --- | --- | --- | --- |
| FB-F003 | F-003 | Progressão visível (atributos antes e depois, inimigos derrotados, número de dano) | PARCIAL | `run_panels.gd:48, 92`; HUD de mapa em texto | Poder sem barra; pílulas e `FOR 14 → 16` animado (UI-R3) |
| FB-F008 | F-008 | Faixa de dano e chance de acerto antes de escolher | APLICADO | UI-C7 | n/d |
| FB-F012 | F-012/F-018 | Moeda mostra o risco concreto antes do lance | NAO APLICADO | `combat_screen.gd:375` ("Escolha o lado da moeda") | Texto da aposta real |
| FB-F013 | F-013 | Cada inimigo único em silhueta e aviso | PARCIAL | 17 fichas em `docs/enemies/`; 3 modelos novos | Ver seção 13 |
| FB-F019 | F-019 | Chefe visível de longe; primeira Descida chamativa | PARCIAL | Texto "O Coveiro te espera" (`map_view.gd:88`) | Chefe visível no mapa (UI-M9) |
| FB-F021 | F-021 | Cenário coerente, sem props aleatórios | APLICADO | ADR-0041; `scenario_*.gd`; validador | Combate fora do gerador |
| FB-F022 | F-022 | Cânone visual em todo asset | PARCIAL | ADR-0042, ART-DIRECTION | Ver seções 10 e 11 |
| FB-F023 | F-023 | Roaming boss: conceito e modelo | PARCIAL | Dossiê e 5 pranchas (TASK-054) | Sem `.glb`, sem ficha, sem alarme no mapa (seção 13) |
| FB-F018 | F-018 | Tensão e apresentação da moeda variável por inimigo | NAO APLICADO | Ritual único (`combat_screen.gd:338-367`) | Varia som/animação por inimigo |

---

## 13. Inimigos do estudo e Roaming Boss

| ID | Fonte | Requisito | Status | Evidência | O que falta |
| --- | --- | --- | --- | --- | --- |
| EN-01 | §4.2 | Turiferário Cego (`blind_censer_bearer`): máscara de ferro sem olhos, brasa no peito, braço longo com corrente e turíbulo | PARCIAL | `model_registry.gd:28`, `assets/bibiana/enemies/blind_censer_bearer.glb` (modificado e não commitado); print `TASK-057-turiferario.png`, ficha ENEMY-15 | Print mostra esqueleto claro e magro; a arte (`refs/inimigos/01`) é de capuz azul-ardósia, máscara rebitada e peito aceso. Falta corrente espessa visível e o cone quente no peito |
| EN-02 | §4.3 | Dama do Relicário (`reliquary_lady`), 2,25 m, gaiola de bronze com mãos | NAO APLICADO | Nenhuma ocorrência em `game`, `assets`, `tools`, `docs/enemies` | Ficha, ADR, modelo, entrada em `enemies.json` |
| EN-03 | §4.4 | Peregrino da Roda | NAO APLICADO | Idem | Idem |
| EN-04 | §4.5 | Médico da Cera (`wax_physician`): corcunda de cera, 12+ velas, máscara de bico, seringa-serra | PARCIAL | `model_registry.gd:29`; print `TASK-058-wax_physician.png`; ficha ENEMY-16 | Print mostra um boneco branco de pé, sem corcunda nem coroa de velas legível |
| EN-05 | §4.6 | Lavadeira do Brejo (dobrada a 90 graus, 4 braços, lampião) | NAO APLICADO | Idem EN-02 | Idem |
| EN-06 | §4.7 | Coro Sem Lábios | NAO APLICADO | Idem | Idem |
| EN-07 | §4.8 | Cavaleiro Calcificado | NAO APLICADO | Idem | Idem |
| EN-08 | §4.9 | Rastejador da Vala (`trench_crawler`): ponte invertida, tampa de caixão, cabeça pendurada | PARCIAL | `model_registry.gd:30`; print `TASK-058-trench_crawler.png`; ficha ENEMY-17 | Verificar contra `refs/inimigos/08`; silhueta de ponte invertida |
| EN-09 | IDENT §D | Nenhuma haste fina; cabeça 25-35% da altura; um foco emissivo | NAO APLICADO | Prints: Coveiro com pá fina e membros de 1 px; cão é bloco sobre quatro hastes | Reprojetar o Coveiro e o Cão de Peste (os modelos de TASK-062 estão modificados e não commitados) |
| EN-10 | §5.2 | Substituir `infected_citizen` (zumbi Kenney) e `sewer_slime` (slime colorido) | NAO APLICADO | `model_registry.gd:16, 26` ainda apontam para kit | Modelos próprios |
| RB-1 | Dossiê §2, F-023 | Conceito visual (5 pranchas) | APLICADO | `refs/roaming-boss/01-04` | n/d |
| RB-2 | Dossiê §6 | Modelo `crowned_pursuer` 4.500-6.000 tris, 2,75 m, 2 armas | NAO APLICADO | Nenhuma ocorrência de `crowned_pursuer` | Modelo, `enemies.json`, ficha `ENEMY-NN` |
| RB-3 | Dossiê §1, GDD §13/§19 | Alarme por 2 toques do sino; distância no mapa "O Perseguidor está a N nós" | NAO APLICADO | Sem tela de alarme (só o multiplicador `roaming_boss` em `run_rules.gd:19`) | Alarme visual e sonoro no mapa |
| RB-4 | Dossiê §4 | 5 patentes Nemesis com variação barata (crânios, brasas) | NAO APLICADO | Idem | Shader e variantes |
| RB-5 | Dossiê §5 | Ciclo de 4 golpes (Gume Partido, Decreto da Maça com moeda, Corte Podre, Varredura) | NAO APLICADO | Idem | Tarefa de gameplay com ADR e `RULES_VERSION` |

---

## 14. Totais

Contagem das 144 linhas das seções 1 a 13: **25 APLICADO (17%)**, **70 PARCIAL (49%)**, **49 NAO APLICADO (34%)**.

Maiores lacunas: design system (Ui-A nunca aberta), palco do combate em 41% contra 57%, intenção no mundo, ritual da moeda, loja em cartões com comparação, cabeçalho de depuração do mapa, Santuário 3D, 5 de 8 inimigos e o Roaming Boss.

---

## 15. Backlog priorizado (máx. 15 pacotes, por impacto nos primeiros 5 minutos)

Estimativa: S ≤ 1 dia, M 2-3 dias, L 4+ dias de agente.

| # | Pacote | Fecha | Arquivos | Est. |
| --- | --- | --- | --- | --- |
| 1 | **Ui-A: `DarkTheme 2.0`**: tokens nomeados, `PrimaryButton`, `DangerButton`, botão de risco âmbar, `CardPanel`, variante de corpo em Alegreya, foco/pressionado com escala 0,96 e vibração | L7, L8, UI-T1..T10, T12, T13, D-UI-4, D-UI-6 | `fx/dark_theme.gd`, `visual_theme.gd`, `tests/unit` do tema | M |
| 2 | **Combate: palco a 57% e intenção no mundo**: remover banner, log fixo e previsão de dentro do palco, ticker de 2,2 s, intenção presa à cabeça do inimigo, abas de 48 px, gaveta fechada por padrão, barras HP/MP lado a lado | L1, L2, L4, UI-C1..C4, C6, C8, C11, ART-13 | `combat/combat_screen.gd`, `combat3d/combat3d_stage.gd` | L |
| 3 | **Chão e luz do duelo**: escurecer piso (multiplicar `#4A4E54`), cone quente com borda, ambiente 0,40, fog 0,04, `ACES`, `edge_strength` 0,35, névoa rasteira, primeiro plano escuro | ART-1, ART-4, ART-5, ART-7, ART-10, ART-11, ART-15 (parcial), D-ART-1, D-ART-2, RV-5 | `combat3d/combat3d_stage.gd`, `duel_arena.gd`, `fx/atmosphere.gd`, `fx/post_fx.gd` | M |
| 4 | **Barra de HP/MP com trail de dano** (e HP do inimigo) | UI-T15, UI-C2, L8 (parte) | `combat/combat_screen.gd` (`_bar`), novo componente em `fx/` | S |
| 5 | **Loja em cartões com comparação**: cartão sem texto corrido, selo de preço, `StatDeltaBadge`, borda por raridade, card de confirmação `COMPRAR E EQUIPAR`, preço insuficiente em vermelho sem sufixo | UI-S2..S5, UI-T8, UI-T13, L5, L6, RV-10 | `run/run_panel_screen.gd`, `run/run_panels.gd` (usa `delta`) | M |
| 6 | **Mapa limpo**: barra superior com fundo, HP/MP em barras, dock inferior de 48 px com gaveta de equipamento, bolhas de ícone, `CAM_SIZE` 14, texto "Caminhar até aqui" | UI-M1..M5, M7, RV-6 | `map3d/map3d_screen.gd` | M |
| 7 | **Ritual da Moeda**: vinheta 75%, câmera a 0,72, faixa com o risco real, CARA/COROA com símbolos, pílula da Moeda da Sorte, variação por inimigo | UI-C10, RV-9, FB-F012, FB-F018 | `combat/combat_screen.gd`, `combat/combat_texts.gd`, `combat3d_stage.gd` | M |
| 8 | **Resultado e Recompensa**: rolagem segura, CTA primário, pílulas de ganho, banner de nível, cartão único do drop com comparação | UI-R3, R4, R6, R7, FB-F003 | `game_screen.gd`, `run/run_panel_screen.gd` | M |
| 9 | **SafeArea e acessibilidade mínima**: `SafeAreaContainer` na raiz, auditar alvos <48 px, opções de vibração e tamanho de texto | UI-T11, UI-T10, L7 (parte) | `main.gd`, `game_screen.gd`, `fx/gfx_settings.gd` | S |
| 10 | **Bibiana nova** (sem capacete chibi) e substituição do zumbi e do slime | ART-16, EN-10, UI-M10 | `tools/blender/kb_humanoid.py`, `assets/bibiana/`, `stage/model_registry.gd` | L |
| 11 | **Reaprovar Turiferário, Médico da Cera, Rastejador, Coveiro e Cão** contra as pranchas e contra o checklist 12/12 | EN-01, EN-04, EN-08, EN-09, ART-14 | `tools/blender/*.py`, `assets/bibiana/enemies/*.glb` | L |
| 12 | **Home e Santuário**: cena 3D do Santuário, abas segmentadas, bestiário com retratos, botão de classe, engrenagem, catedral ao fundo | UI-H2..H8 | `game_screen.gd`, `run/sanctuary_screen.gd` | L |
| 13 | **Fogueira: cartões, clarão ao acender, Bibiana de perfil** | UI-F1 (fade), UI-F3, UI-F5 | `run/run_panel_screen.gd`, `camp3d/scene3d_backdrop.gd` | S |
| 14 | **Chefe visível no mapa e cenário do duelo vindo do gerador** (catedral, ogivas, 2 fachadas) | UI-M9, ART-12, RV-2, RV-3, RV-14, FB-F019 | `scenario/scenario_renderer.gd`, `combat3d/duel_arena.gd`, `map3d/map3d_layout.gd` | L |
| 15 | **Inimigos 02, 03, 05, 06, 07 e Roaming Boss**: fichas, ADRs, modelos; alarme do sino no mapa | EN-02, 03, 05, 06, 07, RB-2..RB-5, FB-F023 | `docs/enemies/`, `game/data/enemies.json`, `tools/blender/`, `map3d/map3d_screen.gd` | L |

Ordem de ataque para o primeiro contato do jogador: 1 e 2 e 3 juntos (mesma sensação de "isso não é protótipo"), depois 4, 5, 6, 7, 8.

---

## 16. Regras que se contradizem e precisam de decisão do Orlando

1. **Altura do palco do combate:** Estudo §3.2.1 e Lei 2 pedem 57% (~548 px) com intenção no mundo; IDENTIDADE-VISUAL §C.1/§E.12 pede ≥ 58%; ART-DIRECTION §4.2 e GDD §19 pedem "metade de cima = palco, metade de baixo = painéis" (50%). Qual número vale como critério de aprovação?
2. **Câmera do duelo:** Estudo `CAM_SIZE` 4.2-4.5; IDENTIDADE §C.1 3.6-4.0 com pitch 22-26 graus; código usa 3,9 com pitch ~32 graus. Qual?
3. **Ambiente de luz:** Estudo 0,40 (combate) e 0,52 (mapa); IDENTIDADE 0,30-0,38 e 0,45; Atmosphere 0,38 e o código sobe para 0,62 no combate "porque as peças vêm tingidas". Decidir se se escurece a luz (IDENTIDADE) ou se se retinge a peça.
4. **Fonte:** Estudo (D-UI-4) manda Alegreya no corpo e Cinzel só em título e botões de até 3 palavras; GDD §18 e o tema atual usam Cinzel em todo `Button`. Confirmar a regra "≤ 3 palavras".
5. **Inimigo claro ou escuro:** os conceitos do Gemini (`refs/inimigos/01..08`) têm pele cinza-azulada clara e capuzes; IDENTIDADE §D.2 proíbe cor pálida e limita o corpo a `#7E8FA8`. Os modelos 057/058 seguem a primeira e quebram a segunda. Qual prevalece?
6. **Câmera e escala do mapa:** Estudo mantém 3 destinos e HUD; IDENTIDADE pede `CAM_SIZE` 13-15 (mostra ~3 camadas); código tem 18. Decidir se cabem os 3 destinos mais o card de prévia de 174 px.
7. **Acento de cor:** GDD §18 e ADR-0042 liberam só 3 acentos (mecha, ouro, perigo); Estudo §3.3 adiciona `ACCENT_AMBER` e `DELTA_UP` verde; IDENTIDADE proíbe verde saturado. Liberar verde só para ▲ de UI?
8. **Moeda:** Estudo §3.2.1 pede o ritual com botões monumentais CARA/COROA e faixa do risco; F-014 do FEEDBACK (sem chance visível, 50%) conflita com GDD §7 ("chance fixa de 50%") e está sem decisão.
9. **Sheet da loja:** Estudo §3.2.3 pede 56% de sheet; IDENTIDADE §C.3 limita painel a 38% (fogueira) e ART-DIRECTION diz "diorama maior"; hoje loja 50% e fogueira 40%.
10. **Bibiana:** IDENTIDADE regra 3 reprova o KayKit; GDD §18 e ART-DIRECTION §6 o definem como MVP. Autorizar a troca e o prazo.
11. **Prints antigos como evidência:** vários prints versionados (`TASK-059-campfire.png`, `TASK-063-shop.png`) já não representam o código; a régua "só o print aprova" (ADR-0050) precisa de prints regenerados a cada commit.
