# TASK-039: estilo unificado, clima, luz e música

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada) |
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

- [ ] Pós-processamento: contorno, realce e paleta de 24 a 32 cores por cenário (GDD §18), vinheta e leve tilt-shift; interruptor para desligar em aparelhos fracos.
- [ ] Regra do acento: só a mecha da Bibiana, o ouro e o vermelho de perigo saturados; o resto dessaturado. Mecha com os 9 estágios do Poder (GDD §9) no modelo 3D.
- [ ] Clima em partículas à frente do cenário, no mapa e no combate; luz quente oscilante nas fontes de fogo.
- [ ] Música de mapa (drone), de combate (camadas esparsas) e de chefe, silêncio antes do golpe de moeda; som ambiente do cenário 1; licenças registradas em `assets/LICENSES.md`.
- [ ] Medição de desempenho no PC (quadros e triângulos contra as metas do GDD §18) e, ao fim, no celular; resultado registrado na tarefa.
- [ ] Prints antes e depois do estilo, anexados.

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

Ainda não executada.

## Revisão cruzada

Pendente.
