# Ferramentas comuns dos scripts de modelagem do Blender (cores chapadas, baixo poligono).
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


