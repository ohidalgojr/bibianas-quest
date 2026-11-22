# TASK-062, lote 1: plague_hound, gravedigger, rotten_executioner, blind_censer_bearer, wax_physician,
# trench_crawler. Kitbash em pecas Kenney (cabeca, maos, torso, props) + tubos/panos bmesh, cor de vertice.
# Uso: blender -b -P tools/blender/kitbash_batch1.py -- <id|all> [pasta de saida]
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kitbash_lib import *  # noqa: E402,F401,F403
import kitbash_lib as L  # noqa: E402

K = L.KENNEY
SK = os.path.join(K, "character-skeleton.glb")
ZB = os.path.join(K, "character-zombie.glb")
VP = os.path.join(K, "character-vampire.glb")
KP = os.path.join(K, "character-keeper.glb")
GH = os.path.join(K, "character-ghost.glb")


def ring_tube(center, R, r, plane="xz", segs=10, sides=5, fn=None, tilt=0.0, name="ring"):
    """Toro grosso (colar, elo de corrente, aro) como tubo fechado."""
    cx, cy, cz = center
    pts = []
    for i in range(segs + 1):
        a = math.tau * i / segs
        if plane == "xz":
            pts.append((cx + math.cos(a) * R, cy + math.sin(a) * R * math.sin(tilt), cz + math.sin(a) * R * math.cos(tilt)))
        elif plane == "xy":
            pts.append((cx + math.cos(a) * R, cy + math.sin(a) * R, cz))
        else:
            pts.append((cx, cy + math.cos(a) * R, cz + math.sin(a) * R))
    up = (0, 1, 0) if plane == "xz" else (0, 0, 1)
    return tube(pts, [r] * len(pts), sides=sides, fn=fn, up=up, caps=(False, False), name=name)


# =============================================================== CAO DE PESTE


def plague_hound():
    fur = make_painter(hexc("#3A424D"), light=hexc("#566170"), low=0.3, noise=0.14, seed=2, top=0.2, stripes=(1, -0.12, 0.36, 0.1, 0.55, hexc("#6C7480")))
    fur_leg = make_painter(hexc("#4A5461"), low=0.3, noise=0.12, seed=3, top=0.15)
    bone = make_painter(hexc("#5E6672"), dark=SKIN_D, noise=0.10, seed=4, top=0.15)
    dark = make_painter(ABYSS, noise=0.05)
    blood = make_painter(BLOOD, dark=ABYSS, noise=0.2, seed=5)
    iron = make_painter(IRON, light=STONE, noise=0.2, seed=6)
    # tronco: garupa baixa, ombros altos (hiena), peito fundo
    tube([(0, 0.50, 0.70), (0, 0.24, 0.80), (0, -0.04, 0.92), (0, -0.30, 1.02)],
         [(0.13, 0.15), (0.18, 0.21), (0.22, 0.27), (0.24, 0.29)], sides=7, fn=fur, name="torso")
    # pescoco grosso e cabeca baixa, avancando
    tube([(0, -0.30, 1.0), (0, -0.54, 0.96), (0, -0.74, 0.88)], [(0.17, 0.19), (0.15, 0.16), (0.14, 0.14)], sides=6, fn=fur, name="neck")
    # cranio: caveira do kit esticada para frente
    blob((0, -0.86, 0.92), (0.15, 0.2, 0.15), fn=bone, jitter=0.06, seed=9, name="skull")
    blob((0, -0.94, 1.0), (0.17, 0.1, 0.05), fn=bone, name="brow")
    for sx in (-1, 1):
        blob((sx * 0.1, -1.0, 0.95), (0.045, 0.03, 0.045), fn=dark, name="socket")
    tube([(0, -0.96, 0.88), (0, -1.2, 0.82)], [(0.115, 0.095), (0.08, 0.06)], sides=6, fn=bone, name="snout")
    tube([(0, -0.92, 0.76), (0, -1.16, 0.62)], [(0.08, 0.045), (0.06, 0.035)], sides=5, fn=bone, name="jaw")
    blob((0, -1.06, 0.75), (0.055, 0.12, 0.02), fn=blood, name="maw")
    for sx in (-1, 1):
        spike((sx * 0.06, -1.16, 0.79), (sx * 0.065, -1.19, 0.6), 0.036, fn=bone, name="fang")
        spike((sx * 0.1, -0.8, 1.02), (sx * 0.2, -0.62, 1.28), 0.07, fn=fur_leg, name="ear")
    for sx in (-1, 1):
        eye = blob((sx * 0.12, -0.99, 0.93), (0.065, 0.06, 0.06), subdiv=1, name="eye")
        if sx < 0:
            set_ember(eye)
        else:
            paint_flat(eye, ABYSS)
    # espinhos dorsais ossudos furando o couro (grossos e curtos)
    for i, y in enumerate((-0.2, -0.02, 0.16, 0.34)):
        zt = 0.98 - 0.30 * (y + 0.2) / 0.55 + 0.27
        spike((0, y, zt - 0.08), (0, y + 0.08, zt + 0.15), 0.065, fn=bone, name="dorsal")
    # pernas dianteiras retas, traseiras dobradas
    for sx in (-1, 1):
        tube([(sx * 0.17, -0.20, 0.82), (sx * 0.18, -0.25, 0.44), (sx * 0.17, -0.18, 0.10)],
             [0.125, 0.085, 0.065], sides=5, fn=fur_leg, name="legF")
        blob((sx * 0.17, -0.27, 0.045), (0.085, 0.16, 0.05), fn=bone, name="pawF")
        tube([(sx * 0.17, 0.42, 0.74), (sx * 0.2, 0.30, 0.50), (sx * 0.17, 0.5, 0.26), (sx * 0.17, 0.42, 0.07)],
             [0.15, 0.10, 0.07, 0.065], sides=5, fn=fur_leg, name="legB")
        blob((sx * 0.17, 0.39, 0.045), (0.085, 0.16, 0.05), fn=bone, name="pawB")
    # cauda de rato, caida
    tube([(0, 0.54, 0.70), (0, 0.76, 0.52), (0.07, 0.86, 0.3)], [0.075, 0.055, 0.035], sides=5, fn=fur_leg, name="tail")
    # coleira de ferro com corrente grossa partida
    ring_tube((0, -0.52, 0.97), 0.19, 0.04, plane="xy", segs=8, fn=iron, name="collar")
    ring_tube((0.0, -0.66, 0.78), 0.08, 0.035, plane="xz", segs=6, fn=iron, name="link")
    ring_tube((0.0, -0.66, 0.63), 0.08, 0.035, plane="yz", segs=6, fn=iron, name="link")


# =============================================================== registro

BUILDERS = {
    "plague_hound": plague_hound,
}


import kb_humanoid  # noqa: E402
BUILDERS.update(kb_humanoid.BUILDERS)


def main():
    argv = sys.argv
    args = argv[argv.index("--") + 1:] if "--" in argv else []
    which = args[0] if args else "all"
    out = args[1] if len(args) > 1 else os.path.join(L.REPO, "assets", "bibiana", "enemies")
    ids = list(BUILDERS) if which == "all" else [which]
    for i in ids:
        L.reset()
        BUILDERS[i]()
        L.export(i, out)


main()
