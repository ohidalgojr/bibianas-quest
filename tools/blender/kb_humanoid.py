# TASK-062: inimigos humanoides do lote 1, modelados de verdade (sem corpos de personagem dos kits).
# Cabecas descarnadas, maos longas, panos rasgados, props de silhueta; Kenney so entra como PROP
# (caixao, pa, lampiao) escurecido. Convencoes de kitbash_lib.
import math
import os

import mathutils
from mathutils import Euler, Vector

import kitbash_lib as L
from kitbash_lib import *  # noqa: F401,F403

K = L.KENNEY
SKIN_L = hexc("#3E4752")


def xf(p, center, rot):
    e = Euler([math.radians(a) for a in rot])
    return Vector(center) + e.to_matrix() @ Vector(p)


def head(center, h=0.5, w=0.36, d=0.42, rot=(0, 0, 0), skin=None, hollow=0.8, name="head"):
    """Cabeca adulta descarnada: faces fundas, testa alta, queixo estreito. Devolve posicoes dos olhos."""
    skin = skin or make_painter(SKIN_L, dark=SKIN_D, light=hexc("#566270"), noise=0.12, seed=31, top=0.2)
    rings = [(0.00, 0.13, 0.17, -0.07), (0.14, 0.24, 0.28, -0.04), (0.34, 0.25 * hollow + 0.06, 0.34, -0.01),
             (0.55, 0.45, 0.46, 0.0), (0.75, 0.47, 0.5, 0.02), (0.92, 0.40, 0.44, 0.04), (1.0, 0.20, 0.26, 0.05)]
    pts = [xf((0, yc * d, (f - 0.5) * h), center, rot) for f, rx, ry, yc in rings]
    tube(pts, [(rx * w, ry * d) for f, rx, ry, yc in rings], sides=8, fn=skin, up=(0, -1, 0), name=name)
    nose = [xf((0, -0.40 * d, 0.0), center, rot), xf((0, -0.60 * d, -0.13 * h), center, rot)]
    tube(nose, [0.09 * w, 0.02 * w], sides=4, fn=skin, up=(1, 0, 0), name="nose")
    dark = make_painter(ABYSS, noise=0.0)
    eyes = []
    for sx in (-1, 1):
        ep = xf((sx * 0.21 * w, -0.455 * d, 0.1 * h), center, rot)
        eyes.append(ep)
        blob(ep, (0.085 * w, 0.045 * d, 0.075 * h), rot=rot, fn=dark, name="socket")
    blob(xf((0, -0.43 * d, -0.26 * h), center, rot), (0.2 * w, 0.04 * d, 0.025 * h), rot=rot, fn=dark, name="mouth")
    return eyes


def hand(wrist, s=0.3, dirv=(0, 0, -1), curl=0.5, fn=None, spread=1.0, name="hand"):
    """Mao longa: palma + 4 dedos grossos curvados + polegar. s ~ comprimento da palma."""
    fn = fn or make_painter(SKIN_L, dark=SKIN_D, light=hexc("#566270"), noise=0.12, seed=41, top=0.15)
    w = Vector(wrist)
    dv = Vector(dirv).normalized()
    side = dv.cross(Vector((0, 1, 0)))
    if side.length < 0.1:
        side = Vector((1, 0, 0))
    side.normalize()
    fwd = Vector((0, -1, 0))
    blob(w + dv * 0.4 * s, (0.5 * s, 0.22 * s, 0.4 * s), fn=fn, name="palm") if False else None
    palm = w + dv * 0.38 * s
    box_c = palm
    blob(box_c, (0.30 * s, 0.17 * s, 0.34 * s), rot=(0, 0, 0), fn=fn, subdiv=1, name="palm")
    for i, off in enumerate((-1.5, -0.5, 0.5, 1.5)):
        base = w + dv * 0.62 * s + side * off * 0.16 * s * spread
        ln = (0.95, 1.1, 1.05, 0.8)[i] * s
        mid = base + dv * 0.55 * ln + fwd * curl * 0.08 * ln
        tip = mid + dv * 0.5 * ln + fwd * curl * 0.35 * ln
        tube([base, mid, tip], [0.14 * s, 0.11 * s, 0.06 * s], sides=4, fn=fn, name="finger")
    tb = w + dv * 0.3 * s + side * 0.34 * s
    tube([tb, tb + side * 0.25 * s + dv * 0.2 * s + fwd * 0.1 * s, tb + side * 0.35 * s + dv * 0.5 * s + fwd * 0.25 * s],
         [0.15 * s, 0.12 * s, 0.06 * s], sides=4, fn=fn, name="thumb")


def limb(pts, radii, fn, sides=6, name="limb"):
    return tube(pts, radii, sides=sides, fn=fn, name=name)


def boot(pos, sx=1, s=1.0, fn=None):
    fn = fn or make_painter(hexc("#2A2520"), noise=0.1, seed=51)
    blob((pos[0], pos[1] - 0.07 * s, pos[2]), (0.1 * s, 0.22 * s, 0.075 * s), fn=fn, jitter=0.05, name="boot")


def shoulder_pad(pos, r, fn):
    blob(pos, r, fn=fn, jitter=0.07, seed=int(abs(pos[0]) * 10) + 3, name="shoulder")


# =============================================================== O COVEIRO


def gravedigger():
    coat = make_painter(hexc("#3A4350"), light=hexc("#5E6B7E"), low=0.6, grime=0.55, noise=0.14, seed=11, top=0.35)
    coat_d = make_painter(hexc("#1C2128"), low=0.5, grime=0.5, noise=0.12, seed=12, top=0.15)
    hat = make_painter(hexc("#262B34"), light=hexc("#4A5462"), noise=0.12, seed=16, top=0.3)
    rope = make_painter(hexc("#6A5C48"), noise=0.2, seed=15)
    for sx in (-1, 1):
        limb([(sx * 0.17, 0.10, 1.05), (sx * 0.2, -0.02, 0.58), (sx * 0.19, 0.06, 0.12)], [0.12, 0.09, 0.075], coat_d, name="leg")
        boot((sx * 0.19, 0.0, 0.07), sx, 1.1)
    # tronco corcunda, ombros largos
    tube([(0, 0.24, 1.0), (0, 0.06, 1.44), (0, -0.22, 1.8)], [(0.25, 0.18), (0.31, 0.22), (0.45, 0.24)], sides=8, fn=coat, name="torso")
    blob((0, 0.2, 1.7), (0.4, 0.28, 0.3), fn=coat, jitter=0.1, seed=5, name="hump")
    for sx in (-1, 1):
        shoulder_pad((sx * 0.5, -0.18, 1.76), (0.21, 0.19, 0.15), coat)
        limb([(sx * 0.5, -0.18, 1.74), (sx * 0.66, -0.26, 1.2), (sx * 0.62, -0.34, 0.66)], [0.11, 0.09, 0.075], coat, name="arm")
        hand((sx * 0.62, -0.34, 0.66), s=0.52, curl=0.6, name="hand")
    limb([(0, -0.24, 1.8), (0, -0.5, 1.88)], [0.11, 0.1], make_painter(SKIN_L, dark=SKIN_D), name="neck")
    eyes = head((0, -0.62, 1.78), h=0.62, w=0.4, d=0.46, rot=(14, 0, 0), name="head")
    # chapeu de aba larga caida
    cloth((0, -0.62, 0), 2.14, 2.0, (0.2, 0.22), (0.56, 0.6), n=12, rows=2, fold=0.05, jag=0.05, seed=17, fn=hat, name="brim")
    tube([(0, -0.58, 2.0), (0, -0.56, 2.38)], [(0.26, 0.28), (0.2, 0.22)], sides=8, fn=hat, up=(0, -1, 0), name="crown")
    # sobretudo longo, rasgado, e capa curta nas costas
    cloth((0, 0.1, 0), 1.72, 0.26, (0.44, 0.3), (0.76, 0.6), n=14, rows=4, fold=0.07, jag=0.22, seed=21, fn=coat, name="coat")
    cloth((0, 0.16, 0), 1.9, 0.9, (0.5, 0.3), (0.66, 0.42), n=10, arc=(100, 260), rows=3, fold=0.05, jag=0.2, seed=22, fn=coat_d, name="mantle")
    # caixao nas costas
    kit(K + "/coffin-old.glb", "coffin-old", loc=(0, 0.6, 1.5), rot=(-66, 0, 0), scale=(2.1, 2.1, 2.1), pivot=(0, 0, 0.1),
        ramp=(hexc("#171310"), hexc("#3A2F24"), hexc("#6A5842")), name="coffin")
    for z0 in (1.15, 1.65):
        tube([(-0.44, -0.12, z0 + 0.15), (0.0, -0.32, z0 - 0.05), (0.44, -0.12, z0 + 0.15)], [0.055] * 3, sides=5, fn=rope, name="rope")
    # pa de lamina larga
    kit(K + "/shovel.glb", "shovel", loc=(0.78, -0.4, 1.0), rot=(-20, 0, 8), scale=(3.6, 3.6, 3.6), pivot=(0, 0, 0.32),
        ramp=(hexc("#100E0A"), hexc("#262A32"), hexc("#444C5A")), name="shovel")
    # lampiao na aba do chapeu: unico foco ambar
    kit(K + "/lantern-glass.glb", "lantern-glass", loc=(0.0, -1.2, 2.02), scale=(1.4, 1.4, 1.4), pivot=(0, 0, 0.2),
        ramp=(IRON, hexc("#34373E"), hexc("#50545E")),
        ember_if=lambda r, g, b: r > 0.7 and g > 0.55 and b < 0.45, name="lamp")


# =============================================================== CARRASCO APODRECIDO


def rotten_executioner():
    flesh = make_painter(hexc("#3E4752"), dark=SKIN_D, light=hexc("#58646F"), noise=0.14, seed=61, top=0.2, low=0.4, grime=0.4)
    apron = make_painter(hexc("#3A3128"), dark=hexc("#14100C"), light=hexc("#5A4A38"), low=0.6, grime=0.5, noise=0.2, seed=62)
    hood = make_painter(hexc("#232A33"), light=hexc("#3A4553"), noise=0.14, seed=63, low=0.5)
    iron = make_painter(hexc("#2E3238"), light=hexc("#555B64"), noise=0.25, seed=64)
    rust = make_painter(hexc("#3A322E"), dark=hexc("#14100E"), light=hexc("#5A4E46"), noise=0.3, seed=65)
    blood = make_painter(BLOOD, dark=ABYSS, noise=0.25, seed=66)
    legcl = make_painter(hexc("#2E3742"), low=0.5, grime=0.5, seed=67)
    for sx in (-1, 1):
        limb([(sx * 0.24, 0.06, 1.05), (sx * 0.28, 0.0, 0.58), (sx * 0.26, 0.04, 0.12)], [0.17, 0.13, 0.1], legcl, sides=7, name="leg")
        boot((sx * 0.26, -0.02, 0.08), sx, 1.5)
    # torso enorme, descarnado, curvado
    tube([(0, 0.2, 1.05), (0, 0.04, 1.5), (0, -0.2, 1.88)], [(0.36, 0.25), (0.5, 0.3), (0.6, 0.3)], sides=8, fn=flesh, name="torso")
    blob((0, 0.24, 1.75), (0.46, 0.3, 0.34), fn=flesh, jitter=0.1, seed=7, name="hump")
    cloth((0, -0.06, 0), 1.36, 0.5, (0.34, 0.26), (0.5, 0.36), n=9, arc=(-70, 70), rows=3, fold=0.04, jag=0.18, seed=68, fn=apron, name="apron")
    tube([(-0.5, 0.0, 1.1), (0, -0.3, 1.04), (0.5, 0.0, 1.1)], [0.06] * 3, sides=5, fn=iron, name="belt")
    for sx in (-1, 1):
        shoulder_pad((sx * 0.66, -0.16, 1.84), (0.25, 0.22, 0.2), flesh)
    # braco esquerdo pendente, mao enorme, algema
    limb([(-0.68, -0.16, 1.8), (-0.82, -0.26, 1.24), (-0.78, -0.4, 0.66)], [0.17, 0.14, 0.12], flesh, name="armL")
    ring_tube((-0.78, -0.4, 0.72), 0.13, 0.045, plane="xy", segs=8, fn=iron, name="manacle")
    hand((-0.78, -0.4, 0.62), s=0.62, curl=0.7, fn=flesh, name="handL")
    # braco direito ergue o machado
    limb([(0.68, -0.16, 1.8), (0.92, -0.42, 1.5), (0.7, -0.62, 1.7)], [0.17, 0.14, 0.12], flesh, name="armR")
    ring_tube((0.7, -0.6, 1.66), 0.12, 0.045, plane="xz", segs=8, fn=iron, name="manacle")
    blob((0.7, -0.64, 1.76), (0.13, 0.13, 0.12), fn=flesh, name="fist")
    # machado de carrasco: cabo grosso, lamina larga em meia-lua com barba
    tube([(0.7, -0.56, 0.9), (0.7, -0.64, 1.76), (0.62, -0.5, 2.36)], [0.075, 0.075, 0.075], sides=6, fn=rust, name="haft")
    prism([(0.0, 0.45), (0.55, 0.62), (0.95, 0.38), (1.08, 0.0), (0.95, -0.55), (0.6, -0.7), (0.0, -0.3), (0.12, 0.05)], 0.16,
          origin=(0.62, -0.5, 1.98), fn=rust, name="blade")
    prism([(0.9, 0.34), (1.08, 0.0), (0.92, -0.52), (0.98, -0.0)], 0.2, origin=(0.62, -0.5, 1.98), fn=iron, name="edge")
    box((0.62, -0.5, 2.18), (0.24, 0.3, 0.3), fn=iron, name="socket")
    blob((0.62, -1.2, 1.85), (0.1, 0.3, 0.2), fn=blood, name="stain")
    # capuz de saco justo na cabeca, ponta caida; fenda ambar
    head((0, -0.6, 1.98), h=0.58, w=0.38, d=0.44, rot=(26, 0, 0), name="head")
    tube([(0, -0.48, 1.72), (0, -0.56, 2.0), (0, -0.62, 2.3), (-0.12, -0.5, 2.5)], [(0.27, 0.28), (0.3, 0.32), (0.27, 0.29), (0.1, 0.1)],
         sides=8, fn=hood, up=(0, -1, 0), name="sack")
    cloth((0, -0.4, 0), 1.84, 1.5, (0.3, 0.3), (0.55, 0.5), n=10, rows=2, fold=0.06, jag=0.12, seed=69, fn=hood, name="collar")
    eye = blob((-0.1, -0.93, 2.06), (0.08, 0.03, 0.04), name="slit")
    set_ember(eye)
    blob((0.12, -0.93, 2.06), (0.08, 0.03, 0.04), fn=make_painter(ABYSS), name="slit2")
    # cinto de cordas e corrente de baixo
    for i, x in enumerate((-0.3, 0.0, 0.3)):
        ring_tube((x, -0.34, 0.9 - 0.1 * i), 0.07, 0.03, plane="xz", segs=6, fn=iron, name="chain")


# =============================================================== TURIFERARIO CEGO


def blind_censer_bearer():
    cass = make_painter(hexc("#323A46"), light=hexc("#4C5766"), dark=hexc("#161B22"), low=0.5, grime=0.5, noise=0.16, seed=71, top=0.25)
    lin = make_painter(hexc("#6A6A5C"), dark=hexc("#2E2E28"), noise=0.18, seed=72, stripes=(3, -9, 9, 0.28, 0.5))
    skin = make_painter(SKIN_L, dark=SKIN_D, noise=0.12, seed=73)
    iron = make_painter(hexc("#3A3F47"), light=hexc("#667080"), dark=hexc("#14171C"), noise=0.25, seed=74)
    rust = make_painter(hexc("#3A322E"), dark=hexc("#14100E"), light=hexc("#5A4E46"), noise=0.3, seed=75)
    cavity = make_painter(hexc("#120C0A"), noise=0.0)
    bone = make_painter(hexc("#6C7480"), dark=SKIN_D, noise=0.1, seed=76)
    for sx in (-1, 1):
        limb([(sx * 0.14, 0.04, 0.95), (sx * 0.16, -0.04, 0.5), (sx * 0.15, 0.04, 0.1)], [0.1, 0.075, 0.065], lin, name="leg")
        blob((sx * 0.15, -0.08, 0.05), (0.09, 0.2, 0.05), fn=skin, name="foot")
    # tronco magro e curvado, peito aberto
    tube([(0, 0.14, 0.95), (0, 0.04, 1.3), (0, -0.14, 1.62)], [(0.2, 0.15), (0.22, 0.17), (0.3, 0.18)], sides=8, fn=cass, name="torso")
    box((0, -0.14, 1.34), (0.34, 0.12, 0.46), fn=cavity, name="cavity")
    for z in (1.18, 1.3, 1.42, 1.54):
        for sx in (-1, 1):
            tube([(sx * 0.2, -0.04, z), (sx * 0.17, -0.2, z + 0.02), (sx * 0.06, -0.24, z + 0.03)], [0.035, 0.035, 0.03], sides=4, fn=bone, name="rib")
    brazier = blob((0, -0.16, 1.36), (0.11, 0.08, 0.15), jitter=0.1, name="coal")
    set_ember(brazier)
    for x in (-0.1, 0.0, 0.1):
        tube([(x, -0.22, 1.2), (x, -0.22, 1.56)], [0.025, 0.025], sides=4, fn=iron, name="cagebar")
    tube([(-0.12, -0.22, 1.56), (0.12, -0.22, 1.56)], [0.03, 0.03], sides=4, fn=iron, name="cagetop")
    # batina rasgada
    cloth((0, 0.04, 0), 1.0, 0.18, (0.24, 0.2), (0.44, 0.36), n=11, rows=3, fold=0.06, jag=0.2, seed=77, fn=cass, name="skirt")
    tube([(-0.28, 0.04, 1.0), (0.0, -0.22, 0.98), (0.28, 0.04, 1.0)], [0.05] * 3, sides=5, fn=lin, name="rope")
    # capuz-capa nos ombros
    cloth((0, -0.04, 0), 1.9, 1.3, (0.12, 0.12), (0.5, 0.36), n=10, arc=(30, 330), rows=3, fold=0.07, jag=0.14, seed=78, fn=cass, name="hood")
    # cabeca com mascara de ferro sem olhos
    head((0, -0.34, 1.82), h=0.42, w=0.3, d=0.34, rot=(22, 0, 0), name="head")
    mc = xf((0, -0.1, 0.0), (0, -0.34, 1.82), (22, 0, 0))
    box((0, -0.58, 1.84), (0.34, 0.1, 0.48), rot=(22, 0, 0), fn=iron, taper=(0.8, 1.0), name="mask")
    box((0, -0.64, 1.86), (0.2, 0.04, 0.05), rot=(22, 0, 0), fn=make_painter(ABYSS), name="slit")
    box((0, -0.55, 1.96), (0.36, 0.14, 0.05), rot=(22, 0, 0), fn=iron, name="band")
    # braco direito longo demais, corrente grossa, turibulo de espinhos
    limb([(0.28, -0.1, 1.58), (0.4, -0.18, 1.08), (0.4, -0.3, 0.46)], [0.08, 0.065, 0.055], cass, name="armR")
    ring_tube((0.4, -0.3, 0.52), 0.1, 0.04, plane="xy", segs=8, fn=iron, name="manacle")
    hand((0.4, -0.3, 0.46), s=0.34, curl=0.8, fn=skin, name="handR")
    limb([(-0.3, -0.1, 1.58), (-0.4, -0.2, 1.1), (-0.3, -0.42, 0.9)], [0.07, 0.06, 0.05], cass, name="armL")
    hand((-0.3, -0.42, 0.92), s=0.3, curl=0.6, fn=skin, name="handL")
    prev = (0.42, -0.4, 0.3)
    links = [(0.42, -0.52, 0.2), (0.42, -0.66, 0.12), (0.42, -0.82, 0.1), (0.42, -0.98, 0.1)]
    for i, p in enumerate(links):
        ring_tube(p, 0.06, 0.03, plane="xz" if i % 2 == 0 else "yz", segs=6, fn=iron, name="link")
    ball = (0.42, -1.2, 0.2)
    blob(ball, (0.19, 0.19, 0.19), fn=rust, jitter=0.06, name="censer")
    for d in ((1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0.7, 0.7, 0.4), (-0.7, -0.7, 0.4), (0.7, -0.7, 0.4), (-0.7, 0.7, 0.4)):
        v = Vector(d).normalized()
        spike(Vector(ball) + v * 0.15, Vector(ball) + v * 0.34, 0.06, sides=4, fn=iron, name="spine")


# =============================================================== MEDICO DA CERA


def wax_physician():
    cape = make_painter(hexc("#2C3440"), light=hexc("#485464"), dark=hexc("#12161C"), low=0.5, grime=0.5, noise=0.16, seed=81, top=0.3)
    cape_d = make_painter(hexc("#1E242C"), noise=0.14, seed=82, low=0.5)
    wax = make_painter(hexc("#54544A"), dark=hexc("#2C2C26"), light=hexc("#6A6A5C"), noise=0.14, seed=83, top=0.4)
    leather = make_painter(hexc("#3A322C"), dark=hexc("#16120E"), light=hexc("#544A40"), noise=0.2, seed=84)
    brass = make_painter(hexc("#463E2A"), dark=hexc("#181410"), light=hexc("#645A3E"), noise=0.2, seed=85)
    steel = make_painter(hexc("#5A6472"), dark=hexc("#22262C"), light=hexc("#8494AA"), noise=0.25, seed=86)
    glove = make_painter(hexc("#3E3226"), dark=hexc("#16100A"), noise=0.18, seed=87)
    wick = make_painter(hexc("#1A1410"), noise=0.0)
    for sx in (-1, 1):
        limb([(sx * 0.15, 0.2, 0.95), (sx * 0.17, 0.08, 0.5), (sx * 0.16, 0.14, 0.1)], [0.1, 0.075, 0.065], cape_d, name="leg")
        boot((sx * 0.16, 0.06, 0.07), sx, 1.0, fn=leather)
    # coluna muito curvada: ombros a frente do quadril
    tube([(0, 0.3, 0.95), (0, 0.05, 1.3), (0, -0.28, 1.5)], [(0.2, 0.16), (0.28, 0.2), (0.36, 0.22)], sides=8, fn=cape, name="torso")
    # capa larga com barra rasgada
    cloth((0, 0.14, 0), 1.58, 0.2, (0.5, 0.36), (0.82, 0.62), n=14, rows=4, fold=0.08, jag=0.22, seed=88, fn=cape, name="cape")
    cloth((0, -0.1, 0), 1.72, 1.1, (0.46, 0.34), (0.72, 0.56), n=12, rows=2, fold=0.06, jag=0.18, seed=89, fn=cape_d, name="cape2")
    # cupula de cera derretida sobre os ombros, com escorridos
    blob((0, -0.02, 1.66), (0.66, 0.5, 0.3), fn=wax, jitter=0.07, seed=12, name="waxcap")
    drips = [(-0.6, -0.1, 0.5), (-0.45, -0.38, 0.38), (-0.2, -0.46, 0.55), (0.2, -0.46, 0.34), (0.46, -0.38, 0.5), (0.62, -0.08, 0.42),
             (0.5, 0.3, 0.46), (0.0, 0.46, 0.52), (-0.5, 0.3, 0.4), (-0.64, -0.22, 0.28), (0.64, -0.22, 0.3)]
    for i, (x, y, ln) in enumerate(drips):
        spike((x, y, 1.62), (x * 1.04, y * 1.04, 1.62 - ln), 0.07, sides=5, fn=wax, name="drip")
    # coroa de velas grossas, so uma acesa
    candles = [(-0.4, -0.1, 0.26), (-0.22, -0.32, 0.4), (0.0, -0.1, 0.62), (0.24, -0.3, 0.32), (0.42, -0.06, 0.28), (-0.2, 0.2, 0.34),
               (0.2, 0.22, 0.3), (0.0, -0.36, 0.22), (-0.5, 0.1, 0.18), (0.5, 0.14, 0.2)]
    for i, (x, y, hh) in enumerate(candles):
        z0 = 1.84 - 0.1 * (abs(x) + abs(y))
        hh = hh * 0.75
        tube([(x, y, z0), (x, y, z0 + hh)], [0.065, 0.06], sides=6, fn=wax, name="candle")
        if i == 2:
            fl = tube([(x, y, z0 + hh), (x, y, z0 + hh + 0.12), (x, y, z0 + hh + 0.26)], [0.06, 0.05, 0.0], sides=5, name="flame")
            set_ember(fl)
        else:
            blob((x, y, z0 + hh + 0.01), (0.04, 0.04, 0.02), fn=wick, name="wick")
    # cabeca de bico: mascara de couro rachada
    head((0, -0.42, 1.62), h=0.36, w=0.28, d=0.3, rot=(30, 0, 0), name="head")
    tube([(0, -0.54, 1.66), (0, -0.82, 1.52), (0, -1.02, 1.28)], [(0.1, 0.1), (0.07, 0.07), (0.015, 0.015)], sides=5, fn=leather, up=(1, 0, 0), name="beak")
    blob((0, -0.5, 1.72), (0.18, 0.12, 0.17), fn=leather, jitter=0.05, name="mask")
    for sx in (-1, 1):
        ring_tube((sx * 0.08, -0.6, 1.72), 0.05, 0.025, plane="xz", segs=6, fn=brass, name="lens")
    # braco direito: seringa-serra de latao
    limb([(0.4, -0.2, 1.46), (0.52, -0.36, 1.1), (0.4, -0.5, 0.86)], [0.1, 0.085, 0.075], cape, name="armR")
    hand((0.4, -0.5, 0.86), s=0.32, curl=0.9, fn=glove, dirv=(0, -0.6, -0.8), name="handR")
    tube([(0.38, -0.46, 0.92), (0.3, -1.0, 0.56)], [0.09, 0.09], sides=6, fn=brass, name="barrel")
    tube([(0.3, -1.0, 0.56), (0.24, -1.5, 0.3)], [0.045, 0.04], sides=5, fn=steel, name="needle")
    box((0.26, -1.4, 0.24), (0.08, 0.9, 0.17), rot=(-20, 0, 0), fn=steel, name="blade")
    for i in range(6):
        t = i / 5.0
        spike((0.26, -1.0 - 0.8 * t, 0.2 - 0.2 * t - 0.05 + 0.08), (0.26, -1.0 - 0.8 * t - 0.02, 0.2 - 0.2 * t - 0.2 + 0.08), 0.055, sides=3, fn=steel, name="tooth")
    # braco esquerdo caido, dedos longos
    limb([(-0.4, -0.2, 1.46), (-0.52, -0.2, 1.0), (-0.46, -0.3, 0.55)], [0.1, 0.085, 0.07], cape, name="armL")
    hand((-0.46, -0.3, 0.55), s=0.36, curl=0.6, fn=glove, name="handL")


# =============================================================== RASTEJADOR DA VALA


def trench_crawler():
    skin = make_painter(hexc("#3E464F"), dark=hexc("#20252B"), light=hexc("#566270"), noise=0.14, seed=91, top=0.2,
                        stripes=(3, -9, 9, 0.22, 0.6, hexc("#4E4C3E")))
    skin_d = make_painter(hexc("#3E454F"), dark=hexc("#1C2026"), noise=0.14, seed=92)
    rag = make_painter(hexc("#4A4A3E"), dark=hexc("#1E1E18"), low=0.2, noise=0.2, seed=93)
    wood = make_painter(hexc("#4A3C2E"), dark=hexc("#1A130D"), light=hexc("#6A5642"), noise=0.3, seed=94)
    iron = make_painter(hexc("#2E3238"), light=hexc("#4A5058"), noise=0.25, seed=95)
    bandf = skin
    # coluna em ponte invertida: barriga para cima
    tube([(0, 0.55, 0.78), (0, 0.15, 1.0), (0, -0.3, 0.92), (0, -0.52, 0.72)], [(0.2, 0.17), (0.25, 0.2), (0.27, 0.2), (0.2, 0.17)], sides=7, fn=skin, name="spine")
    for sx in (-1, 1):
        # bracos: ombro baixo, cotovelo alto, mao no chao
        limb([(sx * 0.26, -0.44, 0.82), (sx * 0.62, -0.6, 1.0), (sx * 0.6, -1.0, 0.1)], [0.14, 0.105, 0.085], skin, name="arm")
        hand((sx * 0.6, -1.0, 0.12), s=0.34, dirv=(0, -0.9, -0.3), curl=0.2, spread=1.4, fn=skin_d, name="hand")
        # pernas viradas ao contrario
        limb([(sx * 0.22, 0.52, 0.8), (sx * 0.6, 0.62, 1.05), (sx * 0.52, 1.02, 0.1)], [0.16, 0.115, 0.09], skin, name="leg")
        hand((sx * 0.52, 1.04, 0.08), s=0.32, dirv=(0, -0.8, -0.4), curl=0.2, spread=1.3, fn=skin_d, name="foot")
    cloth((0, 0.5, 0), 0.82, 0.3, (0.2, 0.18), (0.3, 0.26), n=8, arc=(130, 230), rows=2, fold=0.05, jag=0.16, seed=96, fn=rag, name="loin")
    # cabeca pendurada de ponta-cabeca entre os bracos
    tube([(0, -0.5, 0.78), (0, -0.62, 0.55)], [0.09, 0.08], sides=5, fn=skin, name="neck")
    eyes = head((0, -0.68, 0.36), h=0.52, w=0.36, d=0.42, rot=(10, 180, 0), name="head")
    # tampa podre de caixao presa as costas, inclinada
    kit(K + "/coffin-old.glb", "coffin-old", loc=(0, 0.1, 1.2), rot=(8, 0, 4), scale=(1.7, 1.55, 1.7), pivot=(0, 0, 0.0),
        ramp=(hexc("#0E0C0A"), hexc("#2A241E"), hexc("#4A4036")), name="coffin")
    for y in (-0.2, 0.3):
        tube([(-0.7, y, 1.25), (0.0, y, 1.5), (0.7, y, 1.25)], [0.05] * 3, sides=5, fn=iron, name="band")
        tube([(-0.7, y, 1.25), (-0.5, y + 0.02, 0.85)], [0.05, 0.05], sides=5, fn=iron, name="strap")
        tube([(0.7, y, 1.25), (0.5, y + 0.02, 0.85)], [0.05, 0.05], sides=5, fn=iron, name="strap")
    for i, (x, y) in enumerate(((-0.5, 0.6), (0.4, 0.65), (0.1, -0.55))):
        spike((x, y, 1.2), (x + 0.25, y + 0.15, 1.7 + 0.1 * i), 0.07, sides=4, fn=wood, name="splinter")
    glow = box((0.0, 0.1, 1.44), (0.55, 0.12, 0.07), rot=(8, 0, 4), name="crack")
    set_ember(glow)


BUILDERS = {
    "gravedigger": gravedigger,
    "rotten_executioner": rotten_executioner,
    "blind_censer_bearer": blind_censer_bearer,
    "wax_physician": wax_physician,
    "trench_crawler": trench_crawler,
}
