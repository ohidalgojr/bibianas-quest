"""Transforma uma prancha de conceito (figura sobre fundo escuro liso) em sprite 2D HD-2D.

Passos: recorta a região pedida, separa a figura do fundo (distância de cor ao fundo estimado
pelas bordas, fechamento morfológico, preenchimento de buracos, maior componente), reduz para a
altura do sprite com média de área, quantiza a paleta e põe um contorno escuro de 1 px.

Uso:
  python tools/make_sprite.py <prancha.jpg> <saida.png> --box x0,y0,x1,y1 [--height 224]
         [--colors 40] [--thresh 22] [--debug <mascara.png>]
"""
import argparse

import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage as ndi


def build_mask(rgb: np.ndarray, thresh: float, keep_all: bool = False) -> np.ndarray:
    h, w, _ = rgb.shape
    border = np.concatenate([
        rgb[:8].reshape(-1, 3), rgb[-8:].reshape(-1, 3),
        rgb[:, :8].reshape(-1, 3), rgb[:, -8:].reshape(-1, 3)])
    bg = np.median(border, axis=0)
    # Fundo com vinheta: estima o fundo por um desfoque muito forte das bordas preenchidas.
    dist = np.linalg.norm(rgb - bg, axis=2)
    lum = rgb.mean(axis=2)
    bg_lum = bg.mean()
    mask = (dist > thresh) | (lum > bg_lum + 12)
    mask = ndi.binary_opening(mask, iterations=1)
    mask = ndi.binary_closing(mask, structure=np.ones((3, 3)), iterations=6)
    mask = ndi.binary_fill_holes(mask)
    labels, count = ndi.label(mask)
    if count == 0 or keep_all:
        return mask
    sizes = ndi.sum(mask, labels, range(1, count + 1))
    keep = 1 + int(np.argmax(sizes))
    return labels == keep


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--box", required=True)
    ap.add_argument("--height", type=int, default=224)
    ap.add_argument("--colors", type=int, default=40)
    ap.add_argument("--thresh", type=float, default=22.0)
    ap.add_argument("--all", action="store_true", help="mantém todos os pedaços (portões, grades)")
    ap.add_argument("--debug", default="")
    args = ap.parse_args()
    x0, y0, x1, y1 = [int(v) for v in args.box.split(",")]
    img = Image.open(args.src).convert("RGB").crop((x0, y0, x1, y1))
    rgb = np.asarray(img).astype(np.float32)
    mask = build_mask(rgb, args.thresh, args.all)
    ys, xs = np.where(mask)
    bx0, bx1, by0, by1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
    pad = 3
    bx0, by0 = max(bx0 - pad, 0), max(by0 - pad, 0)
    bx1, by1 = min(bx1 + pad, mask.shape[1]), min(by1 + pad, mask.shape[0])
    img = img.crop((bx0, by0, bx1, by1))
    mask_img = Image.fromarray((mask[by0:by1, bx0:bx1] * 255).astype(np.uint8))
    if args.debug:
        mask_img.save(args.debug)
    scale = args.height / img.height
    size = (max(int(round(img.width * scale)), 1), args.height)
    small = img.resize(size, Image.BOX)
    small_mask = mask_img.resize(size, Image.BOX)
    alpha = np.asarray(small_mask) > 127
    # Paleta fechada: quantiza só os pixels da figura.
    quant = small.quantize(colors=args.colors, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGB")
    arr = np.asarray(quant).copy()
    # Contorno escuro de 1 px ao redor da silhueta.
    edge = ndi.binary_dilation(alpha, iterations=1) & ~alpha
    out = np.zeros((size[1], size[0], 4), dtype=np.uint8)
    out[..., :3] = arr
    out[..., 3] = np.where(alpha, 255, 0)
    out[edge] = (10, 11, 15, 255)
    Image.fromarray(out, "RGBA").save(args.dst)
    print("sprite", args.dst, size, "cores", args.colors)


if __name__ == "__main__":
    main()
