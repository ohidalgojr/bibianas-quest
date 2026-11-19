# TASK-037: combate em 3D com fundo derivado do nó

| Campo | Valor |
| --- | --- |
| Status | Em andamento: palco 3D, fundo do nó, animações e composição prontos; faltam linha do tempo em coluna, painel de previsão, moeda no palco, hit-stop e mutações no modelo |
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

- [x] **Fundo do nó:** praça, passagem estreita ou sala do chefe, a partir das mesmas peças do mapa, escurecido, desfocado e com vinheta; clima ativo.
- [x] **Composição em retrato:** inimigo grande e central, Bibiana de costas embaixo à esquerda, luz no chão e sombras; metade de baixo para painéis e menu.
- [ ] **Linha do tempo em coluna** à esquerda com retratos numerados (referência FFT) e **ícone de intenção** sobre a cabeça do inimigo; ícones de status.
- [ ] **Painel de previsão** entre os dois lados (acerto, crítico, dano previsto), no lugar do texto nos botões.
- [ ] **Moeda no palco:** a moeda cresce ao centro, a vinheta fecha, silêncio e tique; Cara e Coroa distintas por forma e símbolo (GDD §7, §19); escolha do lado e Moeda da Sorte como hoje.
- [~] **Número de dano** grande e luminoso sobre o alvo, hit-stop de 60 a 100 ms; animações de atacar, receber dano e morrer dos kits. (feito: número sobre o alvo 3D, animações de atacar, receber dano e morrer e tremor de câmera; falta o hit-stop)
- [~] Menu embaixo na zona do polegar, botões de 48 px ou mais; mutações visíveis no modelo; mini boss e chefe com palco próprio.
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

Suíte em 2026-11-19: 329 testes, 329 passando (`test_combat3d.gd`: palco para todo tipo de nó e inimigo, animações, luta até o fim com palco). Prints (`combat3d_preview.tscn`): `docs/tasks/prints/TASK-037-combate-comum.png`, `-elite.png` e `-chefe.png`.

**Feito:** `Combat3DStage` (palco em 3D com o fundo derivado do tipo do nó: praça, passagem de elite, sala do chefe com cestos de fogo e cripta, muros, luz quente no chão, vinheta), o inimigo grande ao fundo e a Bibiana de costas à frente, animações de atacar, receber dano e morrer, tremor de câmera, números de dano sobre os modelos e a intenção do inimigo e o registro como faixas sobre a cena; `StageKit` compartilhado com o mapa. A tela 2D é a mesma (menus e barras); só o miolo virou 3D.

**Falta (por isso a tarefa segue aberta):** (1) linha do tempo em **coluna com retratos** (hoje são chips de texto no topo); (2) **painel de previsão** entre os dois lados (hoje o texto fica nos botões); (3) **moeda no palco** com vinheta que fecha e silêncio (hoje o medalhão sobe como painel); (4) **hit-stop** de 60 a 100 ms; (5) mutações visíveis no modelo; (6) a Bibiana fica no centro-baixo, não no canto esquerdo; (7) chefe e elite usam substitutos de modelo (ver `assets/LICENSES.md`).

**Teste do print:** 1 cenário com profundidade: sim; 2 composição como Fear & Hunger: em parte (inimigo central, luz no chão, vinheta, faixas de interface; faltam retratos e painel de previsão); 3 não se aplica; 4 kits CC0: sim, sem contorno nem clima (TASK-039); 5 números sobre o mundo: sim; 6 retrato 540x960: sim.

## Revisão cruzada

Pendente.
