# TASK-050: botão de som mudo

| Campo | Valor |
| --- | --- |
| Status | Em verificação (código, testes e print prontos; falta o Orlando ouvir o mudo funcionando) |
| Aberta em | 2026-11-19 |
| Fase | 1, pedido do Orlando |
| GDD | 19 |
| ADRs | ADR-0036 |

## Objetivo

Um botão sempre visível que **liga e desliga todo o som** (música, ambiente e efeitos), com a escolha lembrada entre as sessões.

## Fora do escopo

- Volumes separados, tela de opções completa, vibração.

## Critérios de aceite

- [x] Botão no canto da tela, por cima de qualquer tela e do fade, com ícone de alto-falante ligado e desligado (Kenney, CC0).
- [x] Mudo silencia música, chuva, fogo, trovão e efeitos (bus Master) e para os efeitos novos de `SoundFx`.
- [x] A escolha é salva em `user://settings.cfg` e vale na próxima abertura; testes de contrato.

## Arquivos afetados

- `game/presentation/fx/mute_button.gd`, `game/services/audio_settings.gd`, `game/presentation/game_screen.gd`, `assets/kenney/game_icons/`, `assets/LICENSES.md`

## Testes esperados

- Alternar muda o estado e o bus; salvar e carregar mantém a escolha; `SoundFx.muted` acompanha.

## Regras que esta tarefa não pode quebrar

- Só apresentação; `RULES_VERSION` não muda; asset registrado em `assets/LICENSES.md`.

## Verificação

Suíte em 2026-11-19: 348 testes, 348 passando (`test_mute.gd`: bus Master e `SoundFx` mudos, escolha salva e carregada, ícone muda, botão por cima de tudo). Print: `docs/tasks/prints/TASK-050-botao-som.png`.

**Não verificado:** o silêncio de fato no alto-falante (o teste confere o mudo do bus, não o som saindo); a escolha fica em `user://settings.cfg`.

## Revisão cruzada

Pendente.
