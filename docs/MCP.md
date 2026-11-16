# MCP do Godot e do Blender (Claude Code)

Configurados em `.mcp.json` na raiz (escopo de projeto). Na primeira vez, o Claude Code pergunta se confia nos servidores: aprove.

| Servidor | Pacote (versão fixada) | Para que serve | Requisitos |
| --- | --- | --- | --- |
| `godot` | `@coding-solo/godot-mcp@0.1.1` (npx) | Abrir o editor, rodar o projeto e ler a saída de depuração, criar cenas, ver a versão. **Não roda a suíte GUT**: para isso use `tools\run_tests.ps1` ou o observador (ADR-0005) | Node.js; variável `GODOT_BIN` (já definida na máquina do Orlando, aponta para `C:\Program Files\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`) |
| `blender` | `blender-mcp==2.0.0` (uvx) | Controlar o Blender aberto: cena, objetos, materiais, scripts. Usado na etapa 3 do pipeline de assets (GDD §18): mecha da Bibiana, paleta, escala, limpeza | `uv` e Blender 5.3 com o addon ligado |

## Ligar o addon do Blender (uma vez)

O servidor `blender` fala com um addon que roda **dentro** do Blender, escutando só em `localhost:9876`.

1. O arquivo do addon está em `tools/blender/blender_mcp_addon.py` (cópia do repositório ahujasid/blender-mcp, versão 2.0, baixada em 2026-11-16).
2. No Blender: Edit, Preferences, Add-ons, seta no canto superior direito, **Install from Disk**, escolha esse arquivo e marque o addon.
3. Na vista 3D, aperte `N`, aba **BlenderMCP**, **Connect to MCP server**.
4. Mantenha o Blender aberto enquanto o Claude trabalha. A API de código do addon executa Python arbitrário dentro do Blender: salve o `.blend` antes de pedir operações grandes.

Alternativa por linha de comando (instala e ativa sem abrir a janela): `blender.exe -b --python tools\blender\install_addon.py -- <caminho absoluto de blender_mcp_addon.py>`.

## Conferir

- `claude mcp list` deve mostrar `godot` e `blender` conectados.
- Godot: pedir "qual a versão do Godot" ao Claude; deve responder 4.7.2.
- Blender: com o addon conectado, pedir "liste os objetos da cena".

## Cuidados

- O addon traz integrações opcionais (Poly Haven, Sketchfab, Hyper3D, Meshy, Tripo). Deixe desligadas; qualquer ativo baixado precisa entrar em `assets/LICENSES.md` (GDD §18).
- Arte-fonte vai em `assets_src/`; só exporte `.glb` para `game/` depois de conferir o orçamento de triângulos (GDD §18).
