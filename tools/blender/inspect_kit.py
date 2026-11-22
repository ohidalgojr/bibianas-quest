# Lista objetos/dimensoes de um arquivo de kit (depuracao).
import sys

import bpy
import mathutils

for f in sys.argv[sys.argv.index("--") + 1:]:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()
    if f.lower().endswith(".fbx"):
        bpy.ops.import_scene.fbx(filepath=f)
    else:
        bpy.ops.import_scene.gltf(filepath=f)
    print("FILE", f)
    for o in bpy.data.objects:
        info = ""
        if o.type == "MESH":
            ws = [o.matrix_world @ mathutils.Vector(c) for c in o.bound_box]
            lo = [round(min(w[i] for w in ws), 2) for i in range(3)]
            hi = [round(max(w[i] for w in ws), 2) for i in range(3)]
            info = f"tris={len(o.data.polygons)} lo={lo} hi={hi} mats={[m.name for m in o.data.materials]}"
        print("  OBJ", o.type, o.name, "parent=", o.parent.name if o.parent else None, info)
