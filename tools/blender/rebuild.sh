#!/bin/bash
# Gera o glb de um inimigo do lote 1, reimporta no Godot e captura o print real do jogo.
# Uso: bash tools/blender/rebuild.sh <id> [nivel]
cd "$(dirname "$0")/../.." || exit 1
ID="$1"
"/c/Program Files/Blender Foundation/Blender 5.3/blender.exe" -b -P tools/blender/kb2_enemies.py -- "$ID" 2>&1 | grep -E "MODELO|Error|Traceback|File \"|rror:"
"$GODOT_BIN" --headless --path . --import >/dev/null 2>&1
powershell -ExecutionPolicy Bypass -File tools/screenshot.ps1 -Scene res://game/presentation/combat3d/combat3d_preview.tscn -Out "docs/tasks/prints/TASK-062-$ID.png" -Extra "inimigo=$ID" 2>&1 | grep -E "salvo|rro"
python tools/blender/crop.py "docs/tasks/prints/TASK-062-$ID.png" "C:/Users/Orlando/AppData/Local/Temp/claude/28277ba82e664b6e/5d23219e-ba4e-4d2b-afeb-148c4ea126ad/scratchpad/crop.png"
