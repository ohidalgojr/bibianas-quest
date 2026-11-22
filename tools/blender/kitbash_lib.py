# Biblioteca de kitbash (TASK-062): pecas reais dos kits CC0 (Kenney, Quaternius, KayKit) mais formas
# organicas feitas com bmesh (tubos com raio variavel, panos com barra rasgada, blobs), tudo pintado por
# cor de vertice na paleta de IDENTIDADE-VISUAL B.1 e exportado como UM mesh por inimigo (.glb).
# Convencoes: olha para -Y, pes em z=0, 1 unidade = 1 m, flat shading.
import math
import os
import random

import bmesh
import bpy
import mathutils
from mathutils import Matrix, Vector

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
KENNEY = os.path.join(REPO, "assets", "kenney", "graveyard")
KAYKIT = os.path.join(REPO, "assets", "kaykit", "adventurers")

# O palco do jogo ilumina forte (spot ambar + direcional): cor de vertice e multiplicada por este fator
# para o resultado em tela cair na paleta B.1 (ajustado olhando o print real, nao o Blender).
EXPOSURE = float(os.environ.get("KB_EXPOSURE", "2.4"))
VC_GAIN = 1.0   # ganho aplicado na cor de vertice (a rota com textura aplica EXPOSURE na textura)
EMBER_COLOR = (1.0, 0.36, 0.04, 1.0)

BODY = 1   # indices dos slots de material (a ordem importa para o import do Godot)
EMBER = 0
PARTS: list = []
_MATS: list = []


def hexc(h: str):
    """#RRGGBB (sRGB) -> tupla linear (vertex color do glTF e linear)."""
    h = h.lstrip("#")
    out = []
    for i in (0, 2, 4):
        c = int(h[i:i + 2], 16) / 255.0
        out.append(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4)
    return tuple(out)


# Paleta fechada (B.1) mais tons de trabalho (todos frios/escuros ou lama).
ABYSS = hexc("#07080B")
SLATE = hexc("#1B2029")
STONE = hexc("#4A4E54")
STEEL = hexc("#7E8FA8")
MUD = hexc("#3A3128")
AMBER = hexc("#E08A30")
FEVER = hexc("#8A834C")
BLOOD = hexc("#6E1B18")
IRON = hexc("#2A2D33")
RUST = hexc("#4A2E20")
BONE = hexc("#6C7480")      # osso/pele: nunca acima de #7E8FA8
SKIN = hexc("#4F5864")
SKIN_D = hexc("#2E343D")
CLOTH = hexc("#2A313B")
CLOTH_L = hexc("#3F4955")
WAX = hexc("#7A7A68")       # cera: mais clara que o resto, ainda abaixo do limite
WOOD = hexc("#3A3128")
WOOD_L = hexc("#52463A")


def mix(a, b, t):
    t = max(0.0, min(1.0, t))
    return (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t)


def reset():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()
    for coll in (bpy.data.meshes, bpy.data.materials, bpy.data.images):
        for b in list(coll):
            coll.remove(b)
    PARTS.clear()
    _MATS.clear()
    body = bpy.data.materials.new("body")
    body.use_nodes = True
    nt = body.node_tree
    bsdf = nt.nodes["Principled BSDF"]
    bsdf.inputs["Roughness"].default_value = 0.92
    bsdf.inputs["Base Color"].default_value = (0.98, 0.98, 0.98, 1.0)
    body.use_backface_culling = False
    ember = bpy.data.materials.new("ember")
    ember.use_nodes = True
    eb = ember.node_tree.nodes["Principled BSDF"]
    eb.inputs["Base Color"].default_value = (0.0, 0.0, 0.0, 1.0)
    eb.inputs["Emission Color"].default_value = EMBER_COLOR
    eb.inputs["Emission Strength"].default_value = 1.4
    _MATS.extend([ember, body])


# ---------------------------------------------------------------- pintura


def _hash(*v):
    h = 0
    for x in v:
        h = (h * 73856093) ^ int(round(x * 1000.0) * 19349663 + 83492791)
    return (h & 0xFFFFFF) / float(0xFFFFFF)


def make_painter(base, dark=None, light=None, low=0.0, noise=0.10, grime=0.5, top=0.30, bottom=0.45, seed=0, stripes=None, region=0.0):
    """Devolve fn(co, nrm) -> cor. Valor: topo claro, fundo escuro, sujeira perto do chao e ruido por face."""
    dark = dark or mix(base, ABYSS, 0.6)
    light = light or mix(base, STEEL, 0.35)

    def fn(co, nrm, cen):
        c = base
        if nrm.z > 0.25:
            c = mix(c, light, top * min(1.0, nrm.z * 1.3))
        elif nrm.z < -0.25:
            c = mix(c, dark, bottom * min(1.0, -nrm.z * 1.3))
        if low > 0.0 and co.z < low:
            c = mix(c, dark, grime * (1.0 - co.z / low))
        if stripes:
            axis, a0, a1, period, depth = stripes[:5]
            v = (cen.x + cen.y + cen.z) if axis == 3 else cen[axis]
            if a0 <= v <= a1 and ((v - a0) % period) < period * 0.45:
                c = mix(c, stripes[5] if len(stripes) > 5 else dark, depth)
        n = _hash(cen.x, cen.y, cen.z, seed)
        c = mix(c, dark if n < 0.5 else light, abs(n - 0.5) * 2.0 * noise)
        return c
    fn.region = region
    return fn


def paint(ob, fn, only=None):
    """Aplica fn a todos os cantos (loops) do objeto; only = lista de indices de poligono."""
    me = ob.data
    if "Col" not in me.color_attributes:
        me.color_attributes.new("Col", "FLOAT_COLOR", "CORNER")
    attr = me.color_attributes["Col"]
    idx = range(len(me.polygons)) if only is None else only
    for pi in idx:
        poly = me.polygons[pi]
        cen = poly.center
        for li in poly.loop_indices:
            v = me.vertices[me.loops[li].vertex_index].co
            c = fn(v, poly.normal, cen)
            a = c[3] if len(c) > 3 else getattr(fn, "region", 0.0)
            attr.data[li].color = (c[0] * VC_GAIN, c[1] * VC_GAIN, c[2] * VC_GAIN, a)
    me.color_attributes.active_color = attr


def paint_flat(ob, color, material=None):
    material = BODY if material is None else material
    paint(ob, lambda co, n, c: color)
    for p in ob.data.polygons:
        p.material_index = material


def set_ember(ob):
    for p in ob.data.polygons:
        p.material_index = EMBER


# ---------------------------------------------------------------- criacao


def _finish(bm, name, fn=None):
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(name, me)
    bpy.context.collection.objects.link(ob)
    for m in _MATS:
        me.materials.append(m)
    for p in me.polygons:
        p.use_smooth = False
        p.material_index = BODY
    PARTS.append(ob)
    if fn is not None:
        paint(ob, fn)
    return ob


def _vec(p):
    return Vector(p)


def tube(pts, radii, sides=6, fn=None, up=(0, 0, 1), caps=(True, True), twist=0.0, name="tube"):
    """Tubo varrido por uma polilinha com raio (ru, rv) por ponto. Raio 0 vira ponta (espinho, dedo)."""
    bm = bmesh.new()
    pts = [_vec(p) for p in pts]
    n = len(pts)
    upv = Vector(up)
    rings = []
    prev_u = None
    for i in range(n):
        a = pts[max(i - 1, 0)]
        b = pts[min(i + 1, n - 1)]
        t = (b - a).normalized()
        u = t.cross(upv)
        if u.length < 1e-3:
            u = prev_u if prev_u is not None else Vector((1, 0, 0))
        u.normalize()
        v = u.cross(t).normalized()
        prev_u = u
        r = radii[i]
        ru, rv = (r, r) if not isinstance(r, (tuple, list)) else r
        if ru < 1e-5 and rv < 1e-5:
            rings.append([bm.verts.new(pts[i])])
            continue
        ring = []
        for k in range(sides):
            ang = math.tau * k / sides + math.pi / sides + twist
            ring.append(bm.verts.new(pts[i] + u * math.cos(ang) * ru + v * math.sin(ang) * rv))
        rings.append(ring)
    for i in range(n - 1):
        r0, r1 = rings[i], rings[i + 1]
        if len(r0) == 1 and len(r1) == 1:
            continue
        for k in range(sides):
            k2 = (k + 1) % sides
            if len(r0) == 1:
                bm.faces.new((r0[0], r1[k2], r1[k]))
            elif len(r1) == 1:
                bm.faces.new((r0[k], r0[k2], r1[0]))
            else:
                bm.faces.new((r0[k], r0[k2], r1[k2], r1[k]))
    if caps[0] and len(rings[0]) > 1:
        bm.faces.new(rings[0][::-1])
    if caps[1] and len(rings[-1]) > 1:
        bm.faces.new(rings[-1])
    return _finish(bm, name, fn)


def blob(center, radii, rot=(0, 0, 0), fn=None, subdiv=1, jitter=0.0, seed=1, name="blob"):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subdiv, radius=1.0)
    rnd = random.Random(seed)
    m = Matrix.Translation(center) @ Matrix(mathutils.Euler([math.radians(a) for a in rot]).to_matrix()).to_4x4()
    sc = Matrix.Diagonal((radii[0], radii[1], radii[2], 1.0))
    for v in bm.verts:
        if jitter:
            v.co *= 1.0 + rnd.uniform(-jitter, jitter)
        v.co = m @ (sc @ v.co)
    return _finish(bm, name, fn)


def box(center, size, rot=(0, 0, 0), fn=None, taper=(1.0, 1.0), name="box"):
    """Caixa; taper=(x,y) escala o topo (z+) em relacao a base."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    m = Matrix.Translation(center) @ Matrix(mathutils.Euler([math.radians(a) for a in rot]).to_matrix()).to_4x4()
    for v in bm.verts:
        top = 1.0 if v.co.z > 0 else 0.0
        sx = 1.0 + (taper[0] - 1.0) * top
        sy = 1.0 + (taper[1] - 1.0) * top
        v.co = m @ Vector((v.co.x * size[0] * sx, v.co.y * size[1] * sy, v.co.z * size[2]))
    return _finish(bm, name, fn)


def spike(base, tip, r, sides=5, fn=None, name="spike"):
    return tube([base, tip], [r, 0.0], sides=sides, fn=fn, name=name)


def cloth(center, z_top, z_bot, top_r, bot_r, n=10, arc=(0.0, 360.0), fold=0.05, jag=0.12, seed=3, fn=None,
          rows=3, front_lift=0.0, sway=(0.0, 0.0), name="cloth"):
    """Pano em anel/arco: topo estreito, barra larga com pregas e pontas rasgadas.
    top_r/bot_r = (rx, ry). arc em graus (0 = -Y/frente?) ; sway desloca a barra (cx, cy)."""
    bm = bmesh.new()
    rnd = random.Random(seed)
    a0, a1 = [math.radians(a) for a in arc]
    full = abs((a1 - a0) - math.tau) < 1e-3
    cols = n if full else n + 1
    grid = []
    for r in range(rows + 1):
        t = r / rows
        z = z_top + (z_bot - z_top) * t
        rx = top_r[0] + (bot_r[0] - top_r[0]) * t
        ry = top_r[1] + (bot_r[1] - top_r[1]) * t
        row = []
        for c in range(cols):
            a = a0 + (a1 - a0) * (c / n)
            f = 1.0 + (fold if (c % 2 == 0) else -fold) * t * 1.6
            zz = z
            if r == rows:
                zz = z + rnd.uniform(-jag, jag) * (1.0 if c % 2 == 0 else 0.4) - (jag if c % 3 == 0 else 0.0)
            cx = center[0] + sway[0] * t
            cy = center[1] + sway[1] * t
            row.append(bm.verts.new((cx + math.sin(a) * rx * f, cy - math.cos(a) * ry * f, max(zz, 0.0 if front_lift >= 0 else zz))))
        grid.append(row)
    for r in range(rows):
        for c in range(cols - 1 if not full else cols):
            c2 = (c + 1) % cols
            bm.faces.new((grid[r][c], grid[r][c2], grid[r + 1][c2], grid[r + 1][c]))
    return _finish(bm, name, fn)


# ---------------------------------------------------------------- kit real


def kit(path, part, loc=(0, 0, 0), rot=(0, 0, 0), scale=(1, 1, 1), ramp=None, name=None, ember_if=None, pivot=None):
    """Importa uma peca de um glb do kit, copia a malha, aplica transformacao e recolore pela luminancia
    original usando a rampa (escuro, meio, claro). pivot = ponto local (antes de escalar) que vai para loc."""
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=path)
    new = [o for o in bpy.data.objects if o not in before]
    src = [o for o in new if o.type == "MESH" and o.name.split(".")[0] == part]
    if not src:
        raise RuntimeError("peca nao achada: %s em %s (%s)" % (part, path, [o.name for o in new]))
    src = src[0]
    me = src.data.copy()
    me.transform(src.matrix_world)
    # cores originais por canto
    img = None
    for m in src.data.materials:
        if m and m.node_tree:
            for nd in m.node_tree.nodes:
                if nd.type == "TEX_IMAGE" and nd.image:
                    img = nd.image
    px = None
    if img is not None:
        w, h = img.size
        px = list(img.pixels[:])
    uvl = me.uv_layers.active
    lumas = []
    for li in range(len(me.loops)):
        if px is not None and uvl is not None:
            u, v = uvl.data[li].uv
            x = min(w - 1, max(0, int(u * w)))
            y = min(h - 1, max(0, int(v * h)))
            r, g, b = px[(y * w + x) * 4:(y * w + x) * 4 + 3]
            lumas.append((0.3 * r + 0.59 * g + 0.11 * b, max(r, g, b) - min(r, g, b), r, g, b))
        else:
            lumas.append((0.5, 0.0, 0.5, 0.5, 0.5))
    for o in new:
        bpy.data.objects.remove(o, do_unlink=True)
    for uv in list(me.uv_layers):
        me.uv_layers.remove(uv)
    ob = bpy.data.objects.new(name or part, me)
    bpy.context.collection.objects.link(ob)
    me.materials.clear()
    for m in _MATS:
        me.materials.append(m)
    # transformacao
    pv = Vector(pivot) if pivot else Vector((0, 0, 0))
    mat = Matrix.Translation(loc) @ Matrix(mathutils.Euler([math.radians(a) for a in rot]).to_matrix()).to_4x4() @ Matrix.Diagonal((scale[0], scale[1], scale[2], 1.0)) @ Matrix.Translation(-pv)
    me.transform(mat)
    ramp = ramp or (SKIN_D, SKIN, BONE)
    attr = me.color_attributes.new("Col", "FLOAT_COLOR", "CORNER")
    for li, (l, s, _r, _g, _b) in enumerate(lumas):
        t = max(0.0, min(1.0, l))
        c = mix(ramp[0], ramp[1], t * 2.0) if t < 0.5 else mix(ramp[1], ramp[2], (t - 0.5) * 2.0)
        attr.data[li].color = (c[0] * VC_GAIN, c[1] * VC_GAIN, c[2] * VC_GAIN, 1.0)
    me.color_attributes.active_color = attr
    for p in me.polygons:
        p.use_smooth = False
        p.material_index = BODY
        if ember_if is not None:
            hits = sum(1 for li in p.loop_indices if ember_if(lumas[li][2], lumas[li][3], lumas[li][4]))
            if hits * 2 > len(p.loop_indices):
                p.material_index = EMBER
    PARTS.append(ob)
    return ob


def grime(ob, low=0.4, strength=0.5, tint=ABYSS, noise=0.12, seed=7):
    """Suja uma peca ja colorida: escurece perto do chao e por face (multiplicativo, preserva o valor do kit)."""
    me = ob.data
    attr = me.color_attributes["Col"]
    for poly in me.polygons:
        n = _hash(poly.center.x, poly.center.y, poly.center.z, seed)
        for li in poly.loop_indices:
            z = me.vertices[me.loops[li].vertex_index].co.z
            k = 0.0
            if low > 0 and z < low:
                k += strength * (1.0 - z / low)
            k += (n - 0.5) * noise
            c = attr.data[li].color
            m = mix((c[0], c[1], c[2]), tint, max(0.0, k))
            attr.data[li].color = (m[0], m[1], m[2], 1.0)


# ---------------------------------------------------------------- saida


def tri_count():
    return sum(len(p.data.loop_triangles) if p.data.loop_triangles else 0 for p in PARTS)


def export(name, out_dir, center_xy=True):
    objs = [o for o in PARTS if o.name in bpy.data.objects]
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    ob = bpy.context.active_object
    ob.name = name
    me = ob.data
    zs = [v.co.z for v in me.vertices]
    xs = [v.co.x for v in me.vertices]
    ys = [v.co.y for v in me.vertices]
    dx = -(min(xs) + max(xs)) / 2.0 if center_xy else 0.0
    dy = -(min(ys) + max(ys)) / 2.0 if center_xy else 0.0
    me.transform(Matrix.Translation((dx, dy, -min(zs))))
    for p in me.polygons:
        p.use_smooth = False
    me.calc_loop_triangles()
    tris = len(me.loop_triangles)
    ob.select_set(True)
    path = os.path.join(out_dir, name + ".glb")
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=True, export_apply=True,
                              export_vertex_color="ACTIVE", export_materials="EXPORT")
    dims = (max(xs) - min(xs), max(ys) - min(ys), max(zs) - min(zs))
    print("MODELO", path, "tris", tris, "dims", [round(d, 2) for d in dims])
    return tris


def ring_tube(center, R, r, plane="xz", segs=10, sides=5, fn=None, tilt=0.0, name="ring"):
    """Toro grosso (colar, elo de corrente, aro) como tubo fechado."""
    cx, cy, cz = center
    pts = []
    for i in range(segs + 1):
        a = math.tau * i / segs
        if plane == "xz":
            pts.append((cx + math.cos(a) * R, cy + math.sin(a) * R * math.sin(tilt), cz + math.sin(a) * R * math.cos(tilt)))
        elif plane == "xy":
            pts.append((cx + math.cos(a) * R, cy + math.sin(a) * R, cz))
        else:
            pts.append((cx, cy + math.cos(a) * R, cz + math.sin(a) * R))
    up = (0, 1, 0) if plane == "xz" else (0, 0, 1)
    return tube(pts, [r] * len(pts), sides=sides, fn=fn, up=up, caps=(False, False), name=name)




def prism(pts2d, thick, origin=(0, 0, 0), plane="yz", fn=None, name="prism", rot=(0, 0, 0)):
    """Poligono 2D extrudado (laminas, mascaras, placas). plane yz: u=-y (para frente), v=z, espessura em x."""
    bm = bmesh.new()
    lo, hi = [], []
    for (u, v) in pts2d:
        if plane == "yz":
            lo.append(bm.verts.new((-thick / 2, -u, v)))
            hi.append(bm.verts.new((thick / 2, -u, v)))
        elif plane == "xz":
            lo.append(bm.verts.new((u, -thick / 2, v)))
            hi.append(bm.verts.new((u, thick / 2, v)))
        else:
            lo.append(bm.verts.new((u, v, -thick / 2)))
            hi.append(bm.verts.new((u, v, thick / 2)))
    n = len(pts2d)
    bm.faces.new(lo[::-1])
    bm.faces.new(hi)
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((lo[i], lo[j], hi[j], hi[i]))
    m = Matrix.Translation(origin) @ Matrix(mathutils.Euler([math.radians(a) for a in rot]).to_matrix()).to_4x4()
    for v in bm.verts:
        v.co = m @ v.co
    return _finish(bm, name, fn)
