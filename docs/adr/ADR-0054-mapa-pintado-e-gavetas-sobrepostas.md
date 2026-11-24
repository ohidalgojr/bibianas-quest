# ADR-0054: mapa pintado em 2D, gavetas de combate sobrepostas e herói de costas por arquivo

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-24 |
| Tarefa | TASK-067 |
| GDD | 5, 17, 18, 19 |

## Contexto

O diretor de arte (`docs/design/critica-diretor/CRITICA-DIRETOR.md`) deu ao mapa 3D nota 2,5 a 3: escuro, inimigos cinza sobre piso cinza, metade da tela vazia, pílulas cortadas, props Kenney fora da paleta. As gavetas de combate (nota 4) encolhiam o palco ao abrir.

## Decisão

1. O mapa passa a ser `PaintedMapScreen` (`game/presentation/map2d/`): rua gótica vertical montada com as arenas pintadas (beco, praça, catedral) e névoa nas emendas, estradas desenhadas só para o caminho feito, as ofertas e os ramos dos destinos, sprites HD-2D com contorno de luz e sombra de contato, props novos (baú de ferro, poste, lápide, fogueira recortada da arena) e o herói a cerca de 70% da altura. O `Map3DScreen` fica como reserva.
2. Pílulas de nível e recompensa são limitadas a 8 px das bordas.
3. As gavetas de combate viram uma folha sobreposta de 270 px acima da fileira de abas, sem redimensionar o palco; skills em lista de uma coluna com botões de 64 px.
4. O combate pintado limita o inimigo pela altura e pela largura e usa `ModelRegistry.hero_id()`: a Bibiana de costas (`bibiana_back.png`) entra sozinha quando o arquivo existir.

## Alternativas

- Corrigir iluminação e props do mapa 3D: descartado, a base de cubos é o que está feio e o diretor pediu os assets refeitos.
- Gerar a Bibiana de costas por transformação da imagem de frente: descartado, não existe como obter uma costas fiel sem nova arte.

## Consequências

O mapa fica legível e coerente com o combate. A tela do mapa duplica o HUD e os ícones do `Map3DScreen` (a extrair se o 3D for apagado). A Bibiana de costas depende do Gemini (`docs/design/PROMPTS-BIBIANA-COSTAS.md`).
