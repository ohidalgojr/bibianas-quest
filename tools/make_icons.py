"""Fatia as 7 folhas de ícones 4x4 (1024x1024, células de 256, fundo #10131A) em PNGs 96x96 RGBA.

Cada célula vira `assets/bibiana/icons/<categoria>/<id>.png`: alfa por chave de cor (distância ao fundo,
com o limiar de cada folha), recorte ao conteúdo, quadrado com respiro e redução Lanczos.

Uso: python tools/make_icons.py
"""
import os

import numpy as np
from PIL import Image

SRC = "docs/design/refs/ui/"
DST = "assets/bibiana/icons/"
SIZE = 96
BG = np.array([16.0, 19.0, 26.0], dtype=np.float32)

# folha -> (limiar, ids por linha; "" = célula vazia)
SHEETS = {
    "ico-a-actions": (10.0, [
        ["action/attack", "action/defend", "action/skills", "action/items"],
        ["action/tactical", "action/flee", "action/speed_1x", "action/speed_2x"],
        ["ui/gold", "ui/embers", "ui/firewood", "ui/luck"],
        ["ui/echoes", "ui/power", "ui/hp", "ui/mp"]]),
    "ico-b-skills-intent": (10.0, [
        ["skill/shield_bash", "skill/charge", "skill/bulwark", "skill/whirlwind"],
        ["skill/war_cry", "skill/second_wind", "skill/sharpen_blade", "skill/reinforce_shield"],
        ["skill/sharpen_edge", "intent/attack", "intent/heavy", "intent/debuff"],
        ["intent/defend", "intent/coin", "intent/deadly", "intent/unknown"]]),
    "ico-c-status": (10.0, [
        ["status/defending", "status/bulwark", "status/armor_down", "status/slowed"],
        ["status/poison", "status/weakened", "status/empowered", "status/blinded"],
        ["status/cursed", "status/silenced", "status/disease", "status/bleeding"],
        ["", "", "", ""]]),
    "ico-d-weapons-slots": (7.5, [
        ["item/sword_and_shield", "item/worn_longsword", "item/bone_dagger", "item/rusty_axe"],
        ["item/spiked_mace", "item/reaper_sickle", "item/bellringer_blade", "item/executioner_axe"],
        ["item/blood_stiletto", "slot/weapon", "slot/armor", "slot/head"],
        ["slot/offhand", "slot/relic", "slot/consumable", ""]]),
    "ico-e-armor-head": (9.5, [
        ["item/old_chainmail", "item/dented_plate", "item/leather_vest", "item/reinforced_mail"],
        ["item/warden_plate", "item/soaked_cloak", "item/bone_cuirass", "item/penitent_armor"],
        ["item/plague_hood", "item/bellringer_helm", "item/thorn_crown", "item/rotten_shield"],
        ["item/traveler_lantern", "item/torn_prayer_book", "", ""]]),
    "ico-f-relics-consum": (9.5, [
        ["item/worn_charm", "item/iron_ring", "item/sharp_claw", "item/grave_bell"],
        ["item/giant_rat_tooth", "item/glass_eye", "item/hanged_rope", "item/penitent_medal"],
        ["item/murky_potion", "item/dirty_ether", "item/lucky_coin", "item/firewood"],
        ["item/rotting_bread", "item/rancid_elixir", "item/sage_smoke", ""]]),
    "ico-g-nodes": (9.5, [
        ["node/start", "node/battle", "node/ambush", "node/elite"],
        ["node/chest", "node/event", "node/bonfire", "node/shop"],
        ["node/mini_boss", "node/boss", "node/fog", "node/visited"],
        ["node/lock", "node/danger", "", ""]]),
}


def slice_cell(cell: Image.Image, thresh: float) -> Image.Image | None:
    rgb = np.asarray(cell.convert("RGB")).astype(np.float32)
    dist = np.abs(rgb - BG).max(axis=2)
    alpha = np.clip((dist - 6.0) / max(thresh, 1.0), 0.0, 1.0)
    ys, xs = np.where(alpha > 0.5)
    if len(xs) < 40:
        return None
    x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
    out = np.zeros((rgb.shape[0], rgb.shape[1], 4), dtype=np.uint8)
    out[..., :3] = rgb.astype(np.uint8)
    out[..., 3] = (alpha * 255).astype(np.uint8)
    crop = Image.fromarray(out, "RGBA").crop((x0, y0, x1, y1))
    side = int(max(crop.width, crop.height) * 1.14)
    square = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    square.paste(crop, ((side - crop.width) // 2, (side - crop.height) // 2))
    return square.resize((SIZE, SIZE), Image.LANCZOS)


def main() -> None:
    total = 0
    for sheet, (thresh, rows) in SHEETS.items():
        image = Image.open(SRC + sheet + ".jpg").convert("RGB")
        cell_w = image.width // 4
        cell_h = image.height // 4
        for r, row in enumerate(rows):
            for c, icon_id in enumerate(row):
                if not icon_id:
                    continue
                cell = image.crop((c * cell_w, r * cell_h, (c + 1) * cell_w, (r + 1) * cell_h))
                icon = slice_cell(cell, thresh)
                if icon is None:
                    print("vazio:", sheet, r, c, icon_id)
                    continue
                path = DST + icon_id + ".png"
                os.makedirs(os.path.dirname(path), exist_ok=True)
                icon.save(path)
                total += 1
    print("icones", total)


if __name__ == "__main__":
    main()
