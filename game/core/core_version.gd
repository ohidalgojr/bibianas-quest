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
## vencibilidade do mapa e Coveiro calibrado (TASK-008, ADR-0012); 5, intervalo entre golpes de moeda, golpes de debuff, Veneno e Fraqueza (TASK-016, ADR-0020); 6, drops de equipamento e consumível, venda a 40%, loja sem raros (TASK-018, ADR-0022); 7, Poder 0,4 por nível de inimigo (TASK-019, ADR-0023); 8, skills na loja e três skills novas (TASK-020, ADR-0024); 9, moeda 50/50, SORTE e Maré de azar nos drops, Moeda da Sorte (TASK-021, ADR-0026); 10, ouro 10 por nível, mapa de 6 camadas, baú multiplicável (TASK-022, ADR-0027); 11, fogueira com Galhos Secos (TASK-023, ADR-0028); 12, atacar devolve MP, Éter em combate, crítico manipulável (TASK-024, ADR-0029); 13, inimigos únicos: golpes de moeda temáticos, doença, IA reativa (TASK-025, ADR-0030); 14, primeira Descida chamativa com garantias, Ecos em dobro e morte que ensina (TASK-026, ADR-0031); 15, inimigos mutados, emboscadas em combate e SORTE/Maré de azar no mapa (TASK-027, ADR-0032); 16, eventos de mapa com escolhas, moeda e crítico, e mini boss anunciado com recompensa rara garantida (TASK-028, ADR-0033); 17, Santuário e meta-progresso: Biblioteca, Arsenal e Códice/Bestiário (TASK-030, ADR-0034); 18, quatro inimigos comuns novos no cenário 1: Sineiro Penado, Ossada Errante, Lodo de Esgoto e Sanguessuga de Beco (TASK-044, ADR-0038); 19, criaturas de horror: Enforcado, Costurado e a elite Mãe das Ratazanas (TASK-047, ADR-0039); 20, 20 itens novos de equipamento, incluindo cabeça e mão secundária (TASK-048, ADR-0040).

const RULES_VERSION: int = 20
