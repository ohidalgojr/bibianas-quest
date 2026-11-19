class_name GfxSettings
extends RefCounted
## Interruptores de qualidade gráfica (TASK-039): aparelho fraco desliga o pós-processamento e o
## clima sem mexer em regra. Em headless (testes) ficam ligados, mas ninguém desenha.

static var post_fx: bool = true
static var weather: bool = true
## Relâmpagos na tela (GDD §19, "reduzir flashes"): falso desliga só o clarão, não o som.
static var flashes: bool = true
