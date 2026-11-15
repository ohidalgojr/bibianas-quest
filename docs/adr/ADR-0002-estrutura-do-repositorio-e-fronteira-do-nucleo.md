# ADR-0002: projeto Godot na raiz do repositório e núcleo sem nós

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-15 |
| Tarefa | TASK-001 |
| GDD | 20 (Camadas; Estrutura do repositório) |

## Contexto

O GDD §20 lista as pastas `docs/`, `game/` (com `core/`, `data/`, `presentation/`, `services/`), `tools/`, `assets_src/` e `tests/` na raiz, e exige que o núcleo rode sem nós do Godot. O Godot só enxerga arquivos dentro da pasta que contém `project.godot`. Se o projeto ficasse em `game/`, os testes em `tests/` e o simulador em `tools/` não conseguiriam carregar o núcleo.

## Decisão

- `project.godot` fica na **raiz do repositório**. Os caminhos são `res://game/core`, `res://tests`, `res://tools`.
- `docs/` e `assets_src/` têm um arquivo `.gdignore`, então o Godot não os importa nem os exporta.
- **Fronteira do núcleo:** scripts em `game/core/` estendem `RefCounted` ou `Resource`, nunca uma classe derivada de `Node`, e não usam árvore de cena, `Time`, `OS` nem aleatoriedade global. A dependência só vai de `presentation` e `services` para `core`.
- A fronteira é verificada por `tests/unit/test_core_purity.gd`, que lê os scripts do núcleo e falha com arquivo e linha.
- `CoreVersion.RULES_VERSION` identifica a versão das regras implementadas e sobe quando uma regra já implementada muda.
- **Idioma:** identificadores em inglês, com o glossário de `CLAUDE.md`; comentários e documentos em português. `FOR` e `MEN` do GDD não podem ser nomes em GDScript (`for` é palavra reservada), então os atributos usam nomes por extenso.
- **Vault do Obsidian:** a pasta do vault é a raiz do repositório. O estado local do Obsidian (`.obsidian/`) fica fora do Git.

## Alternativas

- **`project.godot` em `game/`, com `game/tests/`:** mantém a raiz limpa, mas contraria a lista de pastas do GDD e esconde o simulador dentro do jogo.
- **Vault só em `docs/`:** combina com a frase do GDD ("docs: vault do Obsidian"), mas o vault já existia como a pasta `bibianas-quest`. Reabrir `docs/` como vault continua possível a qualquer momento.
- **Fronteira só por convenção:** agentes erram convenções; um teste que cita arquivo e linha corrige na hora.

## Consequências

- Os presets de exportação (tarefa futura) precisam excluir `tests/`, `tools/` e `addons/gut/` do pacote do jogo.
- O teste de pureza é por texto. Ele barra os erros comuns, mas não prova pureza; a revisão cruzada continua valendo.
- Código do núcleo que precise de hora ou de caminho de arquivo recebe esses valores de `services`.
- Com o vault na raiz, o Obsidian também indexa `README.md`, `CLAUDE.md` e os `.md` do GUT em `addons/`. Em Configurações, Arquivos e links, Arquivos excluídos, vale listar `addons/`, `game/`, `tests/` e `tools/`. É uma configuração local do Obsidian e fica fora do Git.
