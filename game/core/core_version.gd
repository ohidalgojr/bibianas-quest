class_name CoreVersion
extends RefCounted
## Versão das regras do núcleo.
##
## Suba [constant RULES_VERSION] sempre que uma regra ou fórmula já implementada no
## núcleo mudar de comportamento (o que exige ADR). Saves e relatórios do simulador
## gravam esse número, para que uma semente antiga não seja reproduzida com regras
## novas sem aviso. Vale 0 enquanto o núcleo não implementa nenhuma regra do GDD.

const RULES_VERSION: int = 0
