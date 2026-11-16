class_name CoreVersion
extends RefCounted
## Versão das regras do núcleo.
##
## Suba [constant RULES_VERSION] sempre que uma regra ou fórmula já implementada no
## núcleo mudar de comportamento (o que exige ADR). Saves e relatórios do simulador
## gravam esse número, para que uma semente antiga não seja reproduzida com regras
## novas sem aviso.
##
## Histórico: 0, nenhuma regra; 1, gerador de mapa (TASK-003, ADR-0007); 2, combate e moeda
## (TASK-004, ADR-0008); 3, Descida e peso de evento 0 no protótipo (TASK-007, ADR-0011); 4,
## vencibilidade do mapa e Coveiro calibrado (TASK-008, ADR-0012); 5, intervalo entre golpes de moeda, golpes de debuff, Veneno e Fraqueza (TASK-016, ADR-0020).

const RULES_VERSION: int = 5
