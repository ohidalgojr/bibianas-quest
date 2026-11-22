#!/bin/bash
# Gera o glb e uma previa rapida do Blender (so depuracao de forma). Uso: bash tools/blender/pv.sh <id>
cd "$(dirname "$0")/../.." || exit 1
S="C:/Users/Orlando/AppData/Local/Temp/claude/28277ba82e664b6e/5d23219e-ba4e-4d2b-afeb-148c4ea126ad/scratchpad"
"/c/Program Files/Blender Foundation/Blender 5.3/blender.exe" -b -P tools/blender/kitbash_batch1.py -- "$1" 2>&1 | grep -E "MODELO|Error|Traceback|File \"|rror:"
"/c/Program Files/Blender Foundation/Blender 5.3/blender.exe" -b -P tools/blender/kb_preview.py -- "assets/bibiana/enemies/$1.glb" "$S/$1" 2>&1 | grep -E "Error"
