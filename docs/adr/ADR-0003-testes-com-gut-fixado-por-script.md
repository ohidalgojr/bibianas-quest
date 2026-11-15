# ADR-0003: testes com GUT 9.7.1, instalado por script e rodado em headless

| Campo | Valor |
| --- | --- |
| Status | Aceito |
| Data | 2026-11-15 |
| Tarefa | TASK-001 |
| GDD | 20 (Escolhas: Testes), 21 (etapa 5) |

## Contexto

O GDD §20 pede "GUT ou GdUnit4, mais simulação headless", e a etapa 5 do pipeline exige suíte verde antes do commit. O pedido do arquiteto para esta tarefa foi GUT rodando em headless. Cada versão do GUT serve a uma série do Godot: a 9.7.1 é a da série 4.7.

## Decisão

- Framework de teste: **GUT 9.7.1**.
- O GUT **não é versionado**. `tools/setup.ps1` e `tools/setup.sh` baixam a tag `v9.7.1` do repositório oficial para `addons/gut/`, que está no `.gitignore`. A versão fica em `tools/versions.env`.
- **Um comando** roda tudo: `tools/run_tests.ps1` ou `tools/run_tests.sh`. O script instala o GUT se faltar, importa o projeto (`--headless --import`, necessário para registrar os `class_name`) e chama `addons/gut/gut_cmdln.gd` com `-gexit`. O código de saída é 0 com a suíte verde e 1 com falha.
- A configuração do GUT fica em `.gutconfig.json`: testes em `res://tests/`, com subpastas, arquivos `test_*.gd`.
- O plugin do GUT não é ativado em `project.godot`. Quem quiser o painel no editor ativa localmente.

## Alternativas

- **Versionar `addons/gut/`:** dispensa rede no primeiro uso e é o costume em projetos Godot. Não foi feito porque esta tarefa foi escrita em um ambiente sem acesso ao GitHub, e porque centenas de arquivos de terceiros poluem os diffs da revisão cruzada. Pode ser revisto: basta tirar a linha do `.gitignore` e fazer o commit da pasta.
- **GdUnit4:** também serve, e o GDD aceita os dois. GUT foi o pedido do arquiteto.
- **Runner próprio:** menos dependência, mas reinventa asserts, relatórios e dublês.

## Consequências

- A primeira execução em cada máquina precisa de internet.
- Atualizar o Godot exige conferir a tabela de versões do GUT e mudar `GUT_VERSION` junto.
- Testes de propriedade e de simulação (tarefas 3 e 5) rodam no mesmo comando; se ficarem lentos, ganham pasta própria e opção de filtro.
