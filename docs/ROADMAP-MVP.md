# Roteiro até o MVP jogável

| Campo | Valor |
| --- | --- |
| Status | Aprovado pelo Orlando em 2026-11-16 ("faça as mudanças de task que achar necessário"), incluindo as mudanças da seção "O que muda na ordem combinada" |
| Escrito em | 2026-11-16 |
| GDD | 4, 5, 6, 7, 8, 9, 12, 15, 20, 21, 22 (Fase 1, protótipo cinza) e 23 |

Este arquivo é o plano, não uma tarefa. Cada linha vira um arquivo em `docs/tasks/` só quando chegar a vez dela (uma tarefa por vez, um commit por tarefa).

## O que é o "MVP jogável"

É a Fase 1 do GDD (§22), o **protótipo cinza**: um jogador abre o jogo no PC (e no celular por link ou cabo), escolhe o Guerreiro, atravessa o cenário 1 (5 camadas e o chefe) em retrato, luta com cara ou coroa, passa por fogueira e loja, morre ou vence, e recomeça com outra semente. Tudo com formas e barras simples, sem arte, sem som.

Portão de saída (GDD §22 e §23): o jogador quer "só mais uma" depois de 3 Descidas, e nenhuma morte acontece sem aviso. Se o portão falhar, ajusta-se o design antes de investir em arte.

### Dentro do MVP

- Classe: **Guerreiro** (a classe de entrada, GDD §8, e a que tem mais segurança para calibrar a moeda). As outras três entram na Fase 2.
- Cenário 1, 5 camadas, largura 4, chefe no fim; tipos de nó: batalha, elite, baú, fogueira, chefe. **Eventos e mini boss ficam para depois** (o GDD permite 0 mini boss por cenário).
- Combate 1 contra 1 com Carga por VEL, intenção avisada, moeda completa (Maré de azar, Defender reduz a penalidade, Veterano).
- Poder, ouro, loja pós-batalha enxuta, fogueira (Descansar e as duas skills do Guerreiro), morte e recomeço, auto-save por nó.
- Telas 2D de formas simples (Control), mais ferramentas de depuração.

### Fora do MVP

Anúncios e trapaça por anúncio (a Moeda Viciada fica como item de depuração), doenças, mutações, roaming boss, Forja, Santuário e Ecos além de um contador, Pavor, clima, 3D, shader da mecha, áudio, iOS, traduções, tudo que o GDD §22 já lista como fora do MVP.

## Ordem das tarefas

| # | Tarefa | Entrega | Depende de | Marco |
| --- | --- | --- | --- | --- |
| 0 | TASK-001 (fechar) | Suíte verde, commit fechado, F5 em retrato | Orlando | Fundação |
| 1 | TASK-002 | RNG determinístico em 4 fluxos | 001 | Núcleo |
| 2 | TASK-003 | Grafo do mapa, tipos de nó e invariantes, teste de propriedade em milhares de sementes | 002 | Núcleo |
| 3 | TASK-004 | Motor de combate 1 contra 1 e moeda (Guerreiro) | 002 | Núcleo |
| 4 | TASK-005 | Dados do cenário 1: classe, inimigos, chefe, itens, com validação | 004 | Núcleo |
| 5 | TASK-006 | **Combate jogável** (primeira tela, primeiro teste de sensação da moeda) | 004, 005 | **Jogável 1** |
| 6 | TASK-007 | Estado da Descida: avanço por nós, Poder, ouro, loja, fogueira, vitória e morte | 003, 005 | Núcleo |
| 7 | TASK-008 | Simulador headless, bot de vencibilidade ligado ao mapa, primeiro relatório | 007 | Calibração |
| 8 | TASK-009 | Mapa jogável (3 caminhos, névoa) | 006, 007 | Jogável 2 |
| 9 | TASK-010 | Recompensa, loja e fogueira em tela | 009 | Jogável 3 |
| 10 | TASK-011 | Fluxo completo: menu, Descida, chefe, morte, recomeço com nova semente | 010 | **MVP rodando** |
| 11 | TASK-012 | Auto-save por nó e retomar | 011 | Robustez |
| 12 | TASK-013 | Atalhos de depuração e telemetria local | 011 | Playtest |
| 13 | TASK-014 | Exportação Web e Android, teste de 20 minutos no celular | 011, 013 | **Portão da Fase 1** |

Depois do portão: calibrar com o simulador e com os playtests (alavancas do GDD §23) e abrir a Fase 2 (vertical slice) com um novo roteiro.

### O que muda na ordem combinada (precisa de aprovação)

A ordem do pedido original era: 002 RNG, 003 mapa com bot, 004 combate, 005 simulador. Para chegar mais cedo a algo que se joga, proponho três ajustes. O Orlando autorizou as mudanças em 2026-11-16; elas valem a partir da TASK-002 (nenhum código foi alterado por isso).

1. **O bot de vencibilidade sai da TASK-003 e vai para a TASK-008.** O bot precisa lutar, e o combate só existe na TASK-004. A TASK-003 entrega o grafo, os tipos e as invariantes (3 opções por camada, fogueira na penúltima, nunca duas fogueiras ligadas, nunca três elites na camada, sempre um caminho até o chefe) e uma interface `RouteEvaluator` que a TASK-008 preenche. A garantia de vencibilidade do GDD §5 continua obrigatória; só passa a ser verificada quando o combate existe. Registrar em ADR na TASK-003.
2. **O simulador (antigo 005) vira TASK-008**, depois do estado da Descida, porque simular uma Descida inteira exige `RunState`. Um simulador só de combate já cabe como subproduto da TASK-004 (teste de fórmula com milhares de lutas).
3. **Entram TASK-005 (dados) e TASK-006 (combate jogável) antes do resto.** Jogar uma luta cedo é o teste mais barato de que a moeda é divertida, que é a aposta central do jogo (GDD §1 e §7).

## Detalhe das tarefas

### TASK-002: RNG determinístico em 4 fluxos (GDD §20)

- Objetivo: `RngStreams` com os fluxos `map`, `combat`, `loot` e `coin`, cada um com semente derivada da semente da Descida; mesma semente e mesmas chamadas dão a mesma sequência.
- Aceite: reprodução byte a byte entre duas instâncias; fluxos independentes (consumir `combat` não muda `coin`); estado serializável (para o save da TASK-012); sem usar função global de sorteio.
- Testes: reprodução por semente, independência dos fluxos, salvar e restaurar o estado, distribuição básica (média e limites) em 10 mil sorteios.
- ADR: embrulhar `RandomNumberGenerator` ou gerador próprio (por exemplo PCG32). Recomendação: gerador próprio pequeno, porque o resultado não depende da versão do Godot e o estado é um inteiro fácil de salvar.
- **Atenção ao teste de pureza:** a regex `\.(shuffle|pick_random)\s*\(` barra qualquer método com esses nomes, inclusive os do nosso RNG. Nomear os métodos do fluxo `draw_*`, `shuffled_copy()` etc., ou refinar a regex na mesma tarefa.

### TASK-003: grafo do mapa (GDD §5, §17)

- Objetivo: gerar o grafo do cenário a partir de semente, número de camadas e largura, com janela deslizante de 3 ligações, e atribuir tipos de nó com as frequências do GDD (batalha 55%, elite 10% fora dos 30% iniciais, baú 8% sem dois seguidos, fogueira na penúltima camada, chefe no fim).
- Aceite: para 5.000 sementes por configuração (5 camadas/largura 4 e 9 camadas/largura 5) valem todas as invariantes da seção "O que muda" acima; o mesmo input dá o mesmo grafo; a interface `RouteEvaluator` existe com um avaliador falso para teste.
- Testes: propriedade em milhares de sementes (o GDD pede), determinismo, frequências dentro de uma tolerância.
- ADR: forma do avaliador de rota e adiamento do bot.

### TASK-004: combate e moeda (GDD §6, §7, §8, §9)

- Objetivo: `Combat` puro: Carga por VEL (100 para agir), ações Atacar, Habilidade (Golpe de Escudo), Defender, Item (poção) e Fugir; dano pela fórmula do §6; acerto, crítico, intenção do inimigo avisada um turno antes; moeda com chance `clamp(50 + SORTE + mods, 15, 85)`, Maré de azar (+10 após 3 derrotas) e penalidades do §7; Veterano do Guerreiro.
- Aceite: cada fórmula tem teste citando a seção; "nunca morte imediata acima de 60% de vida" e "nunca dois golpes de moeda seguidos" são propriedades testadas em milhares de combates; o núcleo emite eventos (`DamageDealt`, `CoinFlipped`, `TurnStarted`...) e não chama cena.
- ADR: modelo de eventos do núcleo; arredondamento do dano (inteiro, regra de piso).
- `CoreVersion.RULES_VERSION` passa a 1.

### TASK-005: dados do cenário 1 (GDD §8, §10, §13, §15)

- Objetivo: arquivos de dados (JSON, com validação) para o Guerreiro, 4 a 5 inimigos comuns, 1 elite, 1 chefe de 2 fases, e itens básicos (poção, 1 arma e 1 armadura de reposição); carregador e validador que falham alto em dado inválido.
- Aceite: os dados carregam; um validador rejeita campo faltando, id repetido e referência quebrada; números iniciais copiados do GDD.
- ADR: JSON versus `.tres` (recomendação: JSON validado, simples para agentes e para diff).

### TASK-006: combate jogável (GDD §6, §7, §19)

- Objetivo: cena de combate em retrato, **em 2D com formas simples**, lutando contra um inimigo escolhido por atalho: barras de HP e MP, linha do tempo dos próximos turnos, ícone de intenção, menu de ações na zona do polegar, tooltip com a chance real da moeda e animação de 1,2 s (placeholder).
- Aceite: dá para ganhar e perder uma luta com mouse como toque; o ícone de golpe de moeda aparece um turno antes; a cena só lê eventos do núcleo.
- ADR: UI 2D no protótipo cinza (o GDD fala em cena 3D, que fica para a Fase 2; as regras estão no núcleo, então a troca não mexe nelas).
- Teste de sensação humano: a moeda dá tensão? Anotar no diário.

### TASK-007: estado da Descida (GDD §4, §9, §12, §15)

- Objetivo: `RunState` com semente, cenário, Poder (`0,15 × nível × m_tipo`), ouro (`6 × nível × U(0,8; 1,2) × m_tipo`), inventário mínimo, nó atual; transições escolher nó, resolver batalha, baú, fogueira (6 Brasas, Descansar 3, skills do Guerreiro), loja; fim por chefe ou morte.
- Aceite: um bot dirigido por regras completa uma Descida por semente, de forma determinística; a economia reproduz as fórmulas do §15.
- Testes: fórmulas de Poder e ouro, transições inválidas rejeitadas, Descida reproduzível por semente.

### TASK-008: simulador e vencibilidade (GDD §5, §23)

- Objetivo: simulador headless (milhares de Descidas com bot "mediano" e "cuidadoso"), bot de vencibilidade ligado ao `RouteEvaluator` do mapa (200 simulações no caminho mais seguro, até 5 tentativas de suavizar, descartar o mapa se falhar) e o primeiro relatório em `reports/`.
- Aceite: teste de propriedade "nenhum mapa gerado sem caminho vencível" em milhares de sementes; relatório com vitória do cenário 1, duração média de combate, mortes por moeda.
- Meta de partida: vitória do cenário 1 entre 55% e 65%; combate comum com 6 a 10 turnos (GDD §23). Fora da meta, ajustar as alavancas do §23 **com ADR**, não no código solto.

### TASK-009 a TASK-011: do mapa ao MVP rodando

- **009 Mapa jogável:** três caminhos visíveis com tipo, névoa nas camadas seguintes, toque para escolher; lê o grafo do núcleo.
- **010 Recompensa, loja e fogueira em tela:** tela de recompensa com equipar rápido, loja de 5 itens com atualização por 15 moedas, fogueira com Brasas.
- **011 Fluxo completo:** menu, escolha da classe (só Guerreiro), Descida inteira, chefe, tela de morte, recomeço com nova semente e contador de Ecos.
- Aceite do conjunto: uma Descida de ponta a ponta com mouse em retrato, sem erro no console, 3 Descidas seguidas sem reiniciar o jogo.

### TASK-012 a TASK-014: robustez, playtest e portão

- **012 Auto-save:** salva semente, escolhas e estado a cada nó; retomar após fechar; arquivo de meta separado com versão de formato (GDD §20).
- **013 Depuração e telemetria:** atalhos só em build de desenvolvimento (escolher semente, pular nó, dar ouro, forçar lado da moeda, matar inimigo) e log local de eventos por nó, combate, moeda e morte.
- **014 Exportação:** preset Web para o link de playtest, preset Android de um clique, sessão de 20 minutos no celular, lista de problemas. Desligar `emulate_touch_from_mouse` antes de exportar para o celular (GDD §20).

## Riscos para a velocidade

| Risco | Efeito | Resposta |
| --- | --- | --- |
| A suíte nunca rodou no Godot 4.7 | Erros de GDScript aparecem todos de uma vez | Fechar a TASK-001 primeiro (próxima seção). |
| Moeda sem graça no protótipo | Todo o resto perde sentido | TASK-006 cedo; ajustar o design antes de TASK-009 em diante. |
| Números do GDD fora da meta | Descida impossível ou trivial | TASK-008 antes da tela final; calibrar por simulação, com ADR. |
| Escopo crescendo (eventos, mini boss) | Atrasa o MVP | Lista "Fora do MVP" acima; só entra com ADR. |
| Revisão cruzada atrasa cada tarefa | Gargalo humano | Revisar o diff de cada tarefa por lote pequeno; o Gemini lê `git show HEAD`. |

## Situação em 2026-11-18 e caminho até o portão

O roteiro acima (TASK-001 a 014) foi cumprido, com ajustes: o cenário 1 hoje tem 6 camadas (ADR-0027), e entraram TASK-015 a 025 pelo feedback do primeiro playtest (ADR-0025). Estado: TASK-001 a 013 e 015 a 025 concluídas no código (suíte 285/285, `RULES_VERSION` = 13); TASK-014 em verificação. **Falta o que só pessoa e outro modelo fazem.** O estado detalhado fica no `docs/HANDOFF.md`.

| Ordem | Tarefa | O que é | Quem | Entra no MVP? |
| --- | --- | --- | --- | --- |
| 1 | TASK-014 | Exportar Web e Android; sessão de 20 minutos no celular | Orlando | **Sim** (portão) |
| 2 | TASK-029 | Revisão cruzada das TASK-001 a 025 por outro modelo | Gemini ou outro, não o Claude | **Sim** (GDD §21, etapa 4) |
| 3 | TASK-026 | Primeira Descida chamativa (F-019) | agente | **Sim**, desejável: primeira impressão do portão |
| 4 | TASK-030 | Calibrar números com o `telemetry.log` do Orlando | agente, depois do envio | **Sim** |
| 5 | TASK-031 | Fechar o portão da Fase 1 e abrir o roteiro da Fase 2 | Orlando e agente | **Sim** (fechamento) |
| fora | TASK-027 | Sorte, emboscadas e inimigos mutados | agente | Não: entra se o playtest pedir mais variedade |
| fora | TASK-028 | Eventos de mapa e mini boss | agente | Não: o GDD permite 0 mini boss e o escopo original deixa eventos para depois |

Ordem sugerida: o Orlando joga uma Descida e envia feedback e log enquanto a TASK-029 corre em paralelo (só leitura e achados); TASK-026 em seguida; TASK-030 com os dados; TASK-014 quando templates e SDK estiverem no PC dele; TASK-031 fecha. TASK-027 e 028 só abrem depois do portão, a menos que o feedback as torne bloqueantes.

## Próximo passo único

O Orlando joga uma Descida inteira (F5 na pasta raiz) e envia o `telemetry.log` e o feedback. Em paralelo, um modelo que não seja o Claude executa a TASK-029.
