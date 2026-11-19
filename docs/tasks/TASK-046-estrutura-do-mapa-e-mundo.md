# TASK-046: estrutura do mapa e mais detalhe no mundo

| Campo | Valor |
| --- | --- |
| Status | Em andamento |
| Aberta em | 2026-11-19 |
| Fase | 1, feedback do Orlando ("a profundidade é só subir escada, não segue as referências") |
| GDD | 5, 17, 18 |
| ADRs | ADR-0036, ADR-0037 (e os que a tarefa criar) |

> Leia `docs/ART-DIRECTION.md` (§2 referências, §3 mapa) antes. Fecha com print e o teste do print.

## Objetivo

O tabuleiro deixa de ser uma escadaria única e passa a ter **topografia de cidade em ruínas**: relevo que sobe e desce, platôs, **canais de água**, **ruas em S** com escadas nos dois sentidos, **ruínas, torres e casas** com paredes e criptas, muros, árvores secas e iluminação ao longo das ruas, como nas referências de Final Fantasy Tactics e Hero Wars.

## Fora do escopo

- Pontes sobre vazios navegáveis, outros cenários e biomas; mudança do grafo do mapa (regra do núcleo).

## Critérios de aceite

- [ ] Alturas dos nós por **caminhada aleatória determinística** (sobe, desce ou mantém), não por camada; o chefe fica em um platô alto, mas o caminho **desce em vários trechos**.
- [ ] **Estradas em S** (segmentos retos em Z e X, sem diagonal) com degraus nos dois sentidos (a escada sempre aponta para o lado mais alto); degraus de diferença 1 entre células vizinhas de estrada; teste de contrato.
- [ ] **Canais de água** nos terrenos baixos (plano de água com ondulação), margens com pedra; as estradas nunca cruzam água.
- [ ] **Ruínas e casas** (paredes em anel, cripta, torre de pilares) em áreas livres, e iluminação (postes) ao longo das ruas; densidade de enfeite maior, sempre fora de praças e estradas.
- [ ] Os 3 destinos continuam livres e legíveis; câmera e névoa continuam funcionando; prints do início, meio e fim; executável gerado.

## Arquivos afetados

- `game/presentation/map3d/map3d_layout.gd`, `game/presentation/map3d/map3d_screen.gd`, `tests/unit/test_map3d.gd`

## Testes esperados

- Determinismo; alturas variam (há descidas); passos de estrada de no máximo 1 de altura; degraus apontam para o vizinho mais alto; estradas e praças fora d'água; destinos livres de enfeites; chefe em platô.

## Regras que esta tarefa não pode quebrar

- Só apresentação: `RULES_VERSION` não muda; núcleo sem nós; asset externo registrado.

## Verificação

Ainda não executada.

## Revisão cruzada

Pendente.
