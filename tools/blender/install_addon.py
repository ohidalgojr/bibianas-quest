"""Instala e ativa o addon do Blender MCP.

Uso: blender -b --python install_addon.py -- caminho/blender_mcp_addon.py
"""
import shutil
import sys

import addon_utils
import bpy

src = sys.argv[sys.argv.index("--") + 1]
dest_dir = bpy.utils.user_resource("SCRIPTS", path="addons", create=True)
shutil.copy(src, dest_dir + "/blender_mcp_addon.py")
addon_utils.modules_refresh()
addon_utils.enable("blender_mcp_addon", default_set=True, persistent=True)
bpy.ops.wm.save_userpref()
print("ADDON_OK", dest_dir)
