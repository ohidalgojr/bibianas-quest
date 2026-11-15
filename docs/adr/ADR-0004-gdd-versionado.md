# ADR-0004: `docs/GDD.md` é a cópia do GDD que vale para o código

| Campo | Valor |
| --- | --- |
| Status | Aceito (aprovado por Orlando em 2026-11-15) |
| Data | 2026-11-15 |
| Tarefa | TASK-001 |
| GDD | 21 (etapa 7) |

## Contexto

O GDD nasceu como documento no Claude (artefato "Bibiana's Quest — Game Design Document (GDD)", revisão 83). Agentes que trabalham no repositório não leem o artefato, e a regra "não mexer em fórmulas sem ADR" só é verificável se o texto das fórmulas estiver sob controle de versão, ao lado do código.

## Decisão

- `docs/GDD.md` é a cópia que vale para o código e para os agentes. Foi exportada do artefato em 2026-11-15, na revisão 83.
- Mudança de regra ou fórmula acontece em `docs/GDD.md`, no mesmo commit do ADR que a justifica e do código que a implementa.
- O artefato continua como versão de leitura, com os diagramas. Quando `docs/GDD.md` mudar, o artefato é atualizado em seguida ou recebe uma nota apontando a divergência.
- A nota original do GDD, que ficava solta na raiz do vault, é substituída por `docs/GDD.md`. Editar o GDD no Obsidian continua possível, desde que seja `docs/GDD.md`, porque `docs/` está dentro do vault.
- Os quatro diagramas embutidos do artefato não são exportáveis; no arquivo eles aparecem como marcações em itálico.

## Alternativas

- **Artefato como fonte única:** bom para ler e comentar, mas fora do Git; uma fórmula poderia mudar sem diff e sem ADR.
- **Dois documentos independentes:** divergem em poucas semanas.

## Consequências

- Edições feitas direto no artefato não chegam aos agentes até serem trazidas para `docs/GDD.md`.
- O histórico de cada fórmula fica no `git log` de `docs/GDD.md`, ligado ao ADR.
