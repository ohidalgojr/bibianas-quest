class_name CoreVersion
extends RefCounted
## Versão das regras do núcleo.
##
## Suba [constant RULES_VERSION] sempre que uma regra ou fórmula já implementada no
## núcleo mudar de comportamento (o que exige ADR). Saves e relatórios do simulador
## gravam esse número, para que uma semente antiga não seja reproduzida com regras
## novas sem aviso.
##
## Histórico: 0, nenhuma regra; 1, gerador de mapa (TASK-003, ADR-0007).

const RULES_VERSION: int = 1
