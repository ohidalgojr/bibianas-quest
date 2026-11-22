# Cinco inimigos do lote 1 (rodada 2): Skin modifier + props + textura assada. Ver kb2.py.
from kb2_common import *  # noqa: F401,F403


def _graph(nodes, chain_edges):
    return nodes, chain_edges


def humanoid_legs(nodes, edges, hip_y, hip_x, hip_r, knee, ankle, toe, pelvis="pelvis"):
    """Acrescenta pernas simetricas: knee/ankle/toe = (x, y, z, r)."""
    for sx, tag in ((-1, "L"), (1, "R")):
        nodes["hp" + tag] = ((sx * hip_x, hip_y, knee[2] + 0.45), hip_r)
        nodes["kn" + tag] = ((sx * knee[0], knee[1], knee[2]), knee[3])
        nodes["an" + tag] = ((sx * ankle[0], ankle[1], ankle[2]), ankle[3])
        nodes["to" + tag] = ((sx * toe[0], toe[1], toe[2]), toe[3])
        edges += [(pelvis, "hp" + tag), ("hp" + tag, "kn" + tag), ("kn" + tag, "an" + tag), ("an" + tag, "to" + tag)]


# =============================================================== MEDICO DA CERA (conceito 04)


def wax_physician():
    cape = P("#2C3440", "#12161C", "#485464", R_CLOTH, low=0.5, grime=0.5, noise=0.16, seed=81, top=0.3)
    cape_d = P("#1E242C", "#0C0F13", "#323C48", R_CLOTH, noise=0.14, seed=82, low=0.5)
    wax = P("#4E4630", "#24200F", "#665C3E", R_WAX, noise=0.14, seed=83, top=0.4)
    leather = P("#3A322C", "#16120E", "#544A40", R_PLAIN, noise=0.2, seed=84)
    brass = P("#40381F", "#161208", "#5E5230", R_RUST, noise=0.2, seed=85)
    steel = P("#505A68", "#1E2228", "#76849A", R_RUST, noise=0.25, seed=86)
    glove = P("#3A322C", "#16100A", "#4E443A", R_PLAIN, noise=0.18, seed=87)
    wick = P("#1A1410", region=R_PLAIN, noise=0.0)
    nodes = {
        "pelvis": ((0, 0.28, 0.95), (0.16, 0.12)), "spine": ((0, 0.08, 1.25), (0.17, 0.13)), "chest": ((0, -0.2, 1.46), (0.2, 0.15)),
        "neck": ((0, -0.36, 1.52), 0.07),
        "shL": ((-0.32, -0.22, 1.5), 0.085), "shR": ((0.32, -0.22, 1.5), 0.085),
        "elR": ((0.5, -0.32, 1.12), 0.075), "wrR": ((0.42, -0.5, 0.88), 0.065),
        "elL": ((-0.5, -0.25, 1.1), 0.075), "wrL": ((-0.46, -0.3, 0.6), 0.065),
    }
    edges = [("pelvis", "spine"), ("spine", "chest"), ("chest", "neck"), ("chest", "shL"), ("chest", "shR"), ("shL", "elL"), ("elL", "wrL"),
             ("shR", "elR"), ("elR", "wrR")]
    humanoid_legs(nodes, edges, 0.26, 0.15, 0.1, (0.17, 0.1, 0.5, 0.08), (0.16, 0.16, 0.1, 0.06), (0.16, -0.06, 0.04, 0.06))
    skin_body("body", nodes, edges, "pelvis", body_painter(skin=hexc("#262C36"), band_below=0.2, band_color=hexc("#2A2420"), seed=4), subdiv=1, target_tris=800)
    cloth((0, 0.14, 0), 1.58, 0.2, (0.5, 0.36), (0.84, 0.64), n=14, rows=4, fold=0.08, jag=0.22, seed=88, fn=cape, name="cape")
    cloth((0, -0.08, 0), 1.72, 1.0, (0.46, 0.34), (0.74, 0.58), n=12, rows=3, fold=0.06, jag=0.18, seed=89, fn=cape_d, name="cape2")
    blob((0, 0.12, 1.7), (0.66, 0.44, 0.28), fn=wax, jitter=0.07, seed=12, subdiv=2, name="waxcap")
    drips = [(-0.62, -0.1, 0.55), (-0.46, -0.4, 0.4), (-0.22, -0.48, 0.58), (0.0, -0.5, 0.3), (0.22, -0.48, 0.38), (0.46, -0.4, 0.52), (0.64, -0.08, 0.44),
             (0.52, 0.3, 0.5), (0.2, 0.46, 0.4), (-0.2, 0.46, 0.55), (-0.52, 0.3, 0.42), (-0.66, -0.24, 0.3), (0.66, -0.26, 0.32), (0.0, 0.5, 0.6)]
    for (x, y, ln) in drips:
        y = y * 0.85 + 0.12
        tube([(x * 0.96, y * 0.96, 1.7), (x * 1.04, y * 1.04, 1.7 - ln * 0.6), (x * 1.04, y * 1.04, 1.7 - ln)], [0.09, 0.075, 0.0], sides=5, fn=wax, name="drip")
    candles = [(-0.42, -0.1, 0.32), (-0.24, -0.32, 0.46), (0.0, -0.12, 0.62), (0.26, -0.3, 0.38), (0.44, -0.06, 0.3), (-0.2, 0.2, 0.4),
               (0.2, 0.22, 0.34), (0.0, -0.38, 0.26), (-0.52, 0.12, 0.22), (0.52, 0.14, 0.24), (-0.08, 0.36, 0.3), (0.3, 0.02, 0.5)]
    lit = {2, 3, 7, 11}
    for i, (x, y, hh) in enumerate(candles):
        y = y * 0.85 + 0.12
        z0 = 1.92 - 0.12 * (abs(x) + abs(y))
        tube([(x, y, z0), (x, y, z0 + hh)], [0.05, 0.045], sides=6, fn=wax, name="candle")
        if i in lit:
            fl = tube([(x, y, z0 + hh), (x, y, z0 + hh + 0.07), (x, y, z0 + hh + 0.17)], [0.045, 0.04, 0.0], sides=5, name="flame")
            set_ember(fl)
        else:
            blob((x, y, z0 + hh + 0.01), (0.035, 0.035, 0.018), fn=wick, name="wick")
    hc = (0, -0.52, 1.5)
    head2(hc, h=0.38, w=0.30, d=0.32, rot=(30, 0, 0), skin=leather, hollow=0.8, name="mask")
    B.DECALS.clear()
    tube([xf((0, -0.1, 0.02), hc, (30, 0, 0)), xf((0, -0.42, -0.02), hc, (30, 0, 0)), xf((0, -0.72, -0.2), hc, (30, 0, 0)), xf((0, -0.86, -0.42), hc, (30, 0, 0))],
         [(0.12, 0.12), (0.095, 0.095), (0.06, 0.06), (0.012, 0.012)], sides=6, fn=leather, up=(1, 0, 0), name="beak")
    for sx in (-1, 1):
        ep = xf((sx * 0.075, -0.18, 0.06), hc, (30, 0, 0))
        ring_tube(ep, 0.06, 0.03, plane="xz", segs=7, fn=brass, name="goggle")
        decal(ep, 0.05, ABYSS, 1.0)
    hand2((0.42, -0.5, 0.88), s=0.34, curl=0.9, fn=glove, dirv=(0, -0.6, -0.8), name="handR")
    tube([(0.38, -0.5, 0.96), (0.32, -1.1, 0.64)], [0.11, 0.11], sides=7, fn=brass, name="barrel")
    ring_tube((0.37, -0.56, 0.93), 0.14, 0.035, plane="yz", segs=7, fn=brass, name="flange")
    tube([(0.32, -1.1, 0.64), (0.3, -1.28, 0.55)], [0.07, 0.05], sides=6, fn=steel, name="collar")
    saw = [(0.0, 0.1), (1.05, 0.1), (1.05, -0.1)]
    for i in range(7):
        x = 1.05 - 0.15 * i
        saw += [(x - 0.075, -0.2), (x - 0.15, -0.1)]
    saw += [(0.0, -0.1)]
    prism(saw, 0.06, origin=(0.3, -1.2, 0.52), plane="yz", fn=steel, name="saw", rot=(16, 0, 0))
    hand2((-0.46, -0.3, 0.6), s=0.36, curl=0.6, fn=glove, name="handL")
    B.STREAK.update({"amount": 0.4})


# =============================================================== O COVEIRO


def gravedigger():
    coat = P("#35322E", "#14120F", "#52504A", R_CLOTH, low=0.6, grime=0.6, noise=0.14, seed=11, top=0.3)
    coat_d = P("#26282C", "#101113", "#3A3E44", R_CLOTH, low=0.5, grime=0.5, noise=0.12, seed=12)
    hat = P("#26282E", "#0E0F12", "#3C4048", R_CLOTH, noise=0.12, seed=16, top=0.3)
    wood = P("#4A3C2E", "#1A130D", "#6A5844", R_WOOD, noise=0.2, seed=14)
    steel = P("#4E5666", "#1C2026", "#707C90", R_RUST, noise=0.25, seed=15)
    glove = P("#36404A", "#1A2026", "#4E5A66", R_PLAIN, noise=0.14, seed=17)
    iron = P("#2E3238", "#121417", "#4A5058", R_RUST, noise=0.25, seed=18)
    nodes = {
        "pelvis": ((0, 0.32, 1.0), (0.2, 0.15)), "spine": ((0, 0.22, 1.4), (0.24, 0.17)), "chest": ((0, -0.12, 1.76), (0.32, 0.2)),
        "hump": ((0, 0.4, 1.68), (0.3, 0.24)), "neck": ((0, -0.4, 1.84), 0.1),
        "shL": ((-0.46, -0.1, 1.78), 0.12), "shR": ((0.46, -0.1, 1.78), 0.12),
        "elL": ((-0.62, -0.2, 1.3), 0.1), "wrL": ((-0.6, -0.4, 0.72), 0.085),
        "elR": ((0.64, -0.22, 1.4), 0.1), "wrR": ((0.64, -0.4, 1.1), 0.09),
    }
    edges = [("pelvis", "spine"), ("spine", "chest"), ("spine", "hump"), ("chest", "neck"), ("chest", "shL"), ("chest", "shR"), ("shL", "elL"), ("elL", "wrL"),
             ("shR", "elR"), ("elR", "wrR")]
    humanoid_legs(nodes, edges, 0.3, 0.17, 0.12, (0.2, 0.12, 0.55, 0.1), (0.18, 0.2, 0.12, 0.075), (0.18, -0.04, 0.05, 0.07))
    skin_body("body", nodes, edges, "pelvis", body_painter(skin=hexc("#2A2E34"), seed=5), subdiv=1, target_tris=1500)
    hs = P("#4A5560", "#242A32", "#667282", R_PLAIN, noise=0.12, seed=19)
    hand2((0.64, -0.4, 1.1), s=0.62, curl=1.0, fn=glove, dirv=(0, -0.5, -0.8), name="handR")
    hand2((-0.6, -0.4, 0.72), s=0.66, curl=0.7, fn=glove, name="handL")
    hc = (0, -0.62, 1.78)
    head2(hc, h=0.62, w=0.40, d=0.46, rot=(14, 0, 0), skin=hs, hollow=0.45, name="head")
    cloth((0, -0.62, 0), 2.17, 2.07, (0.2, 0.22), (0.66, 0.7), n=12, rows=2, fold=0.05, jag=0.06, seed=17, fn=hat, name="brim")
    tube([(0, -0.58, 2.1), (0, -0.56, 2.5)], [(0.27, 0.29), (0.2, 0.22)], sides=10, fn=hat, up=(0, -1, 0), name="crown")
    cloth((0, 0.12, 0), 1.76, 0.24, (0.46, 0.3), (0.82, 0.62), n=14, rows=4, fold=0.08, jag=0.24, seed=21, fn=coat, name="coat")
    cloth((0, 0.14, 0), 1.9, 1.0, (0.52, 0.32), (0.74, 0.46), n=11, arc=(95, 265), rows=3, fold=0.05, jag=0.2, seed=22, fn=coat_d, name="mantle")
    cof = [(-0.22, -0.85), (0.22, -0.85), (0.36, -0.25), (0.24, 0.85), (-0.24, 0.85), (-0.36, -0.25)]
    prism(cof, 0.34, origin=(0, 0.72, 1.55), plane="xz", fn=wood, name="coffin", rot=(-26, 0, 0))
    for zz in (-0.45, 0.35):
        prism([(-0.4, zz), (0.4, zz), (0.4, zz + 0.12), (-0.4, zz + 0.12)], 0.4, origin=(0, 0.72, 1.55), plane="xz", fn=iron, name="strap", rot=(-26, 0, 0))
    tube([(0.64, -0.4, 0.85), (0.7, -0.3, 2.35)], [0.085, 0.085], sides=6, fn=wood, name="pole")
    spade = [(-0.12, 0.0), (0.12, 0.0), (0.38, -0.25), (0.36, -0.58), (0.0, -0.9), (-0.36, -0.58), (-0.38, -0.25)]
    prism(spade, 0.08, origin=(0.64, -0.42, 0.95), plane="xz", fn=steel, name="blade")
    box((0.7, -0.3, 2.4), (0.34, 0.1, 0.1), fn=wood, name="handle")
    kit(K + "/lantern-glass.glb", "lantern-glass", loc=(0.0, -1.22, 2.06), scale=(1.3, 1.3, 1.3), pivot=(0, 0, 0.2),
        ramp=(IRON, hexc("#34373E"), hexc("#50545E")),
        ember_if=lambda r, g, b: r > 0.7 and g > 0.55 and b < 0.45, name="lamp")
    B.STREAK.update({"amount": 0.4})


# =============================================================== CARRASCO APODRECIDO


def rotten_executioner():
    flesh = hexc("#3E4752")
    mud = P("#3A3128", "#14100C", "#564838", R_CLOTH, low=0.6, grime=0.5, noise=0.2, seed=62)
    hood = P("#232A33", "#0C0F13", "#3A4553", R_CLOTH, noise=0.14, seed=63, low=0.5)
    leather = P("#3A3128", "#14100C", "#54463A", R_PLAIN, noise=0.2, seed=60)
    iron = P("#2E3238", "#121417", "#4E545E", R_RUST, noise=0.25, seed=64)
    steel = P("#586272", "#20242B", "#7E8FA8", R_RUST, noise=0.25, seed=65)
    nodes = {
        "pelvis": ((0, 0.16, 1.05), (0.3, 0.2)), "spine": ((0, 0.02, 1.4), (0.38, 0.24)), "chest": ((0, -0.14, 1.72), (0.5, 0.28)),
        "neck": ((0, -0.3, 1.95), 0.17),
        "shL": ((-0.64, -0.1, 1.78), 0.17), "shR": ((0.64, -0.1, 1.78), 0.17),
        "elL": ((-0.82, -0.2, 1.28), 0.15), "wrL": ((-0.76, -0.42, 0.78), 0.13),
        "elR": ((0.9, -0.38, 1.5), 0.15), "wrR": ((0.66, -0.66, 1.7), 0.13),
    }
    edges = [("pelvis", "spine"), ("spine", "chest"), ("chest", "neck"), ("chest", "shL"), ("chest", "shR"), ("shL", "elL"), ("elL", "wrL"),
             ("shR", "elR"), ("elR", "wrR")]
    humanoid_legs(nodes, edges, 0.14, 0.24, 0.18, (0.28, 0.04, 0.55, 0.14), (0.26, 0.1, 0.12, 0.1), (0.26, -0.1, 0.06, 0.09))

    def bp(co, n, cen):
        if co.z < 0.95 and abs(co.x) < 0.45:
            return (*hexc("#232A33"), R_CLOTH)
        c = mix(flesh, STEEL, 0.2) if n.z > 0.3 else (mix(flesh, SKIN_DK, 0.5) if n.z < -0.3 else flesh)
        return (*c, R_PLAIN)
    skin_body("body", nodes, edges, "pelvis", bp, subdiv=1, target_tris=1700)
    fh = P("#3E4752", "#262C34", "#566270", R_PLAIN, noise=0.12, seed=41)
    hand2((-0.76, -0.42, 0.78), s=0.62, curl=0.7, fn=fh, name="handL")
    hand2((0.66, -0.66, 1.72), s=0.5, curl=1.3, fn=fh, dirv=(0, -0.2, -1), name="handR")
    cloth((0, -0.1, 0), 1.4, 0.45, (0.38, 0.28), (0.56, 0.4), n=9, arc=(-72, 72), rows=3, fold=0.04, jag=0.2, seed=68, fn=mud, name="apron")
    tube([(-0.55, 0.0, 1.12), (0, -0.34, 1.06), (0.55, 0.0, 1.12)], [0.07] * 3, sides=5, fn=iron, name="belt")
    ring_tube((-0.76, -0.42, 0.84), 0.15, 0.05, plane="xy", segs=8, fn=iron, name="manacle")
    ring_tube((0.66, -0.66, 1.78), 0.14, 0.05, plane="xz", segs=8, fn=iron, name="manacle")
    hc = (0, -0.5, 2.12)
    head2(hc, h=0.7, w=0.5, d=0.54, rot=(22, 0, 0), skin=leather, hollow=0.7, name="mask")
    B.DECALS.clear()
    cloth((0, -0.5, 0), 2.62, 1.85, (0.12, 0.12), (0.5, 0.54), n=11, arc=(40, 320), rows=3, fold=0.08, jag=0.12, seed=69, fn=hood, name="hood")
    tube([(0, -0.46, 2.5), (0, -0.4, 2.7), (-0.14, -0.3, 2.84)], [(0.2, 0.22), (0.14, 0.14), (0.02, 0.02)], sides=7, fn=hood, name="hoodtip")
    eye = blob(xf((-0.1, -0.54 * 0.47, 0.07), hc, (22, 0, 0)), (0.09, 0.04, 0.045), name="slit")
    set_ember(eye)
    decal(xf((0.1, -0.54 * 0.47, 0.07), hc, (22, 0, 0)), 0.07, ABYSS, 1.0, (1, 1, 0.5))
    decal(xf((0, -0.54 * 0.45, -0.22), hc, (22, 0, 0)), 0.12, hexc("#14100C"), 0.9, (1.0, 0.4, 0.2))
    for k in range(4):
        decal(xf((-0.12 + 0.08 * k, -0.54 * 0.45, -0.22), hc, (22, 0, 0)), 0.014, hexc("#7E8FA8"), 0.8, (0.6, 0.6, 3.0))
    tube([(0.66, -0.66, 0.95), (0.64, -0.66, 1.8), (0.56, -0.58, 2.62)], [0.09, 0.09, 0.09], sides=6, fn=leather, name="haft")
    chop = [(0.0, 0.55), (0.7, 0.62), (0.92, 0.3), (0.96, -0.2), (0.88, -0.62), (0.7, -0.7), (0.0, -0.5)]
    prism(chop, 0.16, origin=(0.56, -0.58, 2.1), plane="yz", fn=steel, name="blade", rot=(0, 0, 90))
    prism([(0.84, 0.4), (0.96, 0.2), (0.96, -0.2), (0.86, -0.62), (0.9, -0.0)], 0.2, origin=(0.56, -0.58, 2.1), plane="yz", fn=iron, name="edge", rot=(0, 0, 90))
    box((0.56, -0.58, 2.1), (0.22, 0.34, 0.5), fn=iron, name="socket")
    decal((1.3, -0.58, 2.0), 0.18, BLOOD, 0.8, (1, 1, 1))
    decal((1.1, -0.58, 1.7), 0.12, BLOOD, 0.8, (1, 1, 1))
    for i, x in enumerate((-0.3, 0.0, 0.3)):
        ring_tube((x, -0.36, 0.95 - 0.1 * i), 0.08, 0.04, plane="xz", segs=6, fn=iron, name="chain")
    B.STREAK.update({"amount": 0.4})


# =============================================================== RASTEJADOR DA VALA (conceito 08)


def trench_crawler():
    wood = P("#3C3730", "#14110D", "#585046", R_WOOD, noise=0.3, seed=94)
    iron = P("#2E3238", "#121417", "#4A5058", R_RUST, noise=0.25, seed=95)
    rag = P("#4A4A3E", "#1E1E18", "#5E5E4E", R_CLOTH, low=0.2, noise=0.2, seed=93)
    skc = hexc("#4A423C")
    nodes = {
        "pelvis": ((0, 0.5, 0.82), (0.2, 0.18)), "mid": ((0, 0.12, 1.0), (0.2, 0.18)), "chest": ((0, -0.3, 0.92), (0.24, 0.2)), "neck": ((0, -0.52, 0.7), 0.085),
    }
    edges = [("pelvis", "mid"), ("mid", "chest"), ("chest", "neck")]
    for sx, tag in ((-1, "L"), (1, "R")):
        nodes.update({
            "sh" + tag: ((sx * 0.3, -0.42, 0.86), 0.12), "bi" + tag: ((sx * 0.46, -0.52, 0.98), 0.125), "el" + tag: ((sx * 0.62, -0.6, 1.04), 0.09),
            "fa" + tag: ((sx * 0.62, -0.82, 0.6), 0.085), "wr" + tag: ((sx * 0.6, -1.0, 0.14), 0.065),
            "hp" + tag: ((sx * 0.26, 0.5, 0.84), 0.13), "th" + tag: ((sx * 0.44, 0.58, 1.0), 0.13), "kn" + tag: ((sx * 0.62, 0.66, 1.08), 0.1),
            "sn" + tag: ((sx * 0.58, 0.86, 0.6), 0.09), "an" + tag: ((sx * 0.52, 1.04, 0.12), 0.07),
        })
        edges += [("chest", "sh" + tag), ("sh" + tag, "bi" + tag), ("bi" + tag, "el" + tag), ("el" + tag, "fa" + tag), ("fa" + tag, "wr" + tag),
                  ("pelvis", "hp" + tag), ("hp" + tag, "th" + tag), ("th" + tag, "kn" + tag), ("kn" + tag, "sn" + tag), ("sn" + tag, "an" + tag)]
    skin_body("body", nodes, edges, "pelvis", body_painter(skin=skc, band_below=0.66, band_color=hexc("#6A6252"), seed=6), subdiv=1, target_tris=1700)
    hp = P("#4A423C", "#2A2420", "#5E544C", R_PLAIN, noise=0.12, seed=43)
    for sx in (-1, 1):
        hand2((sx * 0.6, -1.0, 0.16), s=0.36, dirv=(0, -0.8, -0.5), curl=0.2, spread=1.4, fn=hp, name="hand")
        hand2((sx * 0.52, 1.04, 0.14), s=0.34, dirv=(0, -0.8, -0.5), curl=0.2, spread=1.3, fn=hp, name="foot")
    cloth((0, 0.5, 0), 0.86, 0.3, (0.2, 0.18), (0.3, 0.26), n=8, arc=(130, 230), rows=2, fold=0.05, jag=0.16, seed=96, fn=rag, name="loin")
    hc = (0, -0.74, 0.4)
    head2(hc, h=0.72, w=0.46, d=0.52, rot=(10, 180, 0), skin=P("#5A4E48", "#2E2824", "#6E625A", R_PLAIN, noise=0.12, seed=44), hollow=0.5, name="head")
    for sx in (-1, 1):
        decal(xf((sx * 0.22 * 0.4, -0.47 * 0.46, 0.1 * 0.6), hc, (10, 180, 0)), 0.03, hexc("#7E8FA8"), 1.0)
    lid = [(-0.42, -0.95), (0.42, -0.95), (0.54, -0.3), (0.44, 0.7), (0.2, 0.98), (-0.1, 0.84), (-0.44, 0.95), (-0.54, -0.3)]
    prism(lid, 0.2, origin=(0, 0.1, 1.38), plane="xy", fn=wood, name="lid", rot=(-12, 0, 0))
    prism([(-0.36, -0.8), (0.36, -0.8), (0.36, -0.66), (-0.36, -0.66)], 0.28, origin=(0, 0.1, 1.38), plane="xy", fn=iron, name="strap", rot=(-12, 0, 0))
    prism([(-0.4, 0.3), (0.4, 0.3), (0.4, 0.44), (-0.4, 0.44)], 0.28, origin=(0, 0.1, 1.38), plane="xy", fn=iron, name="strap", rot=(-12, 0, 0))
    for sx in (-1, 1):
        tube([(sx * 0.5, -0.18, 1.34), (sx * 0.34, -0.3, 0.98)], [0.06, 0.05], sides=5, fn=iron, name="strapdown")
    for i, (x, y) in enumerate(((-0.2, 0.9), (0.3, 0.8), (0.0, -0.9))):
        spike((x, y, 1.4), (x + 0.2, y + 0.12, 1.9 + 0.1 * i), 0.08, sides=4, fn=wood, name="splinter")
    glow = box((0.05, 0.0, 1.56), (0.42, 0.05, 0.05), rot=(-12, 0, 0), name="crack")
    set_ember(glow)
    B.STREAK.update({"amount": 0.45})


# =============================================================== CAO DE PESTE


def plague_hound():
    bone = P("#3E444C", "#1A1D22", "#5A626C", R_PLAIN, noise=0.1, seed=4, top=0.15)
    iron = P("#2E3238", "#121417", "#4A5058", R_RUST, noise=0.2, seed=6)
    fur_d = P("#222529", "#0C0D0F", "#34383E", R_PLAIN, noise=0.12, seed=3)
    nodes = {
        "rump": ((0, 0.62, 0.74), (0.17, 0.2)), "loin": ((0, 0.3, 0.8), (0.15, 0.19)), "rib1": ((0, 0.05, 0.88), (0.15, 0.2)),
        "rib2": ((0, -0.2, 0.98), (0.17, 0.24)), "wither": ((0, -0.36, 1.04), (0.2, 0.24)), "neck": ((0, -0.56, 0.98), (0.13, 0.14)), "hbase": ((0, -0.74, 0.9), (0.12, 0.12)),
        "tail1": ((0, 0.78, 0.7), 0.08), "tail2": ((0, 1.0, 0.5), 0.055), "tail3": ((0.05, 1.12, 0.28), 0.03),
    }
    edges = [("rump", "loin"), ("loin", "rib1"), ("rib1", "rib2"), ("rib2", "wither"), ("wither", "neck"), ("neck", "hbase"), ("rump", "tail1"), ("tail1", "tail2"), ("tail2", "tail3")]
    for sx, tag in ((-1, "L"), (1, "R")):
        nodes.update({
            "fs" + tag: ((sx * 0.2, -0.3, 0.9), 0.16), "fe" + tag: ((sx * 0.21, -0.32, 0.55), 0.105), "fw" + tag: ((sx * 0.19, -0.26, 0.2), 0.075), "fp" + tag: ((sx * 0.19, -0.38, 0.05), 0.08),
            "hh" + tag: ((sx * 0.21, 0.55, 0.8), 0.18), "ht" + tag: ((sx * 0.27, 0.46, 0.58), 0.15), "hk" + tag: ((sx * 0.21, 0.68, 0.3), 0.085), "hp" + tag: ((sx * 0.21, 0.6, 0.05), 0.08),
        })
        edges += [("wither", "fs" + tag), ("fs" + tag, "fe" + tag), ("fe" + tag, "fw" + tag), ("fw" + tag, "fp" + tag),
                  ("rump", "hh" + tag), ("hh" + tag, "ht" + tag), ("ht" + tag, "hk" + tag), ("hk" + tag, "hp" + tag)]

    def fp(co, n, cen):
        c = hexc("#2A2D33")
        if n.z > 0.3:
            c = mix(c, hexc("#3E434B"), 0.4)
        elif n.z < -0.3:
            c = mix(c, hexc("#101113"), 0.5)
        if co.z < 0.1:
            c = hexc("#454A52")
        elif co.z < 0.6:
            c = mix(c, hexc("#454A52"), 0.5)
        return (*c, R_PLAIN)
    skin_body("body", nodes, edges, "rump", fp, subdiv=1, target_tris=1500)
    for i, y in enumerate((-0.3, -0.18, -0.06, 0.06, 0.18, 0.3)):
        zc = 0.9 - 0.2 * y
        for sx in (-1, 1):
            tube([(sx * 0.1, y, zc + 0.2), (sx * 0.2, y + 0.02, zc + 0.04), (sx * 0.2, y + 0.04, zc - 0.14), (sx * 0.1, y + 0.06, zc - 0.28)], [0.035, 0.04, 0.035, 0.02], sides=5, fn=bone, name="rib")
    hc = (0, -0.9, 0.92)
    blob(hc, (0.15, 0.22, 0.15), fn=bone, jitter=0.06, seed=9, subdiv=2, name="skull")
    blob((0, -0.98, 1.02), (0.17, 0.11, 0.06), fn=bone, name="brow")
    tube([(0, -1.0, 0.9), (0, -1.28, 0.84)], [(0.115, 0.095), (0.08, 0.06)], sides=6, fn=bone, name="snout")
    tube([(0, -0.96, 0.78), (0, -1.24, 0.62)], [(0.08, 0.05), (0.06, 0.035)], sides=5, fn=bone, name="jaw")
    maw = blob((0, -1.12, 0.75), (0.06, 0.13, 0.025), name="maw")
    set_ember(maw)
    for sx in (-1, 1):
        spike((sx * 0.06, -1.24, 0.8), (sx * 0.065, -1.27, 0.58), 0.04, fn=bone, name="fang")
        spike((sx * 0.1, -0.84, 1.04), (sx * 0.22, -0.64, 1.3), 0.075, fn=fur_d, name="ear")
        decal((sx * 0.11, -1.06, 0.96), 0.05, hexc("#8A834C"), 1.0)
    for i, y in enumerate((-0.24, -0.04, 0.16, 0.36)):
        zt = 1.18 - 0.3 * (y + 0.24) / 0.6
        spike((0, y, zt - 0.08), (0, y + 0.08, zt + 0.16), 0.07, fn=bone, name="dorsal")
    ring_tube((0, -0.58, 1.0), 0.2, 0.045, plane="xy", segs=8, fn=iron, name="collar")
    ring_tube((0.0, -0.7, 0.78), 0.08, 0.04, plane="xz", segs=6, fn=iron, name="link")
    ring_tube((0.0, -0.7, 0.62), 0.08, 0.04, plane="yz", segs=6, fn=iron, name="link")
    for (cx, cy, cz) in ((0.18, 0.1, 0.9), (-0.2, -0.2, 0.85), (0.22, 0.4, 0.8), (-0.2, 0.5, 0.78)):
        decal((cx, cy, cz), 0.12, BLOOD, 0.8, (0.5, 1.0, 1.4))
    decal((0, -1.2, 0.72), 0.1, BLOOD, 0.9)
    B.STREAK.update({"amount": 0.5})


MORE = {"wax_physician": wax_physician, "gravedigger": gravedigger, "rotten_executioner": rotten_executioner,
        "trench_crawler": trench_crawler, "plague_hound": plague_hound}
