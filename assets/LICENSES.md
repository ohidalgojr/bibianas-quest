# Licenças dos assets de terceiros

Todo asset externo do jogo entra aqui **antes** de ser usado (GDD §18, ADR-0036). Os pacotes abaixo são CC0 (domínio público); o texto de cada licença acompanha os arquivos na pasta do pacote.

| Pacote | Autor | Fonte | Licença | Baixado em | Pasta | O que usamos |
| --- | --- | --- | --- | --- | --- | --- |
| Graveyard Kit 5.0 | Kenney | https://kenney.nl/assets/graveyard-kit (arquivo do espelho https://opengameart.org/content/graveyard-kit) | CC0 1.0 | 2026-11-19 | `assets/kenney/graveyard/` | Cenário do cenário 1: estrada, cercas, muros, lampiões, criptas, cruzes, fogueira em cesto, zumbi, esqueleto, fantasma, vigia |
| Modular Dungeon Kit 2.0 | Kenney | https://kenney.nl/assets/modular-dungeon-kit (espelho https://opengameart.org/content/modular-dungeon-kit) | CC0 1.0 | 2026-11-19 | `assets/kenney/modular_dungeon/` | Corredores, salas, escadas, portões e peças de piso para passagens e sala do chefe |
| Mini Dungeon 2.0 | Kenney | https://kenney.nl/assets/mini-dungeon (espelho https://opengameart.org/content/mini-dungeon) | CC0 1.0 | 2026-11-19 | `assets/kenney/mini_dungeon/` | Piso, escadas, muros, baú, moeda, poção, barril, personagem humano |
| KayKit Character Pack: Adventurers 1.0 | Kay Lousberg | https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Adventures-1.0 (Godot Asset Library 2129) | CC0 1.0 (conforme o autor; conferir `LICENSE.txt` ao atualizar) | 2026-11-19 | `assets/kaykit/adventurers/` | Bibiana (Knight, Barbarian) e humanoides |
| Ambient music loops (4 faixas) | congusbongus, CleytonKauffman, yd | https://opengameart.org/content/ancient-caverns-horror-ambient-loop e outras 3 páginas listadas em `License.txt` | CC0 1.0 | 2026-11-19 | `assets/opengameart/ambient_music/` | Música de mapa, combate, chefe e fogueira (TASK-039) |
| Animated Monster Pack | Quaternius | https://opengameart.org/content/lowpoly-animated-monsters | CC0 1.0 | 2026-11-19 | `assets/quaternius/monsters/` | Morcego (corvo), esqueleto, lodo; só 4 monstros (o pacote Ultimate Monsters de 50 modelos está numa pasta do Google Drive e não foi baixado) |

## Pendências de modelo

O Ultimate Monsters não veio. Estes inimigos ainda não têm modelo próprio e usam um substituto até a TASK-039 ou o Blender:

- `giant_rat` (rato grande), `plague_hound` (cão de peste), `rotten_executioner` (Carrasco Apodrecido) e as mutações (Inchado, Voraz, Fantasma, Espinhoso, por cor e escala).
- Mecha de cabelo da Bibiana por estágio de Poder (GDD §9): a fazer no Blender.

## Regra

Pacote novo: baixar, conferir o texto de licença do próprio pacote, adicionar uma linha aqui e só então usar no jogo. Teste `test_assets_licenses.gd` confere que toda pasta de `assets/` tem linha neste arquivo.

## Fontes (SIL Open Font License 1.1)

| Fonte | Autor | Fonte do arquivo | Licença | Baixado em | Pasta | Uso |
| --- | --- | --- | --- | --- | --- | --- |
| Cinzel | The Cinzel Project Authors (NDISCOVER) | https://github.com/google/fonts/tree/main/ofl/cinzel | OFL 1.1 | 2026-11-19 | `assets/google_fonts/cinzel/` | Títulos, botões e números do jogo |
| Alegreya | Juan Pablo del Peral (Huerta Tipográfica) | https://github.com/google/fonts/tree/main/ofl/alegreya | OFL 1.1 | 2026-11-19 | `assets/google_fonts/alegreya/` | Texto corrido |

## Ícones (CC0)

| Pacote | Autor | Fonte | Licença | Baixado em | Pasta | Uso |
| --- | --- | --- | --- | --- | --- | --- |
| 496 RPG Icons | gnola14 | https://opengameart.org/content/496-pixel-art-icons-for-medievalfantasy-rpg | CC0 1.0 | 2026-11-19 | `assets/gnola14/rpg_icons/` | Ícones de itens, skills, status, doenças e tipos de nó (TASK-043) |

## Modelos do próprio projeto (CC0)

| Pacote | Autor | Fonte | Licença | Criado em | Pasta | Uso |
| --- | --- | --- | --- | --- | --- | --- |
| Inimigos do cenário 1 | Projeto Bibiana's Quest (script de Blender) | `tools/blender/make_enemies.py` | CC0 1.0 | 2026-11-19 | `assets/bibiana/enemies/` | Rato Grande, Cão de Peste, Corvo Carniceiro e Carrasco Apodrecido (TASK-044) |
| Peças góticas de cenário | Projeto Bibiana's Quest (script de Blender) | `tools/blender/make_scenery.py` | CC0 1.0 | 2026-11-22 | `assets/bibiana/scenery/` | Arco ogival, arcada, contraforte e agulha (TASK-063) |
| Sprites 2D dos inimigos | Projeto Bibiana's Quest (pranchas geradas por IA pelo Orlando, recorte por script) | `tools/make_sprite.py` | Material próprio do projeto | 2026-11-23 | `assets/bibiana/sprites/` | Bibiana, 17 inimigos, 3 do estudo, 2 NPCs e 4 props recortados das pranchas HD-2D (TASK-065, TASK-066) |
| Arenas pintadas 9:16 | Projeto Bibiana's Quest (pranchas geradas por IA pelo Orlando, redimensionadas) | `docs/design/refs/arenas/` | Material próprio do projeto | 2026-11-24 | `assets/bibiana/arenas/` | Beco e praça da Cidade Abandonada como fundo do combate (TASK-066) |
| Textura de calçamento | Projeto Bibiana's Quest (prancha gerada por IA pelo Orlando, recorte e espelhamento por script) | `docs/design/refs/arenas/road-cobble-tile.jpg` | Material próprio do projeto | 2026-11-26 | `assets/bibiana/textures/` | Pedra do tabuleiro isométrico do mapa (TASK-070) |
| Efeitos de combate (FX) | Projeto Bibiana's Quest (folhas geradas por IA pelo Orlando, chave de cor por `tools/make_fx.py`) | `docs/design/refs/fx/` | Material próprio do projeto | 2026-11-26 | `assets/bibiana/fx/` | Corte, bloqueio, crítico, veneno e chama (TASK-071, TASK-075) |
| Ícones pintados | Projeto Bibiana's Quest (folhas geradas por IA pelo Orlando, fatiadas por `tools/make_icons.py`) | `docs/design/refs/ui/ico-*.jpg` | Material próprio do projeto | 2026-11-27 | `assets/bibiana/icons/` | 102 ícones de ações, skills, status, equipamento, relíquias e nós (TASK-072) |
| Kit de UI | Projeto Bibiana's Quest (peças geradas por IA pelo Orlando, fundo removido por script) | `docs/design/refs/ui/ui-*.jpg` | Material próprio do projeto | 2026-11-27 | `assets/bibiana/ui/` | Painel de pedra, molduras de slot, fita, divisor, moldura de ilustração, discos de nó (TASK-072) |
| Ilustrações de evento | Projeto Bibiana's Quest (pranchas geradas por IA pelo Orlando, redimensionadas) | `docs/design/refs/events/` | Material próprio do projeto | 2026-11-27 | `assets/bibiana/events/` | Os 6 eventos temáticos da Cidade Abandonada (TASK-072) |

| Game Icons (só audioOn e audioOff) | Kenney | https://opengameart.org/content/game-icons | CC0 1.0 | 2026-11-19 | `assets/kenney/game_icons/` | Botão de som (TASK-050) |
