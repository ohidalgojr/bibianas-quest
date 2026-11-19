# TASK-049: preparar o jogo para as classes do GDD

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada; aguarda a decisão do Orlando em `docs/design/ESTUDO-quando-entram-as-classes.md` §5) |
| Aberta em | 2026-11-19 |
| Fase | 2, preparação (GDD §8, §22) |
| GDD | 8, 9, 22 |
| ADRs | a criar |

## Objetivo

Sem criar classe nova, **tirar as exceções do Guerreiro do código** e deixar a escolha de classe visível: regras e conteúdo da classe em dados, e uma tela de seleção com as outras classes bloqueadas.

## Fora do escopo

- Implementar Clérigo, Mago ou Ladino (cada uma é uma tarefa com ADR, ficha, bot e meta de vitória).

## Critérios de aceite

- [ ] Veterano que Defende, skills iniciais, itens de loja e skills de fogueira vêm de `game/data/classes.json` (por classe), sem `if` de Guerreiro no núcleo; testes existentes continuam verdes.
- [ ] Tela de seleção de classe no menu com Guerreiro ativo e as demais "Em breve", com a silhueta 3D do modelo KayKit de cada uma.
- [ ] ADR e GDD §8 atualizados; HANDOFF com a ordem das classes decidida.

## Arquivos afetados

- `game/data/classes.json`, `game/core/` (regras amarradas ao Guerreiro), `game/presentation/game_screen.gd`

## Testes esperados

- Os testes de combate e de Descida passam sem mudança de resultado para o Guerreiro; teste de que classe bloqueada não inicia Descida.

## Regras que esta tarefa não pode quebrar

- Sem mudança de regra para o Guerreiro: o mesmo resultado por semente; `RULES_VERSION` só sobe se algo mudar.

## Verificação

Ainda não executada.

## Revisão cruzada

Pendente.
