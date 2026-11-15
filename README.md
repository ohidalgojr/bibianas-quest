# Bibiana's Quest

RPG tático de turnos em dark fantasy para celular: mapa em grafo com três caminhos por vez, combate 1 contra 1 e cara ou coroa nos momentos de risco. Feito em Godot 4.7 com GDScript tipado.

- Design: [docs/GDD.md](docs/GDD.md)
- Estado atual e próximos passos: [docs/HANDOFF.md](docs/HANDOFF.md)
- Regras para agentes de IA: [CLAUDE.md](CLAUDE.md)
- Decisões de arquitetura: [docs/adr/](docs/adr/)

## Preparar e testar

Requisitos: Godot 4.7.x. No Windows, aponte a variável `GODOT_BIN` para o executável `*_console.exe`, ou deixe `godot` no PATH.

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File tools\run_tests.ps1
```

```bash
# Linux, macOS
bash tools/run_tests.sh
```

Para rodar a suíte sozinha a cada mudança nos arquivos, deixe `tools\watch_tests.ps1` aberto numa janela do PowerShell (ADR-0005); o resultado fica em `reports\last_run.txt`.

Na primeira execução o script baixa o GUT 9.7.1 para `addons/gut/`, importa o projeto e roda a suíte em modo headless. Código de saída 0 significa suíte verde.

## Jogar no PC

Abra `project.godot` no editor do Godot e aperte F5. A janela abre em retrato (540×960) e o mouse funciona como toque.
