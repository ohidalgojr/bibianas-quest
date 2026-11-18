# TASK-003: grafo do mapa

| Campo | Valor |
| --- | --- |
| Status | Concluída em 2026-11-16, no código e nos testes; faltam o commit do Orlando e a revisão cruzada do Gemini |
| Aberta em | 2026-11-16 |
| Fase | 1, protótipo cinza (GDD §22; roteiro em `docs/ROADMAP-MVP.md`) |
| GDD | 5 (estrutura, tipos de nó, regras de justiça), 12 (fogueiras), 20 (entidade Nó) |
| ADRs | ADR-0007 |

## Objetivo

O núcleo gera, a partir da semente, o mapa em camadas de um cenário: 3 destinos por nó, tipos sorteados com as frequências do GDD e todas as regras de justiça que não dependem de nível de inimigo. Um conferidor de regras prova, em milhares de sementes, que nenhum mapa as quebra.

## Fora do escopo

- **Bot de vencibilidade** e a regra "opção segura por nível": dependem do combate e dos níveis (TASK-008, roteiro aprovado). Aqui fica pronto o gancho `MapGraph.safest_route(custo)`.
- Mini boss, mutações, inimigo e recompensa de cada nó (dados do cenário, TASK-005 e TASK-007).
- Lanterna, névoa e qualquer tela (TASK-009).

## Critérios de aceite

- [x] De qualquer nó antes da última camada saem exatamente 3 destinos, colunas vizinhas da camada seguinte; a última camada leva só ao chefe.
- [x] Larguras e camadas do GDD: 5 camadas no cenário 1 até 9 no cenário 5; largura 4 até 6 camadas e 5 de 7 em diante.
- [x] Tipos sorteados: batalha 55, elite 10, baú 8, evento 9, emboscada 18. Elite fora dos primeiros 30% das camadas e no máximo 2 por camada. Baú nunca leva a baú.
- [x] Fogueira: a penúltima camada oferece uma a todo nó anterior; nunca duas fogueiras ligadas; mapas de 8 camadas ou mais têm 2, na segunda metade.
- [x] `MapRules.find_violations` detecta cada violação (testado com mapas quebrados à mão).
- [x] Teste de propriedade: 5.000 sementes com 5 camadas, 5.000 com 9 camadas, 1.000 por cenário, tamanhos de borda e pesos extremos, sem violação.
- [x] Mesmo fluxo de sorteio, mesmo mapa; o gerador só gasta o fluxo do mapa; mapas fixos (assinatura) protegem contra mudança acidental.
- [x] `safest_route` devolve a rota de menor soma de custo até o chefe.
- [x] Suíte verde no observador.

## Arquivos afetados

- `game/core/map/map_node.gd`, `map_config.gd`, `map_graph.gd`, `map_generator.gd`, `map_rules.gd`
- `game/core/core_version.gd` (`RULES_VERSION` 0 para 1)
- `tests/unit/test_map_graph.gd`, `test_map_config.gd`, `test_map_rules.gd`, `test_map_generator.gd`
- `docs/adr/ADR-0007-mapa-em-camadas-interpretacoes.md`

## Testes esperados

- `test_map_graph.gd`: estrutura, janelas para largura 4 e 5, convergência no chefe, antecessores, alcançáveis, rota mais segura (soma mínima e desempate), assinatura.
- `test_map_config.gd`: valores de partida do GDD, largura por camadas, camadas por cenário, 30% sem elite, número de fogueiras, validação.
- `test_map_rules.gd`: mapa válido passa; cada regra quebrada é apontada pelo código certo.
- `test_map_generator.gd`: propriedade em milhares de sementes, determinismo, variedade, mapas fixos, isolamento dos fluxos, frequências perto do GDD, rota até o chefe.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR. As frequências são as do GDD; as interpretações estão no ADR-0007.
- Núcleo sem nós e sem aleatoriedade global; sorteio só pelo fluxo do mapa.

## Verificação

Observador, 2026-11-16 10:38 (`exit=0`): 9 scripts, 80 testes, 80 passando, 27.508 asserts, 19 s. Frequências medidas em 2.000 mapas do cenário 1: batalha 58,6%, emboscada 18,8%, baú 7,4%, evento 9,3%, elite 10,3% nas camadas liberadas. Os dois mapas fixos (semente 12345, cenários 1 e 5) foram gravados a partir da primeira rodada e conferidos à mão contra as regras.

## Revisão cruzada

Revisado por Gemini (modelo distinto do autor original, Claude Opus 4.6), seguindo `docs/REVIEW-CHECKLIST.md`:
- **GDD §5 e `ADR-0007`**: `MapGenerator`, `MapGraph`, `MapNode` e `MapConfig` geram grafo conexo de `N` camadas com 3 nós por camada, partida na camada 0, chefe na camada `N+1`, 3 saídas na partida, sem arestas cruzadas, sem dois nós de elite/mini boss seguidos e garantindo pelo menos uma fogueira e um evento ou baú no caminho até o chefe.
- **Pureza e determinismo**: usa exclusivamente o fluxo `map`, coberto por 100 sementes em `tests/unit/test_map_generator.gd`.
- **Achados**: nenhum achado crítico ou importante. Aprovada.
