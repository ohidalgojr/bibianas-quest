# Criaturas de horror do cenario 1 (TASK-047): silhuetas erradas, membros demais, olhos que brilham.
# Uso (Blender 4.x ou 5.x, sem janela):
#   blender -b -P tools/blender/make_horrors.py -- <pasta de saida>
# Mesmas convencoes de make_enemies.py (olham para -Y no Blender, saem em .glb, CC0).
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from kit import *  # noqa: E402,F401
import bpy  # noqa: E402
import mathutils  # noqa: E402


def rod(a, b, radius, material, verts=5):
    """Cilindro fino entre dois pontos (membros, ossos, correntes)."""
    va, vb = mathutils.Vector(a), mathutils.Vector(b)
    length = (vb - va).length
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=length, location=(va + vb) / 2.0)
    obj = bpy.context.active_object
    obj.rotation_euler = (vb - va).to_track_quat("Z", "Y").to_euler()
    return finish(obj, material)


def claw(base, direction, length, material):
    d = mathutils.Vector(direction).normalized()
    start = mathutils.Vector(base)
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.018, radius2=0.0, depth=length, location=start + d * (length / 2.0))
    obj = bpy.context.active_object
    obj.rotation_euler = d.to_track_quat("Z", "Y").to_euler()
    return finish(obj, material)


def bell_ghost():
    shroud = mat("gh_shroud", (0.16, 0.2, 0.27), 0.9)
    pale = mat("gh_bone", (0.78, 0.8, 0.76))
    dark = mat("gh_dark", (0.02, 0.02, 0.03))
    glow = mat("gh_glow", (0.5, 0.85, 1.0), 0.3, 4.0)
    bronze = mat("gh_bronze", (0.62, 0.45, 0.18), 0.4)
    cone((0, 0, 0.7), (0, 0, 0), (0.5, 0.42, 1.3), shroud, verts=9, r1=1.0, r2=0.22, depth=1.0)
    for i in range(9):
        a = i / 9.0 * math.tau
        cone((math.cos(a) * 0.46, math.sin(a) * 0.4, 0.14), (math.pi, 0, 0), (0.07, 0.07, 0.5 + 0.2 * (i % 3)), shroud, verts=4, r1=1.0, r2=0.0, depth=1.0)
    cone((0, 0.02, 1.48), (0, 0, 0), (0.22, 0.24, 0.34), shroud, verts=8, r1=1.0, r2=0.1, depth=1.0)
    sphere((0, -0.1, 1.36), (0.13, 0.12, 0.15), pale)
    for sx in (-1, 1):
        sphere((sx * 0.055, -0.2, 1.4), (0.045, 0.03, 0.06), dark)
        sphere((sx * 0.055, -0.225, 1.4), (0.018, 0.012, 0.02), glow)
    cube((0, -0.14, 1.12), (0.12, 0, 0), (0.08, 0.05, 0.24), pale)
    cube((0, -0.19, 1.0), (0.05, 0, 0), (0.06, 0.03, 0.05), dark)
    for sx in (-1, 1):
        rod((sx * 0.22, -0.02, 1.15), (sx * 0.34, -0.22, 0.55), 0.028, shroud)
        rod((sx * 0.34, -0.22, 0.55), (sx * 0.32, -0.34, 0.2), 0.022, pale)
        for k in (-0.04, 0.0, 0.04):
            claw((sx * 0.32 + k, -0.34, 0.2), (k * 3, -0.2, -1.0), 0.16, pale)
    rod((0.32, -0.34, 0.2), (0.32, -0.34, -0.02), 0.01, mat("chain", (0.3, 0.3, 0.32)), verts=3)
    cone((0.32, -0.34, 0.02), (math.pi, 0, 0), (0.1, 0.1, 0.16), bronze, verts=8, r1=1.0, r2=0.45, depth=1.0)
    sphere((0.32, -0.34, -0.08), (0.03, 0.03, 0.03), pale)
    export("bell_ghost", OUT)


def wandering_bones():
    bone = mat("wb_bone", (0.74, 0.7, 0.58), 0.8)
    old = mat("wb_old", (0.45, 0.4, 0.3), 0.9)
    dark = mat("wb_dark", (0.02, 0.02, 0.02))
    glow = mat("wb_glow", (1.0, 0.45, 0.1), 0.3, 4.0)
    rag = mat("wb_rag", (0.28, 0.2, 0.16), 0.95)
    cube((0, 0, 0.62), (0, 0, 0), (0.26, 0.14, 0.12), old)
    for i in range(6):
        sphere((0, -0.03 * i, 0.74 + i * 0.075), (0.05, 0.05, 0.05), bone)
    for i in range(5):
        z = 0.84 + i * 0.075
        w = 0.22 - 0.02 * abs(i - 1)
        for sx in (-1, 1):
            rod((sx * 0.03, -0.04, z), (sx * w, -0.16, z - 0.02), 0.014, bone, verts=4)
            rod((sx * w, -0.16, z - 0.02), (sx * 0.03, -0.27, z - 0.04), 0.014, bone, verts=4)
    sphere((0, -0.14, 1.34), (0.14, 0.15, 0.17), bone)
    for sx in (-1, 1):
        sphere((sx * 0.06, -0.27, 1.37), (0.05, 0.03, 0.06), dark)
        sphere((sx * 0.06, -0.295, 1.37), (0.022, 0.012, 0.025), glow)
    cube((0, -0.2, 1.17), (0.15, 0, 0), (0.1, 0.07, 0.2), bone)
    for k in range(-3, 4):
        cone((k * 0.012, -0.275, 1.1), (math.pi, 0, 0), (0.008, 0.008, 0.04), bone, verts=3, r1=1.0, r2=0.0, depth=1.0)
    for sx in (-1, 1):
        for level, (zs, ys) in enumerate(((1.0, 0.0), (0.82, 0.04))):
            elbow = (sx * (0.34 + 0.05 * level), -0.1 - 0.06 * level, zs - 0.12)
            hand = (sx * (0.46 + 0.1 * level), -0.46 - 0.1 * level, zs - 0.42)
            rod((sx * 0.14, ys, zs), elbow, 0.018, bone)
            rod(elbow, hand, 0.014, bone)
            for k in (-0.03, 0.0, 0.03):
                claw((hand[0] + k, hand[1], hand[2]), (k * 4, -0.4, -1.0), 0.17, bone)
        knee = (sx * 0.2, -0.22, 0.42)
        rod((sx * 0.14, 0.02, 0.6), knee, 0.025, bone)
        rod(knee, (sx * 0.2, 0.02, 0.2), 0.02, bone)
        rod((sx * 0.2, 0.02, 0.2), (sx * 0.22, -0.3, 0.02), 0.018, bone)
    cube((0, 0.05, 0.5), (0.1, 0, 0), (0.3, 0.02, 0.4), rag)
    export("wandering_bones", OUT)


def alley_leech():
    skin = mat("al_skin", (0.62, 0.64, 0.58), 0.7)
    belly = mat("al_belly", (0.46, 0.34, 0.34), 0.7)
    mouth = mat("al_mouth", (0.35, 0.05, 0.08))
    tooth = mat("al_tooth", (0.92, 0.9, 0.8))
    eye = mat("al_eye", (1.0, 0.1, 0.08), 0.3, 4.0)
    cape = mat("al_cape", (0.22, 0.04, 0.06), 0.95)
    sphere((0, 0.05, 0.62), (0.26, 0.4, 0.3), skin)
    sphere((0, -0.04, 0.5), (0.2, 0.28, 0.2), belly)
    sphere((0, -0.38, 0.78), (0.19, 0.28, 0.2), skin)
    sphere((0, -0.58, 0.72), (0.11, 0.06, 0.1), mouth)
    for i in range(8):
        a = i / 8.0 * math.tau
        cone((math.cos(a) * 0.1, -0.62, 0.72 + math.sin(a) * 0.085), (math.pi / 2, 0, 0), (0.014, 0.014, 0.05), tooth, verts=3, r1=1.0, r2=0.0, depth=1.0)
    for sx in (-1, 1):
        sphere((sx * 0.07, -0.55, 0.84), (0.022, 0.022, 0.022), eye)
        rod((sx * 0.2, -0.05, 0.78), (sx * 0.36, -0.42, 0.42), 0.035, skin)
        rod((sx * 0.36, -0.42, 0.42), (sx * 0.4, -0.7, 0.06), 0.028, skin)
        for k in (-0.04, 0.0, 0.04):
            claw((sx * 0.4 + k, -0.7, 0.06), (k * 3, -0.6, -0.6), 0.22, tooth)
        rod((sx * 0.14, 0.28, 0.34), (sx * 0.2, 0.1, 0.12), 0.04, skin)
        rod((sx * 0.2, 0.1, 0.12), (sx * 0.2, -0.12, 0.02), 0.03, skin)
    for k in range(5):
        cube((-0.22 + k * 0.11, 0.42 + 0.03 * (k % 2), 0.5), (0.5 + 0.1 * k, 0, 0.2 * (k - 2)), (0.07, 0.02, 0.5), cape)
    export("alley_leech", OUT)


def bell_warden():
    iron = mat("bw_iron", (0.22, 0.23, 0.26), 0.5)
    bronze = mat("bw_bronze", (0.62, 0.46, 0.18), 0.45)
    flesh = mat("bw_flesh", (0.5, 0.45, 0.4), 0.8)
    glow = mat("bw_glow", (1.0, 0.35, 0.1), 0.3, 4.0)
    chain = mat("bw_chain", (0.3, 0.3, 0.33))
    for sx in (-1, 1):
        cube((sx * 0.22, 0, 0.35), (0, 0, 0), (0.2, 0.22, 0.7), iron)
        cube((sx * 0.22, -0.04, 0.03), (0, 0, 0), (0.26, 0.34, 0.08), iron)
    cube((0, 0, 1.1), (0, 0, 0), (0.8, 0.46, 0.85), flesh)
    cube((0, -0.24, 1.15), (0, 0, 0), (0.7, 0.04, 0.7), iron)
    cube((0, 0.04, 0.78), (0, 0, 0), (0.84, 0.5, 0.1), iron)
    cone((0, -0.02, 1.95), (math.pi, 0, 0), (0.55, 0.55, 0.8), bronze, verts=12, r1=1.0, r2=0.3, depth=1.0)
    cylinder((0, -0.02, 2.4), (0, 0, 0), (0.1, 0.1, 0.15), iron, verts=6)
    for sx in (-1, 1):
        sphere((sx * 0.12, -0.18, 1.72), (0.07, 0.05, 0.07), glow)
        rod((sx * 0.46, 0, 1.35), (sx * 0.62, -0.15, 0.8), 0.1, flesh)
        rod((sx * 0.62, -0.15, 0.8), (sx * 0.66, -0.4, 0.3), 0.09, flesh)
        cube((sx * 0.66, -0.42, 0.22), (0, 0, 0), (0.26, 0.3, 0.26), iron)
        for fy in (0.26, 0.48):
            rod((sx * 0.3, fy, 0.5), (sx * 0.3, fy, 1.95), 0.025, iron)
        rod((sx * 0.3, 0.26, 1.95), (sx * 0.3, 0.48, 1.95), 0.025, iron)
        rod((sx * 0.3, 0.26, 0.5), (sx * 0.3, 0.48, 0.5), 0.025, iron)
    rod((-0.3, 0.26, 1.95), (0.3, 0.26, 1.95), 0.025, iron)
    rod((-0.3, 0.48, 1.95), (0.3, 0.48, 1.95), 0.025, iron)
    sphere((0, 0.37, 1.2), (0.16, 0.12, 0.18), mat("bw_skull", (0.78, 0.76, 0.68)))
    for i in range(5):
        rod((-0.5 + i * 0.25, -0.26, 1.7), (-0.4 + i * 0.25, -0.3, 1.0), 0.016, chain, verts=3)
    export("bell_warden", OUT)


def gravedigger():
    robe = mat("gd_robe", (0.05, 0.05, 0.07), 0.95)
    cloth = mat("gd_cloth", (0.2, 0.17, 0.13), 0.95)
    bone = mat("gd_bone", (0.72, 0.7, 0.6))
    wood = mat("gd_wood", (0.3, 0.2, 0.12))
    iron = mat("gd_iron", (0.35, 0.36, 0.38), 0.45)
    glow = mat("gd_glow", (0.4, 1.0, 0.35), 0.3, 5.0)
    black = mat("gd_black", (0.0, 0.0, 0.0))
    cone((0, 0.05, 1.0), (0.12, 0, 0), (0.6, 0.45, 2.0), robe, verts=9, r1=1.0, r2=0.14, depth=1.0)
    for i in range(7):
        a = i / 7.0 * math.tau
        cone((math.cos(a) * 0.58, 0.05 + math.sin(a) * 0.44, 0.1), (math.pi, 0, 0), (0.09, 0.09, 0.6 + 0.2 * (i % 3)), robe, verts=4, r1=1.0, r2=0.0, depth=1.0)
    cone((0, -0.14, 2.12), (0.3, 0, 0), (0.28, 0.3, 0.46), robe, verts=8, r1=1.0, r2=0.08, depth=1.0)
    sphere((0, -0.26, 1.98), (0.14, 0.13, 0.17), bone)
    for sx in (-1, 1):
        sphere((sx * 0.06, -0.37, 2.02), (0.04, 0.03, 0.05), black)
        sphere((sx * 0.06, -0.39, 2.02), (0.02, 0.012, 0.024), glow)
        rod((sx * 0.3, -0.05, 1.7), (sx * 0.5, -0.5, 1.0), 0.04, cloth)
        rod((sx * 0.5, -0.5, 1.0), (sx * 0.4, -0.85, 0.5), 0.032, bone)
        for k in (-0.05, 0.0, 0.05):
            claw((sx * 0.4 + k, -0.85, 0.5), (k * 2, -0.3, -1.0), 0.26, bone)
    rod((0.4, -0.85, 0.55), (0.46, -0.95, 2.3), 0.03, wood)
    cube((0.46, -0.95, 0.08), (0, 0, 0), (0.1, 0.34, 0.5), iron)
    cube((0, 0.42, 1.4), (0.2, 0, 0), (0.42, 0.28, 1.0), wood)
    sphere((-0.5, -0.5, 1.1), (0.06, 0.06, 0.06), glow)
    rod((-0.5, -0.5, 1.1), (-0.5, -0.5, 1.4), 0.008, iron, verts=3)
    export("gravedigger", OUT)


def hanged_man():
    cloth = mat("hm_cloth", (0.3, 0.26, 0.2), 0.95)
    skin = mat("hm_skin", (0.55, 0.58, 0.5), 0.8)
    rope = mat("hm_rope", (0.45, 0.35, 0.22), 0.95)
    glow = mat("hm_glow", (1.0, 0.85, 0.3), 0.3, 4.0)
    dark = mat("hm_dark", (0.02, 0.02, 0.02))
    rod((0.03, -0.02, 0.55), (0.03, 0.0, 2.6), 0.02, rope)
    cube((0, 0, 1.0), (0.1, 0, 0.05), (0.34, 0.2, 0.8), cloth)
    sphere((0.03, -0.03, 1.55), (0.14, 0.13, 0.17), skin)
    cube((0.03, -0.03, 1.4), (0, 0, 0.3), (0.16, 0.05, 0.06), rope)
    for sx in (-1, 1):
        sphere((0.03 + sx * 0.055, -0.15, 1.58), (0.04, 0.03, 0.045), dark)
        sphere((0.03 + sx * 0.055, -0.17, 1.58), (0.018, 0.012, 0.02), glow)
        rod((sx * 0.2, 0.0, 1.35), (sx * 0.3, -0.08, 0.75), 0.03, cloth)
        rod((sx * 0.3, -0.08, 0.75), (sx * 0.28, -0.14, 0.4), 0.025, skin)
        for k in (-0.03, 0.0, 0.03):
            claw((sx * 0.28 + k, -0.14, 0.4), (k * 3, -0.2, -1.0), 0.18, skin)
        rod((sx * 0.1, 0.0, 0.62), (sx * 0.12, 0.05, 0.12), 0.04, cloth)
        cube((sx * 0.12, 0.0, 0.05), (0, 0, 0), (0.08, 0.2, 0.08), skin)
    export("hanged_man", OUT)


def stitched_horror():
    flesh1 = mat("sh_a", (0.62, 0.5, 0.44), 0.85)
    flesh2 = mat("sh_b", (0.46, 0.5, 0.42), 0.85)
    flesh3 = mat("sh_c", (0.55, 0.38, 0.36), 0.85)
    thread = mat("sh_thread", (0.05, 0.04, 0.04))
    iron = mat("sh_iron", (0.5, 0.52, 0.55), 0.35)
    big_eye = mat("sh_eye1", (1.0, 0.1, 0.1), 0.3, 4.0)
    small_eye = mat("sh_eye2", (0.9, 0.9, 0.5), 0.3, 3.0)
    cube((0, 0, 0.95), (0, 0, 0.05), (0.62, 0.4, 0.8), flesh1)
    cube((0.15, -0.21, 0.95), (0, 0, 0), (0.3, 0.02, 0.8), flesh2)
    for k in range(7):
        cube((0.0, -0.215, 0.62 + k * 0.1), (0, 0, 0), (0.55, 0.012, 0.02), thread)
    sphere((0.05, -0.05, 1.5), (0.2, 0.19, 0.18), flesh3)
    cube((0.05, -0.2, 1.38), (0, 0, 0), (0.22, 0.02, 0.05), thread)
    for k in range(5):
        cube((-0.04 + k * 0.045, -0.205, 1.38), (0, 0, 0), (0.012, 0.02, 0.09), thread)
    sphere((-0.05, -0.2, 1.55), (0.07, 0.04, 0.07), big_eye)
    sphere((0.16, -0.18, 1.5), (0.03, 0.02, 0.03), small_eye)
    rod((-0.36, 0, 1.2), (-0.62, -0.12, 0.7), 0.15, flesh2)
    rod((-0.62, -0.12, 0.7), (-0.7, -0.3, 0.2), 0.13, flesh2)
    sphere((-0.7, -0.32, 0.1), (0.2, 0.18, 0.2), flesh3)
    rod((0.34, 0, 1.2), (0.42, -0.2, 0.8), 0.045, flesh3)
    rod((0.42, -0.2, 0.8), (0.44, -0.5, 0.5), 0.04, flesh3)
    cube((0.44, -0.62, 0.5), (0, 0, math.radians(20)), (0.04, 0.6, 0.16), iron)
    for sx, fl in ((-1, flesh2), (1, flesh1)):
        rod((sx * 0.16, 0.0, 0.58), (sx * 0.2, -0.04, 0.1), 0.1, fl)
        cube((sx * 0.2, -0.1, 0.04), (0, 0, 0), (0.2, 0.34, 0.08), flesh3)
    export("stitched_horror", OUT)


def rat_mother():
    fur = mat("rm_fur", (0.28, 0.24, 0.22), 0.95)
    skin = mat("rm_skin", (0.6, 0.38, 0.38), 0.8)
    tumor = mat("rm_tumor", (0.5, 0.3, 0.32), 0.7)
    eye = mat("rm_eye", (1.0, 0.1, 0.1), 0.3, 4.0)
    tooth = mat("rm_tooth", (0.9, 0.85, 0.7))
    sphere((0, 0.1, 0.6), (0.62, 0.9, 0.55), fur)
    sphere((0, -0.2, 0.42), (0.5, 0.7, 0.35), skin)
    sphere((0, -0.9, 0.7), (0.38, 0.45, 0.34), fur)
    cone((0, -1.28, 0.62), (math.pi / 2, 0, 0), (0.18, 0.18, 0.4), fur, verts=6, r1=1.0, r2=0.35, depth=1.0)
    for sx in (-1, 1):
        sphere((sx * 0.28, -0.75, 1.0), (0.2, 0.05, 0.24), skin)
        sphere((sx * 0.14, -1.05, 0.82), (0.05, 0.05, 0.05), eye)
        sphere((sx * 0.24, -0.98, 0.86), (0.035, 0.035, 0.035), eye)
        cone((sx * 0.05, -1.45, 0.52), (math.pi, 0, 0), (0.02, 0.02, 0.12), tooth, verts=3, r1=1.0, r2=0.0, depth=1.0)
        for fy in (-0.45, 0.65):
            cylinder((sx * 0.4, fy, 0.22), (0, 0, 0), (0.1, 0.1, 0.44), fur, verts=5)
    for p in ((0.3, 0.2, 1.0), (-0.28, 0.5, 1.02), (0.1, -0.1, 1.14), (-0.4, -0.05, 0.9), (0.38, 0.7, 0.86)):
        sphere(p, (0.13, 0.13, 0.12), tumor)
    for p in ((0.25, 0.3, 1.12), (-0.3, 0.35, 1.1), (0.05, 0.6, 1.0), (-0.15, -0.2, 1.18), (0.35, -0.1, 1.04), (-0.05, 0.9, 0.9)):
        sphere(p, (0.1, 0.17, 0.08), fur)
        sphere((p[0], p[1] - 0.15, p[2] + 0.01), (0.05, 0.06, 0.05), fur)
        sphere((p[0] - 0.03, p[1] - 0.2, p[2] + 0.03), (0.014, 0.014, 0.014), eye)
    for i in range(9):
        t = i / 8.0
        sphere((0.0, 0.95 + t * 0.8, 0.4 + 0.2 * math.sin(t * 3.0)), (0.07 - 0.03 * t, 0.12, 0.07 - 0.03 * t), skin)
    export("rat_mother", OUT)


if __name__ == "__main__":
    argv = sys.argv
    OUT = argv[argv.index("--") + 1] if "--" in argv else os.getcwd()
    os.makedirs(OUT, exist_ok=True)
    for build in (bell_ghost, wandering_bones, alley_leech, bell_warden, gravedigger, hanged_man, stitched_horror, rat_mother):
        clear()
        build()
