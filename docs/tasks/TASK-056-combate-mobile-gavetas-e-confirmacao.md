# TASK-056: combate mobile-first com gavetas e confirmação em dois toques (Ui-B parcial)

| Campo | Valor |
| --- | --- |
| Status | Em verificação (código e testes prontos; falta o Orlando jogar no celular) |
| Aberta em | 2026-11-22 |
| Fase | 1, melhorias do estudo da TASK-051 (D-UI-1 e D-UI-2, recomendação "Opção A") |
| GDD | 6, 19 |
| ADRs | ADR-0044 |

## Objetivo

O combate deixa de depender de hover e de 12 botões idênticos: Atacar e Defender ficam fixos em um toque; Habilidades, Itens e Tático viram abas de uma gaveta; skill, item e Fugir pedem um segundo toque, com a previsão no primeiro. Sem texto duplicado de HP/MP e status quando há palco 3D.

## Fora do escopo

- Intenção em espaço de mundo, takeover da Moeda, trilha de dano nas barras (Ui-A e restante da Ui-B).
- Menus de loja, fogueira e mapa (Ui-C, Ui-D).

## Critérios de aceite

- [x] Atacar e Defender fora das gavetas; as outras 10 ações em exatamente uma gaveta.
- [x] Uma gaveta aberta por vez; tocar na aberta recolhe.
- [x] Skill, item e Fugir: 1º toque seleciona e mostra a previsão, 2º executa (`confirm_taps`, ligado fora de headless).
- [x] Atacar e Defender executam em um toque.
- [x] Com palco 3D, sem os textos de HP/MP e de status duplicados.

## Arquivos afetados

- `game/presentation/combat/combat_screen.gd`, `tests/unit/test_combat_drawers.gd`

## Testes esperados

- `tests/unit/test_combat_drawers.gd`: posição das ações, gaveta única, dois toques, um toque para atacar, troca de seleção.

## Regras que esta tarefa não pode quebrar

- Só apresentação; `RULES_VERSION` não muda; a API `perform(action)` e `_buttons` seguem iguais para os testes.

## Verificação

Ver HANDOFF (suíte e data). Não verificado: toque real num celular.

## Revisão cruzada

Pendente.
