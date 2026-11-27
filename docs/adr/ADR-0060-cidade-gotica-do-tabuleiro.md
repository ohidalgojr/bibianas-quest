# ADR-0060: o tabuleiro do mapa é uma cidade gótica que sobe até a igreja

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-27 |
| Tarefa | TASK-073 |
| GDD | 5, 17, 18 |

## Contexto

O Orlando apontou que o tabuleiro "não faz sentido com o fundo": o primeiro cenário (Cidade Abandonada) tem uma igreja gótica pintada ao fundo (`map-strip-02-praca.jpg`, fixa na tela) e o tabuleiro era uma grade de 16 praças com terraços de ruído, criptas espalhadas, muros sem função e uma catedral 3D preta que brigava com a pintura. O diagnóstico completo, com prints, está em `docs/design/ESTRUTURA-TABULEIRO-GOTICO.md`. O ADR-0041 (Terrace-Grammar-Constraint) garantia coerência *local* (degraus, escadas, oclusão), mas não a estrutura da cidade.

## Decisão

1. **Orientação:** cada camada do grafo avança `LAYER_STEP` em `-Z` **e** `NORTH_SHEAR` (= `LAYER_STEP`) em `-X`. Como a câmera olha de `+X +Z` para `-X -Z`, o caminho sobe reto na tela, em direção à igreja pintada. Os nós de uma camada continuam na mesma linha de Z (a névoa do `Map3DScreen` é por linha); o desvio é em X. Parâmetros: `LAYER_STEP = 8`, `COLUMN_STEP = 6`.
2. **Estrutura da cidade** (`ScenarioGenerator.generate_map`): níveis por camada em rampa até o chefe (nível 5) com um único desnível (`canal_layer`); silhueta em faixa diagonal; ruas em Z (tronco, travessa por intervalo, tronco) com a escada colada na praça mais alta; rua principal marcada (`main_road`); terreno derivado da rua mais próxima; canal de 2 células no desnível com pontes; adro com portão de ferro no eixo do chefe, escadaria de 3 células e dois campos-santos.
3. **Gramática de construções:** casa de empena (`COMPOUND_HOUSE`, ≈2,3), casa baixa (`COMPOUND_COTTAGE`, ≈1,5), ruína (`COMPOUND_RUIN_HOUSE`, 0,72), muro do adro (`COMPOUND_CHURCH_GATE`) e portão em ruína (`COMPOUND_CITY_GATE`). Toda casa tem a porta voltada para rua ou praça, no nível do piso.
4. **Regra de oclusão geral:** uma parede alta não pode ficar nas 2 células da diagonal `+X +Z` de nenhuma célula caminhável (`ScenarioGenerator.occluding_cells`); a casa baixa respeita 1 célula. Substitui a regra do cone 3×3 dos nós (que passa a ser consequência).
5. **Cenografia por tipo de nó** (`plaza_dress`): sala em ruínas (baú), abrigo (fogueira), campo-santo (evento), praça de armas (elite e mini boss), cobertura (emboscada), restos (luta), portão em ruína (partida).
6. **Validador:** novas regras de rua principal contínua, chefe no ponto mais alto, escadaria e portão do adro, canal com ponte, mínimo de casas, portas para a rua, casas altas fora da oclusão e cenografia fora das ruas. Os 12 invariantes do ADR-0041 continuam valendo, com a regra 7 reformulada como em 4.
7. **Renderização:** `_render_gothic_mass` e a catedral 3D saem; casas, ruínas, portão, braseiros e cenografia entram; terreno e fachadas em faixas de 12 linhas de Z para corte por tela; janelas âmbar e chamas como quads sem luz dinâmica. O horizonte pintado continua sendo a igreja.
8. **Sem mudança no núcleo:** `game/core/` não é tocado e `RULES_VERSION` continua 21. Os dioramas focais (combate, loja etc.) mantêm a gramática do ADR-0041.

## Alternativas

- **Girar a câmera 45° para alinhar o tabuleiro:** exigiria mexer em `map3d_screen.gd`, no preview e na névoa; rejeitada nesta rodada. Inclinar o tabuleiro em X dá o mesmo resultado na tela.
- **Modelar a igreja em 3D:** custo alto de arte e de primitivas e desalinhamento com a pintura; o eixo e o portão bastam para a leitura.
- **WFC por tiles:** já rejeitado no ADR-0041; a gramática de zonas é mais curta, verificável e determinística.

## Consequências

- O tabuleiro lê como uma cidade e guia o olhar para a igreja; nós viram lugares. O custo é de primitivas (≈+25% no pior quadro), parte pela grade de névoa maior da tela e parte pelas casas (módulo de cripta de 1.032 triângulos).
- A planta cresce (75 × 57 no cenário 1; 145 × 121 a 12 camadas): mapas de 8+ camadas pedem bairros e LOD.
- Faltam peças próprias (textura de fachada e telhado, porta, janela, poço, forca, ponte em arco, portão grande); prompts em `docs/design/ESTRUTURA-TABULEIRO-GOTICO.md` §7.2.
- Fica pendente a revisão cruzada e o OK visual do Orlando.
