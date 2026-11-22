# Pintores e constantes comuns dos inimigos da rodada 2 (TASK-062).
from kb2 import *  # noqa: F401,F403
import kb2 as B  # noqa: F401
import kitbash_lib as L  # noqa: F401

K = L.KENNEY
SKIN_C = hexc("#3E4752")
SKIN_DK = hexc("#262C34")
BAND_C = hexc("#5A584A")


def body_painter(skin=SKIN_C, band_below=None, band_color=BAND_C, seed=1, dark=SKIN_DK, light=None):
    light = light or mix(skin, STEEL, 0.25)

    def fn(co, n, cen):
        if band_below is not None and 0.08 < co.z < band_below:
            return (*band_color, R_BAND)
        c = skin
        if n.z > 0.3:
            c = mix(c, light, 0.35)
        elif n.z < -0.3:
            c = mix(c, dark, 0.5)
        return (*c, R_PLAIN)
    return fn


def P(base, dark=None, light=None, region=0.0, **kw):
    return make_painter(hexc(base), dark=hexc(dark) if dark else None, light=hexc(light) if light else None, region=region, **kw)
