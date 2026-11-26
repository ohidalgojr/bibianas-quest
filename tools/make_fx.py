"""Converte uma folha de FX sobre fundo escuro liso (#10131A) em PNG RGBA por chave de cor.

O alfa vem da distancia ao fundo (com rampa suave); a cor e mantida. Os quadros continuam alinhados
na grade original (hframes), prontos para `Sprite3D`.

Uso: python tools/make_fx.py <folha.jpg> <saida.png> [--thresh 28] [--scale 1.0]
"""
import argparse

import numpy as np
from PIL import Image


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--thresh", type=float, default=28.0)
    ap.add_argument("--scale", type=float, default=1.0)
    args = ap.parse_args()
    img = Image.open(args.src).convert("RGB")
    if args.scale != 1.0:
        img = img.resize((int(img.width * args.scale), int(img.height * args.scale)), Image.LANCZOS)
    rgb = np.asarray(img).astype(np.float32)
    bg = np.array([16.0, 19.0, 26.0], dtype=np.float32)
    dist = np.abs(rgb - bg).max(axis=2)
    alpha = np.clip((dist - 10.0) / args.thresh, 0.0, 1.0)
    out = np.zeros((img.height, img.width, 4), dtype=np.uint8)
    out[..., :3] = rgb.astype(np.uint8)
    out[..., 3] = (alpha * 255).astype(np.uint8)
    Image.fromarray(out, "RGBA").save(args.dst)
    print("fx", args.dst, img.size)


if __name__ == "__main__":
    main()
