# TASK-062 rodada 2: os seis inimigos do lote 1 com Skin modifier + textura assada (ver kb2.py).
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kb2 import *  # noqa: E402,F401,F403
import kb2 as B  # noqa: E402
import kitbash_lib as L  # noqa: E402

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


# =============================================================== TURIFERARIO CEGO (conceito 01)


def blind_censer_bearer():
    cass = P("#323A46", "#161B22", "#4C5766", R_CLOTH, low=0.5, grime=0.5, noise=0.16, seed=71, top=0.25)
    cass_d = P("#262C36", "#12161C", "#3A4452", R_CLOTH, noise=0.14, seed=72)
    iron = P("#3A3F47", "#14171C", "#667080", R_RUST, noise=0.25, seed=74)
    bone = P("#6C7480", "#2E343D", "#7E8FA8", R_PLAIN, noise=0.1, seed=76)
    cav = P("#120C0A", region=R_PLAIN, noise=0.0)
    rope = P("#5A5242", "#2A261E", "#6E6552", R_CLOTH, noise=0.2, seed=77)
    nodes = {
        "pelvis": ((0, 0.10, 0.95), (0.15, 0.11)), "spine": ((0, 0.07, 1.22), (0.14, 0.10)),
        "chest": ((0, -0.02, 1.48), (0.19, 0.12)), "neck": ((0, -0.13, 1.66), (0.06, 0.06)),
        "shL": ((-0.27, -0.02, 1.56), 0.075), "shR": ((0.27, -0.02, 1.56), 0.075),
        "elL": ((-0.34, -0.12, 1.20), 0.058), "wrL": ((-0.30, -0.30, 0.92), 0.05),
        "elR": ((0.34, -0.10, 1.16), 0.062), "wrR": ((0.38, -0.20, 0.62), 0.055), "hdR": ((0.40, -0.24, 0.52), 0.05),
        "hpL": ((-0.12, 0.10, 0.92), 0.09), "hpR": ((0.12, 0.10, 0.92), 0.09),
        "knL": ((-0.14, -0.02, 0.50), 0.07), "knR": ((0.14, -0.02, 0.50), 0.07),
        "anL": ((-0.14, 0.06, 0.10), 0.055), "anR": ((0.14, 0.06, 0.10), 0.055),
        "toL": ((-0.14, -0.14, 0.04), 0.05), "toR": ((0.14, -0.14, 0.04), 0.05),
    }
    edges = [("pelvis", "spine"), ("spine", "chest"), ("chest", "neck"), ("chest", "shL"), ("chest", "shR"), ("shL", "elL"), ("elL", "wrL"),
             ("shR", "elR"), ("elR", "wrR"), ("wrR", "hdR"), ("pelvis", "hpL"), ("pelvis", "hpR"), ("hpL", "knL"), ("hpR", "knR"),
             ("knL", "anL"), ("knR", "anR"), ("anL", "toL"), ("anR", "toR")]
    skin_body("body", nodes, edges, "pelvis", body_painter(band_below=0.82, seed=3), subdiv=1, target_tris=900)
    # costelas abertas, cavidade e gaiola de ferro com brasa quente
    box((0, -0.12, 1.32), (0.34, 0.12, 0.46), fn=cav, name="cavity")
    for z in (1.16, 1.28, 1.40, 1.52):
        for sx in (-1, 1):
            tube([(sx * 0.2, -0.02, z), (sx * 0.18, -0.15, z + 0.02), (sx * 0.07, -0.2, z + 0.03)], [0.04, 0.04, 0.035], sides=5, fn=bone, name="rib")
    coal = blob((0, -0.17, 1.34), (0.1, 0.08, 0.14), jitter=0.1, name="coal")
    set_ember(coal)
    for x in (-0.11, -0.04, 0.04, 0.11):
        tube([(x, -0.25, 1.16), (x, -0.26, 1.52)], [0.026, 0.026], sides=4, fn=iron, name="bar")
    for z in (1.16, 1.52):
        tube([(-0.13, -0.25, z), (0.13, -0.25, z)], [0.03, 0.03], sides=4, fn=iron, name="barring")
    # batina rasgada, aberta na frente, barra irregular
    cloth((0, 0.06, 0), 1.0, 0.16, (0.24, 0.19), (0.46, 0.38), n=12, arc=(40, 320), rows=4, fold=0.08, jag=0.22, seed=77, fn=cass, name="tunic")
    cloth((0, 0.02, 0), 1.0, 0.45, (0.25, 0.2), (0.34, 0.28), n=9, arc=(-50, 50), rows=3, fold=0.05, jag=0.16, seed=78, fn=cass_d, name="front")
    tube([(-0.26, 0.05, 1.0), (0.0, -0.22, 0.97), (0.26, 0.05, 1.0)], [0.05] * 3, sides=5, fn=rope, name="rope")
    # capuz-xale caindo dos ombros
    cloth((0, -0.03, 0), 1.72, 1.12, (0.12, 0.12), (0.5, 0.38), n=11, arc=(25, 335), rows=3, fold=0.08, jag=0.15, seed=79, fn=cass, name="shawl")
    # mascara de ferro longa e cega, rebitada
    hc = (0, -0.34, 1.80)
    eyes = head2(hc, h=0.50, w=0.30, d=0.34, rot=(20, 0, 0), skin=iron, hollow=0.5, long_face=1.18, name="mask")
    B.DECALS.clear()
    for sx in (-1, 1):
        for k, (yy, zz) in enumerate(((-0.40, 0.18), (-0.32, -0.02), (-0.2, -0.2))):
            decal(xf((sx * 0.34 * 0.3, yy * 0.34, zz * 0.5 * 1.18), hc, (20, 0, 0)), 0.018, hexc("#7E8FA8"), 0.9)
    decal(xf((0, -0.47 * 0.34, 0.12), hc, (20, 0, 0)), 0.05, ABYSS, 0.9, (3.0, 0.5, 0.2))   # fenda cega da boca
    tube([xf((0, -0.1, 0.24), hc, (20, 0, 0)), xf((0, 0.12, 0.26), hc, (20, 0, 0))], [(0.2, 0.03)] * 2, sides=4, fn=iron, name="strap")
    # braco longo: manilha, corrente curta e grossa, turibulo de espinhos
    hand2((0.40, -0.24, 0.52), s=0.34, curl=0.8, fn=P("#3E4752", "#262C34", "#566270", R_PLAIN, noise=0.12, seed=41), name="handR")
    hand2((-0.30, -0.30, 0.92), s=0.30, curl=0.6, fn=P("#3E4752", "#262C34", "#566270", R_PLAIN, noise=0.12, seed=42), name="handL")
    ring_tube((0.4, -0.24, 0.58), 0.1, 0.045, plane="xy", segs=8, fn=iron, name="manacle")
    for i, (p, pl) in enumerate((((0.44, -0.34, 0.36), "xz"), ((0.45, -0.46, 0.24), "yz"), ((0.46, -0.6, 0.18), "xz"))):
        ring_tube(p, 0.075, 0.04, plane=pl, segs=6, fn=iron, name="link")
    ball = (0.47, -0.88, 0.24)
    blob(ball, (0.22, 0.22, 0.22), fn=iron, jitter=0.07, name="censer")
    for d in ((1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0.7, 0.7, 0.4), (-0.7, -0.7, 0.4), (0.7, -0.7, 0.4), (-0.7, 0.7, 0.4), (0, 0.7, 0.7)):
        v = Vector(d).normalized()
        spike(Vector(ball) + v * 0.17, Vector(ball) + v * 0.40, 0.075, sides=4, fn=iron, name="spine")
    B.STREAK.update({"amount": 0.4})


import kb2_more  # noqa: E402
BUILDERS = {"blind_censer_bearer": blind_censer_bearer}
BUILDERS.update(kb2_more.MORE)


def main():
    argv = sys.argv
    args = argv[argv.index("--") + 1:] if "--" in argv else []
    which = args[0]
    out = os.path.join(L.REPO, "assets", "bibiana", "enemies")
    reset2("fever" if which == "plague_hound" else "amber")
    BUILDERS[which]()
    export2(which, out)


main()
