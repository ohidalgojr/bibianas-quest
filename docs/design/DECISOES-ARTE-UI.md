# Decisões de arte e UI (resolução das contradições da auditoria)

| Campo | Valor |
| --- | --- |
| Data | 2026-11-22 |
| Origem | `docs/design/AUDITORIA-UI-vs-ESTUDO.md` §16 (11 regras que se contradiziam) |
| Status | Decididas pelo agente para destravar o trabalho, com a regra "o mais sombrio e o mais legível em celular vence"; o Orlando pode sobrescrever qualquer uma |

| # | Questão | Decisão | Por quê |
| --- | --- | --- | --- |
| 1 | Altura do palco no combate | **≥ 57%** (a do Estudo e da Lei 2) é o critério de aprovação | é a mais exigente das três e libera o inimigo grande |
| 2 | Câmera do duelo | `CAM_SIZE` 3,6 a 4,0, inclinação de 22 a 26 graus (IDENTIDADE) | é o que já está medido em print |
| 3 | Ambiente de luz | **escurece a luz** (0,30 a 0,40) e **não** retinge a peça; a peça só é multiplicada pela paleta | luz baixa com foco quente é a assinatura do jogo |
| 4 | Fonte | **Alegreya no corpo**, Cinzel só em título e em botão de até 3 palavras | legibilidade em 540×960 (D-UI-4) |
| 5 | Inimigo claro ou escuro | os conceitos do Gemini mandam na forma e no clima; o **valor** respeita o teto `#7E8FA8` da IDENTIDADE: o inimigo é o objeto mais escuro ou o mais quente do quadro | pele pálida sumia no dithering |
| 6 | Escala do mapa | `CAM_SIZE` entre 14 e 18, o que ainda mostra os 3 destinos e o mini-card | os 3 destinos precisam caber |
| 7 | Acentos de cor | **sem verde**. ▲ em ouro `#D9AA32`, ▼ em perigo `#B82824`; âmbar é a luz | verde saturado está proibido (IDENTIDADE) |
| 8 | Moeda | chance fixa de 50% e sem número (GDD §7, ADR-0026); o ritual visual do Estudo entra sem mostrar chance | não mexe em regra |
| 9 | Sheet da loja | até 50% da altura; fogueira até 38% | diorama maior sem sacrificar os cartões |
| 10 | Bibiana | **autorizada a troca do KayKit** por modelo próprio sombrio; o MVP do GDD §18 perde validade nesse ponto | "nada fofo" (Orlando, 2026-11-22) |
| 11 | Prints como evidência | todo commit visual regenera os prints que cita; print antigo não vale | ADR-0050 |
