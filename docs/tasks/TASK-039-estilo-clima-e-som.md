# TASK-039: estilo unificado, clima, luz e música

| Campo | Valor |
| --- | --- |
| Status | Em verificação (código, testes e prints prontos; falta o Orlando aprovar os prints; desempenho no celular não medido) |
| Aberta em | 2026-11-19 |
| Fase | 1, apresentação 3D do MVP jogável (ADR-0036) |
| GDD | 9, 14, 18, 19 |
| ADRs | ADR-0036 (e os que a tarefa criar) |

> **Antes de escrever código leia `docs/ART-DIRECTION.md` inteiro.** A tarefa só fecha com o "teste do print" (seção 8): print do jogo rodando com janela, anexado em `docs/tasks/prints/`, e as seis respostas por escrito. Suíte verde não basta.

## Objetivo

Os kits de autores diferentes passam a parecer **um jogo só**: contorno e posterização por shader, paleta por cenário, luz dramática, clima em partículas (chuva e névoa do cenário 1), vinheta e profundidade de campo; música e som ambiente com bibliotecas CC0 por cima do `SoundFx`.

## Fora do escopo

- Troca de arte por artista ou IA (decisão do portão da Fase 2); outros biomas.

## Critérios de aceite

- [x] Pós-processamento: contorno, realce e paleta de 24 a 32 cores por cenário (GDD §18), vinheta e leve tilt-shift; interruptor para desligar em aparelhos fracos.
- [~] Regra do acento: só a mecha da Bibiana, o ouro e o vermelho de perigo saturados; o resto dessaturado. Mecha com os 9 estágios do Poder (GDD §9) no modelo 3D.
- [x] Clima em partículas à frente do cenário, no mapa e no combate; luz quente oscilante nas fontes de fogo.
- [~] Música de mapa (drone), de combate (camadas esparsas) e de chefe, silêncio antes do golpe de moeda; som ambiente do cenário 1; licenças registradas em `assets/LICENSES.md`.
- [~] Medição de desempenho no PC (quadros e triângulos contra as metas do GDD §18) e, ao fim, no celular; resultado registrado na tarefa.
- [x] Prints antes e depois do estilo, anexados.

## Arquivos afetados

- `game/presentation/fx/` (novo), shaders em `game/presentation/shaders/`, `game/services/`, `assets/audio/`, `assets/LICENSES.md`

## Testes esperados

- Contratos: os shaders compilam; o interruptor de qualidade desliga o pós-processamento; todo arquivo de áudio tem licença registrada. A estética é julgada no print.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR. `RULES_VERSION` não muda (só apresentação).
- Núcleo sem nós e sem aleatoriedade global.
- Todo asset externo registrado em `assets/LICENSES.md`.
- Depende de: TASK-036 e TASK-037.

## Verificação

Suíte em 2026-11-19: 336 testes, 336 passando (`test_fx_and_music.gd`). Prints: `docs/tasks/prints/TASK-039-mapa-inicio|combate|fogueira|home.png` (depois do estilo) e os `TASK-036|037|038-*.png` (antes).

**Feito:** `PostFx` (posterização em 12 níveis por canal, contorno por diferença de luminância entre vizinhos e desfoque de miniatura no topo e na base, como material do `SubViewportContainer`; desligável por `GfxSettings.post_fx`), `WeatherLayer` (chuva fina em partículas e névoa que deriva por cima do mapa, do combate e do menu), `MusicBox` (quatro faixas CC0 do OpenGameArt em laço com troca suave: mapa, combate, chefe e elite, fogueira e menu; a música some no lance da moeda e volta depois; silêncio na tela de fim), licenças em `assets/LICENSES.md`.

**Desempenho no PC deste agente (Intel Iris Xe, janela 540x960):** 60 fps nas quatro telas. Mapa: 342 chamadas de desenho e **139 mil primitivas**, acima da meta de 60 mil do GDD §18 (o terreno inteiro é desenhado); combate 162 chamadas e 20 mil primitivas; fogueira e menu cerca de 22 mil. **Celular não medido**: o mapa precisa de corte por distância se travar lá.

**Falta:** (1) regra do acento não conferida célula a célula: a mecha da Bibiana ainda não muda de cor no modelo 3D (os 9 estágios do GDD §9 só existem na tela 2D antiga); (2) som ambiente de chuva (só há música e os efeitos sintetizados); (3) a música é uma faixa por situação, sem camadas adaptativas nem tema próprio de chefe além da faixa escolhida; (4) cartões de ação e Santuário 3D (TASK-038); (5) o visual segue com cara de kit Kenney, e o contorno é por cor, não por silhueta (o efeito de "desenho" depende de modelos melhores).

## Revisão cruzada

Pendente.
