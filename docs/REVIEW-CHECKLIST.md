# Checklist de revisão cruzada (GDD §21, etapa 4)

Use esta lista na revisão de qualquer tarefa. O revisor é **outro modelo** que o autor. Marque cada item no arquivo da tarefa, na seção "Revisão cruzada".

## Regras do projeto (CLAUDE.md)

- [ ] Havia tarefa aberta em `docs/tasks/` antes do código, com objetivo, critérios de aceite, arquivos e testes?
- [ ] Um commit por tarefa, com mensagem `TASK-NNN: resumo (ADR-XXXX)`?
- [ ] Mudança de fórmula ou regra do GDD veio com ADR, GDD atualizado no mesmo commit e `CoreVersion.RULES_VERSION` incrementado?
- [ ] O núcleo (`game/core/`) continua sem `Node`, `Time`, `OS` e sem `randi`, `randf`, `shuffle`, `pick_random`? Todo sorteio passa pelos quatro fluxos (mapa, combate, loot, moeda)?
- [ ] O núcleo fala com a apresentação só por eventos (`CombatEvent`, `RunEvent`); a apresentação só chama ações públicas?
- [ ] Regra nova do núcleo tem teste; fórmula do GDD tem teste de fórmula que cita a seção?
- [ ] `docs/HANDOFF.md` foi atualizado (feito, onde está, falta, decisões)?

## Qualidade do código

- [ ] Tipagem estática em tudo (variáveis, parâmetros, retornos, laços).
- [ ] Identificadores em inglês; comentários, documentação e textos de teste em português.
- [ ] Constantes de regra com a seção do GDD no comentário; sem número mágico de balanceamento espalhado.
- [ ] Sem código morto, sem duplicação evitável, funções curtas; nomes do glossário do CLAUDE.md.
- [ ] Tratamento de dado inválido (validador de dados, save inválido recusado, ação fora da fase rejeitada sem mudar o estado).

## Jogo e equilíbrio

- [ ] Determinismo: mesma semente, mesmo resultado; a previsão e a apresentação não sorteiam.
- [ ] Justiça: golpe perigoso avisado um turno antes, intervalo entre golpes de moeda, sem morte instantânea acima de 60% de vida, Golpe Mortal só em chefe.
- [ ] Vencibilidade do mapa (GDD §5) e tempo de criação da Descida (alvo: menos de 2 s no PC).
- [ ] Simulador rodado depois de mudança de regra, com o relatório anotado no ADR.

## Testes

- [ ] Suíte verde em headless; testes novos cobrem o comportamento novo e o caso de erro.
- [ ] Testes de propriedade e de distribuição usam sementes fixas e margens honestas.
- [ ] Nenhum teste depende de ordem ou de estado em `user://` (use pastas de teste e limpe).

## Documentação

- [ ] ADR com contexto, decisão, alternativas, consequências e a verificação no simulador.
- [ ] GDD, ADRs, fichas de inimigos e `FEEDBACK.md` refletem o que foi feito.
- [ ] A tarefa tem "Verificação" preenchida com comando, resultado e data.

## Fidelidade visual e cânone de assets (ADR-0036, ADR-0042)

Para tarefa que crie/altere qualquer asset (3D, Blender, textura, cenário, inimigo, item, ícone, UI, iluminação, shader) ou mexa em tela, o revisor abre os assets/prints anexados (e, se puder, o jogo) e responde:

- [ ] A tela tem cenário com profundidade real em camadas (altura em terraços, primeiro plano, palco, fundo em névoa e luz dirigida), e não retângulos, chão plano ou desenho vetorial chapado?
- [ ] **Cânone do ADR-0042 respeitado em todo asset criado/alterado:** grafismo, craft e profundidade espacial alinhados a **Sword of Convallaria** (nº 1), **Tactics Ogre**, **Triangle Strategy**, **Octopath Traveler**, **Ragnarok Online** e **Buriedbornes**, mergulhados em atmosfera **bem dark e gótica** de **Bloodborne** (prioridade máxima) e **Dark Souls** (sem visual cartoon, fofo, plástico liso, verde vivo de pinheiro ou luz ambiente lavada)?
- [ ] A composição segue as referências estruturais em `docs/ART-DIRECTION.md` (mapa: diorama FFT + bolhas legíveis; combate: composição Fear & Hunger + linha do tempo FFT; fogueira: Darkest Dungeon)?
- [ ] No mapa, os três caminhos aparecem e o que vem depois está ofuscado, com a câmera acompanhando a Bibiana e respeitando não-oclusão (ADR-0041)?
- [ ] Os modelos vêm de kit CC0 (retingidos/des-fofificados) ou do Blender/TRELLIS.2/Meshy, com licença registrada em `assets/LICENSES.md`?
- [ ] **Originalidade (GDD §18):** nenhum prompt de geração por IA cita nomes de jogos, personagens ou artistas (apenas descritores originais do `ADR-0042`)?
- [ ] O que o ADR da tarefa diz bate com o GDD §17 e §18? Divergência do GDD sem ADR que a declare e sem GDD atualizado é achado crítico.
