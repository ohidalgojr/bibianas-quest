# Crítica de game design mobile: uma Descida jogada de ponta a ponta

Base: `main` em `1cfa0c9` (TASK-073). Jogo rodado de verdade (Godot 4.7.2, Vulkan/lavapipe, retrato 540x960) por um bot que aperta os botões reais das telas. Prints em `docs/design/critica-diretor/gd/` (prefixo `t1-` é a Descida jogada a 1x; `x-` são telas avulsas). Scripts em `/tmp/claude-0/gd_scripts/` (fora do projeto; nenhum código ou asset foi alterado).

Esta crítica não repete `CRITICA-DIRETOR.md` (arte) nem `CRITICA-UX-COMBATE.md` (layout do combate). Aqui o foco é design: decisão, ritmo, economia, retenção.

## 0. Como joguei e o que os números valem

| O que | Como | Amostra |
| --- | --- | --- |
| Descida completa com render, tempo real 1x | `playrun.gd`, semente 21, 1ª Descida, rota "passeio" (luta, baú, fogueira, elite, chefe) | 1 Descida: 5 nós, 3 lutas, 116 toques, vitória, 290 s de relógio (inclui espera de carga da VM) |
| Estatística de rotas e lutas, sem render | mesma lógica, `--headless`, 2 políticas de combate (ingênua: só Atacar; atenta: Defender contra golpe avisado, skill a cada 2 turnos, poção < 40%), 2 políticas de mapa (segura: foge de luta; gulosa: elite/baú primeiro) | 12 Descidas (3 sementes de 1ª Descida, 3 de Descidas normais): 8 vitórias, 4 derrotas |
| Estrutura dos mapas | `mapsurvey.gd`, checagem padrão de 200 simulações | 12 mapas de 1ª Descida |

Limites: o bot é grosseiro (não lê lore, não compra com critério humano, escolhe lado da moeda no acaso), então **taxa de vitória dele não é taxa humana**; uso só para estrutura, custo em HP e contagem de toques. Os tempos de animação vêm de timers do jogo e valem; os tempos de carga (map 25 s, geração 28 s) foram medidos em CPU de VM com render por software e **não valem para celular**.

## 1. Veredito em 10 linhas

1. O que o jogo tem de melhor: a leitura do golpe (selo de intenção + "AGORA" + linha do tempo), a consequência da Coroa escrita ("Errar: dano +100% e Maldição por 3 turnos") e a moeda pintada. Combate de chefe é legível e dá tensão real.
2. O pior: **a Descida inteira cabe em 5 nós e a rota "só baú/fogueira/evento" chega ao chefe com uma única luta** (2 de 2 rotas passivas na amostra normal ganharam o chefe (4 de 5 no total das rotas passivas)). A escolha de nó vira pouco significativa.
3. O primeiro minuto não ensina nada: nenhum texto sobre Poder, moeda, névoa ou o que é "Nv". A primeira camada tem 3 destinos idênticos (Cidadão Infectado Nv 1 x3).
4. A economia da 1ª Descida entrega a primeira loja com 12 de ouro (item mais barato: 20) e um painel de Recompensa que esconde o botão Equipar abaixo da dobra, com "Continuar (vende o drop)" como caminho padrão.
5. O Poder, que é a progressão central, é muito desigual: Nv 1 dá +0,4; elite Nv 6 dá +3,6; chefe +11,2. Quem pula a elite chega fraco, quem a mata chega com folga. Isso é o mapa decidindo a luta, não o jogador.
6. A moeda tem escolha de lado que não decide nada (50% fixo, o lado é ritual). Custo: 1 toque e cerca de 2,8 s por lance, 2 a 11 lances por luta.
7. Bug de leitura: quando a moeda é do **Golpe de Escudo** da própria Bibiana, a tela mostra as consequências do golpe do inimigo ("Errar: dano +50% e Fraqueza", `t1-22-coin-choose.png`).
8. Meta-progresso: 4 compras no Santuário, 61 Ecos no total; uma Descida vencida rende 10 a 20. Acaba em cerca de 6 a 8 Descidas.
9. Acessibilidade: sem modo daltônico, sem escala de fonte, sem redução de movimento, sem menu de configurações, sem botão de desistir/pausar a Descida.
10. Nota geral de design mobile: **4,8/10**. Há um bom protótipo de combate dentro de uma Descida curta demais, sem ensino e sem laço de retorno.

## 2. Notas por pilar (0 a 10)

| Pilar | Nota | Em uma frase |
| --- | --- | --- |
| Onboarding / primeiro minuto | 4,5 | Home limpa e bonita, mas zero ensino: sem dica do toque duplo no mapa, do Poder, da moeda, do Defender |
| Legibilidade das decisões (mapa) | 4 | "Nv N" e "ouro" são os únicos dados; "ouro" aparece em toda luta; Nv não prevê o perigo (ver 3.3) |
| Escolhas significativas no mapa | 3,5 | 1ª camada sem escolha, rotas passivas vencem, elite é opção óbvia, fogueira some se você já está cheio |
| Combate: clareza e aviso | 6,5 | Melhor parte: aviso um turno antes, previsão "dano 12-15 · acerto 87% · crít 5%", linha do tempo com AGORA |
| Moeda: tensão e justiça | 4,5 | Consequência visível e regra de justiça cumprida; escolha de lado sem efeito; bug de mensagem no golpe de escudo |
| Ritmo e sessão (5 e 25 min) | 5,5 | 5 min cobre a 1ª Descida (bom gancho); falta conteúdo para 25 min; chefe de 70 s com 49 toques é longo |
| UX de toque | 6 | Alvos de 48+ px, ações na zona do polegar, confirmação nas skills; Equipar escondido e botão Início cortado |
| Feedback e progressão visível | 4,5 | "Subiu de nível! 0 → 1" é fraco (+5 HP); sem barra de Poder; sem comparação de equipamento visível |
| Economia (ouro, loja, risco) | 4 | Loja inútil no início, rica depois do elite; um único gasto bom por visita; ouro sobra (229 de uma vez) |
| Retenção / meta | 3,5 | Poucos desbloqueios, sem "próxima meta" na tela de fim, sem votos nem Descida diária implementados |
| Monetização sem quebrar o jogo (§16) | 6 | O desenho do GDD é limpo; a única oferta implementada (anúncio no baú, simulado) está cortada e disputa a Moeda da Sorte |
| Acessibilidade | 3,5 | Contraste de texto bom (painéis escuros), mas nada configurável; cor é o único canal em borda de selo e barras |
| **Geral** | **4,8** | |

## 3. Achados, com evidência

### 3.1 O que funciona (manter)

- **Aviso do golpe** (`t1-25-combat-turn-infected_citizen.png`, `t1-21-combat-boss-gravedigger.png`): selo com ícone e nome ("MOEDA Pá"), mensagem "O Coveiro prepara: Pá.", linha do tempo com "AGORA". Responde "o que vem?" em 1 olhada.
- **Previsão de ação**: "Atacar dano 12-15 · acerto 87% · crít 5% · +2 MP". Honesta e útil (GDD §6, ADR-0029).
- **Consequência da Coroa escrita antes do lance** (`Acertar: dano -50%. Errar: dano +100% e Maldição por 3 turnos.`). Cumpre o GDD §7 e F-018.
- **Gaveta com CONFIRMAR** (`t1-27-drawer-skills-selected.png`): segura contra toque errado, mostra custo e previsão.
- **Moeda pintada** com Cara e Coroa distintas, botões de 96 px de altura (`t1-22-coin-choose.png`).
- **Fogueira como alívio** (`t1-60-campfire-dark.png`): HP 125 → 135 e MP restaurados com 1 toque.
- **Elite e chefe apresentam bem** (`t1-21-combat-boss-gravedigger.png`); o chefe ocupa o palco e tem "crít 17%" na previsão (crítico visível, F-011).
- **Primeira Descida curta** como gancho (F-020): 5 nós, cerca de 5 minutos de jogo.
- **Sem tela de "morte" punitiva**: Ecos sempre creditados, em dobro na 1ª Descida.

### 3.2 Telemetria da Descida jogada a 1x (`t1.json`)

| Luta | Duração | Ações do jogador | Toques | Lances de moeda | HP |
| --- | --- | --- | --- | --- | --- |
| Cidadão Infectado Nv 1 | 15,8 s | 4 | 10 | 2 | 130 → 120 |
| Carrasco Apodrecido Nv 6 (elite) | 41,9 s | 14 | 30 | 6 | 135 → 88 |
| O Coveiro Nv 7 (chefe) | 70,3 s | 28 | 49 | 9 | 135 → 59 |

- Ação simples (Atacar/Defender): 0,7 a 1,8 s. Ação com moeda (inclui o giro): 4,3 a 5,5 s. Cada lance de moeda pede de 2,7 a 2,9 s de animação, mais o toque no lado.
- Descida total: 116 toques (46 em lutas de turnos, 12 no mapa, 9 em lojas e recompensas). Para uma sessão de 5 minutos isso é aceitável; o custo está no chefe (49 toques) e no número de lances de moeda.
- No lance do Golpe de Escudo o jogador paga 3 toques para abrir a gaveta, escolher e confirmar, mais 1 para o lado da moeda: **4 toques e cerca de 8 s por uma habilidade de 6 MP**.

### 3.3 Mapa e rotas (headless, 12 Descidas e 12 mapas de 1ª Descida)

- **1ª camada sempre com 4 Cidadãos Infectados Nv 1** (3 visíveis, idênticos). É o primeiro "momento de escolha" do jogo e não há escolha. O mapa 3D tem 3 marcadores iguais (`smoke_map.png` do teste, `t1-10-map-layer0.png`).
- **A 2ª camada tem baú na coluna 2 em 12 de 12 mapas; a 3ª tem fogueira (coluna 2 ou 3) em 12 de 12.** O desenho é previsível: o jogador aprende por repetição em 2 Descidas e o mapa deixa de ser decisão.
- **Rota passiva vence.** Com a política "segura" (baú, fogueira, evento antes de luta; 5 Descidas) o bot venceu 4: duas delas com 2 lutas (a obrigatória da camada 1 e o chefe) e duas, nas Descidas normais, com **uma única luta (a do chefe)**, ambas ganhas com 45 de 139 HP restantes. Nenhum sistema avisa "você está fraco para o chefe".
- **Poder pelo tipo de nó:** `power_gain = 0,4 × Nv × m_tipo`. Nv 1 comum +0,4; Nv 3 comum +1,2; elite Nv 6 +3,6; chefe Nv 7 +11,2 (`run_rules.gd`). Na Descida jogada: Poder 1,4 antes da elite, 5,0 depois; o chefe virou "luta de conferência" (135 → 59 HP, vitória). Resultado: a decisão mais forte do jogo é "lutar na elite sim ou não", e a resposta certa é sempre sim quando HP > 60%.
- **"Nv N" não prevê perigo.** Mesma camada, mesmo nível: Rastejador da Vala Nv 3 custou em média 78 HP em 2 lutas e matou o bot uma vez; Lodo de Esgoto Nv 4 custou 8 HP; Cão de Peste Nv 4 custou 85 HP (matou o bot em 1 de 2); Ossada Errante Nv 1 custou 41. A ficha de inimigos tem o contra-jogo, mas o mapa só mostra "Nv" e "ouro".
- **Pílula "ouro" em toda luta** não informa nada (todas dão ouro). Poderia ser a recompensa que difere: "chance de item", "Poder +1,2", "Galho Seco".

### 3.4 Economia (1ª Descida, `t1.log`)

- Ouro: luta Nv 1 = 12; baú = 49 (e Moeda da Sorte e Lâmina de Sineiro); elite Nv 6 = cerca de 150; total 229 na 2ª loja, gasto em 3 itens (Escudo Podre, Manto, Elixir) sem decisão real, porque o ouro não tem outro destino até a Descida seguinte.
- **1ª loja inútil:** 12 de ouro contra preço mínimo de 20 (Pão Mofado). A tela abre, mostra 2 cartões "(Ouro insuficiente)" cortados no texto e um botão Atualizar apagado (`t1-50-shop.png`). É 1 tela obrigatória sem decisão logo no minuto 2.
- **Recompensa esconde o Equipar** (`t1-40-reward.png`): o drop "Olho de Vidro (Incomum, Relíquia)" aparece, mas os botões "Equipar" e "Vender por 58 ouro" estão abaixo da dobra do painel; o botão visível é "Continuar (vende o drop)". Um jogador novo toca Continuar e vende o primeiro item que o jogo lhe dá. (O bot achou os botões na árvore de controles; um humano precisa rolar.)
- **Baú abre sozinho:** a tela já nasce com "+49 de ouro / Encontrou: Moeda da Sorte" (`t1-30-chest.png`); o baú pintado está fechado atrás do texto, e o botão do anúncio fica cortado atrás do "Seguir". O momento de abrir (maior pico de recompensa do mapa) não existe.
- **Moeda da Sorte tem dois usos concorrentes:** armar antes de um lance perigoso (valor alto) ou multiplicar o baú (×1,25 a ×2). O texto do baú a oferece primeiro; o jogador novo a gasta aí.

### 3.5 Moeda: tensão e justiça

- A regra de justiça funciona: 11 lances no chefe (bot ingênuo, 34 ações) foi o pior caso medido; no jogo a 1x o chefe fez 9 em 28 ações. Aviso um turno antes: sim em 100% dos casos vistos.
- **A escolha Cara/Coroa não decide nada** (GDD §7: 50% fixo, "a escolha é ritual"). Para o jogador é uma decisão falsa: custa 1 toque e a leitura do botão, sem informação nova. Uma decisão falsa repetida 9 vezes por chefe vira ruído (F-017/F-018 pedem o contrário).
- **A decisão real da moeda acontece um turno antes** (Defender anula a penalidade do Guerreiro), mas a tela de moeda não diz isso na hora: não mostra "Você Defendeu: penalidade anulada" nem o contrário.
- **Bug de leitura** (`t1-22-coin-choose.png`): moeda do Golpe de Escudo, o chip do topo diz "MOEDA Abraço Febril" e o texto "Errar: dano +50% e Fraqueza por 3 turnos", que é o golpe do inimigo. `_ask_call` reaproveita `_intent_detail.text` sem saber de quem é o lance (`combat_screen.gd`, `_ask_call`). O jogador conclui que a Fraqueza é dele. Pior que não dizer nada.
- O lance de moeda do Golpe de Escudo é feito 2 a 3 vezes por luta pelo bot por ser a skill nº 1 do Guerreiro; isso empurra o total de lances (2 na luta Nv 1, 6 no elite). Cada lance custa 2,8 s e 1 toque: F-017 continua verdadeiro para quem usa a skill.

### 3.6 Fim de Descida e retenção

- **Resultado** (`t1-99-result.png`): painel de texto corrido, "Conquistado: camada 5/4, Nível 16 (Poder 16.20), ouro 309, 5 nós..." (bug: "5/4"), botão "Início" cortado fora da tela. Nada diz **o que desbloquear agora** nem quanto falta.
- **Derrota:** "Derrotada por O Coveiro, nível 7 (ficou com 13% de HP)": ambíguo, parece a vida da Bibiana; é a do chefe. O número que ensina ("faltaram 13%") precisa de rótulo ("o Coveiro ficou com 13%").
- **Meta** (`x-sanctuary-library.png`): 4 itens (12, 16, 15, 18 Ecos = 61). Ecos por Descida: 1 por nó + 5 por chefe, em dobro na 1ª; vitória = 10 (20 na 1ª), derrota no meio = 3 a 6. Em 6 a 8 Descidas o Santuário está completo; o jogo deixa de dar razão de voltar antes de existir um 2º cenário (ADR-0049 adia isso).
- Santuário mostra "Faltam 2 Ecos" (bom), mas só depois de entrar no menu. A tela de fim não leva até ele com a meta.
- Sem votos, sem Descida diária, sem sequência: tudo no GDD §26 como Alpha/Beta. Hoje a razão para a Descida nº 3 é só "tentar outra rota".

### 3.7 Primeiro minuto

Sequência real: Home (`t1-00-home.png`) → "Nova Descida" → tela preta "Gerando o mapa... Semente 21. Conferindo se há caminho vencível (GDD §5)." (`t1-01-loading.png`) → mapa → toque no inimigo → cartão "Luta / Cidadão Infectado, nv 1 / Voltar · Caminhar" → combate.

- Home é boa (arte, 1 CTA). Mas o texto técnico de carga ("Semente", "GDD §5") é para desenvolvedor, não para jogador.
- No mapa não há nenhuma frase: não diz "toque num inimigo", "a névoa esconde a próxima camada", "HP/MP no topo", "mochila".
- Primeiro combate: o jogador vê Atacar/Defender e o aviso, mas não sabe que Defender anula a penalidade da Coroa (o Guerreiro, GDD §7). A dica só aparece na tela de **derrota** ("morte que ensina"). Para o jogador que vence, nunca aparece.
- A carga: 4 a 9 s para gerar o mapa (200 simulações, medido em headless nesta VM) e 25 s de reconstrução da cena do mapa a cada nó (render por software; não representativo). **Não medi em celular.** O guia `docs/PLAYTEST.md` já lista isso como pergunta aberta; mantenho como risco P0 de verificação.

### 3.8 UX de toque e acessibilidade (do código e dos prints)

- Positivos: `DarkTheme.polish_button` força mínimo de 48 px de altura, vibração de 12 ms, escala no toque; ações do combate em y 820 a 944; alvo de nó do mapa de 120x120.
- Gaveta e linha de previsão: contraste ok (texto claro sobre pedra escura).
- Problemas: botão "Início" cortado (resultado); "Atualizar" cortado em duas linhas (loja); "Assistir anúncio" cortado (baú); "Equipar" fora da dobra (recompensa); cartões de loja com texto empilhado em 5 linhas e cortado ("CRIT +8 (equipado: Olho de Vidro)").
- Pílulas do mapa de 14 px; barras HP/MP do mapa sem número.
- A velocidade 2x do combate é do `CombatScreen`; `GameScreen` recria a tela a cada luta com `time_scale` do jogo (1,0), então **a escolha 2x se perde na próxima luta** (leitura do código: `_show_fight`). Não confirmei em jogo.
- Sem: modo daltônico, escala de fonte, redução de movimento/relâmpago na UI (existe `GfxSettings.flashes` mas não há tela que o ligue), tela de configurações (haptics, áudio além do mudo), pausa, desistir da Descida, idioma.

### 3.9 Monetização (GDD §16 e §26)

- O que existe: anúncio simulado no baú (multiplicador). Nada mais.
- Risco real do que existe: o botão do anúncio disputa o espaço com a Moeda da Sorte e fica cortado; a tela já mostra o ganho pronto (+49) e depois oferece "multiplicar", o que lê como "o ganho de graça já veio, quer mais?". Bom para a regra "nunca pagar para vencer", fraco como ponto de conversão.
- Bons pontos de oferta (sem quebrar o jogo): **Soprar as Brasas** na fogueira apagada (+1 Brasa), **Lanterna do Viajante** na primeira camada (revelar o tipo de 1 nó), **dobrar Ecos** na tela de fim. Todos já estão em §26; a fogueira e a tela de fim são as de maior pico emocional. Não colocar anúncio antes da 2ª Descida.
- Moeda: nunca vender re-jogada (§16 já deixa "a definir"; recomendo fechar em "não").

## 4. Lista de melhorias

Convenção: **[ADR]** = muda regra ou fórmula do GDD, exige ADR, GDD e `RULES_VERSION`. Arquivo provável entre parênteses. Todas são sugestões; nenhuma foi implementada.

### P0 (arruínam o gancho ou mentem ao jogador)

1. **Corrigir a mensagem de moeda do golpe da Bibiana.** Causa: `_ask_call` usa `_intent_detail.text` (e o chip fica no golpe do inimigo) em qualquer lance (`combat_screen.gd`, `_ask_call`/`_show_coin`). Solução: passar a origem do lance (`event.label` já diz "shield_bash" ou o golpe do inimigo) e mostrar, para o golpe da Bibiana, "Golpe de Escudo: acertar o lado = atordoa o inimigo; errar = só dano" com o chip trocado por ícone de escudo. Sem regra nova.
2. **Mostrar o Equipar da recompensa sem rolagem e nunca vender por padrão.** Causa: `_render_drop` coloca 2 botões no `ScrollContainer` e o rodapé fixo é "Continuar (vende o drop)" (`run_panel_screen.gd`, `_render_reward`/`_render_drop`). Solução: mover Equipar e Vender para o rodapé (2 botões de 56 px lado a lado), "Continuar" só existe depois de escolher; se o item for equipamento melhor, Equipar com borda ouro e seta verde "▲ PRE +6". Sem regra nova (muda só o padrão de UI).
3. **Descida sem luta.** Causa: o grafo permite rota só com baú/fogueira/evento (`MapConfig`/`MapGenerator`) e a vencibilidade (§5) aceita isso. Solução (**[ADR]**, GDD §5): garantir no mínimo 2 camadas com luta obrigatória (todas as 3 opções do tipo luta/elite) na 1ª Descida; nas seguintes, no mínimo 40% das camadas. Alternativa leve sem tocar o gerador: o primeiro baú/fogueira só desbloqueia depois da 1ª vitória em luta. Meta de aceitação: em 100 mapas, nenhuma rota chega ao chefe com menos de 2 lutas.
4. **Onboarding mínimo em 4 dicas contextuais.** Causa: `runs_played == 0` existe, mas só serve para o mapa e os Ecos. Solução (sem regra): 4 balões únicos, dispensáveis, com `runs_played == 0`: (a) mapa: "Toque num inimigo para ver, toque em Caminhar para ir" (pulso 1 Hz no destino); (b) 1º aviso do inimigo: "O ícone mostra o próximo golpe. Defender reduz o dano"; (c) 1ª moeda: "Cara ou Coroa decide o dano. Defender antes anula a penalidade (Veterano)"; (d) recompensa: "Poder 1,00 → 1,40: seus atributos subiram". Telas: `map3d_screen.gd` (preview), `combat_screen.gd`, `run_panel_screen.gd`.
5. **Rótulo da carga e verificação em celular.** O texto "Conferindo se há caminho vencível (GDD §5)" sai; no lugar, "A cidade respira..." com barra de progresso real (`Winnability` reporta a fração) e teto de 3 s: se passar, reduzir `DEFAULT_RUNS` de 200 para 60 em celular. Medir em Android de entrada antes de decidir (teste 5.1).
6. **Tela de fim útil.** Causa: `_show_result` é um texto corrido com 3 botões, o último fora da tela (`game_screen.gd`). Solução: cabeçalho (VITÓRIA/DERROTA), 3 linhas com ícone (Poder, ouro, nós), faixa "Próximo desbloqueio: Tomo do Grito de Guerra, faltam 2 Ecos" com barra, rodapé fixo com "Outra Descida" (primário) e "Santuário" (secundário); "Início" vai para um ícone. Corrigir "camada 5/4" e "ficou com 13% de HP" → "O Coveiro ficou com 13% de vida".

### P1 (profundidade e retenção)

7. **Escolha de nó com informação que pesa.** Causa: pílulas "Nv N" e "ouro" (`map3d_screen.gd`, `_make_bubble`, `MapView.nodes`). Solução: substituir "ouro" por 1 ícone de recompensa real (Poder +1,2, item, Galho Seco, Moeda da Sorte) e "Nv" por 3 níveis de perigo para o jogador atual (calculado com a previsão que já existe: dano esperado do inimigo contra o HP atual), com legenda no cartão "Caminhar". Sem regra nova: é leitura do núcleo (padrão do ADR-0029).
8. **Nivelar o Poder.** Causa: `power_gain = 0,4 × Nv × m_tipo`; a elite dá 9 vezes uma luta comum e o chefe 28 vezes. Solução (**[ADR]**, GDD §9): dar um piso (+0,6 por luta comum de camada ≥ 2) e baixar o m_tipo da elite de 1,5 para 1,25, ou, melhor, mostrar a barra de Poder no HUD para o jogador *ver* o que perde ao pular a elite. Medir com o simulador (`--runs 150`) depois do MVP gráfico (regra 9 do CLAUDE.md).
9. **A escolha de Cara/Coroa precisa significar algo ou sumir.** Causa: GDD §7 fixa 50% e diz "ritual". Opções, da menor para a maior mudança: (a) **[sem ADR]** manter a escolha, mas encurtar o giro para 1,6 s e pular o botão com "Repetir último lado" (toque no medalhão); (b) **[ADR]** "Aposta": Cara = consequência normal; Coroa = aceitar o risco do golpe do inimigo (+25% do dano se perder) em troca de +1 Brasa ou 25% mais ouro se vencer; mesma chance de 50%, decisão real; (c) **[ADR]** moeda automática e a decisão volta inteira ao Defender. Recomendo (a) agora e testar (b) no experimento 3.
10. **Mostrar na moeda o efeito de ter Defendido** ("Defender: penalidade anulada" em verde) e do Golpe de Escudo ("Cara: o inimigo perde o turno"). Texto de 1 linha entre a moeda e os botões (`combat_screen.gd`, `_coin_label`).
11. **Baú com ritual.** Causa: `_render_chest` já mostra o conteúdo (`run_panel_screen.gd`). Solução: tela inicial só com o baú fechado e "Abrir" (primário); ao abrir, tampa e moedas (já há asset `iron_chest`); só então as linhas e o multiplicador, com o anúncio em cartão próprio (56 px) acima do "Seguir". Separar a Moeda da Sorte do baú: oferecer o multiplicador só se o jogador tiver 2 ou mais (preservar o uso de combate).
12. **Loja sem lixo.** Pular a loja (ou abrir só um selo "Mercador: 20 ouro mínimo") quando o ouro for menor que o item mais barato e não houver nada para vender; cartões de 2 colunas com ícone, nome, 1 linha de efeito e preço dourado; remover "Atualizar" quando desativado (`run_panel_screen.gd`, `_render_shop`, `game_screen.gd` fase SHOP). Sem regra.
13. **Velocidade 2x persistente.** Guardar `time_scale` no `GameScreen` e aplicar a cada luta (`game_screen.gd`, `_show_fight`; `combat_screen.gd`, `_toggle_speed`); botão de ícone no canto do palco.
14. **Atalho de repetição.** "Repetir último comando" já está no GDD §6; hoje o Golpe de Escudo custa 4 toques e 8 s. Toque longo no botão de skill executa a última skill sem gaveta; o 1º uso continua com confirmação.
15. **Mais camada e mais variedade antes de pensar em retenção.** A 1ª Descida é boa; a 2ª já repete tudo (mesmos 5 nós, 4 camadas). Prioridade de conteúdo: 6 eventos hoje mas só 3 ilustrados; 2º cenário (ADR-0049 prevê 6 camadas); Votos da Descida (§26) como camada de variação barata (3 votos, "sem poções", "só rotas de luta"; Ecos extras). Votos mudam a decisão sem arte nova.
16. **Meta com gotejamento de verdade.** 61 Ecos é pouco. Subir o catálogo para pelo menos 10 itens (3 por ala) com preço crescente 12 a 40, de modo que as primeiras 5 Descidas sempre desbloqueiem algo (já prometido em §26). **[ADR]** se mexer em `ECHOES_PER_NODE`/`ECHOES_PER_BOSS`.
17. **Dica de "morte que ensina" também na vitória apertada**: se ganhou com menos de 25% de HP ou usou as 2 poções, mostrar "Você usou todas as poções; no próximo mapa passe pela fogueira" no resultado.

### P2 (acabamento e acessibilidade)

18. **Menu de configurações** (engrenagem no canto, ao lado do som): efeitos de relâmpago (`GfxSettings.flashes`), vibração (`haptics`), tamanho do texto (100/115/130%), reduzir movimento, modo daltônico (adicionar forma ao selo: golpe = triângulo, debuff = losango, moeda = círculo; barras com padrão listrado no HP baixo). Hoje os `GfxSettings` existem sem tela.
19. **Botão "Desistir"/pausa** no mapa (confirmação, vale como derrota com Ecos): sessão curta no celular precisa de saída limpa. Auto-save já existe (`SaveStore`), então fechar o app é seguro.
20. **Pílulas do mapa** 14 → 16 px e HUD com número ("135/182") em vez de só barra.
21. **Contador de lances de moeda** no chefe ("lance 3 de ~5") só como chip pequeno, para reduzir a sensação de repetição (F-017).
22. **Cartão de combate "Nível 0 → 1".** O nível começa em 0 e o rótulo "Subiu de nível! 0 → 1" na 1ª luta soa a placebo (+5 HP). Começar em 1 e reservar "Subiu de nível!" para ganhos de skill ou de espaço (**[ADR]** só se mudar a fórmula; o rótulo em si é cosmético).
23. **Tela de carga** com dica rotativa em vez da semente.

## 5. Cinco experimentos de playtest (com métrica)

Para 8 a 10 pessoas que nunca viram o jogo, celular de entrada (Android 8 GB ou menos), `telemetry.log` ligado.

1. **Primeiros 90 segundos sem ajuda.** Gravar tela. Medir: tempo até o 1º toque em Caminhar (meta ≤ 20 s), tempo até o 1º Atacar (≤ 45 s), % que toca Voltar ou fica parado por 10 s no mapa, % que vende o 1º drop sem querer (hoje esperado alto; meta < 10% depois do P0 2). Comparar com e sem as 4 dicas (P0 4).
2. **A rota passiva.** Dois grupos: mapa atual vs mapa com 2 lutas obrigatórias. Medir: nº de lutas por Descida, % que chega ao chefe com Poder < 3, taxa de vitória contra o chefe, e a resposta "sentiu que escolheu a rota?" (1 a 5, meta ≥ 4).
3. **Moeda: ritual vs aposta.** A: moeda atual. B: moeda com "Aposta" (P1 9b). Medir: tempo médio por lance, % de lances em que o jogador troca de lado de uma vez para outra (indicador de decisão real), nota de tensão (1 a 5), mortes por moeda (meta ≤ 25%, GDD §23).
4. **Ritmo do chefe.** Chefe atual (cerca de 28 ações, 70 s, 49 toques) vs chefe com menos lances (1 a cada 4 ações) e skill com repetição por toque longo. Medir: duração, toques, abandono no meio, e "ficou cansativo?" (1 a 5, meta ≤ 2).
5. **Retorno D1 com meta visível.** Dois grupos: tela de fim atual vs tela com "Próximo desbloqueio: faltam N Ecos" e botão direto. Medir: % que inicia a 2ª Descida na mesma sessão (meta ≥ 70%), % que abre o Santuário, retorno em 24 h (D1, meta ≥ 35%), Descidas por sessão.

## 6. O que não consegui verificar

- **Desempenho e carga em celular**: geração do mapa 4 a 9 s só no headless da VM; 25 s de reconstrução do mapa por nó com render por software. Nada em GPU móvel, temperatura, bateria, 60 fps.
- **Toque de verdade**: os alvos foram avaliados por tamanho e por posição nos prints, não com polegar; zona de alcance em celulares grandes e telas com notch não testados.
- **Eventos, derrota, vitória do chefe com todas as opções, mini boss e Santuário em todas as abas**: capturei Santuário (3 abas: `x-sanctuary-*.png`), vitória (`t1-99-result.png`) e derrota forçada por script (`x-defeat.png`, números artificiais, serve só para o layout: lá também só o 1º botão cabe na tela). **A tela de evento não foi capturada** (o bot não caiu em nó de evento na rota jogada; a tentativa avulsa terminou em vitória e o print foi descartado); evento e mini boss foram lidos só pelo código e pelas fichas.
- **Taxa de vitória humana**: o bot não representa pessoa. As estatísticas (8 vitórias em 12) provam estrutura, não balanceamento.
- **Áudio, vibração e trepidação**: rodei com driver de áudio mudo (ALSA falhou, dummy). Nada sobre mixagem, sons de moeda ou aviso.
- **Daltonismo e contraste real**: avaliação visual dos prints e dos tokens da paleta; sem simulador de daltonismo.
- **Velocidade 2x que reseta**: lido no código; não reproduzi alternando entre lutas em tela.
- **Retorno no dia seguinte, monetização real, anúncio de verdade**: não implementados.
