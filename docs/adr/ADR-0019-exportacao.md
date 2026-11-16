# ADR-0019: presets de exportação

| Campo | Valor |
| --- | --- |
| Status | Aceito (decisão técnica; presets ainda não exercitados) |
| Data | 2026-11-16 |
| Tarefa | TASK-014 |
| GDD | 20 |

## Decisão

1. **`export_presets.cfg` vai para o Git**, sem segredos: o Android usa a debug keystore configurada no editor de cada pessoa, e nenhuma senha entra no arquivo.
2. **Dados:** `include_filter="game/data/*.json"` nos dois presets, porque o Godot não exporta `.json` por padrão. Docs, testes, GUT, relatórios e ferramentas ficam de fora.
3. **Web sem threads** (`thread_support=false`): roda em qualquer hospedagem estática, sem cabeçalhos de isolamento. A criação da Descida usa `Thread`; na Web sem threads, o Godot executa a chamada na hora, então a tela de espera pode congelar por cerca de 1,5 s. Se incomodar no teste, mover a checagem para o Android apenas ou fatiá-la por frames.
4. **Toque:** `emulate_touch_from_mouse` fica ligado no desktop e desligado em `mobile` e `web` por override de plataforma no `project.godot`.
5. **Android:** arm64 apenas, sem Gradle, pacote `com.orlando.bibianasquest`.

## Consequências

- O primeiro build real pode revelar ajustes nos presets; registrar em `docs/FEEDBACK.md`.
- Atalhos de depuração somem em exportação release (ADR-0018).
