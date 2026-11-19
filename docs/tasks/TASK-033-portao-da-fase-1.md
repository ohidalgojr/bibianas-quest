# TASK-033: portão da Fase 1 (MVP jogável)

| Campo | Valor |
| --- | --- |
| Status | Aberta (não iniciada; fecha o MVP depois das TASK-014 e 032) |
| Aberta em | 2026-11-18 |
| Fase | 1, portão de saída (GDD §22, §23) |
| GDD | 21, 22, 23 |
| ADRs | ADR-0031 em diante, se o portão pedir decisão |

## Objetivo

Registrar formalmente que o protótipo cinza passou (ou não) no portão da Fase 1 e abrir o roteiro da Fase 2. É a tarefa de fechamento: pouco código, muita conferência.

## Fora do escopo

- Arte, som, 3D, outras classes, Santuário, monetização real (Fase 2).

## Critérios de aceite

- [ ] TASK-014 concluída: Web exportado e aberto, APK no celular, sessão de 20 minutos feita e ficha preenchida (`docs/PLAYTEST.md`).
- [ ] TASK-029 concluída (feita; conferir achados abertos).
- [ ] TASK-032 concluída (números calibrados com dados humanos).
- [ ] Portão do GDD §22 e §23 avaliado por escrito: a pessoa quer "só mais uma" depois de 3 Descidas e nenhuma morte acontece sem aviso. Se falhar, a lista de ajustes vira tarefas antes de qualquer arte.
- [x] Primeira Descida chamativa (TASK-026) concluída (ADR-0031).
- [ ] `docs/ROADMAP-MVP.md` e `docs/HANDOFF.md` marcam o MVP como entregue e apontam o roteiro da Fase 2 (vertical slice: arte, cena 3D, som, animação da moeda, Santuário, anúncio real).
- [ ] Suíte verde e `main` no GitHub com o branch padrão corrigido.

## Arquivos afetados

- `docs/ROADMAP-MVP.md`, `docs/HANDOFF.md`, `docs/PLAYTEST.md`, `docs/FEEDBACK.md`

## Testes esperados

- Nenhum teste novo; a suíte inteira e o simulador devem estar verdes.

## Regras que esta tarefa não pode quebrar

- Não mudar fórmulas do GDD sem ADR.

## Verificação

Ainda não executada.

## Revisão cruzada

Pendente.
