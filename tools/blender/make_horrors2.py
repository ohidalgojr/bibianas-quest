# MÃ©dico da Cera e Rastejador da Vala (TASK-058, fichas ENEMY-16 e ENEMY-17, estudo da TASK-051).
# Mesmas convencoes de make_horrors.py (olha para -Y, flat shading, .glb). Uso:
#   blender -b -P tools/blender/make_horrors2.py -- <pasta de saida>
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kit import *  # noqa: E402,F401
from make_horrors import rod, claw  # noqa: E402
from make_censer import taper  # noqa: E402
import bpy  # noqa: E402
import mathutils  # noqa: E402

PI = math.pi


def hexc(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))


def wax_physician():
    slate = mat("wx_slate", hexc("46525C"), 0.9)
    leather = mat("wx_leather", hexc("332E2B"), 0.72)
    wax = mat("wx_wax", hexc("B5A578"), 0.42)
    brass = mat("wx_brass", hexc("8A7240"), 0.4)
    steel = mat("wx_steel", hexc("707880"), 0.4)
    flame = mat("wx_flame", hexc("FFA938"), 0.3, 6.0)
    dark = mat("wx_dark", (0.01, 0.01, 0.012))

    # Botas e perneiras.
    for sx in (-1, 1):
        cube((sx * 0.12, -0.07, 0.07), (0, 0, 0), (0.12, 0.26, 0.14), leather)
        taper((sx * 0.12, 0.0, 0.14), (sx * 0.13, 0.03, 0.72), 0.06, 0.08, leather)
    # Casaco com linguas na barra.
    cone((0, 0.08, 0.9), (0.08, 0, 0), (0.34, 0.3, 0.9), slate, verts=10, r1=1.0, r2=0.66, depth=1.0)
    for i in range(9):
        a_ = i / 9.0 * math.tau
        length = 0.14 + 0.1 * ((i * 5) % 3) / 2.0
        cone((math.cos(a_) * 0.34, 0.08 + math.sin(a_) * 0.3, 0.45 - length / 2), (PI, 0, a_ + PI / 2), (0.17, 0.025, length), slate, verts=3, r1=1.0, r2=0.0, depth=1.0)
    cylinder((0, 0.05, 0.92), (0, 0, 0), (0.26, 0.22, 0.04), leather, verts=10)
    # Corcunda: torso projetado para a frente, giba alta atras.
    sphere((0, 0.04, 1.36), (0.34, 0.3, 0.28), slate, sub=2)
    sphere((0, 0.3, 1.58), (0.3, 0.26, 0.28), slate, sub=2)
    # Manto de cera derretida: capuz de cera mais largo que os ombros e 6 linguas de pingo.
    sphere((0, 0.16, 1.56), (0.38, 0.32, 0.15), wax, sub=2)
    drips = ((-0.38, 0.0, 0.38), (0.4, 0.04, 0.3), (-0.18, -0.2, 0.26), (0.14, -0.22, 0.34), (-0.3, 0.28, 0.4), (0.3, 0.3, 0.28))
    for x, y, length in drips:
        cone((x, y, 1.6 - length / 2), (PI, 0, 0), (0.07, 0.05, length), wax, verts=5, r1=1.0, r2=0.12, depth=1.0)
    # Velas: 4 grupos baixos e grossos, poca de cera, gota e chama.
    clusters = ((-0.3, 0.06), (0.3, 0.08), (0.0, 0.34), (-0.12, 0.14))
    n = 0
    for cx, cy in clusters:
        count = 4 if (cx, cy) == (0.0, 0.34) else 3
        for k in range(count):
            a_ = k * 2.1 + cx * 5
            x, y = cx + math.cos(a_) * 0.075, cy + math.sin(a_) * 0.06
            h = 0.12 + 0.08 * ((n * 3) % 3) / 2.0
            base = 1.84 if (cx, cy) == (0.0, 0.34) else 1.7
            cylinder((x, y, base - 0.02), (0, 0, 0), (0.1, 0.1, 0.03), wax, verts=7)
            cylinder((x, y, base + h / 2), (math.sin(a_) * 0.12, 0.0, 0), (0.055, 0.055, h), wax, verts=6)
            cone((x + 0.04, y, base + h / 2 - 0.02), (PI, 0, 0), (0.025, 0.025, 0.08), wax, verts=3, r1=1.0, r2=0.1, depth=1.0)
            cone((x, y, base + h + 0.03), (0, 0, 0), (0.04, 0.04, 0.07), flame, verts=4, r1=1.0, r2=0.0, depth=1.0)
            n += 1
    # Cabeca caida para a frente: capuz, bico longo curvo e rachado, oculos de latao.
    sphere((0, -0.24, 1.44), (0.15, 0.16, 0.17), leather, sub=2)
    cone((0, -0.46, 1.36), (PI / 2 + 0.34, 0, 0), (0.08, 0.08, 0.38), leather, verts=6, r1=1.0, r2=0.0, depth=1.0)
    for sx in (-1, 1):
        cylinder((sx * 0.07, -0.355, 1.47), (PI / 2, 0, 0), (0.05, 0.05, 0.035), brass, verts=8)
        sphere((sx * 0.07, -0.375, 1.47), (0.034, 0.02, 0.034), dark)
    sphere((0.03, -0.32, 1.57), (0.06, 0.05, 0.05), wax)
    cube((-0.03, -0.42, 1.34), (0.3, 0, 0.2), (0.012, 0.1, 0.012), dark)
    # Bracos: direito pendente, esquerdo com a seringa-serra.
    taper((0.34, 0.1, 1.5), (0.44, -0.04, 1.08), 0.07, 0.045, slate)
    taper((0.44, -0.04, 1.08), (0.36, -0.18, 0.8), 0.045, 0.04, slate)
    cube((0.35, -0.2, 0.74), (0, 0, 0), (0.08, 0.08, 0.1), leather)
    taper((-0.34, 0.06, 1.5), (-0.46, -0.14, 1.1), 0.07, 0.045, slate)
    taper((-0.46, -0.14, 1.1), (-0.36, -0.32, 0.9), 0.045, 0.04, slate)
    cube((-0.35, -0.34, 0.88), (0, 0, 0), (0.09, 0.09, 0.1), leather)
    # Seringa-serra: corpo de latao grosso inclinado, flange, anel do embolo, agulha, serra na frente.
    top, bot = (-0.35, -0.38, 1.02), (-0.35, -0.64, 0.58)
    rod(top, bot, 0.07, brass, verts=8)
    cylinder((-0.35, -0.38, 1.02), (0.5, 0, 0), (0.12, 0.05, 0.03), brass, verts=8)
    rod((-0.35, -0.35, 1.08), (-0.35, -0.37, 1.2), 0.02, steel, verts=4)
    cylinder((-0.35, -0.37, 1.22), (0.5, 0, 0), (0.07, 0.07, 0.025), steel, verts=8)
    rod(bot, (-0.35, -0.76, 0.36), 0.015, steel, verts=4)
    rod((-0.35, -0.44, 1.0), (-0.35, -0.7, 0.55), 0.02, steel, verts=4)
    for k in range(6):
        t = k / 5.0
        p = mathutils.Vector((-0.35, -0.5 - 0.24 * t, 0.98 - 0.43 * t))
        cone((p.x, p.y, p.z), (PI / 2, 0, 0), (0.032, 0.032, 0.07), steel, verts=3, r1=1.0, r2=0.0, depth=1.0)
    export("wax_physician", OUT)


def trench_crawler():
    wood = mat("tc_wood", hexc("45392C"), 0.94)
    strap = mat("tc_strap", hexc("3E3430"), 0.68)
    rags = mat("tc_rags", hexc("6B675D"), 0.95)
    flesh = mat("tc_flesh", hexc("78726B"), 0.8)
    eye = mat("tc_eye", hexc("EDEBD8"), 0.3, 4.5)
    dark = mat("tc_dark", (0.01, 0.01, 0.012))

    # Arco invertido: pelve baixa atras, apice alto no meio, peito baixo na frente; costelas.
    spine = [(0, 0.66, 0.82), (0, 0.42, 1.04), (0, 0.15, 1.2), (0, -0.12, 1.2), (0, -0.36, 1.04), (0, -0.54, 0.84)]
    for i in range(len(spine) - 1):
        rod(spine[i], spine[i + 1], 0.07, flesh, verts=6)
    for pt in spine:
        sphere(pt, (0.085, 0.085, 0.085), flesh)
    for i in range(1, 5):
        pt = spine[i]
        for sx in (-1, 1):
            rod((sx * 0.02, pt[1], pt[2] - 0.03), (sx * 0.17, pt[1], pt[2] - 0.18), 0.02, rags, verts=4)
            rod((sx * 0.17, pt[1], pt[2] - 0.18), (sx * 0.04, pt[1], pt[2] - 0.34), 0.02, rags, verts=4)
    sphere((0, 0.7, 0.8), (0.15, 0.15, 0.13), flesh)
    # Pernas de aranha: joelho bem acima do corpo, segmentos distais longos e finos.
    limbs = (
        ((0.15, -0.44, 0.88), (0.6, -0.5, 1.45), (0.52, -0.7, 0.03)),
        ((0.15, 0.58, 0.84), (0.58, 0.6, 1.4), (0.46, 0.76, 0.03)),
    )
    for sx in (-1, 1):
        for sh, kn, ft in limbs:
            a_ = (sx * sh[0], sh[1], sh[2])
            b_ = (sx * kn[0], kn[1], kn[2])
            c_ = (sx * ft[0], ft[1], ft[2])
            taper(a_, b_, 0.05, 0.03, flesh)
            taper(b_, c_, 0.03, 0.016, flesh)
            sphere(b_, (0.05, 0.05, 0.05), flesh)
            for t in (0.3, 0.5, 0.7):
                q = mathutils.Vector(b_).lerp(mathutils.Vector(c_), t)
                cylinder((q.x, q.y, q.z), (0, 0, 0), (0.036, 0.036, 0.03), rags, verts=6)
            for k in (-0.03, 0.0, 0.03):
                claw((c_[0] + k, c_[1], c_[2] + 0.02), (k * 3, -0.2, -1.0), 0.14, rags)
    # Tampa de caixao hexagonal, torta e deslocada, com crista central e quinas quebradas.
    cylinder((0.1, 0.06, 1.44), (0, 0.26, PI / 2), (0.64, 0.29, 0.1), wood, verts=6)
    cylinder((0.1, 0.06, 1.5), (0, 0.26, PI / 2), (0.5, 0.1, 0.1), wood, verts=6)
    cone((0.34, 0.5, 1.4), (0.2, 0.9, 0), (0.08, 0.2, 0.1), wood, verts=3, r1=1.0, r2=0.0, depth=1.0)
    cone((-0.22, -0.52, 1.5), (-1.2, 0.3, 0), (0.07, 0.16, 0.1), wood, verts=3, r1=1.0, r2=0.0, depth=1.0)
    for y in (-0.22, 0.3):
        cylinder((0.1, y, 1.42), (0, 0.26, 0), (0.33, 0.06, 0.2), strap, verts=4)
        sphere((0.4, y - 0.04, 1.47), (0.025, 0.025, 0.025), rags)
        rod((0.3, y, 1.36), (0.3, y, 1.1), 0.015, strap, verts=4)
        rod((-0.12, y, 1.36), (-0.12, y, 1.1), 0.015, strap, verts=4)
    cube((0.4, 0.42, 1.2), (0, 0, 0.3), (0.04, 0.04, 0.22), strap)
    # Cabeca grande de cabeca para baixo sob o peito, mandibula frouxa, olhos palidos para -Y.
    rod((0, -0.5, 0.86), (0, -0.44, 0.7), 0.04, flesh, verts=5)
    sphere((0, -0.44, 0.54), (0.16, 0.17, 0.2), flesh, sub=2)
    cube((0, -0.5, 0.74), (0.2, 0, 0), (0.12, 0.1, 0.12), flesh)
    for sx in (-1, 1):
        sphere((sx * 0.065, -0.595, 0.58), (0.03, 0.02, 0.035), eye)
    cube((0, -0.605, 0.44), (0, 0, 0), (0.08, 0.014, 0.04), dark)
    for i in range(7):
        a_ = i / 7.0 * math.tau
        cone((math.cos(a_) * 0.1, -0.44 + math.sin(a_) * 0.1, 0.32), (PI, 0, 0), (0.016, 0.016, 0.14 + 0.06 * (i % 3)), rags, verts=3, r1=1.0, r2=0.0, depth=1.0)
    export("trench_crawler", OUT)


if __name__ == "__main__":
    argv = sys.argv
    OUT = argv[argv.index("--") + 1] if "--" in argv else os.getcwd()
    os.makedirs(OUT, exist_ok=True)
    for build in (wax_physician, trench_crawler):
        clear()
        build()


