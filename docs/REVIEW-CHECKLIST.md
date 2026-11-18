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
