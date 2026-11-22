# Pecas de cenario gotico proprias (TASK-063, IDENTIDADE-VISUAL C.3 e D.5): arco ogival, arcada,
# contraforte e agulha. Flat shading, pedra gasta, pe em z=0, centro em x=0/y=0, frente para -Y
# (vira +Z no Godot). Material cinza claro: o jogo tinge pela paleta com StageKit.place.
# Uso: blender -b -P tools/blender/make_scenery.py
import math
import os
import random

import bmesh
import bpy

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
OUT = os.path.join(REPO, "assets", "bibiana", "scenery")
os.makedirs(OUT, exist_ok=True)


def clear():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()


def material():
    m = bpy.data.materials.new("stone")
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (0.78, 0.78, 0.8, 1.0)
    b.inputs["Roughness"].default_value = 1.0
    return m


def finish(bm, name, rough=0.02, seed=1):
    rnd = random.Random(seed)
    for v in bm.verts:
        if v.co.z > 0.05:
            v.co.x += rnd.uniform(-rough, rough)
            v.co.y += rnd.uniform(-rough, rough)
            v.co.z += rnd.uniform(-rough, rough)
    mesh = bpy.data.meshes.new(name)
    bm.normal_update()
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(material())
    for p in obj.data.polygons:
        p.use_smooth = False
    return obj


def extrude_polygon(bm, pts, depth):
    """Extruda um contorno (x, z) por `depth` em +Y a partir da frente em y=-depth/2."""
    front = [bm.verts.new((x, -depth / 2.0, z)) for x, z in pts]
    face = bm.faces.new(front)
    res = bmesh.ops.extrude_face_region(bm, geom=[face])
    verts = [e for e in res["geom"] if isinstance(e, bmesh.types.BMVert)]
    bmesh.ops.translate(bm, vec=(0, depth, 0), verts=verts)
    bmesh.ops.triangulate(bm, faces=bm.faces[:], quad_method='BEAUTY', ngon_method='EAR_CLIP')
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])


def ogive_points(x0, x1, spring, steps=7):
    """Pontos do arco ogival da esquerda (x0) para a direita (x1), saindo da altura `spring`."""
    w = x1 - x0
    r = w
    out = []
    # arco esquerdo: centro em (x1, spring); vai de (x0, spring) ate o apice
    for i in range(steps + 1):
        a = math.pi - (math.pi / 3.0) * (i / steps)
        out.append((x1 + r * math.cos(a), spring + r * math.sin(a)))
    # arco direito: centro em (x0, spring); do apice ate (x1, spring)
    for i in range(1, steps + 1):
        a = (2.0 * math.pi / 3.0) - (math.pi / 3.0) * (i / steps)
        out.append((x0 + r * math.cos(a), spring + r * math.sin(a)))
    return out


def arcade(name, width, height, openings, spring, depth=0.9, seed=1, ruin=0.7):
    """Parede com aberturas ogivais ate o chao. `openings` = lista de (x0, x1)."""
    rnd = random.Random(seed)
    bm = bmesh.new()
    hw = width / 2.0
    pts = [(-hw, 0.0)]
    top = [(-hw, height - rnd.uniform(0, ruin))]
    n = 6
    for i in range(1, n):
        top.append((-hw + width * i / n, height - rnd.uniform(0, ruin)))
    top.append((hw, height - rnd.uniform(0, ruin)))
    pts = [(-hw, 0.0)] + top
    pts += [(hw, 0.0)]
    # entalhes pelo chao, da direita para a esquerda
    for (x0, x1) in sorted(openings, key=lambda o: -o[1]):
        pts.append((x1, 0.0))
        pts.append((x1, spring))
        arc = ogive_points(x0, x1, spring)
        pts.extend(reversed(arc))
        pts.append((x0, spring))
        pts.append((x0, 0.0))
    # remove duplicados consecutivos
    clean = []
    for p in pts:
        if not clean or abs(clean[-1][0] - p[0]) + abs(clean[-1][1] - p[1]) > 1e-4:
            clean.append(p)
    extrude_polygon(bm, clean, depth)
    # cornijas (fiadas) horizontais e pilares de apoio
    for z in (height * 0.52, height * 0.78):
        bmesh.ops.create_cube(bm, size=1.0, matrix=_scale_loc((width + 0.16, depth + 0.16, 0.14), (0, 0, z)))
    return finish(bm, name, seed=seed)


def _scale_loc(scale, loc):
    from mathutils import Matrix
    m = Matrix.Translation(loc)
    for i in range(3):
        m[i][i] = scale[i]
    return m


def buttress(name, height=6.5, seed=3):
    bm = bmesh.new()
    steps = [(0.95, 1.5, 0.0, 2.4), (0.8, 1.1, 2.4, 4.2), (0.62, 0.7, 4.2, height)]
    for sx, sy, z0, z1 in steps:
        bmesh.ops.create_cube(bm, size=1.0, matrix=_scale_loc((sx, sy, z1 - z0), (0, 0.0, (z0 + z1) / 2.0)))
    # pinaculo
    bmesh.ops.create_cone(bm, cap_ends=True, segments=4, radius1=0.5, radius2=0.0, depth=1.6, matrix=_scale_loc((1, 1, 1), (0, 0, height + 0.8)))
    # arcobotante inclinado ao lado da parede
    bmesh.ops.create_cube(bm, size=1.0, matrix=_scale_loc((0.3, 1.8, 0.35), (0, 0.9, 4.6)))
    return finish(bm, name, seed=seed)


def spire(name, height=10.0, seed=5):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0, matrix=_scale_loc((1.3, 1.3, 3.0), (0, 0, 1.5)))
    bmesh.ops.create_cone(bm, cap_ends=True, segments=8, radius1=0.62, radius2=0.5, depth=2.0, matrix=_scale_loc((1, 1, 1), (0, 0, 4.0)))
    bmesh.ops.create_cone(bm, cap_ends=True, segments=8, radius1=0.5, radius2=0.0, depth=height - 5.0, matrix=_scale_loc((1, 1, 1), (0, 0, 5.0 + (height - 5.0) / 2.0)))
    for sx in (-0.55, 0.55):
        for sy in (-0.55, 0.55):
            bmesh.ops.create_cone(bm, cap_ends=True, segments=4, radius1=0.2, radius2=0.0, depth=1.4, matrix=_scale_loc((1, 1, 1), (sx, sy, 3.7)))
    return finish(bm, name, rough=0.02, seed=seed)


def export(obj, name):
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    path = os.path.join(OUT, name + ".glb")
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=True, export_apply=True)
    print("MODELO", path, len(obj.data.polygons), "tris")


clear()
export(arcade("ogive_arch", 5.0, 7.0, [(-1.2, 1.2)], 2.6, seed=2), "ogive_arch")
clear()
export(arcade("ogive_arcade", 8.0, 6.2, [(-3.3, -1.1), (1.1, 3.3)], 2.3, seed=4), "ogive_arcade")
clear()
export(arcade("ogive_wall", 4.0, 6.0, [], 2.0, seed=6, ruin=1.2), "ogive_wall")
clear()
export(buttress("buttress"), "buttress")
clear()
export(spire("spire"), "spire")
