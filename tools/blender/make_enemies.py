# Gera os modelos 3D proprios dos inimigos (TASK-044) em baixo poligono, com cores chapadas,
# no mesmo estilo dos kits CC0. Uso (Blender 4.x ou 5.x, sem janela):
#   blender -b -P tools/blender/make_enemies.py -- <pasta de saida>
# Cada modelo olha para -Y no Blender (vira +Z no glTF, como os modelos da Kenney) e sai em
# .glb. Os modelos sao do proprio projeto (CC0).
import math
import os
import sys

import bpy


def clear():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()
    for block in list(bpy.data.materials):
        bpy.data.materials.remove(block)


_materials = {}


def mat(name, rgb, rough=0.85, emit=0.0):
    key = (name, rgb, emit)
    if key in _materials:
        return _materials[key]
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (rgb[0], rgb[1], rgb[2], 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    if emit > 0.0:
        bsdf.inputs["Emission Color"].default_value = (rgb[0], rgb[1], rgb[2], 1.0)
        bsdf.inputs["Emission Strength"].default_value = emit
    _materials[key] = m
    return m


def finish(obj, material, flat=True):
    obj.data.materials.append(material)
    if flat:
        for poly in obj.data.polygons:
            poly.use_smooth = False
    return obj


def sphere(loc, scale, material, sub=1):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=sub, radius=1.0, location=loc)
    obj = bpy.context.active_object
    obj.scale = scale
    return finish(obj, material)


def cone(loc, rot, scale, material, verts=6, r1=1.0, r2=0.0, depth=1.0):
    bpy.ops.mesh.primitive_cone_add(vertices=verts, radius1=r1, radius2=r2, depth=depth, location=loc, rotation=rot)
    obj = bpy.context.active_object
    obj.scale = scale
    return finish(obj, material)


def cylinder(loc, rot, scale, material, verts=6):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=1.0, depth=1.0, location=loc, rotation=rot)
    obj = bpy.context.active_object
    obj.scale = scale
    return finish(obj, material)


def cube(loc, rot, scale, material):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=loc, rotation=rot)
    obj = bpy.context.active_object
    obj.scale = scale
    return finish(obj, material)


def export(name, out_dir):
    parts = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    bpy.ops.object.select_all(action="DESELECT")
    for o in parts:
        o.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.join()
    obj = bpy.context.active_object
    obj.name = name
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    path = os.path.join(out_dir, name + ".glb")
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=True, export_apply=True)
    print("MODELO", path, len(obj.data.polygons), "faces")


def rat():
    fur = mat("rat_fur", (0.36, 0.3, 0.26))
    belly = mat("rat_belly", (0.55, 0.47, 0.4))
    pink = mat("rat_pink", (0.78, 0.45, 0.45))
    eye = mat("rat_eye", (0.95, 0.12, 0.1), 0.4, 2.0)
    tooth = mat("rat_tooth", (0.9, 0.85, 0.7))
    sphere((0, 0, 0.3), (0.28, 0.5, 0.26), fur)
    sphere((0, 0.04, 0.22), (0.25, 0.44, 0.18), belly)
    sphere((0, -0.46, 0.34), (0.2, 0.25, 0.19), fur)
    cone((0, -0.72, 0.31), (math.radians(90), 0, 0), (0.1, 0.1, 0.22), fur, verts=5, r1=1.0, r2=0.35, depth=1.0)
    sphere((0, -0.83, 0.31), (0.05, 0.05, 0.05), pink)
    for sx in (-1, 1):
        sphere((sx * 0.14, -0.4, 0.5), (0.1, 0.03, 0.11), pink)
        sphere((sx * 0.085, -0.6, 0.42), (0.035, 0.035, 0.035), eye)
        sphere((sx * 0.03, -0.77, 0.25), (0.012, 0.012, 0.03), tooth)
    for sx in (-1, 1):
        for fy in (-0.22, 0.26):
            cylinder((sx * 0.16, fy, 0.1), (0, 0, 0), (0.05, 0.05, 0.2), fur, verts=5)
    for i in range(6):
        t = i / 5.0
        sphere((0.0, 0.5 + t * 0.35, 0.22 + 0.1 * math.sin(t * 3.1)), (0.035 - 0.015 * t, 0.07, 0.035 - 0.015 * t), pink)
    export("giant_rat", OUT)


def hound():
    fur = mat("hound_fur", (0.2, 0.2, 0.22))
    belly = mat("hound_belly", (0.32, 0.3, 0.3))
    bone = mat("hound_bone", (0.78, 0.74, 0.62))
    eye = mat("hound_eye", (0.45, 0.95, 0.25), 0.4, 2.5)
    sore = mat("hound_sore", (0.55, 0.2, 0.18))
    sphere((0, 0.05, 0.55), (0.3, 0.62, 0.3), fur)
    sphere((0, 0.0, 0.45), (0.26, 0.5, 0.22), belly)
    sphere((0, -0.58, 0.72), (0.22, 0.26, 0.22), fur)
    cone((0, -0.86, 0.66), (math.radians(90), 0, 0), (0.13, 0.13, 0.3), fur, verts=5, r1=1.0, r2=0.45, depth=1.0)
    sphere((0, -1.0, 0.62), (0.05, 0.04, 0.04), mat("nose", (0.05, 0.05, 0.05)))
    for sx in (-1, 1):
        cone((sx * 0.14, -0.52, 0.95), (math.radians(-15), 0, math.radians(sx * 12)), (0.07, 0.04, 0.2), fur, verts=4, r1=1.0, r2=0.0, depth=1.0)
        sphere((sx * 0.1, -0.74, 0.76), (0.04, 0.04, 0.04), eye)
        for fy in (-0.32, 0.42):
            cylinder((sx * 0.17, fy, 0.24), (0, 0, 0), (0.07, 0.07, 0.48), fur, verts=5)
            sphere((sx * 0.17, fy - 0.03, 0.02), (0.08, 0.1, 0.04), belly)
    for i in range(5):
        cone((0, 0.35 - i * 0.22, 0.86 - 0.02 * i), (0, 0, 0), (0.05, 0.05, 0.16), bone, verts=4, r1=1.0, r2=0.0, depth=1.0)
    sphere((0.12, 0.1, 0.62), (0.08, 0.1, 0.06), sore)
    cone((0, 0.78, 0.7), (math.radians(-55), 0, 0), (0.07, 0.07, 0.34), fur, verts=5, r1=1.0, r2=0.3, depth=1.0)
    export("plague_hound", OUT)


def crow():
    feather = mat("crow_feather", (0.07, 0.07, 0.1), 0.6)
    sheen = mat("crow_sheen", (0.16, 0.18, 0.28), 0.4)
    beak = mat("crow_beak", (0.55, 0.5, 0.35))
    eye = mat("crow_eye", (0.95, 0.75, 0.2), 0.4, 2.0)
    sphere((0, 0.0, 0.5), (0.2, 0.34, 0.2), feather)
    sphere((0, -0.02, 0.58), (0.15, 0.26, 0.14), sheen)
    sphere((0, -0.34, 0.66), (0.14, 0.15, 0.14), feather)
    cone((0, -0.52, 0.64), (math.radians(90), 0, 0), (0.06, 0.06, 0.16), beak, verts=4, r1=1.0, r2=0.0, depth=1.0)
    for sx in (-1, 1):
        sphere((sx * 0.07, -0.44, 0.7), (0.025, 0.025, 0.025), eye)
        wing = cube((sx * 0.5, 0.02, 0.58), (0, math.radians(sx * -18), math.radians(sx * 8)), (0.62, 0.3, 0.03), feather)
        cube((sx * 0.92, 0.08, 0.5), (0, math.radians(sx * -25), math.radians(sx * 14)), (0.3, 0.22, 0.025), sheen)
        cylinder((sx * 0.07, 0.04, 0.26), (0, 0, 0), (0.02, 0.02, 0.26), beak, verts=4)
        for k in (-1, 0, 1):
            cone((sx * 0.07 + k * 0.03, -0.05, 0.12), (math.radians(80), 0, 0), (0.012, 0.012, 0.1), beak, verts=3, r1=1.0, r2=0.0, depth=1.0)
    cone((0, 0.5, 0.52), (math.radians(-80), 0, 0), (0.12, 0.03, 0.34), feather, verts=4, r1=1.0, r2=0.3, depth=1.0)
    export("carrion_crow", OUT)


def executioner():
    cloth = mat("exe_cloth", (0.34, 0.12, 0.12))
    leather = mat("exe_leather", (0.2, 0.14, 0.1))
    skin = mat("exe_skin", (0.55, 0.62, 0.48))
    metal = mat("exe_metal", (0.55, 0.57, 0.6), 0.35)
    rust = mat("exe_rust", (0.5, 0.25, 0.12))
    eye = mat("exe_eye", (0.95, 0.2, 0.15), 0.4, 2.5)
    cube((0, 0, 0.62), (0, 0, 0), (0.42, 0.26, 0.5), cloth)
    cube((0, -0.01, 0.4), (0, 0, 0), (0.44, 0.28, 0.16), leather)
    for sx in (-1, 1):
        cylinder((sx * 0.14, 0, 0.18), (0, 0, 0), (0.09, 0.09, 0.36), leather, verts=6)
        cube((sx * 0.14, -0.05, 0.03), (0, 0, 0), (0.14, 0.2, 0.06), metal)
        sphere((sx * 0.3, 0, 0.84), (0.13, 0.13, 0.13), metal)
        cylinder((sx * 0.34, -0.1, 0.62), (math.radians(35), 0, 0), (0.07, 0.07, 0.4), skin, verts=6)
    sphere((0, -0.02, 1.06), (0.2, 0.2, 0.22), cloth)
    cone((0, 0.02, 1.2), (0, 0, 0), (0.22, 0.22, 0.26), cloth, verts=6, r1=1.0, r2=0.1, depth=1.0)
    sphere((0, -0.14, 1.04), (0.13, 0.08, 0.13), skin)
    for sx in (-1, 1):
        sphere((sx * 0.06, -0.2, 1.07), (0.03, 0.03, 0.03), eye)
    cylinder((0.34, -0.3, 0.74), (math.radians(80), 0, 0), (0.04, 0.04, 1.0), leather, verts=5)
    cube((0.34, -0.72, 0.9), (0, 0, math.radians(8)), (0.04, 0.34, 0.5), metal)
    cube((0.34, -0.72, 1.14), (0, 0, math.radians(8)), (0.05, 0.18, 0.1), rust)
    export("rotten_executioner", OUT)


if __name__ == "__main__":
    argv = sys.argv
    OUT = argv[argv.index("--") + 1] if "--" in argv else os.getcwd()
    os.makedirs(OUT, exist_ok=True)
    for build in (rat, hound, crow, executioner):
        clear()
        build()
