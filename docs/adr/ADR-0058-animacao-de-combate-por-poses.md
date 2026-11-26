# ADR-0058: animação de combate por poses de sprite e FX por quadros

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-26 |
| Tarefa | TASK-071 |
| GDD | 6, 17, 18, 19 |

## Contexto

O Orlando entregou poses de combate, estados e caminhada da Bibiana de costas e folhas de FX. O combate só deslocava o sprite, sem pose nem efeito, e a linha do tempo usava recortes pequenos e borrados.

## Decisão

1. A animação da Bibiana é feita trocando a textura do sprite entre poses recortadas na mesma escala de pixel (referência de 240 px), com movimento por `Tween`. O núcleo não muda; a tela só reage aos eventos.
2. O golpe é uma sequência: caminhada até o inimigo, espada no alto, impacto e volta. A tela aguarda o instante do impacto para aplicar dano e números, e a volta corre sozinha.
3. FX são folhas RGBA (chave de cor por `tools/make_fx.py`) tocadas por quadros em `Sprite3D` billboard, à frente da cena.
4. Os bustos da linha do tempo são recortes quadrados da cabeça, reduzidos com Lanczos; a Bibiana usa a prancha de frente.

## Alternativas

- Esqueleto e animação 3D: descartado pelo ADR-0052.

## Consequências

Cada nova classe precisa das mesmas poses. A duração da sequência aumenta o tempo de cada ataque (cerca de 1 s); a velocidade 2x do combate a encurta.
