# TASK-035: kits CC0, registro de licença e prova de câmera isométrica

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada) |
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

- [ ] **Autorização do Orlando** para baixar, em chat, com nome, fonte e tamanho de cada pacote: Kenney Graveyard Kit, Modular Dungeon Kit e Mini Dungeon (kenney.nl); KayKit Character Pack: Adventurers (Godot Asset Library 2129); Quaternius Ultimate Monsters. Alternativa: o Orlando baixa e coloca em `assets_src/`.
- [ ] Pacotes em `assets/` (formato glTF, importáveis pelo Godot), `assets/LICENSES.md` com pacote, autor, link, licença e data, e fontes brutas em `assets_src/`.
- [ ] Mapeamento id do jogo para cena de modelo (campo `modelo`, GDD §20) para a Bibiana e os 7 inimigos, com animações de parado, andar, ataque e morte quando o kit as tiver; o que o kit não tiver fica listado como pendência do Blender.
- [ ] Cena de prova `game/presentation/stage/proof_scene.tscn`: terreno em blocos de alturas diferentes com escada, luz quente e fria, vinheta, Bibiana e um inimigo, `SubViewport` de 480x270 ampliado em múltiplos inteiros.
- [ ] `tools/screenshot.ps1 -Scene <cena> -Out <png>` abre o Godot **com janela**, espera N quadros e salva o PNG (o headless não desenha).
- [ ] Print da cena de prova anexado e o teste do print respondido. Aprovado pelo Orlando antes de abrir a TASK-036.

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

Ainda não executada.

## Revisão cruzada

Pendente.
