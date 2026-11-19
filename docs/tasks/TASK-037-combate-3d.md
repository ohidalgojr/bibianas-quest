# TASK-037: combate em 3D com fundo derivado do nó

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada) |
| Aberta em | 2026-11-19 |
| Fase | 1, apresentação 3D do MVP jogável (ADR-0036) |
| GDD | 6, 7, 17, 19 |
| ADRs | ADR-0036 (e os que a tarefa criar) |

> **Antes de escrever código leia `docs/ART-DIRECTION.md` inteiro.** A tarefa só fecha com o "teste do print" (seção 8): print do jogo rodando com janela, anexado em `docs/tasks/prints/`, e as seis respostas por escrito. Suíte verde não basta.

## Objetivo

A luta passa a acontecer num **palco 3D** derivado do nó do tabuleiro, com composição inspirada levemente em Fear & Hunger, linha do tempo em coluna e painel de previsão no estilo Final Fantasy Tactics (`docs/ART-DIRECTION.md` §4).

## Fora do escopo

- Fogueira, loja e baú (TASK-038); animações finas e clima (TASK-039).

## Critérios de aceite

- [ ] **Fundo do nó:** praça, passagem estreita ou sala do chefe, a partir das mesmas peças do mapa, escurecido, desfocado e com vinheta; clima ativo.
- [ ] **Composição em retrato:** inimigo grande e central, Bibiana de costas embaixo à esquerda, luz no chão e sombras; metade de baixo para painéis e menu.
- [ ] **Linha do tempo em coluna** à esquerda com retratos numerados (referência FFT) e **ícone de intenção** sobre a cabeça do inimigo; ícones de status.
- [ ] **Painel de previsão** entre os dois lados (acerto, crítico, dano previsto), no lugar do texto nos botões.
- [ ] **Moeda no palco:** a moeda cresce ao centro, a vinheta fecha, silêncio e tique; Cara e Coroa distintas por forma e símbolo (GDD §7, §19); escolha do lado e Moeda da Sorte como hoje.
- [ ] **Número de dano** grande e luminoso sobre o alvo, hit-stop de 60 a 100 ms; animações de atacar, receber dano e morrer dos kits.
- [ ] Menu embaixo na zona do polegar, botões de 48 px ou mais; mutações visíveis no modelo; mini boss e chefe com palco próprio.
- [ ] Ligado ao `CombatSession` sem mudar regra; a tela 2D fica como depuração. Prints de uma luta comum, de uma com golpe de moeda e do chefe anexados.

## Arquivos afetados

- `game/presentation/combat3d/` (novo), `game/presentation/combat/combat_session.gd` (só apresentação), `game/presentation/game_screen.gd`, `tests/unit/`

## Testes esperados

- Contratos: a luta de teste roda do início ao fim pela camada 3D sem erro; o fundo escolhido segue o tipo do nó; a coluna da linha do tempo mostra os 6 próximos turnos. A estética é julgada no print.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR. `RULES_VERSION` não muda (só apresentação).
- Núcleo sem nós e sem aleatoriedade global; as cenas só leem eventos e controladores sem nós.
- Todo asset externo registrado em `assets/LICENSES.md`.
- Depende de: TASK-035 e TASK-036.

## Verificação

Ainda não executada.

## Revisão cruzada

Pendente.
