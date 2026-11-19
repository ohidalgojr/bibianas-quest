# ADR-0037: planta do tabuleiro 3D, névoa por lençol e câmera que acompanha

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-19 |
| Tarefa | TASK-036 |
| GDD | 5, 17 |

## Contexto

O ADR-0036 manda um tabuleiro isométrico 3D com visão parcial (`docs/ART-DIRECTION.md` §3). Faltava decidir como o grafo do mapa vira terreno, como a névoa é desenhada e como a câmera acompanha, sem tocar no núcleo.

## Decisão

1. **Planta em grade (`Map3DLayout`, `RefCounted`).** Cada camada ocupa uma linha de praças (3x3 células) a 5 células da seguinte, as colunas ficam a 4 células. O terreno sobe um bloco a cada 2 camadas, então a Descida sobe pelo cenário e o chefe fica no ponto mais alto. Estradas ligam as praças em passos de célula (diagonal quando precisa) e viram degrau onde a altura muda. O enfeite (props do cenário 1) sai de um hash das coordenadas e da semente da Descida, nunca de sorteio global, e **nunca cai a menos de 2 células de uma praça ou estrada**: os destinos ficam livres.
2. **Terreno em `MultiMesh`.** Blocos, lajes de praça e de estrada saem de uma `MultiMesh` por tipo (uma chamada de desenho cada), com a malha extraída do glTF do kit. Props e inimigos são instâncias comuns.
3. **Névoa como lençol.** Uma `MultiMesh` de quadrados escuros e translúcidos (um por célula, sobre o terreno) com alfa por instância: limpo nos destinos e atrás deles, 0,72 a 0,94 nas camadas à frente (cresce com a distância), 0,55 no chefe (aparece de longe) e 0,5 nas camadas já passadas. O alfa se move para a meta em `_process`, o que dá a animação em que a névoa recua. Ao voltar ao mapa, a tela começa com a névoa do nó anterior e a câmera no ponto anterior, e anima até o atual.
4. **Câmera.** Ortográfica, rotação isométrica fixa, posição móvel. Mira o ponto entre a Bibiana e o centro dos três destinos. Ao tocar num destino, a Bibiana caminha célula a célula (0,2 s por célula) e a câmera desliza; só no fim a tela emite `node_chosen`, e a Descida avança.
5. **Toque e bolhas em 2D por cima.** As áreas de toque (120 px) e as bolhas (nível em vermelho, recompensa em dourado, mutado em roxo) são `Control`s posicionados pela projeção da câmera, para ficarem nítidos em resolução cheia enquanto o mundo 3D usa resolução interna baixa.
6. **Mapa 2D continua como depuração.** `GameScreen.use_3d_map` é verdadeiro fora do headless; os testes do fluxo seguem no mapa 2D, e testes próprios cobrem o 3D.

## Alternativas

- **Um `MeshInstance3D` por bloco:** mais simples, mas centenas de nós por mapa.
- **Névoa por shader no chão com mapa de visibilidade:** mais bonita, exige tocar nos materiais dos kits; o lençol deixa isso para a TASK-039.
- **Bolhas como `Label3D`:** ficariam borradas na resolução interna.

## Consequências

- O tamanho da planta (cerca de 19 x 47 células) é fixo por mapa; um mapa de 10 camadas fica maior e precisa de medição de desempenho no celular (TASK-039).
- O lençol de névoa não escurece as faces laterais dos blocos nem do lado de fora do lençol; o contorno e a névoa de verdade ficam para a TASK-039.
- A pré-visualização por toque (puxão de câmera antes de decidir) não foi feita; fica como melhoria.
