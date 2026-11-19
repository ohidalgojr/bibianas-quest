# TASK-035: kits CC0, registro de licença e prova de câmera isométrica

| Campo | Valor |
| --- | --- |
| Status | Em verificação (código, testes e print prontos; falta o Orlando aprovar o print e a revisão cruzada) |
| Aberta em | 2026-11-19 |
| Fase | 1, apresentação 3D do MVP jogável (ADR-0036) |
| GDD | 17, 18, 20 |
| ADRs | ADR-0036 (e os que a tarefa criar) |

> **Antes de escrever código leia `docs/ART-DIRECTION.md` inteiro.** A tarefa só fecha com o "teste do print" (seção 8): print do jogo rodando com janela, anexado em `docs/tasks/prints/`, e as seis respostas por escrito. Suíte verde não basta.

## Objetivo

Os kits CC0 do GDD §18 estão no repositório com licença registrada, e uma **cena de prova** mostra um pedaço de terreno em blocos com altura, a Bibiana e um monstro, vistos por câmera ortográfica isométrica em resolução interna baixa. Existem também as ferramentas de print (`tools/screenshot.gd` e `tools/screenshot.ps1`) que todas as tarefas visuais seguintes usam.

## Fora do escopo

- Mapa, combate e demais telas (TASK-036 a 038); contorno final, clima e música (TASK-039).

## Critérios de aceite

- [x] **Autorização do Orlando** para baixar, em chat, com nome, fonte e tamanho de cada pacote: Kenney Graveyard Kit, Modular Dungeon Kit e Mini Dungeon (kenney.nl); KayKit Character Pack: Adventurers (Godot Asset Library 2129); Quaternius Ultimate Monsters. Alternativa: o Orlando baixa e coloca em `assets_src/`.
- [x] Pacotes em `assets/` (formato glTF, importáveis pelo Godot), `assets/LICENSES.md` com pacote, autor, link, licença e data, e fontes brutas em `assets_src/`.
- [x] Mapeamento id do jogo para cena de modelo (campo `modelo`, GDD §20) para a Bibiana e os 7 inimigos, com animações de parado, andar, ataque e morte quando o kit as tiver; o que o kit não tiver fica listado como pendência do Blender.
- [x] Cena de prova `game/presentation/stage/proof_scene.tscn`: terreno em blocos de alturas diferentes com escada, luz quente e fria, vinheta, Bibiana e um inimigo, `SubViewport` de 480x270 ampliado em múltiplos inteiros.
- [x] `tools/screenshot.ps1 -Scene <cena> -Out <png>` abre o Godot **com janela**, espera N quadros e salva o PNG (o headless não desenha).
- [ ] Print da cena de prova anexado e o teste do print respondido (feito, ver Verificação). **Falta a aprovação do Orlando antes de abrir a TASK-036.**

## Arquivos afetados

- `assets/`, `assets/LICENSES.md`, `assets_src/`, `game/presentation/stage/`, `game/data/` (campo `modelo`), `tools/screenshot.*`, `docs/tasks/prints/`

## Testes esperados

- Contratos, não estética: cada id de inimigo tem modelo que carrega; a cena de prova carrega sem erro; `LICENSES.md` cita todo pacote de `assets/`. A estética é julgada no print.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR. `RULES_VERSION` não muda (só apresentação).
- Núcleo sem nós e sem aleatoriedade global; as cenas só leem eventos e controladores sem nós.
- Todo asset externo registrado em `assets/LICENSES.md`.
- Depende de: ADR-0036 e da autorização de download do Orlando.

## Verificação

Suíte em 2026-11-19: 319 testes, 319 passando (inclui `test_stage_assets.gd`). Download autorizado pelo Orlando em chat ("pode baixar o que for preciso"); fontes: espelhos do OpenGameArt para os três kits Kenney e o Animated Monster Pack do Quaternius, e o repositório do KayKit no GitHub. Print: `docs/tasks/prints/TASK-035-prova.png`, gerado por `tools/screenshot.ps1`.

**Teste do print (ART-DIRECTION §8):**
1. Cenário com profundidade: **sim**, blocos em 3 alturas, luz fria e quente, sombra, vinheta.
2. Composição como a referência: **em parte**; é um diorama isométrico de blocos como FFT, mas a prova não tem estrada, escada nem muros.
3. Mapa com os três caminhos e o resto ofuscado: **não se aplica**, é a TASK-036.
4. Modelos 3D de kit CC0 e clima: **kits sim** (Kenney e KayKit); **sem clima e sem contorno** (TASK-039).
5. Números e ícones sobre o mundo: **não se aplica** (TASK-036 e 037).
6. Retrato 540x960: **sim**.

**Limites e pendências:** (a) o Ultimate Monsters do Quaternius está numa pasta do Google Drive e não foi baixado; o pacote que veio tem 4 monstros, então rato, cão de peste e Carrasco usam substituto (`placeholder` no `ModelRegistry`); (b) o servidor MCP do Blender não conectou nesta sessão, apesar do addon ligado (porta 9876), então não houve modelagem no Blender; (c) o campo `modelo` ficou no `ModelRegistry` (apresentação) e não em `game/data/*.json`, para não mexer em validador nem em `RULES_VERSION`.

## Revisão cruzada

Pendente.
