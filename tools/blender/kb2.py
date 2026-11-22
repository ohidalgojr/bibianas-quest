# TASK-062 rodada 2: corpo por Skin modifier + subdivisao + decimate, cabecas/maos modeladas, panos em folha
# e UMA textura 256x256 assada por inimigo (regioes: atadura, ferrugem, cera, madeira, pano) com decalques
# (orbitas, rebites, sangue). O Godot so usa cor de vertice na segunda superficie, entao a cor vai para
# a textura e o atributo de cor sai do glb.
import math
import os

import bmesh
import bpy
import numpy as np
from mathutils import Euler, Matrix, Vector

import kitbash_lib as L
from kitbash_lib import *  # noqa: F401,F403

R_PLAIN, R_BAND, R_RUST, R_WAX, R_WOOD, R_CLOTH = 0.0, 0.2, 0.4, 0.6, 0.8, 1.0
DECALS: list = []
STREAK = {"amount": 0.35, "scale": 34.0}


def decal(center, radius, color, alpha=1.0, squash=(1.0, 1.0, 1.0)):
    DECALS.append((Vector(center), radius, color, alpha, squash))


def reset2(ember="amber"):
    L.EMBER_COLOR = (1.0, 0.36, 0.04, 1.0) if ember == "amber" else (0.54, 0.51, 0.2, 1.0)
    L.reset()
    DECALS.clear()
    STREAK.update({"amount": 0.35, "scale": 34.0})


# ------------------------------------------------------------------ corpo por Skin modifier


def skin_body(name, nodes, edges, root, fn, subdiv=1, target_tris=None):
    keys = list(nodes)
    idx = {k: i for i, k in enumerate(keys)}
    bm = bmesh.new()
    vs = [bm.verts.new(nodes[k][0]) for k in keys]
    for a, b in edges:
        bm.edges.new((vs[idx[a]], vs[idx[b]]))
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(name, me)
    bpy.context.collection.objects.link(ob)
    bpy.context.view_layer.objects.active = ob
    ob.select_set(True)
    bpy.ops.object.modifier_add(type="SKIN")
    sk = me.skin_vertices[0].data
    for k, i in idx.items():
        r = nodes[k][1]
        r = (r, r) if not isinstance(r, (tuple, list)) else r
        sk[i].radius = r
        sk[i].use_root = k == root
    ob.modifiers["Skin"].use_smooth_shade = False
    ob.modifiers["Skin"].branch_smoothing = 0.6
    bpy.ops.object.modifier_apply(modifier="Skin")
    if subdiv:
        m = ob.modifiers.new("sub", "SUBSURF")
        m.levels = subdiv
        m.render_levels = subdiv
        bpy.ops.object.modifier_apply(modifier=m.name)
    me = ob.data
    if target_tris:
        me.calc_loop_triangles()
        cur = len(me.loop_triangles)
        if cur > target_tris:
            d = ob.modifiers.new("dec", "DECIMATE")
            d.ratio = max(0.05, target_tris / cur)
            bpy.ops.object.modifier_apply(modifier=d.name)
    me = ob.data
    me.materials.clear()
    for m in L._MATS:
        me.materials.append(m)
    for p in me.polygons:
        p.use_smooth = False
        p.material_index = L.BODY
    ob.select_set(False)
    L.PARTS.append(ob)
    paint(ob, fn)
    return ob


# ------------------------------------------------------------------ cabeca e mao


def xf(p, center, rot):
    e = Euler([math.radians(a) for a in rot])
    return Vector(center) + e.to_matrix() @ Vector(p)


def head2(center, h=0.5, w=0.36, d=0.42, rot=(0, 0, 0), skin=None, hollow=0.7, long_face=1.0, name="head"):
    """Cabeca adulta modelada por aneis: testa alta, arcada, macas fundas, mandibula, queixo. Devolve olhos."""
    rings = [(0.00, 0.12, 0.16, -0.08), (0.08, 0.20, 0.24, -0.06), (0.20, 0.27, 0.30, -0.03),
             (0.34, 0.20 + 0.14 * hollow, 0.34, -0.01), (0.46, 0.40, 0.42, 0.0), (0.56, 0.47, 0.47, 0.0),
             (0.66, 0.44, 0.50, 0.02), (0.76, 0.48, 0.52, 0.03), (0.88, 0.43, 0.47, 0.05), (0.96, 0.30, 0.34, 0.06), (1.0, 0.12, 0.16, 0.06)]
    pts = [xf((0, yc * d, (f - 0.5) * h * long_face), center, rot) for f, rx, ry, yc in rings]
    tube(pts, [(rx * w, ry * d) for f, rx, ry, yc in rings], sides=10, fn=skin, up=(0, -1, 0), name=name)
    nose = [xf((0, -0.40 * d, 0.02 * h), center, rot), xf((0, -0.60 * d, -0.14 * h), center, rot)]
    tube(nose, [0.10 * w, 0.02 * w], sides=4, fn=skin, up=(1, 0, 0), name="nose")
    eyes = []
    for sx in (-1, 1):
        ep = xf((sx * 0.22 * w, -0.47 * d, 0.1 * h), center, rot)
        eyes.append(ep)
        decal(ep, 0.10 * w, ABYSS, 1.0, (1.0, 1.0, 0.8))
    decal(xf((0, -0.45 * d, -0.26 * h), center, rot), 0.16 * w, ABYSS, 0.9, (1.0, 0.6, 0.3))
    return eyes


def hand2(wrist, s=0.32, dirv=(0, 0, -1), curl=0.5, fn=None, spread=1.0, name="hand"):
    """Mao longa: palma achatada, 4 dedos de 3 falanges grossos e um polegar."""
    w = Vector(wrist)
    dv = Vector(dirv).normalized()
    side = dv.cross(Vector((0, 1, 0)))
    if side.length < 0.1:
        side = Vector((1, 0, 0))
    side.normalize()
    fwd = Vector((0, -1, 0))
    blob(w + dv * 0.35 * s, (0.30 * s, 0.14 * s, 0.34 * s), fn=fn, subdiv=1, name="palm")
    for i, off in enumerate((-1.5, -0.5, 0.5, 1.5)):
        base = w + dv * 0.6 * s + side * off * 0.17 * s * spread
        ln = (0.95, 1.15, 1.1, 0.8)[i] * s * 1.25
        p1 = base + dv * 0.4 * ln + fwd * curl * 0.05 * ln
        p2 = p1 + dv * 0.35 * ln + fwd * curl * 0.2 * ln
        p3 = p2 + dv * 0.3 * ln + fwd * curl * 0.35 * ln
        tube([base, p1, p2, p3], [0.12 * s, 0.10 * s, 0.085 * s, 0.045 * s], sides=5, fn=fn, name="finger")
    tb = w + dv * 0.25 * s + side * 0.32 * s
    tube([tb, tb + side * 0.3 * s + dv * 0.15 * s, tb + side * 0.45 * s + dv * 0.5 * s + fwd * 0.2 * s],
         [0.14 * s, 0.11 * s, 0.055 * s], sides=5, fn=fn, name="thumb")


# ------------------------------------------------------------------ textura


def _fract(x):
    return x - np.floor(x)


def vnoise(x, y, z):
    xi, yi, zi = np.floor(x), np.floor(y), np.floor(z)
    xf_, yf_, zf_ = x - xi, y - yi, z - zi
    xf_ = xf_ * xf_ * (3 - 2 * xf_)
    yf_ = yf_ * yf_ * (3 - 2 * yf_)
    zf_ = zf_ * zf_ * (3 - 2 * zf_)

    def h(a, b, c):
        return _fract(np.sin(a * 127.1 + b * 311.7 + c * 74.7) * 43758.5453)
    out = 0
    for dx in (0, 1):
        for dy in (0, 1):
            for dz in (0, 1):
                wgt = (xf_ if dx else 1 - xf_) * (yf_ if dy else 1 - yf_) * (zf_ if dz else 1 - zf_)
                out = out + wgt * h(xi + dx, yi + dy, zi + dz)
    return out


def fbm(p, f, oct=3):
    t, a, s = 0, 0.5, 0
    for _ in range(oct):
        t = t + a * vnoise(p[..., 0] * f, p[..., 1] * f, p[..., 2] * f)
        s += a
        a *= 0.5
        f *= 2.1
    return t / s


def _srgb(c):
    c = np.clip(c, 0, 1)
    return np.where(c <= 0.0031308, c * 12.92, 1.055 * np.power(c, 1 / 2.4) - 0.055)


def bake(ob, size=256):
    """UV (smart project), rasteriza cor/posicao/normal, sombreia por regiao + decalques e liga a textura."""
    bpy.ops.object.select_all(action="DESELECT")
    ob.select_set(True)
    bpy.context.view_layer.objects.active = ob
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(70), island_margin=0.006)
    bpy.ops.object.mode_set(mode="OBJECT")
    me = ob.data
    me.calc_loop_triangles()
    uv = me.uv_layers.active.data
    col = me.color_attributes["Col"].data
    S = size
    C = np.zeros((S, S, 4), np.float32)
    P = np.zeros((S, S, 3), np.float32)
    N = np.zeros((S, S, 3), np.float32)
    M = np.zeros((S, S), bool)
    verts = me.vertices
    for tri in me.loop_triangles:
        if me.polygons[tri.polygon_index].material_index == L.EMBER:
            continue
        uvs = np.array([uv[l].uv for l in tri.loops], np.float64) * S
        x0 = int(max(0, math.floor(uvs[:, 0].min() - 1)))
        x1 = int(min(S - 1, math.ceil(uvs[:, 0].max() + 1)))
        y0 = int(max(0, math.floor(uvs[:, 1].min() - 1)))
        y1 = int(min(S - 1, math.ceil(uvs[:, 1].max() + 1)))
        xs, ys = np.meshgrid(np.arange(x0, x1 + 1) + 0.5, np.arange(y0, y1 + 1) + 0.5)
        a, b, c = uvs
        den = (b[1] - c[1]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[1] - c[1])
        if abs(den) < 1e-9:
            continue
        w0 = ((b[1] - c[1]) * (xs - c[0]) + (c[0] - b[0]) * (ys - c[1])) / den
        w1 = ((c[1] - a[1]) * (xs - c[0]) + (a[0] - c[0]) * (ys - c[1])) / den
        w2 = 1 - w0 - w1
        eps = -0.02
        inside = (w0 >= eps) & (w1 >= eps) & (w2 >= eps)
        if not inside.any():
            continue
        cs = np.array([col[l].color for l in tri.loops], np.float32)
        ps = np.array([verts[v].co for v in tri.vertices], np.float32)
        W = np.stack([w0, w1, w2], -1)[inside]
        yy, xx = ys[inside].astype(int), xs[inside].astype(int)
        C[yy, xx] = W @ cs
        P[yy, xx] = W @ ps
        N[yy, xx] = np.array(tri.normal)
        M[yy, xx] = True
    for _ in range(4):
        need = ~M
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            Ms = np.roll(M, (dy, dx), (0, 1))
            fill = need & Ms
            for arr in (C, P, N):
                arr[fill] = np.roll(arr, (dy, dx), (0, 1))[fill]
            M = M | fill
            need = ~M
    base = C[..., :3].astype(np.float64)
    reg = C[..., 3]
    n1 = fbm(P, 5.0)
    n2 = fbm(P, 22.0)
    grain = np.random.RandomState(3).rand(S, S)
    mult = 0.80 + 0.45 * n1 + 0.22 * (n2 - 0.5) + 0.08 * (grain - 0.5)
    col_ = base * mult[..., None]
    # riscos verticais de sujeira/ferrugem escorrida
    st = vnoise((P[..., 0] + P[..., 1]) * STREAK["scale"], P[..., 2] * 1.5, np.zeros_like(n1))
    streak = np.clip((st - 0.58) * 4.0, 0, 1) * np.clip(1.2 - P[..., 2] * 0.4, 0.2, 1)
    col_ = col_ * (1 - STREAK["amount"] * streak)[..., None]
    z = P[..., 2]
    dg = np.array
    # atadura em espiral
    band = np.abs(reg - R_BAND) < 0.1
    sp = np.sin((P[..., 0] * 0.9 + P[..., 1] * 0.7 + z * 1.6) * 38.0 + n1 * 3)
    col_ = np.where(band[..., None], col_ * (0.62 + 0.55 * (sp > 0.0))[..., None] * 1.0 + 0.0, col_)
    # metal enferrujado
    rust = np.abs(reg - R_RUST) < 0.1
    spots = np.clip((fbm(P, 14.0) - 0.55) * 5, 0, 1)
    rcol = np.stack([0.11 * np.ones_like(n1), 0.075 * np.ones_like(n1), 0.055 * np.ones_like(n1)], -1)
    col_ = np.where(rust[..., None], col_ * (1 - 0.55 * spots)[..., None] + rcol * spots[..., None] * 0.9, col_)
    # cera: gotas e camadas
    wax = np.abs(reg - R_WAX) < 0.1
    layer = 0.78 + 0.35 * np.sin(z * 55 + n1 * 5)
    col_ = np.where(wax[..., None], col_ * layer[..., None], col_)
    # madeira: veios
    wood = np.abs(reg - R_WOOD) < 0.1
    grainw = 0.72 + 0.42 * (np.sin(P[..., 0] * 46 + P[..., 1] * 12 + n2 * 4) > -0.3)
    col_ = np.where(wood[..., None], col_ * grainw[..., None], col_)
    # pano: trama e manchas
    cl = np.abs(reg - R_CLOTH) < 0.1
    weave = 0.88 + 0.12 * np.sin(P[..., 0] * 160) * np.sin(z * 160 + P[..., 1] * 160)
    patch = np.clip((fbm(P + 3.3, 7.0) - 0.62) * 5, 0, 1)
    col_ = np.where(cl[..., None], col_ * weave[..., None] * (1 - 0.5 * patch)[..., None], col_)
    for (cen, rad, dc, al, sq) in DECALS:
        dv = (P - np.array(cen)) / (rad * np.array(sq))
        dd = np.sqrt((dv ** 2).sum(-1))
        a = np.clip(1.4 - dd * 1.4, 0, 1) * al
        col_ = col_ * (1 - a[..., None]) + np.array(dc) * a[..., None]
    col_ = col_ * L.EXPOSURE
    out = _srgb(col_)
    rgba = np.concatenate([out, np.ones((S, S, 1))], -1).astype(np.float32)
    img = bpy.data.images.new(ob.name + "_tex", S, S)
    img.pixels.foreach_set(rgba.ravel())
    img.pack()
    body = L._MATS[L.BODY]
    nt = body.node_tree
    for n in list(nt.nodes):
        if n.type == "TEX_IMAGE":
            nt.nodes.remove(n)
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = img
    tex.interpolation = "Closest"
    bsdf = nt.nodes["Principled BSDF"]
    for l in list(bsdf.inputs["Base Color"].links):
        nt.links.remove(l)
    nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Base Color"].default_value = (0.98, 0.98, 0.98, 1.0)
    return img


def export2(name, out_dir, size=256, target=None):
    objs = [o for o in L.PARTS if o.name in bpy.data.objects]
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    ob = bpy.context.active_object
    ob.name = name
    me = ob.data
    for p in me.polygons:
        p.use_smooth = False
    # fecha o atributo de cor em todos os cantos: pecas sem pintura viram preto
    zs = [v.co.z for v in me.vertices]
    xs = [v.co.x for v in me.vertices]
    ys = [v.co.y for v in me.vertices]
    sh = Vector((-(min(xs) + max(xs)) / 2.0, -(min(ys) + max(ys)) / 2.0, -min(zs)))
    me.transform(Matrix.Translation(sh))
    DECALS[:] = [(c + sh, r, dc, al, sq) for (c, r, dc, al, sq) in DECALS]
    for uvl in list(me.uv_layers):
        me.uv_layers.remove(uvl)
    bake(ob, size)
    me = ob.data
    me.color_attributes.remove(me.color_attributes["Col"])
    me.calc_loop_triangles()
    tris = len(me.loop_triangles)
    ob.select_set(True)
    path = os.path.join(out_dir, name + ".glb")
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=True, export_apply=True,
                              export_vertex_color="NONE", export_materials="EXPORT")
    print("MODELO", path, "tris", tris, "dims", [round(max(a) - min(a), 2) for a in (xs, ys, zs)])
    return tris
