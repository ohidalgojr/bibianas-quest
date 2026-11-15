# ADR-0001: Godot 4.7, GDScript tipado, Compatibility e retrato 540×960

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-15 |
| Tarefa | TASK-001 |
| GDD | 20 (Escolhas; Testar no PC), 25 (pergunta 1) |

## Contexto

O GDD §20 escolhe Godot 4.x, GDScript tipado, renderizador Compatibility e teste diário no desktop com a janela em retrato e o mouse como toque. Faltava fixar a versão do motor e os valores exatos de configuração.

## Decisão

- **Motor:** Godot 4.7.x, a série estável na data. A versão fica em `tools/versions.env`; os scripts de teste avisam quando o Godot em uso é de outra série.
- **Linguagem:** GDScript com tipagem estática obrigatória. O aviso `untyped_declaration` é tratado como erro em `project.godot`. O Godot não aplica essa regra a `addons/`.
- **Renderizador:** `gl_compatibility` no desktop e no celular.
- **Tela:** base de 540×960, orientação retrato, estiramento `canvas_items` com aspecto `keep_width`.
- **Entrada:** `emulate_touch_from_mouse` ligado para desenvolver no PC. Deve ser desligado antes de exportar para o celular (GDD §20).

`keep_width` mantém a proporção sem distorcer e sem barras: a largura lógica fica fixa em 540 e a altura cresce em telas mais altas que 9:16, que é o caso da maioria dos celulares atuais. A interface deve se ancorar no topo e na base, não assumir altura de 960.

## Alternativas

- **Godot 4.6.x:** mais tempo de estrada, mas começar um projeto novo uma série atrás só adia a migração.
- **Aspecto `keep`:** proporção fixa com barras pretas em telas altas. Desperdiça a área do polegar.
- **Aspecto `expand`:** também cresce na largura; em retrato o que varia entre aparelhos é a altura.
- **Renderizador Mobile (Vulkan):** o GDD pede para avaliar depois, medindo em aparelho real.
- **Tipagem apenas como aviso:** agentes ignoram avisos; erro de compilação não dá para ignorar.

## Consequências

- Todo script do jogo e dos testes precisa de tipos, inclusive variáveis de laço.
- Atualizar o motor é mudar `tools/versions.env` e a linha `config/features` de `project.godot`, junto com a versão do GUT (ADR-0003).
- O teste `tests/unit/test_project_settings.gd` trava esses valores; mudar qualquer um exige atualizar este ADR.
