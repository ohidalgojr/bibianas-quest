# TASK-062: modelos dos inimigos refeitos pelos conceitos do Gemini e pela identidade visual

| Campo | Valor |
| --- | --- |
| Status | Em andamento (lote 1 de 6 reprovado pelo diretor de arte na rodada 1; rodada 2 em curso) |
| Aberta em | 2026-11-22 |
| Fase | 1, identidade visual |
| GDD | 13, 18 |
| ADRs | ADR-0050 |

## Objetivo

Substituir os modelos de inimigo feitos à mão (reprovados pelo Orlando: tosco, sem medo, ilegível) por modelos sombrios e adultos que sigam os conceitos do Gemini (`docs/design/refs/inimigos/`, `refs/roaming-boss/`) e as especificações do estudo (§4.2 a §4.9), aprovados só por print do jogo contra o checklist E de `docs/design/IDENTIDADE-VISUAL.md`.

## Fora do escopo

- Os inimigos 02, 03, 05, 06 e 07 do estudo e o Roaming Boss (pacote 15 da auditoria).
- A Bibiana (pacote 10 da auditoria).

## Critérios de aceite

- [ ] Lote 1: Cão de Peste, Coveiro, Carrasco Apodrecido, Turiferário Cego, Médico da Cera e Rastejador da Vala aprovados 12/12 pelo diretor de arte.
- [x] Nenhum corpo de kit de personagem (Kenney, Quaternius, KayKit) como base.
- [ ] Lotes seguintes: os 9 modelos restantes feitos à mão.

## Arquivos afetados

- `tools/blender/kitbash_lib.py`, `kitbash_batch1.py`, `kb_humanoid.py`, `assets/bibiana/enemies/*.glb`, `game/presentation/stage/model_registry.gd`

## Testes esperados

- Suíte existente (identidade dos inimigos, registro de modelos).

## Regras que esta tarefa não pode quebrar

- Cânone visual (ADR-0042 e ADR-0050); sem mudança de regra nem de `RULES_VERSION`.

## Verificação

Rodada 2 entregue (6 GLBs com textura baked, prints `TASK-062-<id>.png`); suíte 369/369 em 2026-11-22. **Pendente: revisão do diretor de arte** (ver `docs/design/PROXIMA-RODADA-VALIDACAO.md`).

## Revisão cruzada

Pendente.
