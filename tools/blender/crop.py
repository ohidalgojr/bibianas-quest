# Recorta o palco de um print do jogo, aumenta 2x e clareia (so para inspecao). Uso: python crop.py in.png out.png
import sys
from PIL import Image, ImageEnhance
im = Image.open(sys.argv[1]).convert("RGB").crop((16, 80, 524, 545))
im = ImageEnhance.Brightness(im).enhance(1.6).resize((1016, 930), Image.NEAREST)
im.save(sys.argv[2])
