# O Turiferario Cego (TASK-057, ficha ENEMY-15): padre de mascara de ferro sem olhos, peito-forno
# aceso e um turibulo de espinhos preso por corrente ao braco longo. Convencoes de make_horrors.py
# (olha para -Y, ~1,95 m, flat shading, .glb). Revisado apos critica (v2). Uso:
#   blender -b -P tools/blender/make_censer.py -- <pasta de saida>
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kit import *  # noqa: E402,F401
from make_horrors import rod, claw  # noqa: E402
import bpy  # noqa: E402
import mathutils  # noqa: E402

PI = math.pi


def taper(a, b, r1, r2, material, verts=6):
    """Membro cônico (grosso no ombro, fino no punho)."""
    va, vb = mathutils.Vector(a), mathutils.Vector(b)
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=(vb - va).length, location=(va + vb) / 2.0)
    obj = bpy.context.active_object
    obj.rotation_euler = (va - vb).to_track_quat("Z", "Y").to_euler()
    return finish(obj, material)


def blind_censer_bearer():
    cassock = mat("cs_cassock", (0.21, 0.23, 0.27), 0.92)
    linen = mat("cs_linen", (0.61, 0.57, 0.48), 0.95)
    skin = mat("cs_skin", (0.42, 0.4, 0.37), 0.85)
    iron = mat("cs_iron", (0.29, 0.23, 0.2), 0.65)
    brass = mat("cs_brass", (0.55, 0.43, 0.2), 0.48)
    ember = mat("cs_ember", (1.0, 0.36, 0.06), 0.3, 5.0)
    dark = mat("cs_dark", (0.01, 0.01, 0.015))

    # Pernas enfaixadas bem visiveis (x +-0.13) e pes.
    for sx in (-1, 1):
        cube((sx * 0.13, -0.06, 0.035), (0, 0, 0), (0.08, 0.15, 0.06), skin)
        rod((sx * 0.13, 0.0, 0.07), (sx * 0.13, 0.0, 0.62), 0.06, skin, verts=6)
        for z in (0.14, 0.23, 0.32, 0.41, 0.5):
            cylinder((sx * 0.13, 0.0, z), (0, 0, 0), (0.075, 0.075, 0.03), linen, verts=6)

    # Batina: cone mais estreito, com 14 linguas de pano rasgadas de comprimentos desiguais.
    cone((0, 0.02, 0.8), (0, 0, 0), (0.3, 0.26, 0.4), cassock, verts=12, r1=1.0, r2=0.62, depth=1.0)
    tongues = 9
    for i in range(tongues):
        a = i / tongues * math.tau
        length = 0.2 + 0.14 * (((i * 5) % 4) / 3.0)
        top_z = 0.62
        bottom = top_z - length
        cone((math.cos(a) * 0.29, 0.02 + math.sin(a) * 0.25, (top_z + bottom) / 2), (PI, 0, a + PI / 2), (0.17, 0.025, length), cassock, verts=3, r1=1.0, r2=0.0, depth=1.0)
    cylinder((0, 0.0, 1.0), (0, 0, 0), (0.2, 0.17, 0.04), linen, verts=10)  # cinto de corda

    # Tronco-forno: peito largo, caverna escura, costelas arqueadas, espinha, brasa grande.
    cube((0, 0.1, 1.25), (0, 0, 0), (0.36, 0.1, 0.52), cassock)  # costas
    cube((0, 0.0, 1.5), (0, 0, 0), (0.5, 0.18, 0.08), cassock)  # ombros estreitos
    for sx in (-1, 1):
        sphere((sx * 0.27, -0.01, 1.5), (0.1, 0.09, 0.08), cassock)
    cube((0, -0.0, 1.22), (0, 0, 0), (0.3, 0.16, 0.48), dark)  # cavidade
    for z in (1.0, 1.06):
        pass
    sphere((0, -0.05, 1.25), (0.12, 0.1, 0.13), ember)
    rod((0, 0.05, 1.0), (0, 0.05, 1.48), 0.02, skin, verts=4)  # espinha
    cube((0, -0.2, 1.3), (0, 0, 0), (0.03, 0.025, 0.3), skin)  # esterno
    for i in range(5):
        z = 1.02 + i * 0.095
        w = 0.19 - 0.012 * abs(i - 2)
        for sx in (-1, 1):
            rod((sx * 0.04, 0.05, z), (sx * (w + 0.04), -0.08, z - 0.01), 0.019, skin, verts=4)
            rod((sx * (w + 0.04), -0.08, z - 0.01), (sx * 0.04, -0.2, z - 0.03), 0.019, skin, verts=4)
    for x in (-0.11, 0.11):
        rod((x, -0.22, 1.0), (x, -0.22, 1.46), 0.014, iron, verts=4)
    for z in (1.0, 1.46):
        cube((0, -0.22, z), (0, 0, 0), (0.26, 0.03, 0.03), iron)
    for k, x in enumerate((-0.07, 0.0, 0.08, 0.03)):
        sphere((x, -0.15, 1.55 + 0.035 * k), (0.017, 0.017, 0.017), ember)

    # Cabeca alta, estreita e inclinada para a frente; placa lisa sem furos e sem cruz.
    cylinder((0, -0.02, 1.58), (0, 0, 0), (0.1, 0.1, 0.1), skin, verts=6)  # pescoco longo
    cone((0, 0.07, 1.4), (0, 0, 0), (0.3, 0.14, 0.34), cassock, verts=6, r1=1.0, r2=0.4, depth=1.0)  # capuz caido nas costas
    cone((0, 0.03, 1.8), (0, 0, 0), (0.17, 0.2, 0.3), cassock, verts=8, r1=1.0, r2=0.62, depth=1.0)  # capuz alto sobre o cranio
    cone((0, 0.12, 1.1), (0, 0, 0), (0.18, 0.05, 0.3), cassock, verts=4, r1=1.0, r2=0.1, depth=1.0)  # cauda do capuz
    sphere((0, -0.05, 1.77), (0.12, 0.14, 0.2), iron, sub=2)
    cube((0, -0.17, 1.75), (0.14, 0, 0), (0.14, 0.04, 0.3), iron)
    cube((0, -0.2, 1.75), (0.14, 0, 0), (0.014, 0.012, 0.26), dark)  # solda vertical
    cube((0, -0.12, 1.79), (0, 0, 0), (0.2, 0.26, 0.045), linen)  # venda de pano sobre os olhos
    for a in range(6):
        t = a / 6.0 * math.tau
        sphere((math.cos(t) * 0.062, -0.2, 1.75 + math.sin(t) * 0.12), (0.014, 0.014, 0.014), brass)
    cone((0, -0.05, 1.96), (0, 0, 0), (0.035, 0.035, 0.07), iron, verts=4, r1=1.0, r2=0.0, depth=1.0)

    # Braco normal (+X): fino, enfaixado, mao aberta.
    taper((0.27, -0.02, 1.5), (0.36, -0.1, 1.12), 0.04, 0.026, skin)
    rod((0.36, -0.1, 1.12), (0.31, -0.27, 0.92), 0.024, skin, verts=6)
    for z in (1.06, 1.0):
        cylinder((0.355, -0.11, z), (0, 0, 0), (0.045, 0.045, 0.03), linen, verts=6)
    for k in (-0.035, 0.0, 0.035):
        claw((0.31 + k, -0.27, 0.92), (k * 3, -0.3, -1.0), 0.16, linen)

    # Braco longo (-X): grosso no ombro, fino no punho, algema pesada; corrente grossa com sag.
    sh, el, wr = (-0.27, -0.02, 1.5), (-0.4, -0.1, 1.05), (-0.46, -0.2, 0.52)
    taper(sh, el, 0.055, 0.03, skin)
    taper(el, wr, 0.03, 0.022, skin)
    cylinder((-0.45, -0.19, 0.6), (0.2, 0, 0.1), (0.08, 0.08, 0.08), iron, verts=6)
    sphere(wr, (0.04, 0.04, 0.04), skin)
    top = mathutils.Vector((-0.78, -0.46, 0.76))
    start = mathutils.Vector((wr[0], wr[1], wr[2] - 0.04))
    links = 8
    for i in range(links):
        t = i / (links - 1)
        p = start.lerp(top, t)
        p.z -= 0.03 * math.sin(t * PI)
        rot = (0.0, 0.0, 0.0) if i % 2 == 0 else (0.0, PI / 2, 0.0)
        cube((p.x, p.y, p.z), rot, (0.06, 0.03, 0.075), iron)

    # Turibulo grande (0,45 x 0,5) pendurado acima do chao, espinhos longos e brasa nas frestas.
    cx, cy, cz = -0.78, -0.46, 0.5
    cone((cx, cy, cz - 0.12), (PI, 0, 0), (0.22, 0.22, 0.24), brass, verts=8, r1=1.0, r2=0.0, depth=1.0)
    cone((cx, cy, cz + 0.12), (0, 0, 0), (0.22, 0.22, 0.24), brass, verts=8, r1=1.0, r2=0.4, depth=1.0)
    cylinder((cx, cy, cz), (0, 0, 0), (0.235, 0.235, 0.045), iron, verts=8)
    for i in range(8):
        a = i / 8.0 * math.tau
        d = mathutils.Vector((math.cos(a), math.sin(a), 0.0))
        loc = (cx + d.x * 0.31, cy + d.y * 0.31, cz)
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.045, radius2=0.0, depth=0.2, location=loc)
        spike = bpy.context.active_object
        spike.rotation_euler = d.to_track_quat("Z", "Y").to_euler()
        finish(spike, iron)
    for i in range(8):
        a = i / 8.0 * math.tau
        cube((cx + math.cos(a) * 0.13, cy + math.sin(a) * 0.13, cz + 0.2), (0, 0, a), (0.12, 0.025, 0.05), ember)
    sphere((cx, cy, cz + 0.33), (0.045, 0.045, 0.045), iron)
    export("blind_censer_bearer", OUT)


if __name__ == "__main__":
    argv = sys.argv
    OUT = argv[argv.index("--") + 1] if "--" in argv else os.getcwd()
    os.makedirs(OUT, exist_ok=True)
    clear()
    blind_censer_bearer()
