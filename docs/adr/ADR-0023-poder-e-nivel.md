# ADR-0023: Poder mais rápido, Nível e Coveiro recalibrado

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-16 |
| Tarefa | TASK-019 |
| GDD | 9, 23 |

## Contexto

Pedido do Orlando (F-004): ganho de status que se sinta. Com ΔPoder = 0,15 × N × m_tipo, uma luta comum no começo dava +1 ou 2 de HP e nenhum outro atributo. O Poder ao chegar no chefe do cenário 1 era 1,4, enquanto a tabela da mecha do GDD §9 espera cerca de 5 (estágio 3, "perto do chefe do cenário 1"). O mapa do MVP tem poucas lutas por cenário, por isso o GDD (pensado para cenários mais longos) ficava muito abaixo.

## Decisão

1. **Coeficiente do Poder: 0,15 → 0,4.** ΔPoder = 0,4 × N × m_tipo. As taxas por atributo do GDD (HP +10%, FOR e MEN +8%, DEF e RES +6%, VEL +2% por ponto de Poder) não mudam. `RULES_VERSION` sobe para 7. Testado antes com 0,75: o mediano vencia 98%, fácil demais.
2. **Nível** é a parte inteira do Poder (`RunRules.level_of`), só rótulo: aparece no cabeçalho do mapa e a recompensa anuncia "Subiu de nível! 1 → 2".
3. **Coveiro recalibrado** (HP 150 → 215, FOR 14 → 16) para o mediano voltar à meta com o jogador mais forte (ADR-0012 tinha 150 e 14).

## Verificação no simulador

Regras v7, bots mediano e cuidadoso, mapas de verdade (`reports/simulation.md`):

| Configuração | Poder no chefe | Mediano (meta 55% a 65%) | Mortes por moeda | Mapas sem rota vencível |
| --- | --- | --- | --- | --- |
| 0,75 e Coveiro 150/14 | 7,7 | 98,0% | 25% | |
| 0,4 e Coveiro 190/14 | 4,6 | 81,7% | 22,7% | |
| 0,4 e Coveiro 230/17 | 4,6 | 58,3% | 18,0% | 2 de 40 (viola o GDD §5) |
| **0,4 e Coveiro 215/16 (adotado)** | 4,6 | **65,0%** | 19,0% | **0 de 100** |

O Poder no chefe (4,6) fica perto do marco 5 do GDD. O cuidadoso vence 79% no adotado. A configuração com 230/17 deixava 2 de 40 mapas sem caminho vencível, então o Coveiro ficou um pouco mais fraco.

**Ponto em aberto:** a TASK-020 (skills na loja) soma poder de novo; rodar o simulador e ajustar o Coveiro de novo ao final.

## Consequências

- Saves anteriores são recusados (versão das regras).
- A suíte ficou mais lenta (cerca de 2 minutos): o teste de vencibilidade suaviza mais mapas com o chefe mais forte. Se passar disso, separar os testes longos.
- O sentido do "Poder 45 em 3 cenários" do GDD precisa ser revisto quando houver cenários 2 e 3.
