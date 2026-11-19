# TASK-036: tabuleiro 3D isométrico com visão parcial e câmera que acompanha

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada) |
| Aberta em | 2026-11-19 |
| Fase | 1, apresentação 3D do MVP jogável (ADR-0036) |
| GDD | 5, 16, 17, 19 |
| ADRs | ADR-0036 (e os que a tarefa criar) |

> **Antes de escrever código leia `docs/ART-DIRECTION.md` inteiro.** A tarefa só fecha com o "teste do print" (seção 8): print do jogo rodando com janela, anexado em `docs/tasks/prints/`, e as seis respostas por escrito. Suíte verde não basta.

## Objetivo

O mapa da Descida vira o **tabuleiro isométrico com altura** de `docs/ART-DIRECTION.md` §3: os três destinos aparecem iluminados, com estrada e bolhas de número; o que vem depois aparece ofuscado; e a câmera acompanha a Bibiana e libera o cenário conforme ela avança.

## Fora do escopo

- Combate e outras telas; contorno e clima finais (TASK-039); outros cenários além da Cidade Abandonada.

## Critérios de aceite

- [ ] **Gerador do tabuleiro** (apresentação, sem tocar o núcleo): do grafo do `MapView` para posições em grade com alturas, estradas com curvas por busca de caminho, praça por nó com props do tipo (fogueira, baú, forca, altar), preenchimento temático, os 3 destinos sempre livres (GDD §17, passos 1 a 6). Determinístico pela semente da Descida.
- [ ] Peças dos kits: chão, muro, escada, ponte, torre, props. Terreno **com altura visível** (degraus, borda de pedra).
- [ ] **Bolhas de número** sobre cada destino: nível do inimigo em vermelho, recompensa em dourado, marca de elite, mutação, baú, fogueira e evento; baú com valor (referência Hero Wars).
- [ ] **Névoa de guerra por célula** (revelado, visível, oculto) em shader: destinos plenos; depois deles, escurecido e sem tipo; o chefe visível de longe e coberto de névoa; o já visitado esmaecido.
- [ ] **Câmera:** ortográfica isométrica; ao escolher um destino a Bibiana caminha (1 a 2 s, pulável) e a câmera desliza junto; ao chegar, a névoa recua em volta do novo nó (0,6 a 1 s). Pré-visualização ao tocar num destino.
- [ ] Toque mínimo de 48 px nos destinos; funciona em retrato 540x960; ligado ao `GameScreen` no lugar do `MapScreen` 2D, que fica como modo de depuração.
- [ ] Print do mapa em três momentos (início, meio, perto do chefe) anexado, com as seis respostas do teste do print.

## Arquivos afetados

- `game/presentation/map3d/` (novo), `game/presentation/map/map_view.gd` (só dados de apresentação), `game/presentation/game_screen.gd`, `tests/unit/`

## Testes esperados

- Contratos: o gerador é determinístico pela semente; os 3 destinos ficam livres; a célula de um destino fica visível e a do tipo do nó seguinte fica oculta; a câmera termina no nó escolhido. A estética é julgada no print.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR. `RULES_VERSION` não muda (só apresentação).
- Núcleo sem nós e sem aleatoriedade global; as cenas só leem eventos e controladores sem nós. A posição 3D dos nós fica na apresentação.
- Todo asset externo registrado em `assets/LICENSES.md`.
- Depende de: TASK-035.

## Verificação

Ainda não executada.

## Revisão cruzada

Pendente.
