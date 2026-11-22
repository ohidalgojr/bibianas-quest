# Folha de contato de pecas de kit (so para depuracao). Uso:
#   blender -b -P tools/blender/contact_sheet.py -- saida.png arq1 arq2 ...
import math
import os
import sys

import bpy
import mathutils

args = sys.argv[sys.argv.index("--") + 1:]
out = args[0]
files = args[1:]
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete()
x = 0.0
for f in files:
    before = set(bpy.data.objects)
    if f.lower().endswith(".fbx"):
        bpy.ops.import_scene.fbx(filepath=f)
    else:
        bpy.ops.import_scene.gltf(filepath=f)
    new = [o for o in bpy.data.objects if o not in before]
    meshes = [o for o in new if o.type == "MESH"]
    lo = mathutils.Vector((1e9, 1e9, 1e9))
    hi = mathutils.Vector((-1e9, -1e9, -1e9))
    for o in meshes:
        for c in o.bound_box:
            w = o.matrix_world @ mathutils.Vector(c)
            lo = mathutils.Vector((min(lo.x, w.x), min(lo.y, w.y), min(lo.z, w.z)))
            hi = mathutils.Vector((max(hi.x, w.x), max(hi.y, w.y), max(hi.z, w.z)))
    print("DIM", os.path.basename(f), [round(v, 2) for v in (hi - lo)], "tris", sum(len(o.data.polygons) for o in meshes))
    roots = [o for o in new if o.parent is None]
    for r in roots:
        r.location.x += x - (lo.x + hi.x) / 2
    x += max(hi.x - lo.x, 1.0) + 0.4
scene = bpy.context.scene
scene.render.resolution_x = 1600
scene.render.resolution_y = 500
scene.render.engine = "BLENDER_EEVEE"
world = bpy.data.worlds.new("w")
world.use_nodes = True
world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.25, 0.25, 0.28, 1)
scene.world = world
sun = bpy.data.lights.new("s", "SUN")
sun.energy = 3
so = bpy.data.objects.new("s", sun)
so.rotation_euler = (math.radians(50), 0, math.radians(-30))
scene.collection.objects.link(so)
cam_data = bpy.data.cameras.new("c")
cam_data.type = "ORTHO"
cam_data.ortho_scale = max(x * 0.95, 4)
cam = bpy.data.objects.new("c", cam_data)
scene.collection.objects.link(cam)
cam.location = (x / 2 - 0.2, -30, 0.35)
cam.rotation_euler = (math.radians(90), 0, 0)
scene.camera = cam
scene.render.filepath = out
bpy.ops.render.render(write_still=True)
