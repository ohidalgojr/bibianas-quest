# MUDANÇA DE RUMO (2026-11-23): sprites 2D HD-2D

O Orlando reprovou tudo (modelos 3D procedurais e cenário). As referências dele são arte 2D sobre cenário com profundidade. Decisão (ADR-0052): **personagens e inimigos viram sprites 2D**, recortados das pranchas do Gemini. Ver TASK-065. **A parte abaixo sobre revisar os modelos 3D da TASK-062 deixou de ser prioridade**: eles são provisórios.

## O que o Orlando precisa gerar no Gemini (roteiro)

Formato de cada prancha: figura única de corpo inteiro, 3/4 de frente, pose neutra, **fundo escuro liso sem cenário**, 1376x768 ou maior, sem texto, sem moldura, prompt sem citar jogos nem artistas (GDD 18). Estilo das pranchas que já existem em `docs/design/refs/inimigos/`.

1. **Bibiana** (prioridade 1): guerreira de capuz rasgado, armadura de malha, escudo e espada, adulta, sombria, 3/4 virada para a direita (como no mockup `refs/ui/bibiana-mockup-combate-mobile.jpg` e na pintura `refs/roaming-boss/04-...`). Ideal: variantes de cor/brilho da mecha (GDD 9), ao menos a primeira.
2. Inimigos que já existem no jogo e ainda estão em 3D tosco: Cidadão Infectado, Rato Grande, Corvo Carniceiro, Cão de Peste, Sineiro Penado, Ossada Errante, Lodo de Esgoto, Sanguessuga de Beco, Enforcado, Costurado, Carrasco Apodrecido, Mãe das Ratazanas, Carcereiro do Sino e **O Coveiro (chefe)**. Fichas em `docs/enemies/`.
3. Os 5 inimigos do estudo que ainda não têm código: 02, 03, 05, 06, 07 (as pranchas já existem; entram como inimigos novos quando o Orlando mandar).
4. **Fundos pintados** (opcional, recomendado): a arena do combate pintada na proporção do palco (retrato), no estilo de `refs/roaming-boss/04-...` e do mockup, sem personagens, para usar como cenário em camadas (fundo, meio, primeiro plano com neblina).

Salvar em `docs/design/refs/inimigos/` com o id do jogo no nome; o agente roda `python tools/make_sprite.py <prancha> assets/bibiana/sprites/<id>.png --box x0,y0,x1,y1 --height 240` e registra em `ModelRegistry` (chave `sprite`).

# Próxima rodada de validação (parada em 2026-11-22, por cota)

Tudo abaixo está **commitado e com a suíte verde (369/369)**, mas **nada de arte foi aprovado ainda**. A régua é o ADR-0050: só vale o print 540×960 do jogo contra o checklist E de `docs/design/IDENTIDADE-VISUAL.md`, revisado por um agente de direção de arte (12/12). Regras do dono no topo do mesmo arquivo: **nada fofo, nada tosco, mundo sombrio, siga as referências do Gemini à risca**.

## O que o diretor de arte precisa revisar primeiro

1. **Modelos, rodada 2** (prints em `docs/tasks/prints/TASK-062-<id>.png`): plague_hound, gravedigger, rotten_executioner, blind_censer_bearer, wax_physician, trench_crawler. Rodada 1 foi reprovada 6 de 6 (cobalto, hastes finas, sem fidelidade aos conceitos). Técnica nova: Skin modifier + subsurf + decimate, cabeças modeladas, textura baked de 256 px. Auto-avaliação do especialista: "melhor, ainda não aprovado" (rosto é decalque, tronco escuro, abaixo do orçamento de triângulos em 3 deles, cera e latão ainda quentes). Comparar os 3 com conceito (Turiferário, Médico da Cera, Rastejador) contra `docs/design/refs/inimigos/01, 04, 08`.
2. **Cenário, rodada 2** (prints em `docs/tasks/prints/TASK-063-*.png`: campfire, campfire-lit, shop, mapa-inicio, mapa-passo3, arena-comum, arena-chefe). Rodada 1 foi reprovada 7 de 7. O especialista só confia na fogueira. Fracos declarados: catedral do chefe invisível, xadrez leve no mapa, fachadas ainda cubos, mercador borrão, pira ilegível.
3. **Combate e design system** (`TASK-064-combate.png`, `TASK-061-arena-*.png`): conferir o item 12 (palco >= 57%; medido ~68%) com os modelos novos.

Como pedir a revisão: agente de direção de arte lê `IDENTIDADE-VISUAL.md` (regras do dono, B, D, E) e `ESTUDO-ui-mobile-inimigos-estetica.md` partes 4 e 5, abre os prints com o Read e devolve PASS/FAIL dos 12 itens por print, ACEITA ou REJEITA e 3 correções objetivas. Rejeitado volta ao especialista (modelos: `tools/blender/kb2*.py`, `rebuild.sh`; cenário: `focal_set.gd`, `duel_arena.gd`, `scenario_renderer.gd`, `tools/blender/make_scenery.py`).

## Comandos úteis

- Suíte: `powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1` (rode `& "$env:GODOT_BIN" --headless --path . --import` depois de criar `class_name` ou asset novo).
- Print real: `powershell -ExecutionPolicy Bypass -File tools\screenshot.ps1 -Scene <cena> -Out docs\tasks\prints\<nome>.png -Extra <args>`. Cenas: `combat3d/combat3d_preview.tscn -Extra inimigo=<id>`, `camp3d/game_preview.tscn -Extra tela=campfire|shop|chest|event|reward|home|result`, `camp3d/scene3d_preview.tscn -Extra tipo=<kind>`, `map3d/map3d_preview.tscn -Extra passos=N`, `stage/asset_preview.tscn -Extra "pecas=a.glb;b.glb,tamanho=9"`.
- Tamanho das peças dos kits: `godot --headless --path . -s tools/inspect_assets.gd -- res://assets/kenney/<kit>`.
- Blender headless: `"C:\Program Files\Blender Foundation\Blender 5.3\blender.exe" -b -P script.py -- args` (o MCP do Blender deu timeout nesta sessão; o addon responde na porta 9876).
- Nota: o shell de agentes quebra alguns heredocs; escreva scripts com a ferramenta de arquivo.

## Backlog depois da aprovação (ordem da auditoria `docs/design/AUDITORIA-UI-vs-ESTUDO.md` §15)

Feito: pacotes 1 (DarkTheme 2.0), 2 (combate palco cheio, parte), 4 (barra com rastro). Faltam, em ordem: 5 loja com comparação ▲/▼ e selo de preço; 6 mapa limpo (dock inferior, gaveta de equipamento, bolhas de ícone); 7 ritual da Moeda; 8 Resultado e Recompensa; 9 SafeArea; **10 Bibiana nova (sem capacete chibi)**; 11 reaprovar os 5 inimigos; 12 Home e Santuário 3D; 13 fogueira (cartões, clarão ao acender); 14 chefe visível no mapa e cenário vindo do gerador; 15 os inimigos 02, 03, 05, 06, 07 do estudo e o Roaming Boss. Decisões de contradição já tomadas: `docs/design/DECISOES-ARTE-UI.md` (o Orlando pode sobrescrever).

## Estado do repositório

- Branch `claude/project-improvements-701756` (a partir de `main` `83b1a58`), com TASK-052 e 055 a 064. `RULES_VERSION` = 21.
- Pendências que dependem do Orlando: jogar uma Descida no celular, enviar `telemetry.log`, TASK-014 (exportação), conectar o addon do Blender.
