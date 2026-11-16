# ADR-0017: save da Descida e da meta

| Campo | Valor |
| --- | --- |
| Status | Aceito (decisão técnica dentro da tarefa) |
| Data | 2026-11-16 |
| Tarefa | TASK-012 |
| GDD | 20 |

## Decisão

1. **Foto do estado, não repetição de escolhas.** O combate não registra as ações do jogador, então reproduzir escolhas não serve. Salva-se o estado inteiro: mapa, nó atual, Poder, ouro, HP, MP, itens, equipamento, buffs, Brasas, moeda e o `snapshot()` dos quatro fluxos de RNG (texto, ADR-0006). O mapa vai pronto para não refazer a checagem de 200 simulações.
2. **Só no mapa.** Grava-se em cada passagem pela fase de escolha de nó. Fechar durante luta, loja ou fogueira volta ao último nó salvo; a luta sai igual, porque os fluxos voltam ao mesmo ponto.
3. **Núcleo sem I/O.** `RunSave` (núcleo) converte de e para dicionário; `SaveStore` (serviços) lê e grava JSON em `user://` por arquivo temporário e renomeação.
4. **Versão.** O save da Descida guarda `format` e `rules_version`; se a versão das regras mudou, é recusado (ADR de `RULES_VERSION`). O meta tem versão própria e segue válido enquanto o formato dele não mudar.
5. **Fim apaga a Descida salva** e grava o meta (Ecos, Descidas).

## Consequências

- Quem mudar uma regra e subir `RULES_VERSION` invalida os saves antigos de propósito.
- Trapaça e eventos em andamento (futuros) precisarão entrar no `RunSave`.
