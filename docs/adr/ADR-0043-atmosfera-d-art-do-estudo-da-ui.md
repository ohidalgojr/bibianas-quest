# ADR-0043: atmosfera comum (ambiente frio, neblina, foco quente, dithering) e fogueira sincronizada

| Campo | Valor |
| --- | --- |
| Status | Aceito (decisões recomendadas no estudo da TASK-051 e autorizadas pelo Orlando em 2026-11-22: "implementar as melhorias") |
| Data | 2026-11-22 |
| Tarefa | TASK-055 |
| GDD | 18, 19 |

## Contexto

O estudo `ESTUDO-ui-mobile-inimigos-estetica.md` (Parte 5 e quadro 6.2) apontou que o maior problema visual restante era a luz ambiente alta e lilás, o `PostFx` sem dithering e o desfoque forte no combate, além da fogueira 3D acesa antes de o jogador acendê-la.

## Decisão

1. Uma classe `Atmosphere` concentra o ambiente: energia 0,46, azul-ardósia, neblina exponencial. O mapa fica em 0,62 e sem neblina, porque nele a leitura dos nós vem antes do clima (desvio consciente da faixa 0,40 a 0,52 do estudo).
2. O combate ganha um `SpotLight3D` quente sobre o inimigo; o desfoque do `PostFx` no combate cai de 1,3 para 0,35.
3. O `PostFx` ganha dithering de Bayer 4x4 e split-toning (sombras azuis, luzes quentes).
4. `Scene3DBackdrop.set_fire_lit` liga ou desliga chama, faíscas e luz forte; o painel da fogueira o chama a cada render.
5. D-ART-3: os pinheiros já saíram das cenas de jogo (TASK-053); resta só a cena de prova.

## Consequências

Sem mudança de regra nem de `RULES_VERSION`. A validação final é visual, com prints no Godot.
