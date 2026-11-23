# ADR-0042: cânone visual HD-2D/isométrico e atmosfera gótica obrigatórios para todo asset

| Campo | Valor |
| --- | --- |
| Status | Aceito (Orlando, 2026-11-21) |
| Data | 2026-11-21 |
| Tarefa | Transversal a toda criação/ajuste de assets (`F-022`) |
| GDD | 17, 18, 19 |

## Contexto

Ao revisar a direção visual em evolução (`ADR-0036`, `ADR-0041` e o estudo da `TASK-051`), o Orlando consolidou e atualizou a lista definitiva de referências estéticas do projeto (`docs/FEEDBACK.md`, `F-022`), promovendo **Sword of Convallaria** ao topo das referências de arte/craft tático e determinando que todo cenário, profundidade espacial e asset sigam a linguagem dos referenciais táticos/HD-2D/isométricos escolhidos, porém filtrados por uma atmosfera **bem dark e gótica**, com prioridade máxima para **Bloodborne** e **Dark Souls**.

Até aqui, diferentes agentes consultavam referências esparsas (ora mais próximas de fantasia clássica/colorida, ora kits CC0 com peças saturadas ou lavadas em luz lilás), sem um filtro atmosférico gótico explícito e obrigatório para qualquer asset produzido no Blender, adaptado de kits CC0, gerado como conceito de UI/ícone/inimigo ou iluminado nas cenas do Godot.

## Decisão

Fica instituído o **Cânone Visual em Dois Eixos**, obrigatório **sempre que qualquer tipo de asset for criado, adaptado ou revisado** no repositório:

### 1. Eixo 1 — Gráficos, Craft, Cenários e Profundidade Espacial

| Prioridade | Referência | O que define no projeto | O que **não** copiar |
| --- | --- | --- | --- |
| **1 (Topo de arte)** | **Sword of Convallaria** | Dioramas isométricos ricos e artesanais; textura densa em pedra, madeira e metal; iluminação dramática com tochas/frestas quentes sobre sombra fria; leitura tática cristalina de altura/terraços; silhuetas sérias e nobres | Fantasia luminosa diurna ou paletas heróicas saturadas |
| **2** | **Tactics Ogre** (*Reborn*) | Seriedade medieval sombria; arquitetura feudal pesada; proporções sóbrias (sem cara de brinquedo/chibi exagerado); paleta mineral contida | UI carregada de listas longas para tela retrato |
| **3** | **Triangle Strategy** | Lajes e alvenaria com textura mineral aparente; contraste frio azul-ardósia vs âmbar das chamas; partículas atmosféricas em primeiro plano; profundidade de pátios, escadarias e muralhas | Escala de esquadrão amplo com dezenas de unidades na tela |
| **4** | **Octopath Traveler** (*I / II / CotC*) | Profundidade real em múltiplas camadas (primeiro plano desfocado, palco central nítido, planos de fundo em névoa); frestas direcionadas de luz; escala monumental de corredores e ruínas | Sprites 2D planos como rota do MVP (seguimos 3D low-poly pixelizado, GDD §18) |
| **5** | **Ragnarok Online** | Cenários 3D isométricos estilizados com arquitetura imponente, verticalidade de salões/catedrais/becos e leitura espacial envolvente entre pisos e estruturas | Cores pastéis ou tom leve de MMO clássico |
| **6** | **Buriedbornes** (*Buriedbornes / Buriedbornes2*, citado como *"buried bones"*) | Tom cruel de roguelite sombrio; criaturas mórbidas e estranhamento corporal; UI escura, enxuta e opressiva que mantém a tensão do risco | Poluição textual excessiva fora da zona útil do retrato 540×960 |

*Compatibilidade mantida:* a base estrutural de diorama em blocos/terraços do *Final Fantasy Tactics* (`ADR-0036`, `ADR-0041`), as bolhas de leitura de destino no mapa e a composição de combate inspirada em *Fear & Hunger* / fogueira de *Darkest Dungeon* permanecem válidas, subordinadas a este cânone.

### 2. Eixo 2 — Filtro Atmosférico Obrigatório (Dark Fantasy & Horror Gótico)

Todo elemento do Eixo 1 **deve** passar por este filtro atmosférico — é ele que impede o jogo de parecer colorido, limpo ou fofo:

| Prioridade | Referência | Regra atmosférica obrigatória |
| --- | --- | --- |
| **Máxima (Gótica)** | **Bloodborne** | Arquitetura gótica vertical e opressiva: arcos ogivais/pontiagudos, pináculos, contrafortes, grades e portões de ferro forjado retorcido, gárgulas, lanternas de rua penduradas e paralelepípedos molhados; neblina densa rasgada por luar frio azul-prata e luz isolada de lampião âmbar; decadência claustrofóbica de cidade tomada pela praga |
| **Alta (Mundo Morrendo)** | **Dark Souls** | Melancolia monumental de *dying world*: cantaria maciça lascada e enegrecida por fuligem, ferrugem e musgo morto; fogueiras/brasas como raro foco de calor em meio ao abismo; peso físico e silhuetas sérias em armas, armaduras, monstros e ruínas |

### 3. Abrangência obrigatória

Esta decisão aplica-se a **100% dos assets** criados ou modificados em qualquer etapa do projeto:

1. **Modelos 3D** feitos no Blender (`tools/blender/`), gerados via TRELLIS.2/Meshy ou adaptados de kits CC0 (KayKit, Kenney, Quaternius — sempre escurecidos/retingidos e livres de elementos fofos).
2. **Cenários, dioramas, tiles e props** (`ScenarioBlueprint`/`Generator`/`Renderer`, escadas, muros, arcos, pontes, lanternas, túmulos, ruínas).
3. **Personagens, inimigos e chefes** (silhuetas, proporções, desgaste de pano/metal, ferrugem, ossos, postura ameaçadora).
4. **Equipamentos, armas, consumíveis e objetos de cena** (baús, fogueiras, relíquias, moedas).
5. **UI, HUD, ícones, retratos, molduras, painéis e telas inteiras** (pedra escura, ferro batido, bronze oxidado, pergaminho envelhecido, bordas finas).
6. **Iluminação, clima, partículas e pós-processamento** (`WorldEnvironment`, `DirectionalLight3D`, `SpotLight3D`, névoa exponencial, chuva/cinzas, `PostFx` com dithering/split-toning e vinheta).

### 4. Matriz de Tradução Referência → Descritores Originais (GDD §18)

Pela regra de originalidade do GDD §18, **prompts de IA (imagem, 3D, textura, som) jamais citam nomes de jogos, personagens ou artistas**. Agentes devem traduzir as referências nos descritores originais abaixo:

| Intenção visual | Descritores originais obrigatórios (para prompts, specs Blender e shaders) |
| --- | --- |
| Craft + iluminação tática de topo (*Sword of Convallaria*) | Diorama isométrico artesanal em múltiplas alturas, texturas ricas e táteis em pedra e ferro, iluminação direcional dramática com contraste quente-frio limpo e alta legibilidade tática dos planos |
| Profundidade e camadas (*Octopath / Triangle Strategy / Ragnarok*) | Composição em três profundidades (primeiro plano em silhueta/partículas, palco central nítido em relevo, fundo monumental mergulhado em névoa), feixes estreitos de luz, arquitetura imponente com pé-direito alto |
| Arquitetura e clima góticos (*Bloodborne*) | Arcos ogivais pontiagudos, pináculos afilados, vitrais estilhaçados ou cegos, grades de ferro forjado, lampiões de rua solitários em neblina densa, calçamento de paralelepípedos úmidos refletindo luar frio cinza-azulado |
| Peso e decadência (*Dark Souls / Tactics Ogre*) | Cantaria maciça rachada e gasta pelo tempo, metal martelado oxidado com ferrugem escura, tecidos pesados desfiados e sujos de cinza, proporções adultas e sóbrias, rarefeito brilho âmbar de brasa contra sombras profundas |
| Horrores e UI roguelite cruel (*Buriedbornes*) | Anatomia perturbadora e silhuetas únicas de horror corporal/clerical, rostos velados ou sem feições, interface escura de baixo ruído visual com pedra negra e filetes de bronze envelhecido |

### 5. Critérios de reprovação automática de assets

Qualquer asset ou tela deve ser reprovado pelo autor ou revisor (`docs/REVIEW-CHECKLIST.md`) se apresentar:
- Cores alegres, pastéis ou saturação alta fora dos dois acentos permitidos (ouro da moeda e vermelho de perigo, além do raro foco âmbar de lampião/fogueira — GDD §18; **a antiga mecânica de mecha colorida no cabelo da Bibiana foi removida por completo em `F-024`**).
- Vegetação verde viva ou aparência de maquete de brinquedo/cartoon/plástico liso (ex.: pinheiros verdes saturados sem tratamento).
- Cenário plano sem escalonamento de profundidade, sem sombras projetadas nem hierarquia clara entre fundo escuro, palco iluminado e primeiro plano.
- Iluminação ambiente alta e uniforme (tom lilás/lavado que apaga as sombras góticas).
- Citação de nomes de jogos, personagens ou artistas em prompts de geração de assets.

## Alternativas

1. **Manter apenas as 7 referências genéricas do `ADR-0036`:** descartado porque deixava margem para estética colorida/genérica (Hero Wars / kits Kenney originais) sem direção gótica explícita.
2. **Adotar somente *Bloodborne*/*Dark Souls* em 3D realista sem o filtro isométrico/HD-2D:** descartado porque quebraria a legibilidade tática em retrato 540×960 e o orçamento de baixo polígono/renderização móvel definidos no GDD §18.
3. **Separar a regra por tipo de asset (só cenários vs só personagens):** descartado por determinação expressa do Orlando — a unidade visual exige que **todo e qualquer asset** obedeça ao mesmo cânone.

## Consequências

- **Positivo:** todos os agentes (código de cena, Blender, conceitos Nano Banana, TRELLIS.2, UI, shaders) trabalham com uma única régua estética coesa: craft e profundidade isométrica/HD-2D no padrão de *Sword of Convallaria*, *Tactics Ogre*, *Triangle Strategy*, *Octopath Traveler*, *Ragnarok Online* e *Buriedbornes*, mergulhados na atmosfera dark gótica de *Bloodborne* e *Dark Souls*.
- **Obrigatório nas revisões:** `docs/ART-DIRECTION.md §8` ("teste do print") e `docs/REVIEW-CHECKLIST.md` passam a cobrar explicitamente a aderência aos dois eixos e à regra de originalidade (GDD §18) antes de aprovar qualquer tarefa visual ou de asset.
- **Imutabilidade mecânica:** esta decisão é estritamente visual/governança; não altera fórmulas do núcleo nem incrementa `CoreVersion.RULES_VERSION`.
