# ADR-0009: dados em JSON validado e escala de nível dos inimigos

| Campo | Valor |
| --- | --- |
| Status | Aceito (decisão técnica dentro da tarefa; os números do protótipo serão calibrados na TASK-008) |
| Data | 2026-11-16 |
| Tarefa | TASK-005 |
| GDD | 8, 10, 13, 15, 17, 20 |

## Contexto

O GDD §20 deixa em aberto o formato dos dados: recursos `.tres` ou JSON validado. Ele também dá os atributos do Guerreiro e as faixas de nível do cenário, mas não dá os atributos dos inimigos nem diz como eles crescem com o nível. O combate (TASK-004) usava inimigos inventados nos testes.

## Decisão

1. **JSON validado.** Um arquivo por tipo em `game/data/` (`classes`, `skills`, `enemies`, `items`, `scenarios`), cada um com `format: 1`. Texto simples, com diff legível e fácil de editar por agentes. Ids em inglês, nomes em português.
2. **Núcleo sem I/O.** `GameData` e `DataValidator` (`game/core/data/`) recebem dicionários já lidos. Quem lê arquivo é `DataLoader` (`game/services/`). Dado inválido gera uma lista de erros com o caminho do problema (`enemies[gravedigger].phases[1]: ...`). O carregador mostra cada erro com `push_error` e devolve os dados marcados como inválidos. O jogo não deve seguir com dado inválido.
3. **Regras do GDD conferidas no validador:** de 3 a 5 golpes por fase (§6); chefe com 2 a 3 fases, pelo menos um golpe Cruel e Golpe Mortal na fase final (§13); Golpe Mortal só em chefe (§7); a primeira fase começa em 100% e os limites descem. Referências entre arquivos (skills da classe, equipamento inicial, inimigos e chefe do cenário) precisam existir e ser do tipo certo.
4. **Escala de nível dos inimigos.** Cada inimigo tem atributos no `base_level`. Num nível `N`, os atributos crescem com as mesmas taxas do Poder da Bibiana (GDD §9), usando `1 + (N - base_level)` como Poder equivalente: HP +10% por nível, FOR e MEN +8%, DEF e RES +6%, VEL +2%. Nível abaixo do base não encolhe o inimigo. Leitura do protótipo: o GDD compara o Poder com o nível dos inimigos, mas não dá a curva.
5. **Atributos iniciais incluem o equipamento inicial.** A tabela do §8 já é a Bibiana equipada. Por isso o equipamento inicial (Espada e Escudo, Cota de Malha Velha) tem modificadores zero, e os modificadores dos outros itens são diferenças em relação a ele. Os equipamentos só passam a valer na TASK-007.
6. **Números do protótipo (não estão no GDD).** São os atributos e ciclos dos 6 inimigos e do Coveiro, os 30% da Poção Turva, os 50% de MP do Éter Sujo, os modificadores e os preços dos itens. Os preços ficam dentro das faixas do §15. Os inimigos comuns começam perto dos inimigos de teste da TASK-004, que davam cerca de 6 turnos da Bibiana por luta. A meta do §23 é de 6 a 10 turnos. O simulador da TASK-008 calibra tudo, com ADR.

## Alternativas

- **`.tres`:** tipado pelo editor, mas o diff é pior e exige uma classe `Resource` por entidade. Também acopla os dados ao editor do Godot, quando os agentes editam texto.
- **Escala própria por inimigo** (crescimento no dado de cada um): mais flexível, mas são números a mais para calibrar sem dados. Pode entrar depois como sobrescrita opcional.
- **Carregar no núcleo com `FileAccess`:** mais curto, mas mistura I/O com regras e dificulta testar o validador com dados montados no teste.

## Consequências

- Mudar um número em `game/data/` muda resultados por semente. Os relatórios do simulador devem registrar o `format` dos dados junto com o `RULES_VERSION`.
- Nenhuma fórmula do GDD mudou, e o `RULES_VERSION` continua 2. A escala de nível é regra nova, não alteração.
- Inimigos de outros cenários e outras classes entram nos mesmos arquivos, sem código novo, exceto para efeitos novos.
