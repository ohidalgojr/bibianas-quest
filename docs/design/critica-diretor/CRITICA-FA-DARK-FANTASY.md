# Crítica de fã de dark fantasy: o jogo passa a vibe?

Avaliador: fã hardcore de Bloodborne, Dark Souls, Fear & Hunger, Darkest Dungeon, Sword of Convallaria, Tactics Ogre, Triangle Strategy, Octopath, Buriedbornes e Vagrant Story. Não alterei código nem assets.

Prints reais em `docs/design/critica-diretor/fa/`, tirados com Vulkan/lavapipe (540x960, 60 quadros): `home`, `mapa-p0|p2|p4|p5`, `c-*` (combates), `t-*` (loja, fogueira, evento, recompensa, baú, vitória, derrota, resultado) e `zoom-*` (recortes ampliados).

Ressalvas de captura:
- O preview de `tela=event` com a semente fixa 7 nunca chega a um evento e mostra a Vitória. Usei um script próprio fora do projeto (`scratchpad/shot2.gd`, semente 3) para o evento e para a derrota.
- A derrota foi forçada via `run.phase = DEFEAT`. Por isso o texto "Derrotada por ?" e "nível 0" é artefato da captura, não bug confirmado.
- Em lavapipe o mapa roda a 4-5 fps, então não avaliei animação, só quadro parado.
- Não ouvi áudio.

## 1. Notas de vibe

| Tela | Nota | Referência mais próxima: "lembra X porque..., falta Y" |
| --- | --- | --- |
| Home | 8,0 | Lembra a capa de Bloodborne: escadaria ogival, lampiões, grades e chuva, com a Bibiana de armadura gasta no centro. Falta fumaça e névoa baixa. A Bibiana parece recortada por cima do cenário, sem sombra no chão. |
| Mapa, início e meio (p0, p2) | 5,0 | Lembra um diorama de kit (estilo Kenney) com filtro azul, não Triangle Strategy. As casas e os muros são lavanda chapada, de brinquedo, o que o ADR-0042 proíbe ("nunca lavanda lavado"). Falta cantaria com textura real, ferro retorcido e silhueta gótica. O topo é só escuridão sem arquitetura. |
| Mapa, perto do chefe (p4, p5) | 7,5 | O fundo pintado com catedral, rosácea, portão de ferro e forca com lampião é puro Bloodborne. Mas o chão e as casas continuam do mesmo kit lavanda, então a colagem aparece. Em p4 a Bibiana está cortada na borda esquerda. |
| Combate comum (Cidadão, Lodo, Mãe das Ratazanas) | 7,0 a 7,5 | Lembra Fear & Hunger mais um mockup de Tactics Ogre: inimigo enorme e central, Bibiana de costas, luz de lampião e chuva. Falta variação de cenário (ver P1) e luz quente refletida no inimigo. |
| Combate de elite (Cão de Peste) | 8,0 | Melhor cena de combate: sino rachado, forca, correntes e lampião ao fundo. O cão tem peso e silhueta de Bloodborne. |
| Combate de chefe (Coveiro) | 8,0 | Escala, pá e túmulos dão a sensação de Dark Souls. A cabeça fica sob a moldura do topo e o cartão de intenção a cobre. |
| Hanged Man, Sineiro e Corvo | 6,5 a 7,0 | Sprites cinza e planos, sem contato com o chão. O Enforcado flutua sem sombra nem corda legível. |
| Loja | 7,5 | Lembra Darkest Dungeon: balança, poções, lampião, mercador encapuzado. O texto dos cartões está truncado ("Ouro insuficiente" colado nos botões). |
| Fogueira | 6,5 | Cenário gótico bonito, mas a fogueira está apagada e a tela é azul-cinza, sem calor. Falta o clímax Dark Souls: o foco quente e a Bibiana sentada junto às chamas. |
| Evento | 6,0 | A arte da ilustração é ótima (Arauto Cego, balança, lampião), mas o painel estoura a tela (ver P0). |
| Recompensa | 7,0 | Altar com feixe de luz e candelabros, boa composição. O texto é seco: lista de números sem peso. |
| Baú | 7,5 | O baú sob luz quente no escuro é o melhor uso de luz dirigida do jogo. |
| Vitória | 6,5 | Reaproveita o fundo do evento e o painel é um muro de texto. Falta catarse. |
| Derrota | 5,5 | Bibiana ajoelhada, cortada pelo painel. Poderia ser o "VOCÊ MORREU" do jogo e é só um cartão de texto. |
| **Geral** | **7,0** | Tem o DNA certo (paleta, chuva, pintura gótica, tipografia). A execução cai quando entra o kit 3D lavanda do mapa e quando a UI vira parede de texto. |

## 2. O que já passa a vibe de verdade

- **Fundos pintados de combate, home, loja, recompensa e baú.** Ogivas, grades, sinos, forca com lampião, poças com reflexo e neblina azul-ardósia com um único foco âmbar. É exatamente a regra "luz dirigida sobre escuridão" do cânone.
- **Chuva em partículas e vinheta.** Dão peso e fecham o quadro em todas as telas.
- **Bestiário com silhueta.** Cão de Peste, Mãe das Ratazanas, Lodo, Corvo e Coveiro são legíveis em 540x960 e mórbidos no estilo Buriedbornes.
- **Estrutura de tela de combate.** Inimigo grande, Bibiana de costas, linha do tempo à esquerda e cartão de intenção (garras ou moeda) funcionam. O cartão de moeda dourado se destaca bem.
- **Tipografia serifada small-caps (dourada) e painel de pedra com rebites de bronze.** Coerente entre home, loja, fogueira e baú, com cara de Darkest Dungeon.
- **Ícones de ação** (espada, escudo, grimório, mochila) em pixel art escuro e coerentes com os botões.
- **Mapa perto do chefe.** O backdrop da catedral dá a sensação de caminhar rumo a algo monumental.

## 3. O que quebra a imersão

### P0

1. **Kit 3D do mapa lavanda e de brinquedo.** Casas, muros e canteiros são azul-violeta chapados, com telhado liso e janelas de brinquedo. É a pior violação do ADR-0042 e do checklist ("zero lavanda lavado, desgaste real"). Provável causa: `game/presentation/map3d/map3d_screen.gd`, ambiente com `env.ambient_light_color = Color("66728F")` e `ambient_light_energy = 1.9` (linhas ~137-138), mais a falta de textura suja nos materiais do kit. Correção:
   - Baixar a energia ambiente para 0,6 a 0,9 e esfriar para um carvão azul-ardósia dessaturado, por exemplo `#3A4250`.
   - Multiplicar o albedo das paredes por um tom de fuligem (`#4a4742`).
   - Adicionar ruído de textura de pedra/sujeira por shader ou material, e escurecer o topo (gradiente vertical).
2. **Painel do evento estoura a tela e esconde as opções.** O texto é cortado ("...estende uma balança de osso") e os botões de escolha não aparecem (`t-event.png`). O painel também está deslocado para a direita em relação aos outros. Provável causa: o painel do evento em `game/presentation/game_screen.gd` / `game/presentation/run/` com a ilustração fixa ocupando o espaço. Correção: colocar o conteúdo num `ScrollContainer`, reduzir a altura da ilustração (ou sobrepô-la ao cenário) e garantir que as escolhas sejam visíveis sem rolagem. Sem isso o evento é injogável em retrato.
3. **Mapa sem arquitetura no topo e no meio.** Fora do chefe, as camadas mostram só chão escuro e casinhas pequenas. Falta o diorama monumental que o ADR-0036 pede. Correção: fazer o `scene3d_backdrop.gd` (ou equivalente) pintar uma silhueta gótica em todas as camadas, escurecida e com névoa, e não só perto do chefe. Reaproveitar o painel de catedral das camadas finais, com opacidade menor nas iniciais.

### P1

4. **Combate com o mesmo fundo para 5 inimigos diferentes.** Cidadão, Lodo, Mãe das Ratazanas, Sineiro e Enforcado compartilham a rua com portão ao fundo (só Cão de Peste e Coveiro mudam). Isso mata a ideia "luta naquele lugar". Correção: mapear fundos por tipo de nó/camada em `game/presentation/combat3d/combat3d_stage.gd` (ou onde estiver o seletor): sarjeta, cemitério, praça do sino, igreja.
5. **Inimigos cinza e planos, sem luz quente nem sombra de contato.** O lampião do cenário não tinge o sprite, e Enforcado e Cão parecem flutuar. Correção: sombra elíptica escura sob cada sprite (`duel_arena.gd`), com um leve rim light âmbar do lado do lampião e `modulate` frio no lado oposto. Desfocar levemente os pixels do contorno para não parecer adesivo recortado.
6. **Cartão de intenção cobre a cabeça do inimigo.** No Coveiro e no Cidadão a cabeça fica escondida pelo cartão. A linha do tempo também cobre a cabeça do Cão. Correção: ancorar o cartão acima do sprite com margem calculada pela altura dele, ou encolher o cartão e deixar o ícone sem texto no estado normal.
7. **Barras de HP e MP em verde e azul saturados.** Destoam do resto (parecem barras de RPG genérico). Correção: usar vermelho-sangue escurecido para HP e azul-aço dessaturado para MP, com borda de bronze, mantendo o mockup `bibiana-mockup-combate-mobile.jpg` mas mais sóbrio. A barra vermelha do inimigo também é chapada e deveria ter textura fina.
8. **Telas de Vitória, Derrota e Resultado são parede de texto.** O momento mais emocional do jogo vira lista de estatísticas. Correção: título grande e luminoso, cena maior (a Bibiana de pé na vitória, ajoelhada com o corpo inteiro visível na derrota), e as estatísticas num bloco colapsável ou em duas colunas curtas.
9. **Bibiana cortada em quadros diferentes.** Cortada na borda esquerda no mapa (p4) e na derrota (ajoelhada atrás do painel). Correção: recalcular a altura do palco para que o painel de baixo não cubra o personagem.

### P2

10. **Fogueira apagada e sem foco.** A tela mais "Dark Souls" do jogo mostra brasas mortas. Correção: ao menos brasas pulsantes e uma luz âmbar fraca no chão mesmo apagada, para a tela nunca ser só azul.
11. **Cartões de loja truncados.** O texto de "Ouro insuficiente" encosta nos botões; o painel precisa de mais altura ou fonte menor.
12. **Chips do mapa usam texto ("ouro", "fogueira", "chefe") em vez de ícone.** Em Buriedbornes, o ícone comunica o tipo sem ler. Correção: trocar por ícones de `ico-g-nodes.jpg` com o rótulo só no destino selecionado.
13. **HUD do mapa sem rótulos.** As barras no topo (vermelha e azul) não dizem o que são; o ouro está colado numa moeda minúscula.
14. **Linha do tempo com retratos ilegíveis em tamanho pequeno** (bustos cortados que parecem iguais entre aliados). Considerar silhuetas mais distintas por tipo.

## 4. Dez ideias baratas de atmosfera (por prioridade)

1. **Escurecer e dessaturar o ambiente do mapa** (corrige P0.1 de graça): menos energia, tom carvão, e tint de fuligem nos materiais. Custo: poucas linhas.
2. **Sombra de contato + rim light âmbar nos sprites** de combate: some o efeito adesivo e integra com o lampião.
3. **Cintilar o lampião** (oscilação de 3 a 6% de energia com ruído) em todas as telas que o têm. Dá vida com custo quase nulo.
4. **Fogueira viva**: brasas pulsantes e fagulhas subindo (`GPUParticles`/`CPUParticles2D`), mesmo apagada; ao acender, flash e luz que balança.
5. **Névoa rasteira em camadas** (duas faixas de sprite com scroll lento, opacidade 15 a 25%) na frente do chão em combate e home.
6. **Transição de entrada em combate**: vinheta fecha, 1 batida grave e um corte seco com leve tremor de câmera (hit-stop de 60 a 100 ms do GDD §19).
7. **Respiração do inimigo e da Bibiana**: escala vertical de 1 a 2% em ciclo lento, mais um balanço do manto. Em sprite 2D é baratíssimo.
8. **Ambiente sonoro por tela**: chuva constante, sino distante no mapa, crepitar na fogueira, silêncio quase total na moeda (já previsto no GDD). Música só entra no chefe.
9. **Texto de sabor curto em vitória e derrota** ("O sino calou." / "A cidade a engoliu."), com título grande e letra a letra. Troca a parede de números por tom.
10. **Granulação e leve aberração cromática** no pós-processamento (grão de filme fino, 3 a 5%) para unificar sprite pixelado, fundo pintado e UI sob o mesmo "papel sujo".

## 5. Resumo final

- Veredito: o jogo tem a vibe de dark fantasy nas telas pintadas (home, combate, loja, baú) e perde-a no mapa 3D e nas telas de texto. Nota geral **7,0/10**.
- Home 8,0, combate 7,0 a 8,0, loja 7,5, baú 7,5, recompensa 7,0, vitória 6,5, fogueira 6,5, evento 6,0, derrota 5,5, mapa 5,0 (meio) e 7,5 (chefe).
- O que funciona: backdrops góticos pintados, chuva, vinheta, bestiário legível, painel de pedra com rebites e tipografia serifada.
- P0-1: kit do mapa lavanda e de brinquedo (ambiente `66728F` com energia 1,9 em `map3d_screen.gd`); escurecer, dessaturar e sujar.
- P0-2: painel do evento estoura a tela, texto cortado e opções invisíveis.
- P0-3: mapa sem arquitetura monumental fora da camada do chefe; falta backdrop gótico em todas as camadas.
- P1: mesmo fundo para 5 inimigos, sprites sem sombra nem luz quente, cartão de intenção cobrindo a cabeça, barras HP/MP saturadas, telas de vitória e derrota viram texto.
- P2: fogueira apagada sem foco, cartões de loja truncados, chips de texto no mapa, HUD sem rótulos.
- Melhor retorno por custo: ideias 1, 2 e 3 (ambiente do mapa, sombra de contato, cintilar de lampião).
- Prints e zooms em `docs/design/critica-diretor/fa/`.
