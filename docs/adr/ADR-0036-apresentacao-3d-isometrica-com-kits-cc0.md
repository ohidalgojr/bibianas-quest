# ADR-0036: apresentação 3D isométrica com kits CC0 (substitui a apresentação 2D)

| Campo | Valor |
| --- | --- |
| Status | Aceito (Orlando, 2026-11-19). Substitui as partes visuais do ADR-0010, do ADR-0013 e do ADR-0035 |
| Data | 2026-11-19 |
| Tarefa | TASK-035 a TASK-040 (plano); documentação sem código |
| GDD | 5, 6, 12, 17, 18, 19, 22 |

## Contexto

O Orlando abriu o jogo depois da TASK-031 e o reprovou: sem assets, mapa visto de cima em grade, combate com silhuetas desenhadas em código. O GDD pede **tabuleiro isométrico 3D com altura de terreno, peças 3D e câmera fixa, no estilo de Final Fantasy Tactics** (§17, §18), e a decisão 14 do §25 já autorizava **kits 3D CC0** (KayKit, Quaternius, Kenney) para o MVP. As referências e a leitura do pedido estão em `docs/ART-DIRECTION.md`.

### Onde as instruções falharam

A análise abaixo é do histórico do repositório. Nenhum ponto é "o agente desobedeceu": cada passo seguiu a instrução imediata e o resultado somado foi o oposto do GDD.

| # | Momento | O que aconteceu | Falha de processo |
| --- | --- | --- | --- |
| 1 | GDD §22 | A Fase 1 foi escrita como "protótipo cinza, formas simples, sem arte", e a Fase 2 como "vertical slice com os kits CC0". O MVP com kits CC0 (decisão 14) ficou na Fase 2 | A palavra **MVP** passou a ter três sentidos: Fase 1 cinza, "MVP (Alpha)" do §17 e "MVP com assets abertos" do §18. Nada dizia qual valia |
| 2 | 2026-11-16, `ROADMAP-MVP.md` | O MVP jogável foi **definido** como o protótipo cinza, "sem arte, sem som", e o Orlando aprovou a ordem das tarefas | Com razão para testar mecânica cedo, mas o texto aprovado passou a ser lido como **o** MVP, não como a Fase 1 dele |
| 3 | TASK-006 e TASK-009 (ADR-0010, ADR-0013) | Combate e mapa em 2D, "provisório", dizendo que "a Fase 2 substitui só esta camada" | **Nenhuma tarefa** foi aberta para essa substituição. O provisório não tinha dono nem data. O backlog dizia só "Fase 2: roteiro do vertical slice, agente propõe" |
| 4 | 2026-11-16 a 11-18, TASK-015 a 028 | O feedback do Orlando era de mecânica e o trabalho foi só de mecânica | Natural, mas não houve ponto de checagem do tipo "a camada visual cumpre o GDD?". O GDD §17 foi citado em ADRs sem ser comparado com a tela |
| 5 | 2026-11-18, diretriz | O Orlando pediu "MVP jogável de verdade, com gráficos e som" e para suspender simulador e testes pesados | A diretriz foi executada **literalmente e na menor forma**: a TASK-031 desenhou gráficos **vetoriais em código** e sons **sintetizados**, porque assim não dependia de arquivos externos. O pedido era usar os assets abertos que o próprio GDD já listava |
| 6 | TASK-031, ADR-0035 | O ADR cita "condizente com o GDD (§3, §5, §6, §7, §9, §17, §18, §19)" e adota **diorama 2D**, "nenhuma textura ou áudio externo" | O ADR **contradiz** o §17 e o §18 e não os cita como divergência. Nenhum ADR anterior foi marcado como substituído. O GDD não foi alterado, então o desvio passou despercebido |
| 7 | TASK-029, revisão cruzada | A revisão cobriu TASK-001 a 025, e conferiu regra, pureza e determinismo | Não existia critério de **fidelidade visual ao GDD** em `REVIEW-CHECKLIST.md`. A TASK-031 nasceu depois da revisão e não teve outra |
| 8 | Definição de pronto (`CLAUDE.md`) | Testes verdes, ADR, HANDOFF, commit | **Nada exige olhar o jogo.** Os testes de visual conferem que o código desenha, não que o resultado parece o jogo. 315 testes passando e uma tela ridícula são compatíveis |
| 9 | Ambiente do Argon | O trabalho visual foi feito sem janela de jogo e sem Blender (conexão do MCP expirou) | Sem print, o agente não viu o resultado. Ninguém o obrigou a ver |

**Causa raiz:** o requisito visual existia só como prosa no GDD, sem **critério de aceite verificável** em nenhuma tarefa, e a definição de pronto media só o que a suíte mede. Quando a diretriz mudou de "testar mecânica" para "ter cara de jogo", nenhum documento mudou junto (GDD, roadmap, CLAUDE.md), então o agente seguiu os documentos antigos (cinza, provisório, sem arquivos externos).

## Decisão

1. **A apresentação do jogo é 3D isométrica**, como o GDD §17 e §18 descrevem: `Node3D`, câmera ortográfica em ângulo fixo e posição móvel, terreno em blocos com altura, peças e personagens de **kits CC0** (Kenney para cenário, KayKit para a Bibiana e humanoides, Quaternius para monstros), com Blender só para o que faltar.
2. **O mapa é um tabuleiro maior que a tela, com visão parcial.** Os três destinos aparecem com estrada e bolhas de número (referência Hero Wars), o resto aparece ofuscado, e **a câmera acompanha a Bibiana e libera o cenário** conforme ela avança. Detalhes em `docs/ART-DIRECTION.md` §3.
3. **O combate** usa um **fundo derivado do nó** (rua, passagem, sala do chefe), composição inspirada levemente em Fear & Hunger, linha do tempo em coluna e painel de previsão no estilo Final Fantasy Tactics. **A fogueira** segue a referência Darkest Dungeon. `docs/ART-DIRECTION.md` §4 e §5.
4. **As telas 2D atuais (ADR-0010, 0013, 0015, 0035) não são descartadas já:** viram o **modo de depuração e de teste** (`GameScreen`) até a camada 3D cobrir o fluxo inteiro. **Elas deixam de ser tratadas como "o MVP com gráficos".** O ADR-0035 fica **Substituído** nas partes de tabuleiro 2D e de silhueta vetorial; `SoundFx` e a paleta (`VisualTheme`) **continuam**.
5. **O núcleo não muda.** `RULES_VERSION` continua 17. A camada 3D só lê eventos e controladores sem nós (`MapView`, `CombatSession`, `RunPanels`).
6. **Definição de pronto visual** (novo item no `CLAUDE.md` e no `REVIEW-CHECKLIST.md`): toda tarefa de tela fecha com **print do jogo rodando com janela, anexado à tarefa**, e as seis respostas do "teste do print" (`docs/ART-DIRECTION.md` §8). A suíte verde **não basta**.
7. **"MVP" passa a ter um sentido só** neste repositório: **MVP jogável = Fase 1 do GDD (mecânica validada) com a apresentação 3D de kits CC0**, isto é, o que o Orlando consegue jogar e ver com cara de jogo. O que o GDD chama de "MVP (Alpha)" no §17 é a **Fase 3**; passa a ser escrito assim.
8. **Plano de tarefas** (arquivos em `docs/tasks/`, uma por vez): TASK-035 (assets e prova de câmera), TASK-036 (tabuleiro 3D com névoa e câmera que acompanha), TASK-037 (combate em 3D), TASK-038 (fogueira, loja, baú, recompensa, menu), TASK-039 (shader, clima, luz, música) e TASK-040 (fechamento visual). As antigas TASK-032 e TASK-033 passam a depender da TASK-040.

## Alternativas

- **Manter o 2D vetorial e embelezar:** é o que a TASK-031 fez. Reprovado pelo Orlando e contrário ao §17.
- **HD-2D com sprites** (alternativa B do §18): a decisão 13 escolheu o 3D pixelizado; sprites consistentes e animados são o ponto fraco da geração por IA e dos kits abertos.
- **Esperar o artista e a Fase 2 para qualquer arte:** deixaria o Orlando sem ver o jogo. Os kits CC0 existem para evitar isso.
- **Gerar arte com IA já:** o GDD reserva a troca de arte para depois do portão da Fase 2.

## Consequências

- **Trabalho novo e grande:** seis tarefas visuais antes do portão. O núcleo e os testes ficam como estão.
- **Dependências que só o Orlando resolve:** autorizar os downloads dos kits (nome, fonte e tamanho listados na TASK-035), e manter o addon do Blender conectado se quisermos o Blender.
- **Risco de estilo:** kits de autores diferentes (Kenney, KayKit, Quaternius) não combinam sozinhos. A TASK-039 unifica com paleta, luz e contorno; até lá a prova é de composição, não de acabamento.
- **Risco de desempenho no celular:** medir no PC e, ao fim de cada tarefa, no aparelho (GDD §20).
- **A suíte de testes cresce pouco:** testes de visual passam a conferir **contratos** (existe a cena, o modelo carrega, a névoa revela a célula), e o julgamento estético fica no print.

## Pontos que precisam do Orlando

1. Autorizar os downloads (TASK-035) e dizer se prefere baixar os pacotes ele mesmo e colocar em `assets_src/`.
2. Conectar o addon do Blender quando uma tarefa pedir (aba BlenderMCP, tecla `N`).
3. Aprovar cada tarefa **olhando o print e o jogo**, não só o relatório.
