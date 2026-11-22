# Renderiza um .glb em 3 angulos (frente 3/4 estilo isometrico do jogo, perfil, costas) para a
# revisao critica de assets. Uso:
#   blender -b -P tools/blender/render_preview.py -- <arquivo.glb> <prefixo-de-saida>
import math
import sys

import bpy
import mathutils

argv = sys.argv
glb, prefix = argv[argv.index("--") + 1], argv[argv.index("--") + 2]
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete()
bpy.ops.import_scene.gltf(filepath=glb)
scene = bpy.context.scene
scene.render.resolution_x = 540
scene.render.resolution_y = 720
scene.render.engine = "BLENDER_EEVEE"
world = bpy.data.worlds.new("w")
world.use_nodes = True
world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.03, 0.035, 0.05, 1)
world.node_tree.nodes["Background"].inputs["Strength"].default_value = 1.0
scene.world = world


def light(kind, loc, energy, color):
    data = bpy.data.lights.new(kind, kind)
    data.energy = energy
    data.color = color
    obj = bpy.data.objects.new(kind, data)
    obj.location = loc
    scene.collection.objects.link(obj)


light("SUN", (3, -4, 6), 1.6, (0.62, 0.7, 0.95))
light("POINT", (-1.5, -2.5, 1.4), 150, (1.0, 0.6, 0.3))
cam_data = bpy.data.cameras.new("c")
cam_data.type = "ORTHO"
cam_data.ortho_scale = 3.2
cam = bpy.data.objects.new("c", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam
target = mathutils.Vector((-0.1, 0, 0.95))
for name, deg in (("frente", -35), ("perfil", -100), ("costas", 150)):
    a = math.radians(deg)
    pos = target + mathutils.Vector((math.sin(a) * 6, math.cos(a) * -6, 3.2))
    cam.location = pos
    cam.rotation_euler = (target - pos).to_track_quat("-Z", "Y").to_euler()
    scene.render.filepath = f"{prefix}-{name}.png"
    bpy.ops.render.render(write_still=True)
print("PREVIEW", prefix)

