# ADR-0013: tela do mapa e fluxo provisório da Descida

| Campo | Valor |
| --- | --- |
| Status | Aceito; a parte visual (grade 2D) foi substituída pelo ADR-0036; `MapView` continua |
| Data | 2026-11-16 |
| Tarefa | TASK-009 |
| GDD | 5, 17, 19, 20 |

## Contexto

O GDD §17 descreve o mapa como tabuleiro isométrico 3D, e o §5 descreve a névoa. O protótipo cinza segue o ADR-0010: 2D, formas simples, um controlador sem nós e uma tela montada em código. A loja e a fogueira só ganham tela na TASK-010, mas o fluxo da Descida precisa andar já. A checagem de vencibilidade leva segundos (ADR-0012).

## Decisão

1. **Mapa em grade 2D, em retrato.** Uma linha por camada, com a partida embaixo e o chefe no alto; uma coluna por posição do grafo. As ligações são linhas desenhadas pelo `_draw` de um `Control`. Os nós são botões quadrados com uma letra e uma cor por tipo, com o tamanho mínimo de toque do GDD §19 (48 px).
2. **`MapView` (controlador sem nós)** monta o que a tela mostra a partir do `RunState`, sem regra própria:
   - **Destinos:** os 3 nós de `options()` mostram tipo, inimigo e nível e ficam clicáveis.
   - **Névoa:** as camadas acima dos destinos ficam como silhuetas sem tipo, e o chefe sempre aparece.
   - **Caminho feito:** são os nós dos eventos `NODE` da Descida. Eles e o nó atual ficam marcados.
   - **Camadas já passadas:** os nós que não foram visitados ficam esmaecidos e sem tipo.
3. **Combate ligado à Descida.** O `CombatSession` passa a aceitar a luta pronta do `RunState`, com as poções contadas pelo inventário da Descida. Em vez do seletor de depuração, a tela de combate mostra "Continuar" ao fim. O seletor continua acessível pela tela inicial ("Luta de teste").
4. **Loja e fogueira provisórias** num painel simples. Na loja, "Seguir"; na fogueira, "Descansar" (3 Brasas) e "Seguir". As telas de verdade chegam na TASK-010.
5. **Descida criada numa `Thread`.** O `RunState` é `RefCounted` e os dados só são lidos, então criá-lo fora da thread principal é seguro. Uma tela de espera ("Gerando o mapa...") aparece enquanto isso, e a checagem usa as 200 simulações do GDD (`Winnability.DEFAULT_RUNS`). Isso responde em parte ao primeiro ponto do ADR-0012. Guardar o resultado no save fica para a TASK-012.
6. **`GameScreen`** é a raiz do fluxo provisório: tela inicial, espera, mapa, combate, painéis e resultado. A TASK-011 a substitui pelo menu de verdade.

## Alternativas

- **Tabuleiro isométrico já agora:** é o visual final, mas atrasa o teste do fluxo sem mudar as regras.
- **Loja e fogueira saindo sozinhas até a TASK-010:** o fluxo andaria, mas a fogueira ficaria inútil no playtest. Um botão de descanso custa pouco.
- **Criar a Descida na thread principal:** a janela travaria vários segundos e, no celular, o sistema poderia acusar que o app não responde.

## Consequências

- `main.gd` abre o `GameScreen`. A luta de teste da TASK-006 continua acessível por ele.
- A troca para o tabuleiro 3D (Fase 2) substitui só o `MapScreen`; o `MapView` continua igual.
